FROM node:22-alpine

# O build context deve ser a raiz do repositório (aiox-squads-FelippePestana/)
# docker build -f chatbot/Dockerfile -t aiox-chatbot .

WORKDIR /app/chatbot

# Copia package files
COPY chatbot/package*.json ./

# Instala todas as dependências (incluindo devDeps para build)
RUN npm install

# Copia source TypeScript e configs
COPY chatbot/tsconfig.json ./
COPY chatbot/src/ ./src/

# Compila TypeScript
RUN npx tsc && npm prune --omit=dev

# Copia squads para o path correto (../../squads a partir de dist/)
COPY squads/ /app/squads/

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1

ENV NODE_ENV=production

CMD ["node", "dist/server.js"]
