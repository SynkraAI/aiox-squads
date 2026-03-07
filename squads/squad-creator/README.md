# Squad Creator

> **Crie squads de alta qualidade baseados em elite minds reais.**

## Links Rápidos

### Para Iniciantes
| Doc | Descrição |
|-----|-----------|
| [POR-ONDE-COMECAR](docs/POR-ONDE-COMECAR.md) | **Leia primeiro** - Guia de navegação |
| [FAQ](docs/FAQ.md) | Perguntas frequentes e glossário |
| [TUTORIAL-COMPLETO](docs/TUTORIAL-COMPLETO.md) | Exemplo real passo a passo |
| [QUICK-START](docs/QUICK-START.md) | Crie seu primeiro squad em 5 minutos |

### Referência
| Doc | Descrição |
|-----|-----------|
| [CONCEPTS](docs/CONCEPTS.md) | Entenda DNA, Tiers, Quality Gates |
| [COMMANDS](docs/COMMANDS.md) | Referência de todos os comandos |
| [TROUBLESHOOTING](docs/TROUBLESHOOTING.md) | Problemas comuns e soluções |
| [ARCHITECTURE](docs/ARCHITECTURE-DIAGRAMS.md) | Diagramas de fluxo (Mermaid) |
| [HITL-FLOW](docs/HITL-FLOW.md) | Human-in-the-Loop detalhado |

---

## Sobre o Squad Creator

O Squad Creator gerencia os squads da sua instalação AIOX. Use o comando `*refresh-registry` para ver estatísticas atualizadas do seu ecossistema.

**Características:**
- Cria squads baseados em elite minds reais
- Extrai Voice DNA e Thinking DNA automaticamente
- Valida qualidade com quality gates rigorosos

### Governança de Estrutura (Obrigatória)

Todo squad criado deve declarar no `config.yaml`:

```yaml
workspace_integration:
  level: "<none|read_only|read_write|workspace_first>"
  rationale: "Por que esse nível é necessário"
  read_paths: []
  write_paths: []
  template_namespace: null
```

Regras mínimas:
- `read_only|read_write|workspace_first`: precisa ter referências explícitas a `workspace/`.
- `workspace_first`: precisa de `scripts/bootstrap-*-workspace.sh` e `scripts/validate-*-essentials.sh`.

---

## Visão Geral

O Squad Creator cria squads de agentes baseados em **elite minds reais** - pessoas com frameworks documentados e skin in the game.

```
┌─────────────────────────────────────────────────────────────────┐
│                    SQUAD CREATOR FLOW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  "Quero um squad de {domínio}"                                  │
│            ↓                                                    │
│  Research: Elite minds do domínio...                            │
│            ↓                                                    │
│  Clone Mind: Voice DNA + Thinking DNA                           │
│            ↓                                                    │
│  Create Agents: {expert-1}.md, {expert-2}.md...                 │
│            ↓                                                    │
│  Smoke Tests: 3 testes de comportamento                         │
│            ↓                                                    │
│  Squad pronto: @{squad-name}                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 🔧 Deep Tool Discovery (v2.6)

O Squad Creator executa **pesquisa PROFUNDA e PARALELA** por ferramentas que potencializam os entregáveis de cada squad.

### Filosofia Central: TIERS RELATIVOS

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRINCÍPIO FUNDAMENTAL                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  NÃO EXISTEM VALORES ABSOLUTOS UNIVERSAIS.                      │
│                                                                 │
│  Um projeto com 30 stars pode ser EXCELENTE se for o melhor     │
│  do nicho. Um projeto com 10,000 stars pode ser MEDIANO se      │
│  todos os concorrentes tiverem 50,000.                          │
│                                                                 │
│  SEMPRE comparar ferramentas ENTRE SI, dentro do contexto       │
│  da pesquisa realizada.                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Princípios Operacionais

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRINCÍPIOS V2.6                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📊 COMPARAÇÃO RELATIVA                                         │
│     Tiers baseados nos projetos encontrados, não em             │
│     números mágicos como "stars >= 100"                         │
│                                                                 │
│  🎯 CONTEXTO DE DOMÍNIO                                         │
│     Ferramentas de nicho competem com ferramentas de nicho      │
│                                                                 │
│  🚩 FLAGS, NÃO VETOS                                            │
│     Problemas são destacados para decisão humana,               │
│     não eliminados automaticamente                              │
│                                                                 │
│  📈 DADOS > HEURÍSTICAS                                         │
│     Normalizar dentro do dataset encontrado                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Arquitetura: 5 Sub-Agentes em Paralelo

```
┌─────────────────────────────────────────────────────────────────┐
│               DEEP TOOL DISCOVERY ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PHASE 0: Capability Gap Analysis                               │
│           Mapeia o que o squad PRECISA                          │
│            ↓                                                    │
│  PHASE 1: PARALLEL DEEP SEARCH (5 sub-agents)                   │
│                                                                 │
│   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│   │   MCP   │ │   API   │ │   CLI   │ │ Library │ │ GitHub  │   │
│   │  Agent  │ │  Agent  │ │  Agent  │ │  Agent  │ │  Agent  │   │
│   └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘   │
│        │          │          │          │          │           │
│        └──────────┴──────────┼──────────┴──────────┘           │
│                              ↓                                  │
│  PHASE 2: COMPREHENSIVE EVALUATION                              │
│           🔒 Security Gate (BLOCKING)                           │
│           👥 Social Proof Gate (BLOCKING)                       │
│           💰 Cost-Benefit (Paid vs OSS)                         │
│           📊 RICE + WSJF Scoring                                │
│            ↓                                                    │
│  PHASE 3: Decision Matrix                                       │
│                                                                 │
│   ┌─────────────────┬─────────────────┐                         │
│   │   DO NOW        │   DO NEXT       │  High Value             │
│   │  (Score > 80)   │  (Score 60-80)  │  (High WSJF)            │
│   ├─────────────────┼─────────────────┤                         │
│   │   DO LATER      │   DON'T DO      │  Low Value              │
│   │  (Score 40-60)  │  (Score < 40)   │  (Low WSJF)             │
│   └─────────────────┴─────────────────┘                         │
│      Low Effort        High Effort                              │
│                                                                 │
│  OUTPUT: Integration Plan + Decision Matrix + Reports           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### O Que Cada Sub-Agente Pesquisa

