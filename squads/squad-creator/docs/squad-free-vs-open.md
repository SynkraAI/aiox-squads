# Squad Creator: Free vs Pro

> Comparativo completo entre o **Squad Creator Base (Free)** e o **Squad Creator Pro (Upgrade Pack)**.

## TL;DR

| | **Free (Base)** | **Pro (Upgrade Pack)** |
|---|---|---|
| **Versao** | 4.0.0 | 3.1.0 |
| **Tipo** | Squad standalone | Upgrade pack (enhances base) |
| **Agents** | 1 | 3 (+3 especialistas) |
| **Tasks** | 24 | 34 |
| **Workflows** | 3 | 18 (15 + 3 modules) |
| **Checklists** | 9 | 7 |
| **Data files** | 10 | 22 |
| **Config files** | 2 | 7 |
| **Scripts** | 21 | 42 |
| **Test cases** | 0 | 17 |
| **Minds clonadas** | 0 | 2 |
| **Benchmarks** | 0 | Golden + runs |
| **Total de arquivos** | ~116 | ~200+ |

---

## 1. Arquitetura

### Free: Monolito Template-Driven

```
squads/squad-creator/
  agents/       → 1 agent (squad-chief)
  tasks/        → 24 tasks atomicas
  workflows/    → 3 workflows
  templates/    → 21 templates
  checklists/   → 9 checklists
  data/         → 10 frameworks/referencias
  config/       → 2 configs
  scripts/      → 21 scripts
  protocols/    → 1 (ai-first-governance)
  docs/         → 24 docs
```

- **Modelo:** Squad-chief faz tudo — triage, criacao, validacao.
- **Fonte de conhecimento:** User responde perguntas estruturadas (max 3).
- **Templates como fundacao:** Nenhum arquivo e escrito sem carregar template primeiro.
- **Validacao:** Structural completeness + quality gates basicos.

### Pro: Multi-Agent com Specialist Delegation

```
squads/squad-creator-pro/
  agents/       → 3 specialists
  tasks/        → 34 tasks avancadas
  workflows/    → 15 workflows + 3 modules
  checklists/   → 7 checklists avancados
  data/         → 22 data files (inclui anchor words, axiomas, signals)
  config/       → 7 configs (routing, scoring, veto, axiomas)
  scripts/      → 42 scripts (inclui cross-provider, tests)
  minds/        → 2 minds clonadas (oalanicolas, pedro_valerio)
  benchmarks/   → Golden baselines + runs
  test-cases/   → 17 test case directories
  assessments/  → Axioma assessments
  skills/       → squad.md
```

- **Modelo:** Squad-chief delega para especialistas (@oalanicolas, @pedro-valerio, @thiago_finch).
- **Fonte de conhecimento:** Pesquisa automatizada (YouTube, podcasts, artigos) + DNA extraction.
- **Auto-deteccao:** Base detecta Pro automaticamente via `squads/squad-creator-pro/config.yaml`.
- **Degradacao limpa:** Remover o diretorio pro degrada para base-only sem quebrar nada.

---

## 2. Agents

### Free

| Agent | Role | Tipo |
|-------|------|------|
| **squad-chief** | Squad Architect & Domain Knowledge Engineer | Orchestrator (Tier 0) |

O squad-chief acumula todas as funcoes: triage, routing, criacao, validacao, analytics.

### Pro (adiciona 3 especialistas)

| Agent | Role | Especialidade |
|-------|------|---------------|
| **oalanicolas** | Knowledge Architect | DNA extraction, source classification, mind cloning |
| **pedro-valerio** | Process Absolutist & Automation Architect | Axioma assessment, audit, modernization scoring |
| **thiago_finch** | Business Strategy & Marketing Architect | Strategy, positioning, market intelligence |

**Delegacao no Pro:**
- squad-chief identifica a necessidade e delega para o especialista adequado.
- Cada especialista tem heuristics, handoffs e veto conditions proprios.
- Resultados voltam ao squad-chief para integracao no squad final.

---

## 3. Tasks

### Free — 24 Tasks

