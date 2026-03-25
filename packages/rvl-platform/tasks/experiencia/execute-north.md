---
task: Executar NORTH™ — Governança Contínua
responsavel: "@experiencia"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - LIFT_ROADMAP: Artefato de LIFT™
  - TRACE_TOUCHPOINTS: Artefato de TRACE™ (para definir frequência de ritos)
Saida: |
  - NORTH_GOVERNANCA: Sistema de governança contínua da marca
Checklist:
  - "[ ] Definir ritos de governança com frequência"
  - "[ ] Se saude_geral == vermelho → ritos mensais ou mais frequentes"
  - "[ ] Definir responsáveis reais para cada rito"
  - "[ ] Definir critérios de revisão da estratégia"
  - "[ ] NÃO simplificar para facilitar venda"
---

# *execute-north

Executa NORTH™ — governança contínua que garante que a marca vive e evolui.

## Output: NORTH_GOVERNANCA

```yaml
NORTH_GOVERNANCA:
  ritos:
    - nome: string
      frequencia: "semanal" | "mensal" | "trimestral" | "semestral" | "anual"
      responsavel: string
      pauta: [string]
  criterios_revisao_estrategia:
    - criterio: string
      gatilho: string
  north_modo: "padrao" | "intensivo"
  regras_integridade_verificadas: [string]
```