| Sub-Agente | Fontes | Exemplos |
|------------|--------|----------|
| **MCP Agent** | modelcontextprotocol/servers, glama.ai, GitHub topics | playwright, mcp-server-pdf |
| **API Agent** | RapidAPI, PublicAPIs, ProgrammableWeb | SendGrid, SimilarWeb |
| **CLI Agent** | awesome-cli-apps, brew, npm, pip | jq, lighthouse, httpie |
| **Library Agent** | PyPI, npm, GitHub SDKs | langchain, pdfplumber |
| **GitHub Agent** | topics, collections, awesome lists | swipe-file-analyzer |

### Avaliação por Tiers Relativos (v2.6)

#### Sistema de Tiers (Percentis)

```
PASSO 1: Pesquisa encontra N ferramentas
PASSO 2: Coletar métricas brutas de todas
PASSO 3: Calcular percentis DENTRO do conjunto:

         Tier 1: Top 20% (acima de P80)
         Tier 2: 21-50% (entre P50 e P80)
         Tier 3: 51-80% (entre P20 e P50)
         Tier 4: Bottom 20% (abaixo de P20)

NOTA: Não existe "stars >= 100 = bom"
      30 stars pode ser Tier 1 se for o melhor do nicho
```

#### Dimensões Avaliadas (Todas Relativas)

| Dimensão | O que mede | Como compara |
|----------|------------|--------------|
| **Social Proof** | Popularidade, comunidade, adoção | Percentil de stars, downloads, contributors |
| **Security** | CVEs, deps, práticas | Percentil de vulnerabilidades (menos = melhor) |
| **Maturity** | Idade, estabilidade, docs | Percentil de maturidade |
| **RICE** | Reach×Impact×Confidence/Effort | Percentil do score RICE |
| **WSJF** | Cost of Delay / Duration | Percentil de priorização |

#### Flags (Atenção, não VETOs)

```
🔴 CRITICAL_CVE      → Verificar se há patch
🟠 HIGH_CVE          → Comparar com alternativas
🟡 SECURITY_INCIDENT → Verificar se resolvido
🔵 VERY_NEW          → Pode ser inovador ou instável
🟤 SINGLE_MAINTAINER → Bus factor 1
⚫ NO_LICENSE        → Requer clarificação

IMPORTANTE: Flags NÃO eliminam tools automaticamente.
Uma tool com flag pode ser a melhor opção disponível.
```

#### Cost-Benefit (Comparação por Tier)

```
NÃO existe regra "ROI > 200%".

Comparação:
- Se OSS é Tier 1-2: preferir OSS
- Se empate técnico: preferir OSS (custo zero)
- Se Paid >> OSS em tiers: apresentar análise para decisão humana
```

### Comandos

| Comando | Descrição |
|---------|-----------|
| `*discover-tools {domain}` | Executar deep discovery (5 sub-agents) com validação canônica de escopo (sem inferência por nome) |
| `*show-tools` | Exibir registro global de tools |
| `*add-tool {name}` | Adicionar tool às dependências |

### Arquivos

| Arquivo | Descrição | Modo |
|---------|-----------|------|
| `tasks/discover-tools.md` | Task de descoberta de ferramentas MCP | Base |
| `workflows/wf-discover-tools.yaml` | Workflow completo multi-source (900+ linhas) | [PRO] |
| `data/tool-registry.yaml` | Catálogo global de tools | [PRO] |
| `data/tool-evaluation-framework.md` | Framework RICE/WSJF/Security | [PRO] |

### Outputs por Squad