#### Criacao (8)
| Task | Descricao |
|------|-----------|
| create-squad.md | Criar squad completo via workflow guiado |
| create-agent.md | Criar agent individual |
| create-workflow.md | Criar workflow multi-fase |
| create-task.md | Criar task atomica |
| create-template.md | Criar template de output |
| create-pipeline.md | Scaffold de pipeline (state, progress, runner) |
| create-documentation.md | Gerar documentacao do squad |
| detect-squad-context.md | Detectar contexto (greenfield/brownfield) |

#### Validacao (3)
| Task | Descricao |
|------|-----------|
| validate-squad.md | Validar squad completo |
| validate-final-artifacts.md | Validar apenas artefatos finais |
| qa-after-creation.md | QA pos-criacao |

#### Manutencao & Discovery (4)
| Task | Descricao |
|------|-----------|
| discover-tools.md | Discovery de ferramentas com validacao canonical |
| upgrade-squad.md | Upgrade de squad existente |
| reexecute-squad-phase.md | Reexecutar fase de workflow |
| next-squad.md | Recomendar proximo squad a criar |

#### Operacional (4)
| Task | Descricao |
|------|-----------|
| detect-operational-mode.md | Detectar modo operacional vs expert |
| setup-runtime.md | Setup de runtime |
| auto-heal.md | Auto-recuperacao |
| operational-test.md | Teste operacional |

#### Utilidades (5)
| Task | Descricao |
|------|-----------|
| refresh-registry.md | Atualizar ecosystem-registry.yaml |
| squad-analytics.md | Dashboard de analytics |
| squad-overview.md | Gerar SQUAD-OVERVIEW.md |
| sync-ide-command.md | Sincronizar comandos para IDE |
| install-commands.md | Instalar comandos |

### Pro — 34 Tasks (exclusivas)

#### Mind Cloning & DNA (16)
| Task | Descricao |
|------|-----------|
| collect-sources.md | Coletar fontes para mind cloning |
| extract-voice-dna.md | Extrair estilo de comunicacao |
| extract-thinking-dna.md | Extrair frameworks/heuristicas |
| extract-knowledge.md | Extrair conhecimento especializado |
| extract-implicit.md | Extrair conhecimento implicito |
| extract-sop.md | Extrair SOPs (Standard Operating Procedures) |
| validate-extraction.md | Validar resultado de extracao |
| update-mind.md | Atualizar DNA existente com novas fontes |
| an-extract-dna.md | Extracao avancada de DNA |
| an-fidelity-score.md | Score de fidelidade do clone |
| an-validate-clone.md | Validar clone contra original |
| an-clone-review.md | Review completo de clone |
| an-design-clone.md | Design de clone |
| an-diagnose-clone.md | Diagnosticar problemas de clone |
| an-assess-sources.md | Avaliar qualidade de fontes |
| an-extract-framework.md | Extrair framework documentado |

#### Research (3)
| Task | Descricao |
|------|-----------|
| an-compare-outputs.md | Comparar outputs entre versoes |
| deep-research-pre-agent.md | Pesquisa profunda pre-criacao |
| auto-acquire-sources.md | Aquisicao automatica de fontes |

#### Criacao Avancada (3)
| Task | Descricao |
|------|-----------|
| parallel-discovery.md | Discovery paralelo |
| squad-fusion.md | Fusao de squads |
| deconstruct.md | Desconstruir squad existente |

#### Otimizacao (3)
| Task | Descricao |
|------|-----------|
| optimize.md | Otimizar squad/task (Worker vs Agent) |
| optimize-workflow.md | Otimizar workflow em 6 dimensoes |
| find-0.8.md | Encontrar o "80% bom o suficiente" |

#### Model Routing (3)
| Task | Descricao |
|------|-----------|
| qualify-task.md | Qualificar complexidade de task |
| lookup-model.md | Selecionar modelo ideal |
| smoke-test-model-routing.md | Testar model routing |

#### Quality Avancada (4)
| Task | Descricao |
|------|-----------|
| pv-axioma-assessment.md | Avaliacao por 10 meta-axiomas |
| pv-audit.md | Auditoria completa |
| pv-modernization-score.md | Score de modernizacao |
| workspace-integration-hardening.md | Hardening de integracao workspace |

