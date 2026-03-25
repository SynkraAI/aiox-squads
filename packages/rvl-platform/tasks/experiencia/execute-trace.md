---
task: Executar TRACE™ — Matriz de Touchpoints
responsavel: "@experiencia"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - RITUAL_JORNADAS: Artefato de RITUAL™
  - ATLAS_MANUAL_VIVO: Artefato de ATLAS™
Saida: |
  - TRACE_TOUCHPOINTS: Matriz completa com saúde e gaps
Checklist:
  - "[ ] Mapear todos os touchpoints das jornadas"
  - "[ ] Auditar cada touchpoint contra padrão do ATLAS™"
  - "[ ] Identificar momentos_da_verdade_off_brand (NÃO omitir)"
  - "[ ] Calcular saude_geral com rigor"
  - "[ ] saude_geral == vermelho → LIFT™ abre com fase_emergencial"
---

# *execute-trace

Executa TRACE™ — audita touchpoints reais contra o padrão definido pela estratégia.

## Regra Crítica

`momentos_da_verdade_off_brand` não são falhas a esconder — são o dado mais valioso.
Eles informam onde LIFT™ precisa focar e onde NORTH™ precisa ser mais robusto.

## Output: TRACE_TOUCHPOINTS

```yaml
TRACE_TOUCHPOINTS:
  touchpoints:
    - nome: string
      canal: string
      status: "on_brand" | "parcial" | "off_brand"
      gap_identificado: null | string
  momentos_da_verdade_off_brand:
    - touchpoint: string
      problema: string
      severidade: "baixa" | "media" | "alta" | "critica"
  saude_geral: "verde" | "amarelo" | "vermelho"
  regras_integridade_verificadas: [string]
```
