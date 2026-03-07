# Squad Structural Completeness Checklist

**ID:** SC_STRUCT_001
**Purpose:** Verificar que arquivos estruturais obrigatórios existem antes de declarar squad "criado"
**When:** OBRIGATÓRIO ao final de `*create-squad` e `*create-squad-smart`
**Tier:** haiku (checklist determinístico)

---

## Filosofia

```
Um squad não está "criado" até que os arquivos estruturais existam.
Listar no README não é criar.
Mencionar que vai criar não é criar.
O arquivo precisa EXISTIR no filesystem.
Templates DEVEM ser usados - NUNCA escrever ad-hoc.
```

---

## SQUAD TYPE DETECTION (Primeiro Passo)

Antes de validar, detectar o tipo de squad:

| Tipo | Características | Lifecycle Tasks |
|------|-----------------|-----------------|
| **Expert** | Mind clones, voice_dna, múltiplos agents | update + delete RECOMENDADOS |
| **Pipeline** | Fases sequenciais, orchestrator | update + delete RECOMENDADOS |
| **Operational** | Funcional, sem mind clones, focado em automação | update + delete OPCIONAIS |
| **Utility** | Single-purpose, poucos agents | update + delete OPCIONAIS |

```yaml
detect_operational:
  signals:
    - "Agents sem voice_dna"
    - "Agents < 300 linhas"
    - "Sem mind-research executado"
    - "User disse 'operacional' ou 'simples'"
  lifecycle_tasks: "OPTIONAL (warning, not blocking)"

detect_expert:
  signals:
    - "Mind clones baseados em pessoas reais"
    - "voice_dna presente"
    - "Agents > 500 linhas"
  lifecycle_tasks: "RECOMMENDED (warning if missing)"
```

---

## BLOCKING REQUIREMENTS (qualquer falha = ABORT)

### 1. Arquivo de Configuração

| Check | Validação | Blocking |
|-------|-----------|----------|
| `config.yaml` existe | `ls squads/{name}/config.yaml` | YES |
| NÃO é `squad.yaml` | Arquivo deve ser `config.yaml` | YES |
| Campo `entry_agent` presente | `grep "entry_agent:" config.yaml` | YES |
| Campo `version` presente | semver (X.Y.Z) | YES |

### 2. Entry Agent

| Check | Validação | Blocking |
|-------|-----------|----------|
| Arquivo do entry_agent existe | `ls squads/{name}/agents/{entry_agent}.md` | YES |
| Tem `activation-instructions:` | Bloco YAML com steps de ativação | YES |
| Tem comando `*help` | Mínimo obrigatório | YES |

### 3. Documentação Mínima

| Check | Validação | Blocking |
|-------|-----------|----------|
| `README.md` existe | Documentação principal | YES |

### 4. Template Compliance (NOVO - FIX #1)

| Check | Validação | Blocking |
|-------|-----------|----------|
| config.yaml baseado em template | Estrutura match com config-tmpl.yaml | YES |
| Entry agent baseado em template | Estrutura match com agent-tmpl.md | YES |

---

## CONTEXTUAL REQUIREMENTS (depende do tipo de squad)

### Para TODOS os squads (WARNING se faltando)

| Check | Validação | Severity |
|-------|-----------|----------|
| `CHANGELOG.md` existe | Histórico de versões | WARNING |
| `ARCHITECTURE.md` existe | Pipeline flow | WARNING |
| Campo `tested` presente | true/false no config | WARNING |

### Para squads EXPERT/PIPELINE (WARNING se faltando)

| Check | Validação | Severity |
|-------|-----------|----------|
| Task de update existe | `update-*.md` (brownfield) | WARNING |
| Task de delete existe | `delete-*.md` (cleanup) | WARNING |

### Para squads OPERATIONAL/UTILITY (OPTIONAL)

| Check | Validação | Severity |
|-------|-----------|----------|
| Task de update existe | `update-*.md` | OPTIONAL |
| Task de delete existe | `delete-*.md` | OPTIONAL |

---

## SCORING

```yaml
blocking_checks: 14 items
pass_threshold: 14/14 (100%)
any_failure: Squad marcado como INCOMPLETO
```

