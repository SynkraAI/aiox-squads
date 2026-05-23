---
task: Definir Guia de Estilo
agent: web-designer
responsavel: "@web-designer"
responsavel_type: agent
atomic_layer: task
icon: "🖥️"
elicit: true
Entrada: |
  - briefing_completo: Briefing com referências visuais
  - referencias_visuais: URLs ou descrição de referências
Saida: |
  - guia_de_estilo: Documento completo do guia de estilo
  - cores: Paleta com uso de cada cor
  - tipografia: Fontes e escala tipográfica
  - espacamento: Sistema de espaçamento
Checklist:
  - "[ ] Definir paleta de cores (primária, secundária, neutras)"
  - "[ ] Selecionar tipografia (heading + body)"
  - "[ ] Definir escala de tamanhos"
  - "[ ] Estabelecer sistema de espaçamento"
  - "[ ] Definir estilo de botões e inputs"
  - "[ ] Documentar uso correto e incorreto"
---

# *define-style-guide

Define o guia de estilo visual completo do projeto, incluindo cores, tipografia, espaçamento e componentes base.

## Output

```markdown
# Guia de Estilo — [Projeto]

## Cores
| Uso | Nome | Hex | Onde usar |
|-----|------|-----|-----------|
| Primária | [nome] | #XXXXXX | CTAs, destaque |
| Secundária | [nome] | #XXXXXX | Suporte |
| Neutra Clara | [nome] | #XXXXXX | Backgrounds |
| Neutra Escura | [nome] | #XXXXXX | Textos |
| Alerta | [nome] | #XXXXXX | Erros, avisos |

## Tipografia
| Elemento | Fonte | Tamanho | Peso |
|----------|-------|---------|------|
| H1 | [fonte] | 48-64px | 700 |
| H2 | [fonte] | 32-40px | 600 |
| Body | [fonte] | 16-18px | 400 |
| CTA | [fonte] | 16px | 600 |

## Espaçamento
Base: 8px | Escala: 8, 16, 24, 32, 48, 64, 96px
```
