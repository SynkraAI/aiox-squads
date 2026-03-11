#!/usr/bin/env bash
# start.sh — Inicia o chatbot AIOX Squads
# Uso: bash start.sh
#      ANTHROPIC_API_KEY=sk-ant-... bash start.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Verifica API key
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "✗ ANTHROPIC_API_KEY não definida."
  echo ""
  echo "  Defina antes de rodar:"
  echo "    export ANTHROPIC_API_KEY=sk-ant-..."
  echo "    bash start.sh"
  exit 1
fi

# Instala dependências se necessário
if [ ! -d "node_modules" ]; then
  echo "→ Instalando dependências..."
  npm install --silent
fi

# Compila se dist/ não existe ou está desatualizado
if [ ! -d "dist" ] || [ "src/index.ts" -nt "dist/index.js" ]; then
  echo "→ Compilando TypeScript..."
  npx tsc
fi

echo "→ Iniciando chatbot..."
node dist/index.js
