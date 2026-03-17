#!/usr/bin/env bash
# =============================================================================
# AIOX Squads — Script de atualização contínua
#
# Execute na VPS para atualizar a aplicação:
#   bash /opt/aiox/deploy/deploy.sh
#
# Ou configure como alias:
#   echo "alias aiox-deploy='bash /opt/aiox/deploy/deploy.sh'" >> ~/.bashrc
# =============================================================================
set -euo pipefail

DEPLOY_DIR="/opt/aiox"
COMPOSE="docker compose -f $DEPLOY_DIR/deploy/docker-compose.prod.yml --env-file $DEPLOY_DIR/deploy/.env"

G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${G}✓${NC} $*"; }
info() { echo -e "${B}→${NC} $*"; }
warn() { echo -e "${Y}⚠${NC}  $*"; }

echo ""
echo "  ╔═══════════════════════════════════╗"
echo "  ║   AIOX Squads — Deploy            ║"
echo "  ╚═══════════════════════════════════╝"
echo ""

# ── 1. Pull do repositório ────────────────────────────────────────────────────
info "Atualizando repositório..."
cd "$DEPLOY_DIR"
git fetch origin
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

if [[ "$LOCAL" == "$REMOTE" ]]; then
  warn "Sem alterações no repositório. Forçar rebuild? (s/N)"
  read -r FORCE
  [[ "$FORCE" != "s" && "$FORCE" != "S" ]] && echo "Abortado." && exit 0
fi

git pull origin "$(git branch --show-current)"
ok "Código atualizado: $(git log -1 --format='%h %s')"

# ── 2. Build da imagem ────────────────────────────────────────────────────────
info "Construindo imagem do chatbot..."
$COMPOSE build --no-cache chatbot
ok "Imagem construída"

# ── 3. Reiniciar apenas o chatbot (banco e Redis continuam rodando) ───────────
info "Reiniciando chatbot..."
$COMPOSE up -d --no-deps chatbot
ok "Chatbot reiniciado"

# ── 4. Verificar saúde ────────────────────────────────────────────────────────
info "Aguardando serviço ficar saudável..."
sleep 5
if curl -sf http://localhost:3000/health > /dev/null; then
  ok "Serviço respondendo em http://localhost:3000/health"
else
  warn "Health check falhou — verificar logs:"
  echo "  $COMPOSE logs --tail=50 chatbot"
  exit 1
fi

# ── 5. Status final ───────────────────────────────────────────────────────────
echo ""
$COMPOSE ps
echo ""
ok "Deploy concluído: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "  Comandos úteis:"
echo "  Logs em tempo real:  $COMPOSE logs -f chatbot"
echo "  Status dos serviços: $COMPOSE ps"
echo "  Reiniciar tudo:      $COMPOSE restart"
echo "  Parar tudo:          $COMPOSE down"
echo "  Banco de dados:      docker exec -it aiox-postgres psql -U aiox -d aiox"
echo ""
