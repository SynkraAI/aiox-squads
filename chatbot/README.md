# AIOX Squads — Chatbot CLI

Ambiente de conversação com os agentes do repositório **aiox-squads**.
Suporta streaming, upload de arquivos (Files API), troca de agente em tempo real e histórico de sessão.

## Pré-requisitos

- Node.js 18+
- Chave de API Anthropic (`ANTHROPIC_API_KEY`)
- Squads instalados em `../squads/`

## Início rápido

```bash
# 1. Defina sua API key
export ANTHROPIC_API_KEY=sk-ant-...

# 2. Inicie o chatbot
bash start.sh
```

Ou manualmente:

```bash
cd chatbot
npm install
npm run build
node dist/index.js
```

## Comandos disponíveis

| Comando | Descrição |
|---------|-----------|
| `/help` | Exibe ajuda |
| `/agent` | Troca de agente (mantém histórico) |
| `/upload <caminho>` | Envia um arquivo para análise |
| `/files` | Lista arquivos enviados na sessão |
| `/reset` | Limpa o histórico da conversa |
| `/status` | Exibe agente ativo e estatísticas |
| `/exit` | Encerra o chatbot |

## Formatos de arquivo suportados

`pdf`, `txt`, `md`, `json`, `csv`, `png`, `jpg`, `jpeg`, `webp`, `gif`

## Agentes disponíveis

O chatbot carrega automaticamente todos os agentes encontrados em `../squads/*/agents/*.md`:

| Squad | Agentes |
|-------|---------|
| **apex** | Especialistas em frontend premium (14 agentes) |
| **curator** | Curadoria e edição de conteúdo (12 agentes) |
| **deep-research** | Pesquisa acadêmica e investigativa (11 agentes) |
| **dispatch** | Orquestração e roteamento de tarefas (4 agentes) |
| **education** | Design instrucional e currículo (16 agentes) |
| **kaizen** | Melhoria contínua e análise de processos (7 agentes) |
| **seo** | Otimização para motores de busca (8 agentes) |
| **squad-creator** | Criação de novos squads (1 agente) |

## Exemplo de sessão

```
AIOX Squads — Agentes disponíveis
  Squad: education
  [9] Education Chief (education-chief)
  [10] Robert Bjork (bjork-engineer)
  ...

Escolha um agente (número): 9

Education Chief ▶
Olá! Sou o Education Chief. Posso criar curriculo para qualquer domínio.
Use *create-course {domínio} para iniciar.

Você > /upload ./meu-plano.pdf
✓ Arquivo enviado: meu-plano.pdf (42.3 KB)

Você > Analise este plano de curso e sugira melhorias
Education Chief ▶
Com base no PDF enviado, identifiquei...
```

## Arquitetura

```
chatbot/
├── src/
│   ├── index.ts    — CLI principal (menus, loop de chat, comandos)
│   ├── agents.ts   — Carregador de agentes dos arquivos .md
│   ├── chat.ts     — Sessão de chat com streaming (claude-opus-4-6)
│   └── files.ts    — Upload/download de arquivos via Files API
├── dist/           — JavaScript compilado
├── start.sh        — Script de inicialização
└── package.json
```

## Modelo utilizado

`claude-opus-4-6` com adaptive thinking (`thinking: {type: "adaptive"}`).