---

## TEMPLATE COMPLIANCE (FIX #1 - Crítico)

### Regra Fundamental

```
NUNCA escrever arquivos de squad ad-hoc (de memória).
SEMPRE carregar e usar os templates do squad-creator.
```

### Templates Obrigatórios

| Arquivo a Criar | Template a Carregar | Campos Obrigatórios |
|-----------------|---------------------|---------------------|
| `config.yaml` | `templates/config-tmpl.yaml` | name, version, entry_agent, agents[] |
| `agents/*.md` | `templates/agent-tmpl.md` | activation-instructions, persona, commands |
| `README.md` | `templates/readme-tmpl.md` | Overview, Commands, Files |
| `tasks/*.md` | `templates/task-tmpl.md` | Task ID, Inputs, Outputs |

### Verificação de Compliance

```yaml
template_compliance_check:
  - id: "TC-001"
    check: "config.yaml foi gerado a partir de config-tmpl.yaml"
    how: "Verificar se estrutura tem todos os campos do template"
    veto_if: "Campos obrigatórios do template ausentes"

  - id: "TC-002"
    check: "Entry agent foi gerado a partir de agent-tmpl.md"
    how: "Verificar se tem activation-instructions com 4+ STEPs"
    veto_if: "Sem activation-instructions ou com estrutura diferente"

  - id: "TC-003"
    check: "Tasks seguem task-tmpl.md"
    how: "Verificar se tem Task ID, Inputs, Outputs definidos"
    veto_if: "Task sem estrutura padrão"
```

---

## ERROS COMUNS (Aprendi da Pior Forma)

### Erro 0: BYPASS DE TEMPLATES (MAIS GRAVE)
```
❌ ERRADO:
squad-chief usa Write() direto com conteúdo de memória
NÃO carrega config-tmpl.yaml
NÃO carrega agent-tmpl.md
Resultado: estrutura fora do padrão AIOX

✅ CORRETO:
1. Carregar template: Read(templates/config-tmpl.yaml)
2. Preencher campos do template
3. Escrever resultado: Write(squads/{name}/config.yaml)
```

### Erro 1: Nome do Config
```
❌ ERRADO: squad.yaml
✅ CORRETO: config.yaml
```

### Erro 2: Entry Agent sem Activation
```
❌ ERRADO:
# my-chief.md
## SCOPE
...

✅ CORRETO:
# my-chief.md

```yaml
activation-instructions:
  - STEP 1: Read THIS ENTIRE FILE
  - STEP 2: Adopt the persona
  - STEP 3: Display greeting
  - STEP 4: HALT and await user input
```
```

### Erro 3: Documentação Mencionada mas não Criada
```
❌ ERRADO (no README):
## Files
├── CHANGELOG.md    # <-- arquivo não existe!
├── ARCHITECTURE.md # <-- arquivo não existe!

✅ CORRETO:
Criar os arquivos ANTES de listá-los no README
```

### Erro 4: Lifecycle Tasks Faltando (CONTEXTUAL)
```
Para squads EXPERT/PIPELINE:
⚠️ WARNING se faltando:
tasks/
└── create-theme.md   # Só criação

✅ RECOMENDADO:
tasks/
├── create-theme.md   # Criação
├── update-theme.md   # Brownfield
└── delete-theme.md   # Cleanup

Para squads OPERATIONAL/UTILITY:
✅ OK ter apenas create:
tasks/
└── create-simple.md   # Suficiente para squads simples
```

### Erro 5: Metadata Incompleto
```
❌ ERRADO:
squad:
  name: my-squad
  version: 1.0.0

✅ CORRETO:
squad:
  name: my-squad
  version: 1.0.0
  entry_agent: my-chief
  tested: true
```

---

## AUTOMATION

### Script de Verificação

