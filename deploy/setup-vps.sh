#!/usr/bin/env bash
# =============================================================================
# AIOX Squads — VPS Setup (Ubuntu 22.04 LTS)
# Hostinger KVM2: 2 vCPU / 8 GB RAM
#
# Execute como root na VPS recém-instalada:
#   bash <(curl -fsSL https://raw.githubusercontent.com/SEU_REPO/main/deploy/setup-vps.sh)
# ou após clonar:
#   bash deploy/setup-vps.sh
# =============================================================================
set -euo pipefail

# ── Variáveis — EDITE ANTES DE EXECUTAR ──────────────────────────────────────
APP_USER="aiox"                         # Usuário não-root que vai rodar a aplicação
DEPLOY_DIR="/opt/aiox"                  # Diretório de instalação
DOMAIN=""                               # ex: aiox.seuescritorio.com.br (deixe vazio para usar IP)
REPO_URL=""                             # ex: https://github.com/SEU_USER/aiox-squads.git
# ─────────────────────────────────────────────────────────────────────────────

# Cores
G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; B='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${G}✓${NC} $*"; }
info() { echo -e "${B}→${NC} $*"; }
warn() { echo -e "${Y}⚠${NC}  $*"; }
err()  { echo -e "${R}✗${NC} $*"; exit 1; }
step() { echo -e "\n${B}━━━ $* ━━━${NC}"; }

# ── Verificar root ────────────────────────────────────────────────────────────
[[ $EUID -ne 0 ]] && err "Execute como root: sudo bash $0"

# ── Verificar preenchimento ───────────────────────────────────────────────────
[[ -z "$REPO_URL" ]] && err "Preencha REPO_URL no início do script antes de executar."

echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║   AIOX Squads — Configuração da VPS              ║"
echo "  ║   Ubuntu 22.04 LTS · Hostinger KVM2              ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

# ── 1. Atualizar sistema ──────────────────────────────────────────────────────
step "1. Atualizando o sistema"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get upgrade -y -qq
apt-get install -y -qq \
  curl wget git unzip jq htop \
  ufw fail2ban \
  ca-certificates gnupg lsb-release
ok "Sistema atualizado"

# ── 2. Criar usuário da aplicação ─────────────────────────────────────────────
step "2. Criando usuário '$APP_USER'"
if ! id "$APP_USER" &>/dev/null; then
  useradd -m -s /bin/bash -G sudo "$APP_USER"
  # Gerar senha aleatória e exibir UMA VEZ
  PASS=$(openssl rand -base64 16)
  echo "$APP_USER:$PASS" | chpasswd
  warn "Senha criada para '$APP_USER': ${Y}${PASS}${NC}"
  warn "Salve esta senha — ela não será exibida novamente!"
else
  ok "Usuário '$APP_USER' já existe"
fi

# Copiar chave SSH do root para o novo usuário (se existir)
if [[ -f /root/.ssh/authorized_keys ]]; then
  mkdir -p /home/$APP_USER/.ssh
  cp /root/.ssh/authorized_keys /home/$APP_USER/.ssh/
  chown -R $APP_USER:$APP_USER /home/$APP_USER/.ssh
  chmod 700 /home/$APP_USER/.ssh
  chmod 600 /home/$APP_USER/.ssh/authorized_keys
  ok "Chave SSH copiada para '$APP_USER'"
fi

# ── 3. Hardening SSH ──────────────────────────────────────────────────────────
step "3. Configurando SSH seguro"
SSHD="/etc/ssh/sshd_config"
cp $SSHD ${SSHD}.bak

# Desabilitar login root por senha (manter por chave se necessário)
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' $SSHD
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' $SSHD
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' $SSHD
sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' $SSHD

systemctl restart sshd
ok "SSH configurado (root por senha: desabilitado)"

# ── 4. Firewall UFW ───────────────────────────────────────────────────────────
step "4. Configurando firewall UFW"
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp    comment "SSH"
ufw allow 80/tcp    comment "HTTP (redirect para HTTPS)"
ufw allow 443/tcp   comment "HTTPS"
ufw --force enable
ok "UFW ativo: SSH(22), HTTP(80), HTTPS(443)"

# ── 5. Fail2ban ───────────────────────────────────────────────────────────────
step "5. Configurando Fail2ban"
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime  = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port    = 22
filter  = sshd
logpath = /var/log/auth.log
EOF

systemctl enable fail2ban
systemctl restart fail2ban
ok "Fail2ban ativo (ban: 1h após 5 tentativas)"

# ── 6. Instalar Docker ────────────────────────────────────────────────────────
step "6. Instalando Docker + Docker Compose v2"
if command -v docker &>/dev/null; then
  ok "Docker já instalado: $(docker --version | cut -d' ' -f3 | tr -d ',')"
else
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -qq
  apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable docker
  systemctl start docker
  ok "Docker $(docker --version | cut -d' ' -f3 | tr -d ',') instalado"
fi

# Adicionar usuário ao grupo docker
usermod -aG docker $APP_USER
ok "Usuário '$APP_USER' adicionado ao grupo docker"

