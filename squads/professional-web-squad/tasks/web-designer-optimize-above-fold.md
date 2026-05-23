---
task: Otimizar Acima da Dobra
agent: web-designer
responsavel: "@web-designer"
responsavel_type: agent
atomic_layer: task
icon: "🖥️"
elicit: true
Entrada: |
  - wireframe_anotado: Wireframe do hero
  - headline_aprovada: Headline selecionada
Saida: |
  - hero_otimizado: Especificação detalhada do hero
  - recomendacoes_cta: Posição, cor e texto do CTA principal
Checklist:
  - "[ ] Garantir headline visível sem scroll"
  - "[ ] CTA primário acima da dobra"
  - "[ ] Hierarquia visual clara (H1 → Sub → CTA)"
  - "[ ] Visual de apoio que reforça a mensagem"
  - "[ ] Otimizar para mobile first"
  - "[ ] Verificar contraste e legibilidade"
---

# *optimize-above-fold

Otimiza a área acima da dobra (hero) para máximo impacto e conversão imediata.

## Checklist de conversão do Hero

- [ ] Headline responde: "O que é isso e por que me importo?"
- [ ] Subheadline complementa sem repetir
- [ ] CTA principal em destaque visual claro
- [ ] Visual reforça a proposta (não decora apenas)
- [ ] Sem distrações: navegação limpa
- [ ] Mobile: tudo visível sem scroll no iPhone SE

## Output

```markdown
# Hero Otimizado — [Projeto]

**Headline:** [texto final]
**Subheadline:** [texto final]
**CTA:** [texto] | Cor: [hex] | Posição: [centralizado/esquerda]
**Visual:** [descrição do elemento visual]

## Especificação técnica
- Max-width: 1200px
- Padding: 120px top, 80px bottom
- Mobile: stack vertical, CTA full-width
```
