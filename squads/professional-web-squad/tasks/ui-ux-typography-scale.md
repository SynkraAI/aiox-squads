---
task: Definir Escala Tipográfica
agent: ui-ux-expert
responsavel: "@ui-ux-expert"
responsavel_type: agent
atomic_layer: task
icon: "🎨"
elicit: true
Entrada: |
  - guia_de_estilo: Guia de estilo base (se existir)
  - tom_da_marca: Tom de voz (moderno, clássico, bold, minimalista)
Saida: |
  - escala_tipografica: Escala completa de tamanhos e pesos
  - fontes_selecionadas: Fontes para heading e body
  - hierarquia: Guia de uso de cada nível
Checklist:
  - "[ ] Selecionar fonte para headings"
  - "[ ] Selecionar fonte para body"
  - "[ ] Definir escala de tamanhos"
  - "[ ] Definir pesos (font-weight)"
  - "[ ] Definir line-height por elemento"
  - "[ ] Verificar legibilidade em mobile"
---

# *typography-scale

Define a escala tipográfica completa do projeto, garantindo hierarquia clara e legibilidade em todos os dispositivos.

## Combinações de fontes recomendadas

| Estilo | Heading | Body | Caráter |
|--------|---------|------|---------|
| Moderno | Inter | Inter | Clean, tech |
| Editorial | Playfair Display | Lato | Premium, elegante |
| Bold | Montserrat | Open Sans | Forte, confiante |
| Humanista | Nunito | Source Sans | Amigável, acessível |

## Output

```markdown
# Escala Tipográfica — [Projeto]

## Fontes
- **Heading:** [fonte] (Google Fonts)
- **Body:** [fonte] (Google Fonts)

## Escala

| Elemento | Tamanho | Peso | Line-height | Uso |
|----------|---------|------|-------------|-----|
| H1 | 56px / 40px mob | 700 | 1.1 | Headline hero |
| H2 | 40px / 32px mob | 600 | 1.2 | Títulos de seção |
| H3 | 28px / 24px mob | 600 | 1.3 | Subtítulos |
| Body L | 18px | 400 | 1.6 | Textos principais |
| Body | 16px | 400 | 1.6 | Textos gerais |
| Small | 14px | 400 | 1.5 | Legendas, notas |
| CTA | 16px | 600 | 1 | Botões |
```
