# Colaboracao Entre Agentes

> **Documento de referencia** para entender como os agentes do Squad Creator trabalham juntos.
>
> **Versao:** 4.0.0 | **Atualizado:** 2026-03-06

> **Base vs Pro:** A colaboracao multi-agente descrita neste documento
> requer o **AIOX Pro** (squad-creator-pro). No modo base, o @squad-chief
> opera sozinho usando templates e domain knowledge do usuario.

---

## Visao Geral da Arquitetura v4.0

O Squad Creator v4.0 opera em dois modos:

- **Base mode:** 1 agente (@squad-chief) opera sozinho com templates
- **Pro mode:** 4 agentes especializados trabalham em sinergia

```
+-------------------------------------------------------------------------+
|                    SQUAD CREATOR v4.0 ARCHITECTURE                       |
+-------------------------------------------------------------------------+
|                                                                          |
|  BASE MODE:                                                              |
|                                                                          |
|                        +---------------------+                           |
|                        |   @squad-chief      |                           |
|                        |   (Solo Operator)   |                           |
|                        |                     |                           |
|                        | * Template-driven   |                           |
|                        | * Domain knowledge  |                           |
|                        | * All phases        |                           |
|                        +---------------------+                           |
|                                                                          |
+-------------------------------------------------------------------------+
|                                                                          |
|  PRO MODE (squad-creator-pro installed):                                 |
|                                                                          |
|                        +---------------------+                           |
|                        |   @squad-chief      |                           |
|                        |   (Orchestrator)    |                           |
|                        |                     |                           |
|                        | * Ponto de entrada  |                           |
|                        | * Triagem/Routing   |                           |
|                        | * Criacao de squads |                           |
|                        | * Validacao final   |                           |
|                        +----------+----------+                           |
|                                   |                                      |
|                    +--------------+--------------+                       |
|                    |              |              |                       |
|                    v              v              v                       |
|         +---------------+ +---------------+ +---------------+            |
|         | @oalanicolas  | | @pedro-valerio| | @thiago_finch |            |
|         |   [PRO]       | |    [PRO]      | |    [PRO]      |            |
|         |               | |               | |               |            |
|         | Mind Cloning  | | Process Design| | Performance   |            |
|         | DNA Extraction| | Veto Conds    | | Model Routing |            |
|         | Source Curation| | Workflow Audit| | Optimization  |            |
|         | Fidelity Check| | Artifact Build| |               |            |
|         +---------------+ +---------------+ +---------------+            |
|                                                                          |
+-------------------------------------------------------------------------+
```

---

## Base Mode: squad-chief Solo

No modo Base, o @squad-chief lida com **todas as fases** da criacao de squads
sozinho. Nao existe delegacao para outros agentes, handoffs ou protocolos
INSUMOS_READY/ARTIFACTS_READY.

### Principios do Modo Base

```yaml
base_mode_principles:
  single_agent: "@squad-chief handles everything"
  foundation: "Templates are mandatory for all components"
  domain_knowledge: "User provides (3 questions max) + web research"
  handoffs: "None -- no multi-agent coordination"
  validation: "Consistency chain (template -> structural -> QA -> validate)"
```

### Fluxo Base: Criar Squad

```
+-------------------------------------------------------------------------+
|                    FLUXO BASE: *create-squad {domain}                    |
+-------------------------------------------------------------------------+
|                                                                          |
|  FASE 0: DISCOVERY (squad-chief)                                         |
|  +-- Recebe request do usuario                                          |
|  +-- Verifica squads existentes (squad-registry)                        |
|  +-- Pergunta modo (incremental ou yolo)                                |
|  +-- Coleta domain knowledge do usuario (max 3 perguntas)               |
|                                                                          |
|  FASE 1: TEMPLATE SELECTION (squad-chief)                                |
|  +-- Read(data/squad-type-definitions.yaml)                             |
|  +-- Seleciona tipo de squad (operational vs expert_template)           |
|  +-- Mapeia use cases para roles de agentes                             |
|                                                                          |
|  FASE 2: ARCHITECTURE (squad-chief)                                      |
|  +-- Define tier structure usando tier-system-framework                 |
|  +-- Planeja relacionamentos entre agents                               |
|  +-- Define quality gates                                                |
|                                                                          |
|  FASE 3: CREATION (squad-chief)                                          |
|  +-- Read(templates/agent-tmpl.md)       <- OBRIGATORIO                 |
|  +-- Research domain via WebSearch                                      |
|  +-- Cria agents preenchendo template                                   |
|  +-- Read(templates/config-tmpl.yaml)    <- OBRIGATORIO                 |
|  +-- Cria config.yaml a partir do template                              |
|  +-- Cria tasks, workflows, checklists                                  |
|                                                                          |
|  FASE 4: INTEGRATION (squad-chief)                                       |
|  +-- Wire dependencies                                                  |
|  +-- Read(templates/readme-tmpl.md)      <- OBRIGATORIO                 |
|  +-- Gera README.md a partir do template                                |
|  +-- Publica chief activation (command + codex skill)                   |
|                                                                          |
|  FASE 5: VALIDATION (squad-chief)                                        |
|  +-- Consistency chain completa:                                        |
|  |   Step 1: Template enforcement                                       |
|  |   Step 2: Structural completeness                                    |
|  |   Step 3: QA-after-creation                                          |
|  |   Step 4: validate-squad                                             |
|  |   Step 5: validate-final-artifacts                                   |
|  +-- Apresenta resultado ao usuario                                     |
|                                                                          |
+-------------------------------------------------------------------------+
```

