---
task: Definir Persona
agent: discovery
responsavel: "@discovery"
responsavel_type: agent
atomic_layer: task
icon: "🔍"
elicit: true
Entrada: |
  - briefing_completo: Documento de briefing
  - dados_do_mercado: Informações sobre o segmento (opcional)
Saida: |
  - persona_documento: Persona estruturada com nome, dores e desejos
  - dores: Lista de dores e frustrações do público
  - desejos: Lista de desejos e aspirações
  - gatilhos: Gatilhos de decisão de compra
Checklist:
  - "[ ] Nomear e humanizar a persona"
  - "[ ] Mapear dados demográficos"
  - "[ ] Listar dores e frustrações"
  - "[ ] Listar desejos e aspirações"
  - "[ ] Identificar gatilhos de decisão"
  - "[ ] Validar persona com cliente"
---

# *define-persona

Define a persona principal do projeto com base no briefing, mapeando dores, desejos e gatilhos de compra.

## Output

```markdown
# Persona — [Nome]

**Idade:** [faixa]
**Ocupação:** [cargo/área]
**Objetivo principal:** [o que quer alcançar]

## Dores
- [dor 1]
- [dor 2]

## Desejos
- [desejo 1]
- [desejo 2]

## Gatilhos de decisão
- [gatilho 1]
- [gatilho 2]

## Objeções comuns
- [objeção 1]
- [objeção 2]
```