#### Manutencao Pro (2)
| Task | Descricao |
|------|-----------|
| sync-chief-codex-skill.md | Sync skill do chief |
| migrate-workflows-to-yaml.md | Migrar workflows para YAML |

---

## 4. Workflows

### Free — 3 Workflows

| Workflow | Descricao |
|----------|-----------|
| create-squad.yaml | Criacao basica de squad |
| validate-squad.yaml | Validacao basica de squad |
| wf-create-squad.yaml | Orquestracao master (compartilhado com pro override) |

### Pro — 18 Workflows (15 + 3 modules)

| Workflow | Feature | Descricao |
|----------|---------|-----------|
| wf-clone-mind.yaml | Mind Cloning | Clonagem completa (Voice + Thinking DNA) |
| wf-extraction-pipeline.yaml | Mind Cloning | Pipeline de extracao multi-fase |
| wf-mind-research-loop.yaml | Research | Loop de pesquisa iterativa |
| wf-research-then-create-agent.yaml | Research | Pesquisar antes de criar agent |
| wf-auto-acquire-sources.yaml | Research | Aquisicao automatica de fontes |
| wf-create-squad.yaml | Creation | Criacao avancada (override do base) |
| wf-context-aware-create-squad.yaml | Creation | Criacao com deteccao de contexto |
| wf-discover-tools.yaml | Creation | Discovery avancado de ferramentas |
| wf-squad-fusion.yaml | Creation | Fusao de squads |
| wf-brownfield-upgrade-squad.yaml | Creation | Upgrade brownfield seguro |
| wf-optimize-squad.yaml | Optimization | Otimizacao via axioma assessment |
| wf-model-tier-qualification.yaml | Model Routing | Qualificacao por tier de modelo |
| wf-cross-provider-qualification.yaml | Model Routing | Qualificacao cross-provider |
| validate-squad.yaml | Quality | Validacao avancada (override do base) |
| wf-workspace-integration-hardening.yaml | Quality | Hardening de integracao |

#### Modules (composable)
| Module | Descricao |
|--------|-----------|
| module-discovery.yaml | Modulo reutilizavel de discovery |
| module-integration.yaml | Modulo reutilizavel de integracao |
| module-quality-gates.yaml | Modulo reutilizavel de quality gates |

---

## 5. Comandos

### Free — Comandos Base

```
CREATION
  *create-squad        *create-agent         *create-workflow
  *create-task         *create-template      *create-pipeline

TOOL DISCOVERY
  *discover-tools      *show-tools           *add-tool

UPGRADE & MAINTENANCE
  *upgrade-squad

VALIDATION
  *validate-squad      *validate-final-artifacts
  *validate-agent      *validate-task         *validate-workflow
  *validate-template   *validate-checklist

RECOVERY
  *reexecute-phase

PLANNING
  *next-squad

ANALYTICS & UTILITIES
  *guide               *squad-overview        *list-squads
  *show-registry       *squad-analytics       *refresh-registry
  *sync                *show-context          *chat-mode
  *help                *exit
```

### Pro — Comandos Exclusivos (adicionados ao base)

```
ADVANCED FEATURES [PRO]
  *create-squad-smart       Criacao com deteccao de contexto (greenfield/resume)
  *brownfield-upgrade       Upgrade seguro de squad existente
  *clone-mind               Clonagem completa (Voice + Thinking DNA)
  *extract-voice-dna        Extracao de estilo de comunicacao
  *extract-thinking-dna     Extracao de frameworks/heuristicas
  *update-mind              Atualizar DNA com novas fontes
  *auto-acquire-sources     Aquisicao automatica de fontes
  *quality-dashboard        Dashboard de metricas de qualidade
  *review-extraction        Review de output antes da proxima fase
  *review-artifacts         Review de artefatos antes de finalizar
  *optimize                 Otimizacao (Worker vs Agent) + economia
  *optimize-workflow        Otimizacao em 6 dimensoes
```

---

## 6. Quality & Validation

### Free