### Domain Knowledge Collection (Base)

No modo Base, o squad-chief coleta domain knowledge diretamente do usuario:

```yaml
domain_knowledge_collection:
  max_questions: 3
  questions:
    - "Qual o dominio e proposito principal do squad?"
    - "Quais sao os 3-5 use cases mais importantes?"
    - "Quem e o usuario-alvo? (perfil, nivel de expertise)"

  complementary:
    - action: "WebSearch para best practices do dominio"
    - action: "Identificar frameworks e metodologias existentes"
    - action: "Mapear vocabulario e anti-patterns do dominio"
```

### Template Enforcement (Base)

```
REGRA CRITICA:
  Antes de Write() qualquer agent, config ou README:
  1. DEVE ter feito Read() do template correspondente
  2. Template serve como estrutura base
  3. Conteudo e preenchido com research + domain knowledge
  4. VETO se Write() sem Read() previo de template
```

---

## [PRO] Multi-Agent Collaboration

> As secoes abaixo descrevem o modelo de colaboracao multi-agente disponivel
> apenas com o **AIOX Pro** (squad-creator-pro instalado).

### Os 4 Agentes [PRO]

#### @squad-chief (Orchestrator) -- Base + Pro

**Papel:** Ponto de entrada, coordenacao geral, triagem e criacao de squads.

| Aspecto | Descricao |
|---------|-----------|
| **Ativacao** | `@squad-creator` ou `@squad-chief` |
| **Funcoes** | Triagem, routing, criacao de squads, validacao final |
| **Base** | Opera sozinho, executa todas as fases |
| **Pro** | Orquestra @oalanicolas, @pedro-valerio, @thiago_finch |
| **Delega para** | [PRO] @oalanicolas (DNA), @pedro-valerio (processos) |
| **Recebe de** | Usuario, [PRO] @oalanicolas (DNA pronto), @pedro-valerio (artefatos) |

**Quando o Chief age sozinho (Base + Pro):**
- Criar squad completo (orquestra os outros no Pro)
- Extrair SOP de transcricao (*extract-sop)
- Validar squad final (*validate-squad)
- Routing inicial (diagnostico de necessidade)

**Quando o Chief delega [PRO]:**
- Precisa extrair DNA de um mind -> @oalanicolas
- Precisa validar/criar workflow -> @pedro-valerio
- Precisa auditar processo -> @pedro-valerio
- Precisa otimizar performance -> @thiago_finch

---

#### @oalanicolas (Tier 1 - Mind Cloning Specialist) [PRO]

**Papel:** Especialista em extracao de conhecimento e clonagem de mentes.

| Aspecto | Descricao |
|---------|-----------|
| **Ativacao** | `@squad-creator:oalanicolas` |
| **Funcoes** | Curadoria de fontes, extracao de Voice DNA, extracao de Thinking DNA |
| **Recebe de** | @squad-chief (mind para clonar) |
| **Entrega para** | @pedro-valerio (insumos prontos) ou @squad-chief (DNA completo) |

**Comandos exclusivos:**
```
*assess-sources      - Avaliar fontes (ouro vs bronze)
*extract-framework   - Extrair framework + Voice + Thinking DNA
*extract-implicit    - Extrair conhecimento tacito
*find-0.8            - Pareto ao Cubo (0,8% genialidade)
*validate-extraction - Self-validation antes do handoff
*fidelity-score      - Calcular score de fidelidade
```

