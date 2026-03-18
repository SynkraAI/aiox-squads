#!/usr/bin/env bash
# =============================================================================
# AIOX Squads — VPS Setup (Ubuntu 22.04 LTS)
# Hostinger KVM2: 2 vCPU / 8 GB RAM
#
# USO (one-liner — copie e cole no terminal da VPS):
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/SEU_ORG/SEU_REPO/main/deploy/setup-vps.sh)
#
# Ou com parâmetros diretos (sem interação):
#
#   bash setup-vps.sh \
#     --domain aiox.seuescritorio.com.br \
#     --repo   https://github.com/SEU_ORG/aiox-squads.git \
#     --email  seuemail@dominio.com \
#     --user   aiox
# =============================================================================
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# ── Cores ─────────────────────────────────────────────────────────────────────
G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; B='\033[0;34m'; C='\033[0;36m'; NC='\033[0m'
ok()     { echo -e "${G}  ✓${NC}  $*"; }
info()   { echo -e "${B}  →${NC}  $*"; }
warn()   { echo -e "${Y}  ⚠${NC}  $*"; }
err()    { echo -e "${R}  ✗${NC}  $*"; exit 1; }
step()   { echo -e "\n${C}━━━ $* ━━━${NC}"; }
ask()    { echo -e "${Y}  ?${NC}  $*"; }
banner() {
  echo ""
  echo -e "  ${C}╔══════════════════════════════════════════════════╗${NC}"
  echo -e "  ${C}║${NC}  $*"
  echo -e "  ${C}╚══════════════════════════════════════════════════╝${NC}"
  echo ""
}

# ── Verificar root ────────────────────────────────────────────────────────────
[[ $EUID -ne 0 ]] && err "Execute como root: sudo bash $0 $*"

# ── Parse de argumentos ───────────────────────────────────────────────────────
DOMAIN=""
REPO_URL=""
ADMIN_EMAIL=""
APP_USER="aiox"
DEPLOY_DIR="/opt/aiox"
ANTHROPIC_KEY=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --domain)  DOMAIN="$2";       shift 2 ;;
    --repo)    REPO_URL="$2";     shift 2 ;;
    --email)   ADMIN_EMAIL="$2";  shift 2 ;;
    --user)    APP_USER="$2";     shift 2 ;;
    --key)     ANTHROPIC_KEY="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# ── Banner de boas-vindas ─────────────────────────────────────────────────────
clear
echo ""
echo -e "${C}"
echo "   █████╗ ██╗ ██████╗ ██╗  ██╗"
echo "  ██╔══██╗██║██╔═══██╗╚██╗██╔╝"
echo "  ███████║██║██║   ██║ ╚███╔╝ "
echo "  ██╔══██║██║██║   ██║ ██╔██╗ "
echo "  ██║  ██║██║╚██████╔╝██╔╝ ██╗"
echo "  ╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "  ${B}Squads — Assistente Jurídico com IA${NC}"
echo -e "  Hostinger KVM2 · Ubuntu 22.04 LTS"
echo ""

# ── Coletar informações interativamente se não foram passadas por argumento ───
collect_info() {
  echo -e "${C}━━━ Configuração inicial (responda às perguntas abaixo) ━━━${NC}"
  echo ""

  # Domínio
  if [[ -z "$DOMAIN" ]]; then
    ask "Qual é o domínio que vai usar? (ex: aiox.seuescritorio.com.br)"
    echo -n "  Domínio: "
    read -r DOMAIN
    [[ -z "$DOMAIN" ]] && err "Domínio não pode ficar vazio."
  fi

  # URL do repositório
  if [[ -z "$REPO_URL" ]]; then
    ask "URL do repositório Git (HTTPS):"
    ask "  ex: https://github.com/SEU_ORG/aiox-squads.git"
    echo -n "  Repositório: "
    read -r REPO_URL
    [[ -z "$REPO_URL" ]] && err "URL do repositório não pode ficar vazio."
  fi

  # E-mail para SSL
  if [[ -z "$ADMIN_EMAIL" ]]; then
    ask "Seu e-mail (usado para o certificado SSL / Let's Encrypt):"
    echo -n "  E-mail: "
    read -r ADMIN_EMAIL
    [[ -z "$ADMIN_EMAIL" ]] && err "E-mail não pode ficar vazio."
  fi

  # Anthropic API Key
  if [[ -z "$ANTHROPIC_KEY" ]]; then
    ask "Sua ANTHROPIC_API_KEY (começa com sk-ant-):"
    ask "  Deixe em branco para configurar depois manualmente."
    echo -n "  API Key: "
    read -rs ANTHROPIC_KEY
    echo ""
  fi

  echo ""
  echo -e "${Y}  Confirme as configurações abaixo:${NC}"
  echo -e "  Domínio:      ${C}$DOMAIN${NC}"
  echo -e "  Repositório:  ${C}$REPO_URL${NC}"
  echo -e "  E-mail SSL:   ${C}$ADMIN_EMAIL${NC}"
  echo -e "  Usuário app:  ${C}$APP_USER${NC}"
  echo -e "  Diretório:    ${C}$DEPLOY_DIR${NC}"
  echo -e "  API Key:      ${C}$([ -n "$ANTHROPIC_KEY" ] && echo "✓ fornecida" || echo "⚠ não fornecida — configurar depois")${NC}"
  echo ""
  ask "Continuar? (s/N)"
  echo -n "  → "
  read -r CONFIRM
  [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]] && echo "Abortado." && exit 0
}

