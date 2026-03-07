# Changelog - Squad Creator

Todas as alterações notáveis no squad-creator serão documentadas aqui.

---

## [4.0.0] - 2026-02-24

### Base/Pro Architecture Split (SCPRO Epic)

- **SCPRO.1:** Complete dependency mapping and asset classification (53 tasks → 20 base + 33 pro)
- **SCPRO.2:** Restructure base with pro detection
  - Rewrite squad-chief.md (1779→1011 lines) with silent pro detection at boot
  - Rewrite 6 base tasks: create-squad, create-agent, discover-tools, upgrade-squad, install-commands, validate-squad
  - Simplify 2 base workflows: create-squad.yaml (353→280 lines), validate-squad.yaml (new, 222 lines)
  - Stage 33 pro tasks, 17 pro workflows, 3 specialist agents to _staging/
- **SCPRO.3:** Create squads/squad-creator-pro/ upgrade pack
  - config.yaml with type: upgrade-pack, enhances: squad-creator, v3.1.0
  - Migrate all pro assets from _staging/ with path reference updates (143 refs)
  - Feature manifest: mind-cloning, research, advanced-creation, optimization, model-routing, quality, maintenance, strategy
- **SCPRO.4:** Unify entry points
  - .claude/agents/squad-creator.md → loads squad-chief persona directly
  - .claude/agents/squad-chief.md → deprecation redirect
  - Remove .claude/commands/SquadCreator/ (37 files, third copy eliminated)
- **SCPRO.5:** Dual-mode testing, degradation verification, final audit
  - All 53 tasks accounted for: 20 base + 33 pro, zero duplication
  - Registry migrated to {registry_path}
  - Zero broken references, all YAML valid

### Alterado
- Version: 3.1.0 → 4.0.0
- config.yaml: metadata.type = "base", metadata.pro_detection = true
- Single activation path: @squad-creator (no separate @squad-chief)

---

## [3.2.1] - 2026-02-04

### Adicionado
- **T3-DOC: Changelog separation check**
  - Verifica se tasks >= v2.0.0 têm CHANGELOG.md separado
  - Referencia HO-DP-001 do best-practices.md
  - Peso: 1 ponto no score de Documentation

---

## [3.2.0] - 2026-02-04

### Adicionado
- **T2-TOOL-001: Tool Registry Validation**
  - Valida `tool-registry.yaml` se squad usa tools/MCPs externos
  - Verifica se tools declaradas são acessíveis
  - Alerta se tools não documentadas no README

- **T3-OPT: Optimization Opportunities Check**
  - Identifica tasks Agent que poderiam ser Worker (economia de custo)
  - Referencia `executor-decision-tree.md` (Q1-Q6)
  - Fornece projeção econômica (estimativa de economia mensal)
  - Apenas informacional, não bloqueia

- **T4H-EX: Executor Decision Tree Validation** (Hybrid squads)
  - Valida campo `execution_type` nas tasks
  - Verifica aplicação correta do decision tree Q1-Q6
  - Confirma que tasks Worker têm scripts
  - Confirma que tasks Hybrid têm `human_checkpoint`
  - Valida fallback chain definido
  - Peso: 35% do score Hybrid (REQUIRED)

### Alterado
- Ajustados pesos TIER 3: 20% cada (era 25%)
- Ajustados pesos TIER 4 Hybrid para acomodar executor validation
- Atualizada tabela Quick Reference com novos componentes
- Adicionadas referências a `executor-decision-tree.md`, `tool-registry.yaml`, `optimize.md`

---

## [3.1.0] - 2026-02-02

### Corrigido
- Minor fixes e clarificações

---

## [3.0.0] - 2026-02-01

### Adicionado
- Detecção de tipo de squad (Expert/Pipeline/Hybrid)
- Sistema de validação em 4 tiers
- Prompt quality, pipeline coherence, checklist actionability checks
- Coverage ratio checks
- Type-specific veto conditions

### Alterado
- `voice_dna`/`objection_algorithms` agora são contextuais (não obrigatórios para todos)
- Alinhamento com `squad-checklist.md` v3.0

---

## [2.0.0] - 2026-01-15

### Alterado
- Abordagem de validação qualitativa
- Checks baseados em princípios

---

## [1.0.0] - 2025-12-01

### Adicionado
- Task inicial de validação
