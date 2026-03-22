#!/usr/bin/env bash
# web-start.sh — Inicia o chatbot AIOX Squads (interface web)
# Uso: bash web-start.sh
#      ANTHROPIC_API_KEY=sk-ant-... bash web-start.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "✗ ANTHROPIC_API_KEY não definida."
  echo ""
  echo "  Defina antes de rodar:"
  echo "    export ANTHROPIC_API_KEY=sk-ant-..."
  echo "    bash web-start.sh"
  exit 1
fi

if [ ! -d "node_modules" ]; then
  echo "→ Instalando dependências..."
  npm install --silent
fi

if [ ! -d "dist" ] || [ "src/server.ts" -nt "dist/server.js" ]; then
  echo "→ Compilando TypeScript..."
  npx tsc
fi

echo "→ Iniciando servidor web..."
echo "  Acesse: http://localhost:3000"
node dist/server.js