```
squads/{squad}/
├── docs/
│   ├── tool-discovery-report.md   # Relatório completo
│   └── tool-integration-plan.md   # Plano de implementação
└── data/
    └── capability-tools.yaml      # Mapeamento capability → tools
```

### Heuristics (5 Checkpoints)

| Heuristic | Propósito | Critério | Notas |
|-----------|-----------|----------|-------|
| **SC_TLD_001** | Discovery Complete | 3+ agents, 5+ tools | Qualidade por ranking, não quantidade |
| **SC_TLD_002** | Ranking Complete | Todos os tools têm tiers | Sem thresholds absolutos |
| **SC_TLD_003** | Flags Identified | Flags checados | Para atenção humana, não VETOs |
| **SC_TLD_004** | Cost Comparison | Paid vs OSS por tier | Sem ROI fixo |
| **SC_TLD_005** | Matrix Generated | Quadrantes atribuídos | Todos os tools incluídos |

### Filosofia

> "Não existem valores absolutos universais. Um projeto com 30 stars pode ser excelente se for o melhor do nicho. SEMPRE comparar ferramentas entre si, dentro do contexto da pesquisa realizada."

---

## Agentes Especialistas

O Squad Creator possui agentes especializados organizados por Tiers:

| Tier | Agent | Especialidade | Quando Usar | Modo |
|------|-------|---------------|-------------|------|
| **Orch** | **squad-chief** | Orquestração + Triagem + Criação | Ponto de entrada, criar squads | Base |
| **1** | **oalanicolas** | Mind Cloning | Extrair DNA, curar fontes, validar fidelidade | [PRO] |
| **1** | **pedro-valerio** | Process Design | Validar workflows, criar checklists, veto conditions | [PRO] |
| **1** | **thiago_finch** | Business Strategy | Estratégia de negócio e marketing | [PRO] |

> Os agentes [PRO] são ativados automaticamente quando o AIOX Pro está instalado.
> Disponível para alunos do **Cohort Avançado**.

### Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                    ARQUITETURA v4.0.0                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Orchestrator: @squad-chief (Entrada + Criação + SOP)            │
│  ├── Triagem rápida de necessidades                              │
│  ├── Verificação de ecossistema existente                        │
│  ├── Criação completa de squads via templates                    │
│  ├── Research de elite minds                                     │
│  ├── Coordenação entre especialistas                             │
│  └── Validação final de qualidade                                │
│                                                                  │
│  [PRO] Tier 1: @oalanicolas (Mind Cloning)                       │
│  ├── DNA Mental 8 camadas                                        │
│  ├── Curadoria de fontes (ouro vs bronze)                        │
│  ├── Playbook + Framework + Swipe File                           │
│  ├── 46 decision checkpoints (VALUES/OBSESSIONS/MODELS)          │
│  └── Validação de fidelidade (85-97%)                            │
│                                                                  │
│  [PRO] Tier 1: @pedro-valerio (Process Design)                   │
│  ├── Impossibilitar caminhos errados                             │
│  ├── Veto conditions em checkpoints                              │
│  ├── Automação de gaps de tempo                                  │
│  └── Fluxo unidirecional                                         │
│                                                                  │
│  [PRO] Tier 1: @thiago_finch (Business Strategy)                 │
│  ├── Análise de funil e ROI                                      │
│  ├── Go-to-market strategy                                       │
│  └── Inteligência de mercado                                     │
│                                                                  │
│  Sinergia [PRO]:                                                 │
│  Chief roteia/orquestra → Alan extrai DNA →                      │
│  Pedro valida processo → Thiago direciona estratégia             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Ativação

```bash
@squad-creator                      # Ponto de entrada + Orquestrador + SOP
@squad-creator:oalanicolas          # Especialista em minds
@squad-creator:pedro-valerio        # Especialista em processos
```

---

## Funcionalidades Principais

### Mind Cloning (MMOS-lite)

Extrai o DNA de experts reais:
- **Voice DNA**: Como comunicam (vocabulário, tom, histórias)
- **Thinking DNA**: Como pensam (frameworks, heurísticas, decisões)

### YOLO Mode

Roda automaticamente, para só quando dados faltam:
- Sem materiais? Pesquisa web automática
- Fidelidade: 60-75%

### QUALITY Mode

Máxima fidelidade com materiais do usuário:
- Livros, PDFs, transcrições
- Fidelidade: 85-95%

### Smoke Tests

3 testes obrigatórios para validar comportamento real:
1. Conhecimento do domínio
2. Tomada de decisão
3. Resposta a objeções

---

## Início Rápido

```bash
# 1. Ativar
@squad-creator

# 2. Criar squad
"Quero um squad de copywriting"

# 3. Escolher modo
🚀 YOLO (sem materiais)
💎 QUALITY (com materiais)

# 4. Aprovar elite minds
# 5. Aguardar criação
# 6. Usar: @{squad-name}
```

**Tutorial completo:** [QUICK-START.md](docs/QUICK-START.md)