**Filosofia:**
- "Curadoria > Volume"
- "Se entrar cocoo, sai cocoo"
- "Clone minds, not create bots"

---

#### @pedro-valerio (Tier 1 - Process Absolutist) [PRO]

**Papel:** Especialista em processos, workflows, e validacao.

| Aspecto | Descricao |
|---------|-----------|
| **Ativacao** | `@squad-creator:pedro-valerio` |
| **Funcoes** | Design de workflows, veto conditions, automacao, criacao de artefatos |
| **Recebe de** | @oalanicolas (insumos extraidos), @squad-chief (requests) |
| **Entrega para** | @squad-chief (artefatos prontos) |

**Comandos exclusivos:**
```
*eng-map          - Mapear processo completo
*arq-structure    - Criar estrutura de sistema
*auto-rules       - Regras de bloqueio
*create-task      - Criar task a partir de insumos
*create-workflow  - Criar workflow multi-fase
*create-agent     - Criar agent a partir de DNA
*audit            - Auditar processo/workflow
*veto-check       - Verificar veto conditions
```

**Filosofia:**
- "A melhor coisa e impossibilitar caminhos errados"
- "Nada volta num fluxo. NUNCA."
- "Se repete 3x, tem que automatizar"

---

#### @thiago_finch (Tier 1 - Performance Specialist) [PRO]

**Papel:** Especialista em otimizacao de performance e model routing.

| Aspecto | Descricao |
|---------|-----------|
| **Ativacao** | `@squad-creator:thiago_finch` |
| **Funcoes** | Model routing, token economy, optimization |
| **Recebe de** | @squad-chief (optimization requests) |
| **Entrega para** | @squad-chief (metrics, recommendations) |

---

## [PRO] Fluxo de Colaboracao

### Fluxo Principal: Criar Squad [PRO]

```
+-------------------------------------------------------------------------+
|                    FLUXO PRO: *create-squad {domain}                     |
+-------------------------------------------------------------------------+
|                                                                          |
|  FASE 0: DISCOVERY (squad-chief)                                         |
|  +-- Recebe request do usuario                                          |
|  +-- Verifica {registry_path} (existe similar?)              |
|  +-- Pergunta modo (YOLO/QUALITY/HYBRID)                                |
|  +-- Inicia research loop                                               |
|                                                                          |
|  FASE 1: RESEARCH (squad-chief)                                          |
|  +-- Executa mind-research-loop (3-5 iteracoes)                         |
|  +-- Devil's advocate em cada iteracao                                  |
|  +-- Valida frameworks documentados                                     |
|  +-- Apresenta elite minds ao usuario                                   |
|                                                                          |
|  FASE 2: CLONAGEM (squad-chief -> @oalanicolas)                          |
|  +-- Para cada mind aprovado:                                           |
|  |   +-- squad-chief invoca @oalanicolas                                |
|  |   +-- @oalanicolas executa /clone-mind                               |
|  |   |   +-- Coleta sources                                             |
|  |   |   +-- Classifica ouro vs bronze                                  |
|  |   |   +-- Extrai Voice DNA                                           |
|  |   |   +-- Extrai Thinking DNA                                        |
|  |   |   +-- Gera mind_dna_complete.yaml                                |
|  |   +-- @oalanicolas devolve DNA para squad-chief                      |
|  +-- Checkpoint: Todos os DNAs extraidos                                |
|                                                                          |
|  FASE 3: CRIACAO (squad-chief -> @pedro-valerio)                         |
|  +-- squad-chief passa DNAs para @pedro-valerio                         |
|  +-- @pedro-valerio cria artefatos:                                     |
|  |   +-- Agents baseados nos DNAs                                       |
|  |   +-- Tasks com veto conditions                                      |
|  |   +-- Workflows com checkpoints                                      |
|  |   +-- Checklists de validacao                                        |
|  +-- @pedro-valerio devolve artefatos para squad-chief                  |
|                                                                          |
|  FASE 4: INTEGRACAO (squad-chief)                                        |
|  +-- Gera config.yaml                                                   |
|  +-- Gera README.md                                                     |
|  +-- Organiza estrutura de pastas                                       |
|  +-- Wiring de dependencias                                             |
|                                                                          |
|  FASE 5: VALIDACAO (squad-chief)                                         |
|  +-- Executa smoke tests (3 testes por agent)                           |
|  +-- Valida quality gates                                               |
|  +-- Gera quality dashboard                                             |
|  +-- Apresenta resultado ao usuario                                     |
|                                                                          |
+-------------------------------------------------------------------------+
```