collect_info

# ── FASE 1: Sistema ───────────────────────────────────────────────────────────
banner "FASE 1 de 8 — Atualizando o sistema"

info "Atualizando pacotes (pode demorar 2-3 min na primeira vez)..."
apt-get update -qq
apt-get upgrade -y -qq 2>&1 | tail -3
apt-get install -y -qq \
  curl wget git unzip jq htop ncdu \
  ufw fail2ban \
  ca-certificates gnupg lsb-release \
  software-properties-common 2>&1 | tail -3
ok "Sistema atualizado"

# ── FASE 2: Usuário seguro ────────────────────────────────────────────────────
banner "FASE 2 de 8 — Criando usuário '$APP_USER'"

if ! id "$APP_USER" &>/dev/null; then
  useradd -m -s /bin/bash -G sudo "$APP_USER"
  APP_PASS=$(openssl rand -base64 20)
  echo "$APP_USER:$APP_PASS" | chpasswd
  echo ""
  echo -e "  ${Y}┌─────────────────────────────────────────────┐${NC}"
  echo -e "  ${Y}│  SALVE ESTAS CREDENCIAIS AGORA!             │${NC}"
  echo -e "  ${Y}│                                             │${NC}"
  echo -e "  ${Y}│  Usuário: ${NC}$APP_USER"
  echo -e "  ${Y}│  Senha:   ${NC}$APP_PASS"
  echo -e "  ${Y}│                                             │${NC}"
  echo -e "  ${Y}│  Esta mensagem não aparecerá novamente.     │${NC}"
  echo -e "  ${Y}└─────────────────────────────────────────────┘${NC}"
  echo ""
  read -rp "  Pressione ENTER após anotar a senha..."
else
  ok "Usuário '$APP_USER' já existe"
fi

# Copiar chave SSH do root
if [[ -f /root/.ssh/authorized_keys ]]; then
  mkdir -p /home/$APP_USER/.ssh
  cp /root/.ssh/authorized_keys /home/$APP_USER/.ssh/
  chown -R $APP_USER:$APP_USER /home/$APP_USER/.ssh
  chmod 700 /home/$APP_USER/.ssh
  chmod 600 /home/$APP_USER/.ssh/authorized_keys
  ok "Chave SSH copiada para '$APP_USER'"
fi

# ── FASE 3: Segurança ─────────────────────────────────────────────────────────
banner "FASE 3 de 8 — Configurando segurança (SSH, UFW, Fail2ban)"

# SSH hardening
SSHD="/etc/ssh/sshd_config"
cp $SSHD ${SSHD}.bak.$(date +%Y%m%d)
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' $SSHD
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' $SSHD
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' $SSHD
sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' $SSHD
sed -i 's/^#*ClientAliveInterval.*/ClientAliveInterval 300/' $SSHD
sed -i 's/^#*ClientAliveCountMax.*/ClientAliveCountMax 2/' $SSHD
systemctl restart sshd
ok "SSH: login por senha desabilitado, root apenas por chave"

# UFW
ufw --force reset > /dev/null
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp    comment "SSH"
ufw allow 80/tcp    comment "HTTP"
ufw allow 443/tcp   comment "HTTPS"
ufw --force enable > /dev/null
ok "UFW ativo — portas abertas: 22 (SSH), 80 (HTTP), 443 (HTTPS)"

# Fail2ban
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime  = 3600
findtime = 600
maxretry = 5
backend  = systemd

[sshd]
enabled  = true
port     = 22
filter   = sshd
EOF
systemctl enable fail2ban --quiet
systemctl restart fail2ban
ok "Fail2ban: ban de 1h após 5 tentativas SSH falhas"