---

## Comandos Principais

| Comando | Descrição |
|---------|-----------|
| `*create-squad` | Criar squad completo |
| `*clone-mind {name}` | Clonar expert específico |
| `*validate-squad {name}` | Validar squad existente |
| `*update-mind {slug}` | Atualizar DNA existente |
| `*quality-dashboard` | Ver métricas de qualidade |

**Referência completa:** [COMMANDS.md](docs/COMMANDS.md)

---

## Capacidades Completas

### Criação

| Comando | Descrição | Output |
|---------|-----------|--------|
| `*create-squad` | Criar squad completo (6 fases) | `squads/{name}/` |
| `*clone-mind {name}` | Extrair Voice + Thinking DNA | `.aiox/squad-runtime/minds/{slug}/` |
| `*create-agent` | Agent individual para squad | `agents/{name}.md` |
| `*create-workflow` | Workflow multi-fase | `workflows/{name}.yaml` |
| `*create-task` | Task atômica | `tasks/{name}.md` |
| `*create-template` | Template de output | `templates/{name}.yaml` |

### Extração de DNA

| Comando | Descrição | Foco |
|---------|-----------|------|
| `*extract-voice-dna` | Vocabulário, tom, histórias | Comunicação |
| `*extract-thinking-dna` | Frameworks, heurísticas, decisões | Pensamento |
| `*update-mind {slug}` | Atualizar DNA existente | Brownfield |
| `*auto-acquire-sources` | Busca web automática | Research |

### Validação

| Comando | Descrição | Gate |
|---------|-----------|------|
| `*validate-squad {name}` | Validação completa (9 fases) | Blocking |
| `*validate-agent {file}` | AIOX 6-level structure | SC_AGT_001 |
| `*validate-task {file}` | Task Anatomy (8 campos) | - |
| `*validate-workflow {file}` | Phases + checkpoints | - |
| `*quality-dashboard {name}` | Métricas visuais | - |

### Analytics

| Comando | Descrição |
|---------|-----------|
| `*list-squads` | Listar todos os squads |
| `*show-registry` | Registro com gaps e referências |
| `*squad-analytics` | Dashboard detalhado |
| `*refresh-registry` | Escanear e atualizar registro |

---

## Conceitos Fundamentais

| Conceito | Descrição |
|----------|-----------|
| **Mind** | Pessoa real com frameworks documentados |
| **Agent** | Clone digital do mind |
| **Voice DNA** | Como o expert comunica |
| **Thinking DNA** | Como o expert pensa/decide |
| **Tiers** | Níveis de agents (0=diagnóstico, 1=masters, etc.) |
| **Quality Gates** | Checkpoints de validação |
| **Fidelity** | % de similaridade com expert real |

**Explicação detalhada:** [CONCEPTS.md](docs/CONCEPTS.md)

---

## O Que Está Incluído

### Agents

- `squad-chief.md` - Agent orquestrador de squads (triagem, criação, validação)

### Tasks

**Criação**
- `create-squad.md` - Workflow completo de criação de squad
- `create-agent.md` - Criação individual de agent para squads
- `create-workflow.md` - Criação de workflows multi-fase
- `create-task.md` - Criação de task para workflows
- `create-template.md` - Criação de template para outputs
- `create-pipeline.md` - Scaffolding de pipeline (state, progress, runner)
- `create-documentation.md` - Geração de documentação de squad

**Validação**
- `validate-squad.md` - Validação granular de squad
- `validate-final-artifacts.md` - Validação de artefatos finais com hard gates
- `qa-after-creation.md` - Quality assurance pós-criação

**Gestão & Utilidades**
- `discover-tools.md` - Descoberta de ferramentas MCP
- `upgrade-squad.md` - Upgrade de squad existente
- `next-squad.md` - Recomendação de próximo squad
- `squad-overview.md` - Geração de documentação SQUAD-OVERVIEW.md
- `squad-analytics.md` - Analytics e métricas
- `refresh-registry.md` - Atualização do registro de squads
- `sync-ide-command.md` - Sincronização de comandos para IDE
- `install-commands.md` - Instalação de comandos
- `reexecute-squad-phase.md` - Re-execução segura de fase de workflow
- `detect-squad-context.md` - Detecção de contexto (greenfield/brownfield)
- `detect-operational-mode.md` - Detecção de modo operacional
- `setup-runtime.md` - Setup de runtime
- `auto-heal.md` - Auto-correção de problemas
- `operational-test.md` - Teste operacional

### Templates

- `config-tmpl.yaml` - Template de configuração de squad
- `readme-tmpl.md` - Template de README para squads
- `agent-tmpl.md` - Template de definição de agent
- `task-tmpl.md` - Template de workflow de task
- `template-tmpl.yaml` - Template de template de output
- `pop-extractor-prompt.md` - Template de extração de SOP (SC-PE-001)

### Checklists

