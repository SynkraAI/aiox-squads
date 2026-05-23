---
task: Criar Moodboard
agent: ui-ux-expert
responsavel: "@ui-ux-expert"
responsavel_type: agent
atomic_layer: task
icon: "🎨"
elicit: true
Entrada: |
  - briefing_completo: Briefing com tom e objetivos
  - referencias_visuais: URLs ou descrições de referências do cliente
Saida: |
  - moodboard: Direção criativa documentada
  - direcao_criativa: Descrição da estética escolhida
  - justificativa: Por que essa direção serve ao objetivo
Checklist:
  - "[ ] Coletar referências do cliente"
  - "[ ] Pesquisar referências do mercado"
  - "[ ] Identificar padrões visuais desejados"
  - "[ ] Definir adjetivos visuais da marca"
  - "[ ] Documentar direção criativa"
  - "[ ] Validar com o cliente"
---

# *create-moodboard

Cria o moodboard e define a direção criativa visual do projeto antes da execução do design.

## Adjetivos visuais (escolha 3-5)

```
Moderno | Elegante | Bold | Minimalista | Vibrante
Profissional | Amigável | Premium | Jovem | Confiável
Tecnológico | Natural | Orgânico | Limpo | Dinâmico
```

## Elementos do moodboard

1. **Paleta de humor:** cores que evocam a emoção certa
2. **Referências de sites:** 3-5 sites com elementos admiráveis
3. **Referências de tipografia:** exemplos do estilo de texto
4. **Referências de imagem:** estilo fotográfico ou ilustrativo
5. **Referências de layout:** grids, espaçamento, ritmo visual

## Output

```markdown
# Moodboard — [Projeto]

## Adjetivos visuais
[adjetivo 1], [adjetivo 2], [adjetivo 3]

## Direção criativa
[Parágrafo descrevendo a estética: "O design deve transmitir X através de Y..."]

## Referências
- **Layout:** [URL ou descrição]
- **Tipografia:** [URL ou descrição]
- **Cores:** [URL ou descrição]
- **Fotografia/Ícones:** [URL ou descrição]

## O que EVITAR
- [elemento visual a evitar]
- [elemento visual a evitar]
```
