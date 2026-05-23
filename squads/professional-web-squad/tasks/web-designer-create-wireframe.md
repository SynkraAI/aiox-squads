---
task: Criar Wireframe
agent: web-designer
responsavel: "@web-designer"
responsavel_type: agent
atomic_layer: task
icon: "🖥️"
elicit: true
Entrada: |
  - estrutura_pagina: Seções planejadas e ordenadas
  - copy_aprovado: Copy ou rascunho de copy disponível
Saida: |
  - wireframe_anotado: Wireframe ASCII ou descritivo de cada seção
  - notas_ux: Anotações de UX e comportamento
Checklist:
  - "[ ] Wireframe do Hero (desktop e mobile)"
  - "[ ] Wireframe de cada seção"
  - "[ ] Anotar hierarquia visual"
  - "[ ] Indicar posições de CTA"
  - "[ ] Notas de comportamento (hover, scroll, animações)"
---

# *create-wireframe

Cria wireframes anotados de cada seção da página, especificando layout, hierarquia e comportamento.

## Formato de wireframe ASCII

```
┌─────────────────────────────────────┐
│  [LOGO]              [MENU] [CTA]   │  ← Nav: sticky, CTA destaque
├─────────────────────────────────────┤
│                                     │
│  [HEADLINE PRINCIPAL]               │  ← H1: acima da dobra
│  [Subheadline de apoio]             │
│                                     │
│  [CTA PRIMÁRIO] [CTA SECUNDÁRIO]    │  ← CTAs: 40px height mín.
│                                     │
│  [Imagem Hero / Vídeo]              │  ← Visual: direita no desktop
│                                     │
└─────────────────────────────────────┘
```

## Output

```markdown
# Wireframe — [Projeto]

## Seção 1: Hero
[ASCII wireframe]
**Notas UX:** [comportamento, animações, responsivo]

## Seção 2: [Nome]
[ASCII wireframe]
[...]
```