- `squad-checklist.md` - Checklist completo de validação de qualidade
- `agent-quality-gate.md` - Quality gate de validação de agents
- `task-anatomy-checklist.md` - Checklist de anatomia de tasks

### Config

- `squad-config.yaml` - Configuração de squad com data sources

### Data

- `squad-kb.md` - Knowledge base de melhores práticas para squads

### Scripts (Worker)

Scripts Python para operações determinísticas (zero tokens LLM):

| Script | Propósito | Tipo |
|--------|-----------|------|
| `sync-ide-command.py` | Sincroniza components para IDEs | Worker |
| `validate-squad-structure.py` | Validação Phases 0-2 | Worker |
| `refresh-registry.py` | Escaneia squads, gera JSON | Worker |
| `squad-analytics.py` | Métricas e estatísticas | Worker |
| `naming_validator.py` | Validação de nomes | Worker |

**Documentação completa:** [scripts/README.md](scripts/README.md)

---

## ⚡ Arquitetura de Execução

O Squad Creator usa o **Executor Decision Tree** para otimizar custos:

```
┌─────────────────────────────────────────────────────────────────┐
│                    EXECUTOR DECISION TREE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  WORKER (Python)     │ AGENT (LLM)        │ HYBRID              │
│  ─────────────────── │ ────────────────── │ ──────────────────  │
│  • Determinístico    │ • Semântico        │ • Worker coleta     │
│  • Operações arquivo │ • Análise          │ • Agent enriquece   │
│  • Parse YAML/JSON   │ • Geração          │                     │
│  • Contagens         │ • Inferência       │                     │
│  • Custo: $0         │ • Custo: ~$0.05    │ • Custo: ~$0.02     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Tasks por Tipo de Executor

| Task | Tipo | Script Worker |
|------|------|---------------|
| `sync-ide-command.md` | Worker | `sync-ide-command.py` |
| `install-commands.md` | Worker | `sync-ide-command.py` |
| `refresh-registry.md` | Hybrid | `refresh-registry.py` |
| `squad-analytics.md` | Hybrid | `squad-analytics.py` |
| `validate-squad.md` | Hybrid | `validate-squad-structure.py` |
| `validate-squad.md` (Phase 3+) | Agent | (análise semântica) |
| `create-squad.md` | Agent | (geração criativa) |

### Economia

| Métrica | Valor |
|---------|-------|
| Economia mensal | ~$45/mês |
| Economia anual | ~$540/ano |
| Tokens evitados | ~15M/mês |

**Referência:** [data/executor-decision-tree.md](data/executor-decision-tree.md)

## Instalação

1. Copie a pasta `squads/squad-creator/` para o seu projeto AIOX
2. Sincronize os comandos para o IDE:

```bash
# Dentro do Claude Code, ative o squad e execute:
*sync
```

---

## Sistema SOP Extractor

O SOP Extractor transforma transcrições de reuniões em Procedimentos Operacionais Padrão (SOPs) estruturados e prontos para automação.

### Propósito

Extrair SOPs de reuniões gravadas onde alguém explicou um processo de negócio, produzindo:
1. SOP completo seguindo padrão SC-PE-001 (11 partes)
2. Análise de automação usando heurística PV_PM_001
3. Blueprint de Squad AIOX pronto para criação imediata
4. Relatório de gaps com perguntas de esclarecimento

### Fontes de Dados

Configure fontes de transcrição em `config/squad-config.yaml`:

| Fonte | Tipo | Descrição |
|-------|------|-----------|
| `supabase` | banco de dados | Query na tabela `transcripts` (padrão) |
| `local_file` | arquivo | Ler de `inputs/transcripts/` |
| `api` | http | Buscar de API externa |
| `direct` | inline | Passar transcrição como parâmetro |

Para mudar fonte:
```yaml
# config/squad-config.yaml
data_sources:
  transcripts:
    active_source: supabase  # ← mude aqui
```

### Workflow de Extração de SOP [PRO]

> Esta funcionalidade requer o AIOX Pro (Cohort Avançado).

```bash
# Ativar o squad-chief
@squad-creator

# Rodar extração (workflow principal) [PRO]
*extract-sop