```bash
#!/bin/bash
# verify-squad-completeness.sh
SQUAD=$1
ROOT="squads/$SQUAD"

echo "Verificando completude estrutural de: $SQUAD"
echo "============================================="

ERRORS=0

# 1. Config
if [ ! -f "$ROOT/config.yaml" ]; then
  echo "❌ FAIL: config.yaml não existe"
  ERRORS=$((ERRORS+1))
fi

if [ -f "$ROOT/squad.yaml" ]; then
  echo "❌ FAIL: squad.yaml existe (deveria ser config.yaml)"
  ERRORS=$((ERRORS+1))
fi

if ! grep -q "entry_agent:" "$ROOT/config.yaml" 2>/dev/null; then
  echo "❌ FAIL: entry_agent não definido em config.yaml"
  ERRORS=$((ERRORS+1))
fi

if ! grep -q "tested:" "$ROOT/config.yaml" 2>/dev/null; then
  echo "❌ FAIL: campo 'tested' não definido em config.yaml"
  ERRORS=$((ERRORS+1))
fi

# 2. Docs
for doc in README.md CHANGELOG.md ARCHITECTURE.md; do
  if [ ! -f "$ROOT/$doc" ]; then
    echo "❌ FAIL: $doc não existe"
    ERRORS=$((ERRORS+1))
  fi
done

# 3. Entry Agent activation
ENTRY=$(grep "entry_agent:" "$ROOT/config.yaml" 2>/dev/null | cut -d: -f2 | tr -d ' ')
if [ -n "$ENTRY" ]; then
  AGENT_FILE="$ROOT/agents/$ENTRY.md"
  if [ ! -f "$AGENT_FILE" ]; then
    echo "❌ FAIL: Entry agent file não existe: $AGENT_FILE"
    ERRORS=$((ERRORS+1))
  elif ! grep -q "activation-instructions:" "$AGENT_FILE" 2>/dev/null; then
    echo "❌ FAIL: Entry agent sem activation-instructions"
    ERRORS=$((ERRORS+1))
  fi
fi

# 4. Lifecycle tasks
HAS_CREATE=false
HAS_UPDATE=false
HAS_DELETE=false

for task in "$ROOT/tasks/"*.md; do
  [ -f "$task" ] || continue
  case "$(basename $task)" in
    create-*|wf-create-*) HAS_CREATE=true ;;
    update-*|wf-update-*) HAS_UPDATE=true ;;
    delete-*|wf-delete-*) HAS_DELETE=true ;;
  esac
done

[ "$HAS_CREATE" = false ] && echo "⚠️ WARN: Sem task de create" && ERRORS=$((ERRORS+1))
[ "$HAS_UPDATE" = false ] && echo "⚠️ WARN: Sem task de update" && ERRORS=$((ERRORS+1))
[ "$HAS_DELETE" = false ] && echo "⚠️ WARN: Sem task de delete" && ERRORS=$((ERRORS+1))

# Result
echo "============================================="
if [ $ERRORS -eq 0 ]; then
  echo "✅ PASS: Squad estruturalmente completo"
  exit 0
else
  echo "❌ FAIL: $ERRORS problemas encontrados"
  exit 1
fi
```

---

## INTEGRATION

### No qa-after-creation.md

Adicionar como PHASE 0 (antes dos quick checks):

```yaml
phase_0_structural:
  name: "Structural Completeness"
  blocking: true
  checks:
    - "config.yaml exists (NOT squad.yaml)"
    - "entry_agent field present"
    - "tested field present"
    - "Entry agent has activation-instructions"
    - "README.md exists"
    - "CHANGELOG.md exists"
    - "ARCHITECTURE.md exists"
    - "update-*.md task exists"
    - "delete-*.md task exists"
  on_fail: "ABORT - Squad structurally incomplete"
```

---

## HEURISTIC

```yaml
id: SC_STRUCT_001
name: "Squad Structural Completeness Gate"
rule: |
  ANTES de declarar squad criado:

  1. Verificar config.yaml (não squad.yaml)
  2. Verificar entry_agent definido
  3. Verificar tested flag
  4. Verificar activation-instructions no entry agent
  5. Verificar docs: README, CHANGELOG, ARCHITECTURE
  6. Verificar lifecycle tasks: create, update, delete

  IF any check fails:
    → Squad está INCOMPLETO
    → NÃO declarar "Squad criado com sucesso"
    → Listar o que falta

veto_condition: "Qualquer check estrutural falhando"
```

---

