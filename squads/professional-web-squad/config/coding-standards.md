# Coding Standards — professional-web-squad

## Princípios gerais

- Semântica HTML5 correta (section, article, nav, main, header, footer)
- CSS: variáveis CSS para tokens de design (cores, fontes, espaçamento)
- Mobile-first: media queries do menor para o maior breakpoint
- Performance: imagens otimizadas (WebP, lazy loading), fontes com font-display: swap
- Acessibilidade: WCAG AA mínimo, aria-labels, foco visível

## Nomenclatura

- Classes CSS: BEM (block__element--modifier)
- IDs: apenas para âncoras e formulários
- Arquivos: kebab-case (hero-section.html)

## Estrutura de arquivos recomendada

```
projeto/
├── index.html
├── css/
│   ├── tokens.css      # Design tokens (variáveis CSS)
│   ├── base.css        # Reset e estilos globais
│   └── components/     # Estilos por seção
├── js/
│   └── main.js
└── assets/
    └── images/
```