| Dimensao | Abordagem |
|----------|-----------|
| **Structural completeness** | 9-point checklist (config, entry_agent, tested flag, etc.) |
| **Agent quality gate** | SC_AGT_001: smoke tests, heuristics com WHEN, handoffs, output examples |
| **Task anatomy** | 8 campos obrigatorios |
| **Workflow checkpoints** | Checkpoints por fase, fluxo unidirecional |

**Checklists (9):**
agent-quality-gate, create-agent-checklist, create-squad-checklist, create-workflow-checklist, smoke-test-agent, squad-checklist, squad-overview-checklist, squad-structural-completeness, task-anatomy-checklist

### Pro

| Dimensao | Abordagem |
|----------|-----------|
| **Axioma assessment** | 10 meta-axiomas de Pedro Valerio (score ponderado + PASS/FAIL) |
| **Fidelity scoring** | Score de fidelidade do clone vs original |
| **Modernization score** | Score de modernizacao do squad |
| **Model tier qualification** | Qualificacao cross-provider por complexidade |
| **Veto conditions** | 7 configs de veto (axioma-validator, quality-gates, scoring-rubric, etc.) |
| **Workspace integration** | Hardening de contratos de integracao |

**Checklists (7):**
agent-depth-checklist, deep-research-quality, executor-matrix-checklist, mental-model-integration-checklist, mind-validation, quality-gate-checklist, sop-validation

**Config de qualidade (7):**
axioma-validator.yaml, heuristics.yaml, model-routing.yaml, quality-gates.yaml, scoring-rubric.yaml, task-anatomy.yaml, veto-conditions.yaml

---

## 7. Data & Knowledge Base

### Free — 10 Frameworks

| Arquivo | Proposito |
|---------|-----------|
| best-practices.md | Best practices gerais |
| decision-heuristics-framework.md | Framework de heuristicas de decisao |
| executor-decision-tree.md | Arvore de decisao de executor |
| executor-matrix-framework.md | Matriz de executores |
| pipeline-patterns.md | Padroes de pipeline |
| quality-dimensions-framework.md | Dimensoes de qualidade |
| squad-analytics-guide.md | Guia de analytics |
| squad-kb.md | Knowledge base do squad |
| squad-type-definitions.yaml | Definicoes de tipos de squad |
| tier-system-framework.md | Sistema de tiers |

### Pro — 22 Data Files

Inclui tudo acima mais:

| Arquivo | Proposito |
|---------|-----------|
| an-anchor-words.yaml | Palavras-ancora para fidelidade |
| an-clone-anti-patterns.yaml | Anti-patterns de clonagem |
| an-clone-validation.yaml | Regras de validacao de clone |
| an-diagnostic-framework.yaml | Framework de diagnostico |
| an-output-examples.yaml | Exemplos de output |
| an-source-signals.yaml | Sinais de qualidade de fonte |
| an-source-tiers.yaml | Classificacao de fontes por tier |
| core-heuristics.md | Heuristicas core |
| extraction-mentoria-processos-dec19.yaml | Dados de extracao de mentoria |
| fusion-decision-points-analysis.md | Analise de pontos de decisao de fusao |
| fusion-executor-analysis.md | Analise de executores de fusao |
| hybridops-patterns.md | Padroes HybridOps |
| internal-infrastructure-library.yaml | Biblioteca de infraestrutura interna |
| mental-model-task-matrix.yaml | Matriz modelo mental x task |
| pm-best-practices.md | Best practices de PM |
| pv-anchor-words.yaml | Palavras-ancora PV |
| pv-authenticity-markers.yaml | Marcadores de autenticidade PV |
| pv-meta-axiomas.yaml | 10 meta-axiomas PV |
| pv-output-examples.yaml | Exemplos de output PV |
| pv-workflow-validation.yaml | Validacao de workflow PV |
| tool-evaluation-framework.md | Framework de avaliacao de ferramentas |
| tool-registry.yaml | Registro de ferramentas |

---

## 8. Minds (Pro Exclusive)

O Pro inclui **2 minds clonadas** completas com heuristics e artifacts:

### oalanicolas (Knowledge Architect)
- **10 heuristics** (AN_KE_001 a AN_KE_010)
- **Artifacts:** HANDOFF_PROTOCOL.md, SOURCE_CLASSIFICATION.md
- Especialidade: DNA extraction, source classification, knowledge architecture