---

### [PRO] Fluxo: Clonar Mind Individual

```
+-------------------------------------------------------------------------+
|                    FLUXO PRO: *clone-mind {name}                         |
+-------------------------------------------------------------------------+
|                                                                          |
|  squad-chief recebe request                                              |
|       |                                                                  |
|       v                                                                  |
|  squad-chief delega para @oalanicolas                                    |
|       |                                                                  |
|       v                                                                  |
|  @oalanicolas executa pipeline completo:                                 |
|  +---------------------------------------------------------------+      |
|  | 1. COLLECT SOURCES                                             |      |
|  |    +-- Auto-acquire (YouTube, podcasts, articles)             |      |
|  |    +-- User materials (se fornecidos)                         |      |
|  |    +-- Quality Gate: >= 10 sources, >= 5 Tier 1               |      |
|  |                                                                |      |
|  | 2. CURATE SOURCES                                              |      |
|  |    +-- Classificar: OURO (Tier 0-1) vs BRONZE (Tier 2-3)     |      |
|  |    +-- Triangulacao (3+ sources por claim)                    |      |
|  |    +-- Veto: < 3 sources ouro = BLOCK                         |      |
|  |                                                                |      |
|  | 3. EXTRACT VOICE DNA                                           |      |
|  |    +-- Power words, signature phrases                         |      |
|  |    +-- Stories, anecdotes                                     |      |
|  |    +-- Tone dimensions                                        |      |
|  |    +-- Anti-patterns, immune system                           |      |
|  |    +-- Quality Gate: score >= 8/10                            |      |
|  |                                                                |      |
|  | 4. EXTRACT THINKING DNA                                        |      |
|  |    +-- Primary + secondary frameworks                         |      |
|  |    +-- Heuristics (com QUANDO usar)                           |      |
|  |    +-- Recognition patterns                                   |      |
|  |    +-- Objection handling                                     |      |
|  |    +-- Quality Gate: score >= 7/9                             |      |
|  |                                                                |      |
|  | 5. SYNTHESIZE                                                  |      |
|  |    +-- Merge Voice + Thinking                                 |      |
|  |    +-- Gerar mind_dna_complete.yaml                           |      |
|  |    +-- Self-validation checklist                              |      |
|  +---------------------------------------------------------------+      |
|       |                                                                  |
|       v                                                                  |
|  @oalanicolas retorna DNA para squad-chief                               |
|       |                                                                  |
|       v                                                                  |
|  squad-chief apresenta resultado ao usuario                              |
|                                                                          |
+-------------------------------------------------------------------------+
```

---

## [PRO] Handoffs e Protocolos

### Handoff: squad-chief -> @oalanicolas [PRO]

**Trigger:** Precisa extrair DNA de um mind

**Contexto passado:**
```yaml
handoff_to_oalanicolas:
  mind_name: "Gary Halbert"
  domain: "copywriting"
  sources_path: "docs/research/gary-halbert/"  # opcional
  mode: "quality"  # yolo | quality
  focus: "both"  # voice | thinking | both
```

**Esperado de volta:**
```yaml
return_from_oalanicolas:
  status: "complete"
  output_path: "outputs/minds/gary_halbert/"
  artifacts:
    - sources_inventory.yaml
    - voice_dna.yaml
    - thinking_dna.yaml
    - mind_dna_complete.yaml
  quality_scores:
    voice: 8.5
    thinking: 8.0
    overall: 8.25
```

---

### Handoff: @oalanicolas -> @pedro-valerio [PRO]

**Trigger:** Insumos prontos para virar artefatos (tasks, workflows, agents)

**Formato: INSUMOS_READY**
```yaml
insumos_ready:
  from: "@oalanicolas"
  to: "@pedro-valerio"

  validation_checklist:
    - "15+ citacoes diretas com [SOURCE: pagina/minuto]": true
    - "Voice DNA com 5+ signature phrases verificaveis": true
    - "Thinking DNA com decision architecture mapeada": true
    - "Heuristics com contexto de aplicacao (QUANDO)": true
    - "Anti-patterns do EXPERT (nao genericos)": true
    - "Zero conceitos marcados como inferido sem fonte": true

  artifacts:
    - voice_dna.yaml
    - thinking_dna.yaml
    - mind_dna_complete.yaml

  request: "Criar agent baseado neste DNA"
```