# ── 7. Instalar Nginx + Certbot ───────────────────────────────────────────────
step "7. Instalando Nginx + Certbot (Let's Encrypt)"
apt-get install -y -qq nginx
apt-get install -y -qq certbot python3-certbot-nginx
systemctl enable nginx
ok "Nginx instalado: $(nginx -v 2>&1 | cut -d'/' -f2)"

# ── 8. Clonar repositório ─────────────────────────────────────────────────────
step "8. Clonando repositório"
mkdir -p "$DEPLOY_DIR"
chown $APP_USER:$APP_USER "$DEPLOY_DIR"

if [[ -d "$DEPLOY_DIR/.git" ]]; then
  info "Repositório já existe, fazendo pull..."
  sudo -u $APP_USER git -C "$DEPLOY_DIR" pull
else
  sudo -u $APP_USER git clone "$REPO_URL" "$DEPLOY_DIR"
fi
ok "Repositório em $DEPLOY_DIR"

# ── 9. Configurar .env de produção ────────────────────────────────────────────
step "9. Configurando variáveis de ambiente"
ENV_FILE="$DEPLOY_DIR/deploy/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  cp "$DEPLOY_DIR/deploy/.env.example" "$ENV_FILE"

  # Gerar senhas seguras automaticamente
  POSTGRES_PASS=$(openssl rand -hex 20)
  REDIS_PASS=$(openssl rand -hex 16)
  SESSION_SECRET=$(openssl rand -hex 32)

  sed -i "s/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$POSTGRES_PASS/" "$ENV_FILE"
  sed -i "s/REDIS_PASSWORD=.*/REDIS_PASSWORD=$REDIS_PASS/" "$ENV_FILE"
  sed -i "s/SESSION_SECRET=.*/SESSION_SECRET=$SESSION_SECRET/" "$ENV_FILE"
  [[ -n "$DOMAIN" ]] && sed -i "s/APP_DOMAIN=.*/APP_DOMAIN=$DOMAIN/" "$ENV_FILE"

  chown $APP_USER:$APP_USER "$ENV_FILE"
  chmod 600 "$ENV_FILE"
  warn "Edite $ENV_FILE e adicione sua ANTHROPIC_API_KEY antes de iniciar!"
else
  ok ".env já existe, mantendo configurações"
fi

# ── 10. Configurar Nginx ──────────────────────────────────────────────────────
step "10. Configurando Nginx"
if [[ -n "$DOMAIN" ]]; then
  cp "$DEPLOY_DIR/deploy/nginx/aiox.conf" /etc/nginx/sites-available/aiox
  sed -i "s/YOUR_DOMAIN/$DOMAIN/g" /etc/nginx/sites-available/aiox
  ln -sf /etc/nginx/sites-available/aiox /etc/nginx/sites-enabled/aiox
  rm -f /etc/nginx/sites-enabled/default
  nginx -t && systemctl reload nginx
  ok "Nginx configurado para $DOMAIN"

  info "Obtendo certificado SSL (Let's Encrypt)..."
  certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "admin@$DOMAIN" || \
    warn "Certbot falhou — certifique-se que o DNS $DOMAIN aponta para este servidor antes de rodar: certbot --nginx -d $DOMAIN"
else
  # Configuração simples sem domínio (apenas HTTP na porta 3000)
  warn "Nenhum domínio configurado — app acessível em http://$(curl -s ifconfig.me):3000"
fi

# ── 11. Build e start inicial ─────────────────────────────────────────────────
step "11. Iniciando serviços com Docker Compose"
cd "$DEPLOY_DIR"
sudo -u $APP_USER docker compose -f deploy/docker-compose.prod.yml --env-file deploy/.env pull
sudo -u $APP_USER docker compose -f deploy/docker-compose.prod.yml --env-file deploy/.env up -d --build
ok "Serviços iniciados"

# ── 12. Configurar auto-start ─────────────────────────────────────────────────
step "12. Configurando auto-start (systemd)"
cat > /etc/systemd/system/aiox.service << EOF
[Unit]
Description=AIOX Squads
After=docker.service network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$DEPLOY_DIR
ExecStart=docker compose -f deploy/docker-compose.prod.yml --env-file deploy/.env up -d
ExecStop=docker compose -f deploy/docker-compose.prod.yml --env-file deploy/.env down
User=$APP_USER
TimeoutStartSec=120

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable aiox
ok "Auto-start configurado (aiox.service)"

# ── Resumo final ──────────────────────────────────────────────────────────────
SERVER_IP=$(curl -s ifconfig.me)
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║   ✅  Configuração concluída!                    ║"
echo "  ╠══════════════════════════════════════════════════╣"
if [[ -n "$DOMAIN" ]]; then
echo "  ║  URL:     https://$DOMAIN"
else
echo "  ║  URL:     http://$SERVER_IP:3000"
fi
echo "  ║  Dir:     $DEPLOY_DIR"
echo "  ║  Usuário: $APP_USER"
echo "  ║"
echo "  ║  Próximos passos:"
echo "  ║  1. Edite $DEPLOY_DIR/deploy/.env"
echo "  ║     → Adicione sua ANTHROPIC_API_KEY"
echo "  ║  2. Reinicie: systemctl restart aiox"
echo "  ║  3. Logs:     docker compose -f deploy/docker-compose.prod.yml logs -f"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