### pedro_valerio (Process Absolutist)
- **3 heuristics** (PV_BS_001, PV_PA_001, PV_PM_001)
- **Artifacts:** Assinatura_Linguistica.md, META_AXIOMAS.md
- Especialidade: Axioma assessment, process validation, modernization

---

## 9. Scripts & Automation

### Free — 21 Scripts

| Tipo | Scripts |
|------|---------|
| **Python** | checklist_validator, coherence-validator, dependency_check, inventory, naming_validator, refresh-registry, scoring, security_scanner, squad_utils, squad-analytics, sync-ide-command, validate-squad-structure, yaml_validator |
| **JavaScript** | generate-squad-greeting.js, generate-squad-guide.js, scaffold-squad.cjs |
| **Bash** | validate-all.sh, validate-squad.sh, verify-squad-completeness.sh |
| **Lib** | config-loader.js |

### Pro — 42 Scripts

| Tipo | Scripts |
|------|---------|
| **Python** | coherence-validator, create-agent-preflight, on-specialist-complete, quality_gate, save-session-metrics, scoring, validate-agent-output, validate-workspace-contract |
| **JavaScript/CJS** | model-tier-validator.cjs, model-usage-logger.cjs, squad-context-loader.cjs, squad-state-manager.cjs, squad-workflow-runner.cjs, sync-chief-codex-skill.js |
| **Bash** | assess-sources.sh, clone-review.sh, fidelity-score.sh, modernization-score.sh, validate-clone.sh, validate-squad.sh |
| **Cross-Provider** | compare-results.js, cross-provider-runner.js |
| **Tests** | 13 Python tests + 6 Bash tests = **19 test scripts** |

---

## 10. Templates

### Free — 21 Templates

| Template | Proposito |
|----------|-----------|
| config-tmpl.yaml | Estrutura de config.yaml |
| agent-tmpl.md | Estrutura de agent |
| readme-tmpl.md | Estrutura de README |
| task-tmpl.md | Estrutura de task |
| workflow-tmpl.yaml | Estrutura de workflow |
| template-tmpl.yaml | Meta-template |
| orchestrator-tmpl.md | Template de orchestrator |
| quality-dashboard-tmpl.md | Dashboard de qualidade |
| quality-gate-tmpl.yaml | Quality gate |
| pipeline-state-tmpl.py | State de pipeline |
| pipeline-progress-tmpl.py | Progress de pipeline |
| pipeline-runner-tmpl.py | Runner de pipeline |
| agent-flow-doc-tmpl.md | Documentacao de flow |
| handoff-insumos-tmpl.yaml | Handoff de insumos |
| pop-extractor-prompt.md | Prompt de extracao POP |
| research-output-tmpl.md | Output de research |
| research-prompt-tmpl.md | Prompt de research |
| squad-prd-tmpl.md | PRD de squad |
| squad-readme-tmpl.md | README de squad |
| story-create-agent-tmpl.md | Story de criacao de agent |
| workflow-doc-tmpl.md | Documentacao de workflow |

### Pro — Sem diretorio dedicado

O Pro nao tem diretorio `templates/` proprio. Reutiliza os templates do base e adiciona estrutura via:
- Workflow definitions (inline templates)
- Test case template (`test-cases/_template.yaml`)
- Mind artifacts como templates de referencia

---

## 11. Fluxo de Criacao Comparado

### Free: Template-Driven + User Input

```
User pede squad
  → squad-chief faz triage (tipo? operacional/expert?)
  → 3 perguntas ao user (experts, tasks, frameworks)
  → Carrega templates (config, agent, readme)
  → Cria agents preenchendo templates com input do user
  → Quality gate SC_AGT_001 por agent
  → validate-squad
  → refresh-registry
  → sync-ide-command
```

### Pro: Research-Driven + Specialist Delegation