# O agent irá:
# 1. Buscar transcrição da fonte configurada
# 2. Extrair estrutura do processo (passos, papéis, ferramentas)
# 3. Mapear cada passo para Task Anatomy (HO-TP-001)
# 4. Classificar tipos cognitivos (automatizável vs humano-only)
# 5. Aplicar análise de automação PV_PM_001
# 6. Gerar blueprint de Squad
# 7. Documentar gaps e perguntas de esclarecimento
```

### Funcionalidades Principais

| Funcionalidade | Descrição |
|----------------|-----------|
| **Taxonomia Cognitiva** | Classifica cada passo: Percepção, Análise, Julgamento, Empatia, etc. |
| **Tipos de Executor** | Atribui Human/Agent/Hybrid/Worker por passo |
| **Análise de Automação** | Aplica PV_PM_001 (frequência × impacto × guardrails) |
| **META-AXIOMAS** | Pontua processo em 10 dimensões de qualidade |
| **Blueprint de Squad** | Gera agents, tasks, checkpoints, workflow YAML |

### Padrões Utilizados

- **SC-PE-001** - Padrão de Extração de SOP (11 partes)
- **HO-TP-001** - Task Anatomy (8 campos obrigatórios)
- **HO-EP-001-004** - Tipos de Executor (Human/Agent/Hybrid/Worker)
- **PV_PM_001** - Heurística de Automation Tipping Point
- **SC-CK-001** - Checklist de Validação de SOP

### Pipeline: Transcrição → Squad

```
Gravação de Reunião
      ↓
  Transcrição (Supabase/Arquivo/API)
      ↓
  @squad-chief (*extract-sop)
      ↓
  Documento SOP (SC-PE-001)
      ↓
  Validação (SC-CK-001)
      ↓
  @squad-chief (*create-squad)
      ↓
  Squad Funcional
```

**Documentação completa:** Veja `docs/sop-extraction-process.md` para detalhes do processo.

---

## Exemplos de Uso

### 1. Criar um Squad Completo

```bash
# Ativar o agent squad architect
@squad-chief

# Iniciar workflow interativo de criação de squad
*create-squad

# Siga o processo de elicitação guiado
# O agent ajudará você a definir:
# - Domínio e propósito
# - Agents necessários e suas personas
# - Tasks e workflows
# - Templates de output
# - Documentação
```

### 2. Criar Componentes Individuais

```bash
# Criar agent standalone para squad existente
*create-agent

# Criar workflow de task
*create-task

# Criar template de output
*create-template
```

### 3. Validar um Squad

```bash
# Rodar validação completa
*validate-squad
```

## Estrutura de Squad Criado

O Squad Architect gera a seguinte estrutura:

```
squads/nome-do-seu-squad/
├── agents/                          # Agents específicos do domínio
│   └── seu-agent.md
├── checklists/                      # Checklists de validação
│   └── seu-checklist.md
├── config.yaml                      # Configuração do squad
├── data/                           # Knowledge bases
│   └── seu-kb.md
├── README.md                       # Documentação do squad
├── tasks/                          # Tasks de workflow
│   └── sua-task.md
└── templates/                      # Templates de output
    └── seu-template.yaml
```

## Funcionalidades Principais

### Elicitação Interativa

- Questionamento estruturado para coletar requisitos do domínio
- Modos de elicitação flexíveis (incremental vs. rápido)
- Opções de refinamento avançado para cada componente

### Geração Baseada em Templates

- Templates pré-construídos garantem consistência
- Placeholders customizáveis para conteúdo específico do domínio
- Melhores práticas embutidas em cada template

### Validação de Qualidade

- Checklist completo cobrindo todas as dimensões de qualidade
- Validação de segurança para todo código gerado
- Verificação de conformidade com padrões AIOX

### Automação de Documentação

- Arquivos README gerados automaticamente
- Exemplos de uso e guias de integração
- Documentação de melhores práticas

## Integração com AIOX Core

O Squad Architect integra perfeitamente com:

1. **AIOX Developer Agent** - Pode usar aiox-developer para modificações avançadas de componentes
2. **Core Workflows** - Squads gerados integram com workflows greenfield e brownfield
3. **Memory Layer** - Rastreia todos os squads e componentes criados
4. **Installer** - Squads gerados podem ser instalados via installer padrão

## Criando Seu Primeiro Squad

1. **Defina Seu Domínio**
   - Que expertise você está capturando?
   - Que problemas ele resolverá?
   - Quem é o usuário alvo?

2. **Identifique Agents Necessários**
   - Que papéis/personas são necessários?
   - Que conhecimento especializado cada um tem?
   - Como eles colaboram?

3. **Projete Workflows**
   - Quais são as tarefas comuns?
   - Quais são os inputs e outputs?
   - Que validações são necessárias?

4. **Crie Templates**
   - Que documentos/artefatos são produzidos?
   - Que estrutura devem seguir?
   - Que orientação está embutida?

5. **Deixe o Creator Guiar Você**
   - O squad architect irá elicitar todos os detalhes
   - Ele gerará todos os componentes automaticamente
   - Ele validará tudo contra os padrões

## 🏆 Produção Real: Squads Criados

O Squad Creator já produziu **squads reais em produção**. Estes são exemplos verificáveis do sistema em operação:

### Estatísticas do Ecossistema

| Métrica | Valor |
|---------|-------|
| **Total de Squads** | 31+ |
| **Total de Agents** | 206+ |
| **Minds Clonados** | 60+ |
| **Linhas de Código** | 100,000+ |

### Gold Standard: Squad Copy

O squad `copy` é a referência de qualidade máxima:

| Componente | Quantidade | Destaque |
|------------|------------|----------|
| **Agents** | 25 copywriters | Alex Hormozi (110KB), Ry Schwartz (2,207 linhas) |
| **Tasks** | 70+ | Workflows completos de criação de copy |
| **Workflows** | 13 | Mind cloning, validation, production |
| **Templates** | 12+ | Headlines, emails, sales pages |
| **Data** | 50+ | Swipe files, frameworks, heurísticas |
| **Total** | 32,049 linhas | Maior squad do ecossistema |

### Exemplos de Squads em Produção

O AIOX Pro possui 31+ squads em produção, incluindo:

| Squad | Agents | Destaque |
|-------|--------|----------|
| **copy** | 25 copywriters | Gold Standard - Alex Hormozi, Gary Halbert, Dan Kennedy |
| **storytelling** | 10+ | Joseph Campbell, Kindra Hall, Nancy Duarte |
| **brand** | 12+ | Brand strategy, positioning, naming |
| **traffic-masters** | 10+ | Meta Ads, Google Ads, YouTube |
| **deep-research** | 8+ | Systematic reviews, evidence synthesis |

> Estes squads foram criados usando o squad-creator e estão disponíveis no AIOX Pro (Cohort Avançado).

### Exemplo de Agent Real: Alex Hormozi

```yaml
# Extraído do mind real, não template
agent:
  name: Alex Hormozi
  id: alex-hormozi
  title: $100M Offers Expert
  icon: 💰

