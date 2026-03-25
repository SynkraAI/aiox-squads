---
task: Executar LIFT™ — Roadmap de Implementação
responsavel: "@experiencia"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - TRACE_TOUCHPOINTS: Artefato de TRACE™
  - shift_score: Score de maturidade organizacional (quando SHIFT™ ativado)
Saida: |
  - LIFT_ROADMAP: Roadmap de 90 dias priorizado
Checklist:
  - "[ ] Verificar saude_geral de TRACE™"
  - "[ ] Se saude_geral == vermelho → abrir com fase_emergencial"
  - "[ ] Se shift_score baixo → lift_modo = capacitacao"
  - "[ ] Priorizar gaps críticos nas primeiras semanas"
  - "[ ] Marcar acoes_bloqueadas_ate_la quando capacidade não existe"
  - "[ ] NÃO omitir realidade para tornar roadmap mais otimista"
---

# *execute-lift

Executa LIFT™ — roadmap de implementação de 90 dias baseado no diagnóstico real.

## Output: LIFT_ROADMAP

```yaml
LIFT_ROADMAP:
  lift_modo: "padrao" | "capacitacao" | "emergencial"
  semanas_1_4:
    foco: string
    acoes: [{acao, responsavel, entregavel}]
  semanas_5_8:
    foco: string
    acoes: [{acao, responsavel, entregavel}]
  semanas_9_12:
    foco: string
    acoes: [{acao, responsavel, entregavel}]
  acoes_bloqueadas_ate_la: []
  fase_emergencial: null | {descricao, acoes_prioritarias}
  regras_integridade_verificadas: [string]
```