```
User pede squad
  → squad-chief faz triage + detecta contexto (greenfield/resume)
  → Delega para @oalanicolas (DNA extraction)
    → auto-acquire-sources (YouTube, podcasts, artigos)
    → extract-voice-dna + extract-thinking-dna
    → an-fidelity-score (validacao de fidelidade)
  → Delega para @pedro-valerio (quality)
    → pv-axioma-assessment (10 dimensoes)
    → optimize (Worker vs Agent routing)
  → Delega para @thiago_finch (strategy)
    → Posicionamento, market intelligence
  → squad-chief integra tudo
    → Cria squad com DNA extraction
    → validate-squad (versao pro com axiomas)
    → Model routing (economia 60-70% tokens)
```

---

## 12. Model Routing (Pro Exclusive)

| Conceito | Descricao |
|----------|-----------|
| **Task qualification** | Cada task e classificada por complexidade |
| **Tier mapping** | Complexidade mapeia para tier de modelo (haiku/sonnet/opus) |
| **Cross-provider** | Suporte a multiplos providers (Anthropic, OpenRouter) |
| **Economia** | 60-70% reducao de custo via routing inteligente |

### Configs de Routing
- `model-routing.yaml` — Regras de roteamento
- `scoring-rubric.yaml` — Rubrica de scoring
- `task-anatomy.yaml` — Anatomia de task para qualificacao

---

## 13. Testing & Benchmarks (Pro Exclusive)

### Test Cases (17 directories)
```
an-assess-sources/     an-clone-review/      an-design-clone/
an-extract-dna/        an-fidelity-score/    an-validate-clone/
collect-sources/       create-task/          cross-provider/
pv-audit/              pv-axioma-assessment/ pv-modernization-score/
qa-after-creation/     smoke-test-model-routing/
upgrade-squad/         validate-squad/       wf-clone-mind/
```

### Benchmarks
- **Golden baseline:** hormozi-golden.yaml (squad referencia de qualidade)
- **Runs:** Execucoes timestamped para tracking de regressao

### Test Scripts (19)
- 13 Python tests (pytest) cobrindo validators, scoring, analytics
- 6 Bash tests cobrindo assess-sources, clone-review, fidelity-score

---

## 14. Quando Usar Cada Um

| Cenario | Free | Pro |
|---------|------|-----|
| Squad operacional/utility simples | Ideal | Overkill |
| Squad baseado em dominio tecnico | Bom (user provem conhecimento) | Melhor (pesquisa automatizada) |
| Squad baseado em expert real | Limitado (input manual) | Ideal (DNA extraction) |
| Clonar mente de especialista | Nao disponivel | Core feature |
| Otimizar custos de tokens | Nao disponivel | Model routing |
| Validacao profunda (axiomas) | Basica | Completa |
| Primeiro squad do ecosistema | Ideal | Nao necessario |
| Squad de elite/producao | Possivel | Recomendado |
| Upgrade de squad legado | Disponivel (basico) | Disponivel (brownfield seguro) |
| Fusao de squads | Nao disponivel | Disponivel |

---

## 15. Instalacao & Ativacao

### Free
Ja incluido no AIOX core. Ativar com:
```
/squad-creator
```

### Pro
Auto-detectado quando o diretorio existe:
```
squads/squad-creator-pro/config.yaml → PRO_DETECTED
```

**Degradacao limpa:** Remover `squads/squad-creator-pro/` volta ao modo base sem quebrar nada.

**Requisito:** Base >= 4.0.0

---

## 16. Resumo de Capacidades

```
                          FREE              PRO
                          ----              ---
Template-driven           SIM               SIM (herda do base)
User elicitation          SIM (3 perguntas) SIM + research automatizado
Specialist delegation     NAO               SIM (3 agents)
Mind cloning              NAO               SIM (Voice + Thinking DNA)
Source auto-acquisition   NAO               SIM (YouTube, podcasts, artigos)
Model routing             NAO               SIM (60-70% economia)
Axioma assessment         NAO               SIM (10 dimensoes PV)
Cross-provider            NAO               SIM
Benchmarks & golden       NAO               SIM
Test suite                NAO               SIM (19 test scripts)
Workflow modules          NAO               SIM (composable)
Squad fusion              NAO               SIM
Brownfield upgrade        BASICO            AVANCADO (seguro)
```

---

*Documento gerado em 2026-03-06. Versao base: 4.0.0, versao pro: 3.1.0.*