# ── FASE 4: Docker ────────────────────────────────────────────────────────────
banner "FASE 4 de 8 — Instalando Docker + Docker Compose v2"

if command -v docker &>/dev/null; then
  ok "Docker já instalado: $(docker --version)"
else
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -qq
  apt-get install -y -qq docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
  systemctl enable docker --quiet
  systemctl start docker
  ok "Docker instalado: $(docker --version)"
fi

usermod -aG docker $APP_USER
ok "Usuário '$APP_USER' adicionado ao grupo docker"

# ── FASE 5: Nginx + Certbot ───────────────────────────────────────────────────
banner "FASE 5 de 8 — Instalando Nginx + Certbot (Let's Encrypt)"

apt-get install -y -qq nginx certbot python3-certbot-nginx
systemctl enable nginx --quiet

# Config temporária (HTTP-only) para o certbot funcionar primeiro
cat > /etc/nginx/sites-available/aiox-temp << EOF
server {
    listen 80;
    server_name $DOMAIN;
    root /var/www/html;
    location /.well-known/acme-challenge/ { root /var/www/certbot; }
    location / { return 200 'ok'; add_header Content-Type text/plain; }
}
EOF
ln -sf /etc/nginx/sites-available/aiox-temp /etc/nginx/sites-enabled/aiox
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx
ok "Nginx iniciado com config temporária"

# Obter certificado SSL
info "Obtendo certificado SSL para $DOMAIN..."
info "Verificando DNS do domínio..."
RESOLVED_IP=$(dig +short $DOMAIN @1.1.1.1 2>/dev/null | tail -1)
SERVER_IP=$(curl -s --max-time 5 ifconfig.me)
if [[ "$RESOLVED_IP" != "$SERVER_IP" ]]; then
  warn "DNS de '$DOMAIN' aponta para '$RESOLVED_IP'"
  warn "IP desta VPS é '$SERVER_IP'"
  warn "O DNS ainda não propagou — o certbot pode falhar."
  warn "Pressione ENTER para tentar mesmo assim, ou CTRL+C para abortar."
  read -r
fi

if certbot --nginx -d "$DOMAIN" \
    --non-interactive --agree-tos \
    -m "$ADMIN_EMAIL" \
    --redirect 2>&1; then
  ok "Certificado SSL obtido com sucesso para $DOMAIN"
else
  warn "Certbot falhou. Continuando sem SSL por enquanto."
  warn "Quando o DNS propagar, rode: certbot --nginx -d $DOMAIN"
fi

# ── FASE 6: Clonar repositório ────────────────────────────────────────────────
banner "FASE 6 de 8 — Clonando repositório"

mkdir -p "$DEPLOY_DIR"
chown $APP_USER:$APP_USER "$DEPLOY_DIR"

if [[ -d "$DEPLOY_DIR/.git" ]]; then
  info "Repositório já existe — atualizando..."
  sudo -u $APP_USER git -C "$DEPLOY_DIR" pull
else
  sudo -u $APP_USER git clone "$REPO_URL" "$DEPLOY_DIR"
fi
ok "Repositório clonado em $DEPLOY_DIR"
info "Último commit: $(git -C $DEPLOY_DIR log -1 --format='%h %s (%ar)')"

# ── FASE 7: Configurar ambiente ───────────────────────────────────────────────
banner "FASE 7 de 8 — Configurando variáveis de ambiente"

ENV_FILE="$DEPLOY_DIR/deploy/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  cp "$DEPLOY_DIR/deploy/.env.example" "$ENV_FILE"

  POSTGRES_PASS=$(openssl rand -hex 20)
  REDIS_PASS=$(openssl rand -hex 16)
  SESSION_SECRET=$(openssl rand -hex 32)

  sed -i "s|POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$POSTGRES_PASS|"   "$ENV_FILE"
  sed -i "s|REDIS_PASSWORD=.*|REDIS_PASSWORD=$REDIS_PASS|"             "$ENV_FILE"
  sed -i "s|SESSION_SECRET=.*|SESSION_SECRET=$SESSION_SECRET|"         "$ENV_FILE"
  sed -i "s|APP_DOMAIN=.*|APP_DOMAIN=$DOMAIN|"                         "$ENV_FILE"

  if [[ -n "$ANTHROPIC_KEY" ]]; then
    sed -i "s|ANTHROPIC_API_KEY=.*|ANTHROPIC_API_KEY=$ANTHROPIC_KEY|"  "$ENV_FILE"
    ok "ANTHROPIC_API_KEY configurada"
  else
    warn "ANTHROPIC_API_KEY não fornecida."
    warn "Edite depois: nano $ENV_FILE"
  fi

  chown $APP_USER:$APP_USER "$ENV_FILE"
  chmod 600 "$ENV_FILE"
  ok ".env criado com senhas geradas automaticamente"
