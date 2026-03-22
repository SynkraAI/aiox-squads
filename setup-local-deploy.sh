#!/usr/bin/env bash
# setup-local-deploy.sh — Instala e configura o local-deploy (dl) para desenvolvimento local
# Documentação: https://local-deploy.github.io/
#
# O que este script faz:
#   1. Verifica dependências (Docker, Docker Compose v2)
#   2. Instala o dl CLI (local-deploy) v1.2.0
#   3. Instala o certificado CA do dl (opcional, para HTTPS local)
#   4. Exibe o status e próximos passos

set -euo pipefail

DL_VERSION="1.2.0"
ARCH="$(uname -m)"
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

# ── Cores ─────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
err()  { echo -e "${RED}✗${NC} $*"; exit 1; }
step() { echo -e "\n→ $*"; }

# ── Verificar Docker ──────────────────────────────────────────────────────────
check_docker() {
  step "Verificando Docker..."

  if ! command -v docker &>/dev/null; then
    err "Docker não encontrado. Instale Docker v22+ em: https://docs.docker.com/get-docker/"
  fi

  DOCKER_VER="$(docker --version | grep -oE '[0-9]+\.[0-9]+' | head -1)"
  DOCKER_MAJOR="$(echo "$DOCKER_VER" | cut -d. -f1)"
  if [ "$DOCKER_MAJOR" -lt 22 ]; then
    warn "Docker ${DOCKER_VER} detectado — recomendado v22+. Atualize se tiver problemas."
  else
    ok "Docker ${DOCKER_VER}"
  fi

  if docker compose version &>/dev/null 2>&1; then
    ok "Docker Compose v2 (plugin): $(docker compose version --short 2>/dev/null || true)"
  elif docker-compose --version &>/dev/null 2>&1; then
    warn "docker-compose standalone detectado. O dl funciona melhor com Docker Compose v2 (plugin)."
  else
    err "Docker Compose não encontrado. Instale em: https://docs.docker.com/compose/install/"
  fi
}

# ── Instalar dl ───────────────────────────────────────────────────────────────
install_dl() {
  step "Instalando dl ${DL_VERSION}..."

  if command -v dl &>/dev/null; then
    CURRENT_VER="$(dl version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)"
    if [ "$CURRENT_VER" = "$DL_VERSION" ]; then
      ok "dl ${CURRENT_VER} já instalado"
      return
    fi
    warn "dl ${CURRENT_VER} encontrado — atualizando para ${DL_VERSION}..."
  fi

  case "${OS}" in
    linux)
      case "${ARCH}" in
        x86_64)  DL_ARCH="amd64" ;;
        aarch64) DL_ARCH="arm64" ;;
        *) err "Arquitetura não suportada: ${ARCH}" ;;
      esac
      ;;
    darwin)
      case "${ARCH}" in
        x86_64)  DL_ARCH="amd64" ;;
        arm64)   DL_ARCH="arm64" ;;
        *) err "Arquitetura não suportada: ${ARCH}" ;;
      esac
      ;;
    *)
      err "Sistema operacional não suportado: ${OS}"
      ;;
  esac

  ASSET="dl-${DL_VERSION}-${OS}-${DL_ARCH}.tar.gz"
  DOWNLOAD_URL="https://github.com/local-deploy/dl/releases/download/${DL_VERSION}/${ASSET}"

  TMPDIR="$(mktemp -d)"
  trap 'rm -rf "${TMPDIR}"' EXIT

  echo "  Baixando ${ASSET}..."
  curl -fL "${DOWNLOAD_URL}" -o "${TMPDIR}/${ASSET}"
  tar -xzf "${TMPDIR}/${ASSET}" -C "${TMPDIR}"

  if [ -w /usr/local/bin ]; then
    install -m 755 "${TMPDIR}/dl" /usr/local/bin/dl
  else
    echo "  Instalando em /usr/local/bin (pode pedir senha sudo)..."
    sudo install -m 755 "${TMPDIR}/dl" /usr/local/bin/dl
  fi

  ok "dl $(dl version 2>/dev/null || true) instalado em /usr/local/bin/dl"
}

# ── Instalar certificado CA (opcional) ───────────────────────────────────────
install_cert() {
  step "Certificado CA (HTTPS local)..."

  echo "  Para habilitar HTTPS em domínios *.localhost e *.nip.io, execute:"
  echo "  $ dl cert install"
  echo "  (Requer que os serviços do dl estejam rodando: dl service up)"
  warn "Certificado não instalado agora — faça isso após 'dl service up'"
}

# ── Status final ──────────────────────────────────────────────────────────────
show_status() {
  step "Status"

  ok "dl version: $(dl version 2>/dev/null | head -1 || true)"
  echo ""
  echo "  Próximos passos:"
  echo "  1. Iniciar serviços base:    dl service up"
  echo "  2. Instalar certificado CA:  dl cert install"
  echo "  3. Em um projeto:           dl env && dl up"
  echo ""
  echo "  Documentação: https://local-deploy.github.io/"
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  echo "=== Local Deploy (dl) Setup ==="
  check_docker
  install_dl
  install_cert
  show_status
}

main "$@"