voice_dna:
  vocabulary:
    always_use:
      - "stack the value"
      - "create asymmetric risk"
      - "Grand Slam Offer"
      - "dream outcome"
      - "perceived likelihood"
      - "time delay"
      - "effort and sacrifice"
    never_use:
      - "maybe"
      - "hopefully"
      - "I think"

thinking_dna:
  core_frameworks:
    - name: Value Equation
      formula: "Value = (Dream Outcome × Perceived Likelihood) / (Time Delay × Effort)"
    - name: Grand Slam Offer
      components: ["Dream Outcome", "Perception of Achievement", "Time", "Effort"]

output_examples:
  - input: "Como precificar meu curso?"
    output: |
      Primeiro, vamos aplicar a Value Equation...
      [continua com 50+ linhas de resposta real]
```

### Por Que Isso Importa

1. **Evidência Real** - Não são exemplos teóricos, são squads em uso
2. **Escala Comprovada** - 31 squads, 206 agents demonstram capacidade
3. **Qualidade Verificável** - Compare qualquer squad contra templates
4. **Reference Implementation** - Use `copy` como modelo para novos squads

---

## Exemplos por Domínio

Este creator pode gerar squads para qualquer domínio:

**Serviços Profissionais**
- Squad de Assistente Jurídico
- Squad de Contabilidade & Finanças
- Squad de Imobiliário
- Squad de Prática de Saúde

**Criativo & Conteúdo**
- Squad de Marketing de Conteúdo
- Squad de Produção de Vídeo
- Squad de Criação de Podcast
- Squad de Escrita Criativa

**Educação & Treinamento**
- Squad de Design Curricular
- Squad de Treinamento Corporativo
- Squad de Criação de Curso Online

**Pessoal & Estilo de Vida**
- Squad de Desenvolvimento Pessoal
- Squad de Fitness & Nutrição
- Squad de Organização Doméstica
- Squad de Planejamento de Viagem

## Melhores Práticas

1. **Comece Pequeno** - Inicie com um agent e algumas tasks
2. **Teste Completamente** - Valide com cenários do mundo real
3. **Itere** - Refine baseado em feedback do usuário
4. **Documente Bem** - Documentação clara garante adoção
5. **Compartilhe** - Contribua seu squad para a comunidade

## Customização

Você pode customizar squads gerados por:

1. Modificar as personas dos agents gerados
2. Adicionar tasks customizadas para workflows específicos
3. Criar templates específicos do domínio
4. Adicionar checklists de validação para sua indústria
5. Estender com knowledge bases especializadas

## Dependências

Este squad requer:

- Framework AIOX-FULLSTACK core
- AIOX Developer agent (opcional, para modificações avançadas)
- Entendimento básico da sua expertise de domínio

## Suporte & Comunidade

- **Documentação**: Veja a pasta `docs/` para guias detalhados
- **Exemplos**: Navegue `squads/` para implementações de referência
- **Issues**: Reporte problemas via GitHub issues
- **Contribuições**: Envie PRs com melhorias

## Troubleshooting

### Problemas Comuns

#### Agent Não Ativa

**Sintoma:** `@squad-chief` não responde ou mostra erro

**Soluções:**
1. Verifique se o arquivo do agent existe: `ls squads/squad-creator/agents/squad-chief.md`
2. Cheque sintaxe YAML: Garanta que o bloco YAML está formatado corretamente
3. Verifique se o squad está sincronizado: Cheque se `.claude/agents/squad-creator/` existe

---

#### Loop de Research Não Inicia [PRO]

**Sintoma:** Ao solicitar um squad, agent faz perguntas ao invés de pesquisar automaticamente

**Nota:** Pesquisa automática (mind-research-loop) é uma funcionalidade do AIOX Pro. No modo base, o agent coleta informações do domínio através de perguntas estruturadas.

**Solução (com Pro):**
1. Diga explicitamente: "Inicie o mind-research-loop agora"
2. Ou reinicie: `*exit` então reative `@squad-chief`

---

#### Quality Gate de Agent Falha (SC_AGT_001)

**Sintoma:** Agent criado falha validação de qualidade

**Causas Comuns:**
| Problema | Correção |
|----------|----------|
| Lines < 300 | Expandir voice_dna, adicionar mais output_examples |
| voice_dna faltando | Adicionar vocabulary.always_use (8+) e never_use (5+) |
| output_examples < 3 | Adicionar exemplos realistas input→output |
| completion_criteria faltando | Definir critérios para cada tipo de task |
| handoff_to faltando | Definir 3+ cenários de handoff |

**Referência:** `checklists/agent-quality-gate.md`

---

#### Arquivos de Task Não Encontrados

**Sintoma:** Agent não encontra arquivo de task ao executar comando

**Soluções:**
1. Verifique se arquivo existe: `ls squads/squad-creator/tasks/`
2. Cheque se nome do arquivo corresponde à referência de dependência no YAML do agent
3. Garanta que extensão do arquivo é `.md`

---

#### Extração de SOP Incompleta

**Sintoma:** SOP extraído com partes faltando

**Solução:** Valide contra SC-PE-001 (11 partes obrigatórias):
1. Propósito
2. Escopo
3. Pré-condições
4. Passos
5. Regras de Decisão
6. Exceções
7. Outputs
8. Validação
9. Escalação
10. Auditoria
11. Histórico de Revisão

**Referência:** `checklists/sop-validation.md` [PRO]

---

### Obtendo Ajuda

1. Execute `*help` para ver comandos disponíveis
2. Verifique pasta `docs/` para documentação detalhada
3. Revise `checklists/` para critérios de validação
4. Consulte `data/squad-kb.md` para melhores práticas

## Histórico de Versões

- **v3.0.0** - **Mental Model Integration**: 46 decision checkpoints em 10 tasks forçam consulta a VALUES/OBSESSIONS/MODELS/PARADOXES antes de decisões. Matrix + checklist + 4/4 smoke tests PASS
- **v2.8.0** - Test suite completa (6 scripts Python), documentação de outputs reais (31 squads, 206 agents)
- **v2.7.0** - Tier 0 Agent (squad-diagnostician) para triagem/routing + Testes automatizados Python (pytest)
- **v2.6.0** - Deep Tool Discovery com TIERS RELATIVOS (percentis), FLAGS em vez de VETOs, sem thresholds absolutos
- **v2.5.0** - RICE/WSJF frameworks, Security Gate, Social Proof Gate (substituídos por tiers relativos em v2.6)
- **v2.4.0** - Deep Tool Discovery com 5 sub-agentes paralelos, Decision Matrix, Integration Plan
- **v2.2.0** - Agentes especialistas: `@oalanicolas` (mind cloning) e `@pedro-valerio` (process design) com DNA extraído de pessoas reais
- **v2.1.0** - Self-Awareness completo: Squad Architect agora conhece todas suas capacidades, comandos, workflows, tasks e referências de qualidade
- **v2.0.0** - Mind Cloning com Voice DNA + Thinking DNA, Smoke Tests, Quality Dashboard
- **v1.1.0** - Sistema de validação granular (`*validate-squad`, `*validate-agent`, etc.)
- **v1.0.0** - Release inicial com workflow completo de criação de squad

Veja `CHANGELOG.md` para histórico detalhado de versões.

## Notas

- Squads gerados seguem padrões AIOX-FULLSTACK automaticamente
- Todos os componentes incluem validação e checks de segurança embutidos
- O creator usa elicitação interativa para garantir qualidade
- Documentação gerada inclui exemplos de uso e guias de integração

---

**Pronto para democratizar sua expertise? Vamos criar um squad!**

---

## Índice de Documentação

```
docs/
├── POR-ONDE-COMECAR.md      # Guia inicial
├── FAQ.md                   # Perguntas frequentes
├── TUTORIAL-COMPLETO.md     # Tutorial hands-on
├── QUICK-START.md           # Tutorial de 5 minutos
├── CONCEPTS.md              # Conceitos fundamentais
├── AGENT-COLLABORATION.md   # Como os 3 agentes colaboram (v3.0)
├── COMMANDS.md              # Referência de comandos
├── TROUBLESHOOTING.md       # Problemas e soluções
├── ARCHITECTURE-DIAGRAMS.md # Diagramas Mermaid
├── HITL-FLOW.md             # Human-in-the-Loop
├── squad-chief-agent-flow.md # Fluxo detalhado do squad-chief
└── sop-extraction-process.md # Processo de extração SOP
```

---

_Versão: 4.0.0_
_Compatível com: AIOX v5+_
_Última Atualização: 2026-03-06_