else
  ok ".env já existe — mantendo configurações atuais"
fi

# Nginx com config final (HTTPS)
info "Aplicando config nginx final com HTTPS..."
cp "$DEPLOY_DIR/deploy/nginx/aiox.conf" /etc/nginx/sites-available/aiox
sed -i "s/YOUR_DOMAIN/$DOMAIN/g" /etc/nginx/sites-available/aiox
ln -sf /etc/nginx/sites-available/aiox /etc/nginx/sites-enabled/aiox
rm -f /etc/nginx/sites-available/aiox-temp
nginx -t && systemctl reload nginx
ok "Nginx configurado com HTTPS"

# ── FASE 8: Build e start ─────────────────────────────────────────────────────
banner "FASE 8 de 8 — Iniciando serviços com Docker Compose"

COMPOSE="docker compose -f $DEPLOY_DIR/deploy/docker-compose.prod.yml --env-file $ENV_FILE"

info "Baixando imagens Docker (pode demorar na primeira vez)..."
sudo -u $APP_USER $COMPOSE pull 2>&1 | grep -E "Pulling|pulled|Pull complete|already" || true

if [[ -f "$DEPLOY_DIR/chatbot/Dockerfile" ]]; then
  info "Construindo imagem do chatbot..."
  sudo -u $APP_USER $COMPOSE build chatbot
fi

info "Iniciando todos os serviços..."
sudo -u $APP_USER $COMPOSE up -d

# Aguardar serviços ficarem saudáveis
info "Aguardando serviços inicializarem (max 60s)..."
for i in {1..12}; do
  sleep 5
  STATUS=$(sudo -u $APP_USER $COMPOSE ps --format json 2>/dev/null | \
    python3 -c "import sys,json; s=json.load(sys.stdin); print('ok' if all(c.get('Health','') in ['healthy',''] for c in s) else 'wait')" 2>/dev/null || echo "wait")
  if [[ "$STATUS" == "ok" ]] || curl -sf http://localhost:3000/health > /dev/null 2>&1; then
    ok "Serviços saudáveis após $((i*5))s"
    break
  fi
  echo -n "  ... aguardando ($((i*5))s)"$'\r'
done

# Auto-start via systemd
cat > /etc/systemd/system/aiox.service << EOF
[Unit]
Description=AIOX Squads — Assistente Jurídico
After=docker.service network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$DEPLOY_DIR
ExecStart=/usr/bin/docker compose -f deploy/docker-compose.prod.yml --env-file deploy/.env up -d
ExecStop=/usr/bin/docker compose -f deploy/docker-compose.prod.yml --env-file deploy/.env down
User=$APP_USER
TimeoutStartSec=120
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable aiox --quiet
ok "Auto-start configurado (aiox.service)"

# ── Resumo final ──────────────────────────────────────────────────────────────
echo ""
echo -e "${G}"
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║                                                          ║"
echo "  ║   ✅  AIOX Squads — Instalação concluída!               ║"
echo "  ║                                                          ║"
echo -e "  ║   🌐  URL:     ${NC}https://$DOMAIN${G}"
echo -e "  ║   📁  Dir:     ${NC}$DEPLOY_DIR${G}"
echo -e "  ║   👤  Usuário: ${NC}$APP_USER${G}"
echo "  ║                                                          ║"
echo "  ╠══════════════════════════════════════════════════════════╣"
echo "  ║  Comandos úteis:                                         ║"
echo "  ║                                                          ║"
echo -e "  ║  ${NC}Ver logs:    ${G}docker compose ... logs -f chatbot${G}       ║"
echo -e "  ║  ${NC}Status:      ${G}systemctl status aiox${G}                    ║"
echo -e "  ║  ${NC}Atualizar:   ${G}bash $DEPLOY_DIR/deploy/deploy.sh${G}         ║"
echo -e "  ║  ${NC}Banco:       ${G}docker exec -it aiox-postgres psql...${G}     ║"
if [[ -z "$ANTHROPIC_KEY" ]]; then
echo "  ║                                                          ║"
echo -e "  ║  ${Y}⚠ PENDENTE: adicionar ANTHROPIC_API_KEY em:${G}            ║"
echo -e "  ║  ${NC}  nano $DEPLOY_DIR/deploy/.env${G}                    ║"
echo -e "  ║  ${NC}  systemctl restart aiox${G}                            ║"
fi
echo "  ║                                                          ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