**Veto Conditions (PV rejeita se):**
- Conceitos sem `[SOURCE:]`
- Inferencias nao marcadas
- < 15 citacoes
- < 5 signature phrases

**Se veto:** Devolve para @oalanicolas com lista do que falta.

---

### Handoff: @pedro-valerio -> squad-chief [PRO]

**Trigger:** Artefatos prontos para integracao

**Formato: ARTIFACTS_READY**
```yaml
artifacts_ready:
  from: "@pedro-valerio"
  to: "@squad-chief"

  validation:
    smoke_tests: "3/3 PASS"
    veto_conditions: "defined"
    flow: "unidirectional"
    handoffs: "zero gap"

  artifacts:
    - agent.md
    - tasks/*.md
    - workflows/*.yaml
    - checklists/*.md

  quality_score: 8.5
```

---

## Matriz de Responsabilidades

### Quem faz o que?

| Atividade | squad-chief (Base) | squad-chief (Pro) | @oalanicolas [PRO] | @pedro-valerio [PRO] |
|-----------|:------------------:|:-----------------:|:------------------:|:--------------------:|
| **Receber request do usuario** | SIM | SIM | - | - |
| **Triagem/Routing** | SIM | SIM | - | - |
| **Research domain (web)** | SIM | SIM | - | - |
| **Research elite minds** | - | SIM | - | - |
| **Coletar sources** | - | - | SIM | - |
| **Curar sources (ouro/bronze)** | - | - | SIM | - |
| **Extrair Voice DNA** | - | - | SIM | - |
| **Extrair Thinking DNA** | - | - | SIM | - |
| **Criar agent.md (template)** | SIM | - | - | - |
| **Criar agent.md (DNA-based)** | - | - | - | SIM |
| **Criar task.md** | SIM | - | - | SIM |
| **Criar workflow.yaml** | SIM | - | - | SIM |
| **Definir veto conditions** | SIM (from templates) | - | - | SIM |
| **Auditar processo** | SIM (checklists) | - | - | SIM |
| **Gerar config.yaml** | SIM | SIM | - | - |
| **Gerar README.md** | SIM | SIM | - | - |
| **Validacao final** | SIM | SIM | - | - |
| **Apresentar resultado** | SIM | SIM | - | - |

---

### Quando chamar quem?

```
+-------------------------------------------------------------------------+
|                    DECISION TREE: QUAL AGENTE USAR?                      |
+-------------------------------------------------------------------------+
|                                                                          |
|  "O que voce precisa fazer?"                                             |
|       |                                                                  |
|       +-- Criar squad completo -----------------> @squad-chief          |
|       |   (Base: template-driven / Pro: orquestra agentes)              |
|       |                                                                  |
|       +-- Extrair DNA de um expert                                      |
|       |   +-- Base: usuario fornece knowledge --> @squad-chief          |
|       |   +-- Pro: extracao automatica ---------> @oalanicolas [PRO]    |
|       |                                                                  |
|       +-- Avaliar qualidade de fontes                                   |
|       |   +-- Base: pesquisa web ---------------> @squad-chief          |
|       |   +-- Pro: curadoria ouro/bronze -------> @oalanicolas [PRO]    |
|       |                                                                  |
|       +-- Clone nao esta autentico                                      |
|       |   +-- Base: re-criar via template ------> @squad-chief          |
|       |   +-- Pro: ajustar DNA -----------------> @oalanicolas [PRO]    |
|       |                                                                  |
|       +-- Criar workflow/task                                           |
|       |   +-- Base: template-driven ------------> @squad-chief          |
|       |   +-- Pro: process absolutism ----------> @pedro-valerio [PRO]  |
|       |                                                                  |
|       +-- Definir veto conditions                                       |
|       |   +-- Base: template-driven ------------> @squad-chief          |
|       |   +-- Pro: engineered vetos ------------> @pedro-valerio [PRO]  |
|       |                                                                  |
|       +-- Auditar processo existente                                    |
|       |   +-- Base: run checklists -------------> @squad-chief          |
|       |   +-- Pro: deep audit ------------------> @pedro-valerio [PRO]  |
|       |                                                                  |
|       +-- Extrair SOP de transcricao -----------> @squad-chief          |
|       |                                                                  |
|       +-- Validar squad existente --------------> @squad-chief          |
|       |                                                                  |
|       +-- Nao sei qual usar --------------------> @squad-chief          |
|                                         (ele roteia)                    |
|                                                                          |
+-------------------------------------------------------------------------+
```

