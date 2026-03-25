---
task: Verificar Coerência Verbal/Visual e Atlas Completude
responsavel: "@expressao"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - SIGNA_IDENTIDADE_VISUAL: Artefato de SIGNA™
  - ECHO_TOM_DE_VOZ: Artefato de ECHO™
  - ATLAS_MANUAL_VIVO: Artefato de ATLAS™
Saida: |
  - coerencia_verbal_visual: boolean
  - atlas_completude: boolean
  - MSG-01_HANDSHAKE_E2: Mensagem para ORQUESTRADOR
Checklist:
  - "[ ] Verificar coerencia_verbal_visual (SIGNA ↔ ECHO)"
  - "[ ] Verificar atlas_completude"
  - "[ ] Se coerencia == false → identificar incoerência específica e escalar"
  - "[ ] Se atlas_completude == false → listar elementos faltantes e escalar"
  - "[ ] Formatar MSG-01 HANDSHAKE E2"
---

# *check-coerencia

Dois checks de bloqueio obrigatórios antes de liberar E2 para E3.

## Checks

### 1. Coerência Verbal/Visual
O que SIGNA™ comunica visualmente é coerente com o que ECHO™ define verbalmente?
- Empresa com tom de voz "preciso e sem excesso" + identidade ornamental = **incoerência → BLOQUEIA**

### 2. Atlas Completude
O ATLAS™ cobre todos os elementos definidos em E2?
- Manual incompleto → **BLOQUEIA E3**

## Output

```yaml
CHECK_E2:
  coerencia_verbal_visual: true | false
  incoerencia_identificada: null | string
  atlas_completude: true | false
  elementos_faltantes: []

MSG-01_HANDSHAKE_E2:
  de: expressao
  para: orquestrador
  fase: E2
  checks: CHECK_E2
  status: "pronto_para_validacao" | "bloqueado"
```
