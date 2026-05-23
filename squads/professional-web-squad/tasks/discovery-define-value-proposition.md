---
task: Definir Proposta de Valor
agent: discovery
responsavel: "@discovery"
responsavel_type: agent
atomic_layer: task
icon: "🔍"
elicit: true
Entrada: |
  - persona_documento: Persona definida
  - produto_servico: Descrição do produto ou serviço
Saida: |
  - proposta_de_valor: Declaração clara da proposta de valor
  - diferenciais: Lista de diferenciais competitivos
  - beneficios: Benefícios concretos para o público
Checklist:
  - "[ ] Identificar o que o produto resolve"
  - "[ ] Mapear diferenciais vs concorrência"
  - "[ ] Traduzir features em benefícios"
  - "[ ] Redigir proposta de valor em 1 frase"
  - "[ ] Validar clareza e relevância"
---

# *define-value-proposition

Define a proposta de valor única do projeto, traduzindo features em benefícios concretos para a persona.

## Framework: Value Proposition Canvas

```
Para [persona] que [dor/necessidade],
[produto/serviço] oferece [benefício principal]
diferente de [alternativa], porque [diferencial único].
```

## Output

```markdown
# Proposta de Valor

**Declaração:** [1 frase clara e direta]

## Diferenciais
- [diferencial 1]
- [diferencial 2]

## Benefícios para a persona
- [benefício 1]
- [benefício 2]

## Prova social / evidências
- [evidência 1]
- [evidência 2]
```