---

## [PRO] Mental Model Integration

Na versao 4.0, cada agente especialista (@oalanicolas e @pedro-valerio) possui **mental models** integrados que sao consultados em **decision checkpoints**.

### Como funciona

```yaml
decision_checkpoint:
  trigger: "Antes de decisoes importantes"
  action: "Consultar mental model relevante"
  models_available:
    - VALUES (O que importa para o expert)
    - OBSESSIONS (O que os move)
    - MENTAL_MODELS (Como pensam)
    - PARADOXES (Contradicoes autenticas)
```

### Exemplo: @oalanicolas decidindo classificacao de fonte [PRO]

```
Checkpoint: Classificar fonte como OURO ou BRONZE?

1. Consulta VALUES: "Expert valoriza evidencia empirica"
2. Consulta MENTAL_MODEL: "Triangulacao requer 3+ sources"
3. Decisao: Fonte unica sem corroboracao = BRONZE
```

### Tasks com Decision Checkpoints [PRO]

| Task | Checkpoints | Mental Models Consultados |
|------|-------------|---------------------------|
| `an-assess-sources` | 3 | VALUES, OBSESSIONS |
| `an-extract-framework` | 5 | MODELS, PARADOXES |
| `an-validate-clone` | 4 | VALUES, MODELS |
| `pv-audit` | 6 | MODELS, VALUES |
| `create-workflow` | 4 | OBSESSIONS, MODELS |

---

## Veto Conditions por Agente

### @squad-chief - Vetos (Base + Pro)

| Condicao | Acao |
|----------|------|
| Squad ja existe para dominio | WARN + perguntar se quer estender |
| < 3 elite minds encontrados [PRO] | BLOCK research |
| Nenhum mind com framework documentado [PRO] | BLOCK creation |
| Quality score < 6.0 | BLOCK release |
| Write() sem Read() de template | VETO (VETO-TMPL-001) |

### @oalanicolas - Vetos [PRO]

| Condicao | Acao |
|----------|------|
| < 10 sources total | BLOCK extraction |
| < 3 sources ouro (Tier 0-1) | BLOCK synthesis |
| Voice score < 6/10 | WARN + retry |
| Thinking score < 5/9 | WARN + retry |
| Self-validation FAIL | BLOCK handoff |

### @pedro-valerio - Vetos [PRO]

| Condicao | Acao |
|----------|------|
| Insumos sem [SOURCE:] | REJECT + return to AN |
| < 15 citacoes | REJECT + return to AN |
| Workflow permite path reverso | BLOCK + fix |
| Automacao sem guardrails | BLOCK + add guardrails |
| Smoke test FAIL | BLOCK release |

---

## Ativacao dos Agentes

### Via linha de comando

```bash
# Ativar squad-chief (ponto de entrada padrao) -- Base + Pro
@squad-creator

# Ativar oalanicolas diretamente [PRO]
@squad-creator:oalanicolas

# Ativar pedro-valerio diretamente [PRO]
@squad-creator:pedro-valerio

# Ativar thiago_finch diretamente [PRO]
@squad-creator:thiago_finch
```

### Via delegacao interna [PRO]

O squad-chief delega automaticamente baseado no contexto:

```
User: "*clone-mind Gary Halbert"
squad-chief: "Delegando para @oalanicolas..."
@oalanicolas: "Iniciando extracao de DNA..."
```

### No modo Base (sem delegacao)

```
User: "*clone-mind Gary Halbert"
squad-chief: "Essa funcionalidade requer o AIOX Pro.
              Deseja criar o agente usando template-driven approach?"
```

---

## Troubleshooting de Colaboracao

### Problema: Feature PRO solicitada no modo Base

**Sintoma:** Usuario solicita *clone-mind, *assess-sources, ou outra feature PRO

**Causa:** squad-creator-pro nao esta instalado

**Solucao:**
```
squad-chief apresenta upgrade prompt:
  "Essa funcionalidade requer o AIOX Pro (squad-creator-pro).
   Deseja criar usando o fluxo template-driven?"
```

