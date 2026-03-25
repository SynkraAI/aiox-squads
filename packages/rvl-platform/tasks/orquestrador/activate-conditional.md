---
task: Ativar ou Negar Condicional
responsavel: "@orquestrador"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - sinalizacao_agente: Sinalização de necessidade de condicional
  - PROJETO_CLASSIFICADO: Para verificar gatilhos do intake
Saida: |
  - decisao_condicional: ativada | negada
  - registro_ativacao: Log da decisão
Checklist:
  - "[ ] Verificar se gatilho está no PROJETO_CLASSIFICADO"
  - "[ ] Verificar se evidência do agente é suficiente"
  - "[ ] Decidir ativação (ambos critérios) ou avaliar com mais critério (só evidência)"
  - "[ ] Registrar decisão com justificativa"
  - "[ ] Comunicar ao agente"
---

# *activate-conditional

Decide ativação de ferramentas condicionais com base em gatilhos + sinalização de agente.

## Critérios de Ativação

| Situação | Decisão |
|----------|---------|
| Gatilho no intake + evidência do agente | Ativar |
| Apenas evidência do agente (sem gatilho no intake) | Avaliar com mais critério |
| Nenhum dos dois | Negar |

## Output

```yaml
DECISAO_CONDICIONAL:
  ferramenta: string  # Ex: ARCH™, SHIFT™, SAGA™
  decisao: "ativada" | "negada"
  criterio_aplicado: string
  justificativa: string
  comunicar_a: string  # Agente que sinalizou
  timestamp: datetime
```
