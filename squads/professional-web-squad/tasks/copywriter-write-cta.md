---
task: Escrever CTAs
agent: copywriter
responsavel: "@copywriter"
responsavel_type: agent
atomic_layer: task
icon: "✍️"
elicit: true
Entrada: |
  - objetivo_conversao: O que o visitante deve fazer (comprar, agendar, baixar, etc.)
  - persona_documento: Persona definida
Saida: |
  - ctas_variações: 10 variações de CTA para teste
  - microcopy: Textos de suporte ao CTA (abaixo do botão)
Checklist:
  - "[ ] Identificar ação desejada"
  - "[ ] Gerar 10 variações de CTA"
  - "[ ] Incluir gatilhos de urgência e benefício"
  - "[ ] Criar microcopy de suporte"
  - "[ ] Testar clareza e especificidade"
---

# *write-cta

Cria CTAs de alta conversão e microcopy de suporte para maximizar cliques e conversões.

## Fórmulas de CTA eficazes

- **Resultado direto:** "Quero meu site hoje"
- **Benefício + ação:** "Começar a vender mais agora"
- **Baixo risco:** "Ver demonstração gratuita"
- **Urgência:** "Garantir minha vaga (restam X)"
- **Específico:** "Agendar minha consultoria de 30 min"

## Microcopy de suporte

Texto abaixo do botão que reduz objeções:
- "Sem compromisso. Cancele quando quiser."
- "Já são +500 empresas usando"
- "Resposta em até 24h"
- "100% seguro e sem spam"

## Output

```markdown
# CTAs — [Projeto]

| # | CTA | Microcopy | Gatilho |
|---|-----|-----------|---------|
| 1 | [texto] | [suporte] | [urgência/benefício] |
[...]
```