### Problema: Handoff travado entre agentes [PRO]

**Sintoma:** @oalanicolas nao consegue entregar para @pedro-valerio

**Causa provavel:** Self-validation falhou

**Solucao:**
```bash
@oalanicolas
*validate-extraction
# Ver o que esta faltando
# Completar antes de tentar handoff novamente
```

### Problema: @pedro-valerio rejeitando insumos [PRO]

**Sintoma:** "VETO: Insumos incompletos"

**Causa:** Citacoes insuficientes ou inferencias nao marcadas

**Solucao:**
```bash
@oalanicolas
*assess-sources  # Ver cobertura
*extract-framework --deep  # Extrair mais profundamente
```

### Problema: Squad criado mas agents genericos

**Sintoma:** Agents nao soam como o expert

**Causa Base:** Template preenchido sem pesquisa suficiente
**Causa Pro:** DNA extraction superficial

**Solucao Base:**
```bash
@squad-chief
# Re-criar agent com mais pesquisa web
# Coletar mais domain knowledge do usuario
```

**Solucao Pro:**
```bash
@oalanicolas
*diagnose-clone {slug}
*fidelity-score {slug}
*update-mind {slug} --sources ./mais-materiais/
```

---

## Resumo Visual

```
+-------------------------------------------------------------------------+
|                    SQUAD CREATOR COLLABORATION v4.0                      |
+-------------------------------------------------------------------------+
|                                                                          |
|  BASE MODE:                                                              |
|                                                                          |
|                         USER REQUEST                                     |
|                              |                                           |
|                              v                                           |
|                    +------------------+                                   |
|                    |  @squad-chief    |                                   |
|                    |  (Solo)          |                                   |
|                    +--------+---------+                                   |
|                             |                                            |
|              +--------------+--------------+                             |
|              |              |              |                             |
|              v              v              v                             |
|     +------------+  +------------+  +------------+                      |
|     |  Template  |  |  Research  |  |  Validate  |                      |
|     |  Selection |  |  + Create  |  |  (chain)   |                      |
|     +------------+  +------------+  +------------+                      |
|                             |                                            |
|                             v                                            |
|                        SQUAD READY                                       |
|                                                                          |
+-------------------------------------------------------------------------+
|                                                                          |
|  PRO MODE:                                                               |
|                                                                          |
|                         USER REQUEST                                     |
|                              |                                           |
|                              v                                           |
|                    +------------------+                                   |
|                    |  @squad-chief    |                                   |
|                    |   (Triage)       |                                   |
|                    +--------+---------+                                   |
|                             |                                            |
|              +--------------+--------------+                             |
|              |              |              |                             |
|              v              v              v                             |
|     +------------+  +------------+  +------------+                      |
|     |   Clone    |  |   Create   |  |  Extract   |                      |
|     |   Mind     |  |   Squad    |  |   SOP      |                      |
|     +-----+------+  +-----+------+  +------------+                      |
|           |               |                                              |
|           v               |                                              |
|  +------------------+     |                                              |
|  |  @oalanicolas    |<----+                                              |
|  |  (Extract DNA)   |                                                    |
|  +--------+---------+                                                    |
|           |                                                              |
|           | INSUMOS_READY                                                |
|           v                                                              |
|  +------------------+                                                    |
|  | @pedro-valerio   |                                                    |
|  | (Build Artifacts)|                                                    |
|  +--------+---------+                                                    |
|           |                                                              |
|           | ARTIFACTS_READY                                              |
|           v                                                              |
|  +------------------+                                                    |
|  |  @squad-chief    |                                                    |
|  |  (Integrate)     |                                                    |
|  +--------+---------+                                                    |
|           |                                                              |
|           v                                                              |
|       SQUAD READY                                                        |
|                                                                          |
+-------------------------------------------------------------------------+
```

---

## Links Relacionados

- [CONCEPTS.md](./CONCEPTS.md) - Conceitos fundamentais
- [COMMANDS.md](./COMMANDS.md) - Referencia de comandos
- [ARCHITECTURE-DIAGRAMS.md](./ARCHITECTURE-DIAGRAMS.md) - Diagramas tecnicos
- [HITL-FLOW.md](./HITL-FLOW.md) - Human-in-the-Loop checkpoints

---

**Squad Creator | Agent Collaboration v4.0.0**
*"Base: 1 agente, templates, qualidade. Pro: 4 agentes, DNA, fidelidade."*
