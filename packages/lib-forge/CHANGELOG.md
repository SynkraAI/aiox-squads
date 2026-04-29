# Changelog — Lib Forge

## [1.0.0] — 2026-04-29

### Lançamento inicial

**Agentes:**
- 🔥 lib-forge-chief (Forge) — Orchestrator
- 🔍 prd-analyst (Ana) — Tier 1
- 🏗️ lib-architect (Arco) — Tier 2
- ✍️ script-writer (Script) — Tier 3
- ✅ lib-validator (Val) — Tier 4

**Workflows:**
- wf-prd-to-lib — Pipeline completo PRD → lib (6 fases)
- wf-validation-gate — Ciclo de validação com até 3 iterações

**Tasks:**
- analyze-prd
- extract-opportunities
- design-lib-structure (com human gate obrigatório)
- generate-scripts
- validate-scripts
- publish-to-victor-libs

**Configurações:**
- Suporte a Python ≥ 3.10
- Saída padrão em victor-libs/
- Organização por domínio de negócio
- Aprovação humana obrigatória antes de gerar código
