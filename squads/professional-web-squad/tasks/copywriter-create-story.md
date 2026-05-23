---
task: Criar Storytelling
agent: copywriter
responsavel: "@copywriter"
responsavel_type: agent
atomic_layer: task
icon: "✍️"
elicit: true
Entrada: |
  - marca: Informações sobre a marca e fundador
  - persona_documento: Persona definida
  - objetivo: Objetivo emocional da narrativa
Saida: |
  - narrativa_de_marca: História da marca estruturada
  - arco_storytelling: Estrutura narrativa em 3 atos
Checklist:
  - "[ ] Identificar o herói da história (cliente ou fundador)"
  - "[ ] Mapear o conflito/desafio central"
  - "[ ] Desenvolver a jornada de transformação"
  - "[ ] Conectar com as dores da persona"
  - "[ ] Finalizar com resolução e CTA"
---

# *create-story

Desenvolve a narrativa e storytelling da marca, criando conexão emocional com a persona.

## Framework: Jornada do Herói (adaptada para web)

```
Ato 1 — CONTEXTO
"Você sabe como é [situação de dor]..."

Ato 2 — CONFLITO
"A maioria das pessoas tenta [solução comum], mas [por que não funciona]..."

Ato 3 — RESOLUÇÃO
"[Produto/serviço] foi criado para [transformação]. Hoje, [resultado real]."
```

## Output

```markdown
# Narrativa — [Marca]

## Arco da História
**Contexto:** [situação inicial identificável pela persona]
**Conflito:** [problema que a solução resolve]
**Resolução:** [transformação que o produto/serviço proporciona]

## Copy de Storytelling
[Texto corrido da narrativa, pronto para usar na página]
```
