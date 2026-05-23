---
task: Revisão de UI
agent: ui-ux-expert
responsavel: "@ui-ux-expert"
responsavel_type: agent
atomic_layer: task
icon: "🎨"
elicit: true
Entrada: |
  - design_implementado: URL, screenshot ou arquivo do design implementado
Saida: |
  - feedback_ui: Feedback detalhado por seção
  - inconsistencias: Lista de inconsistências visuais
  - melhorias: Melhorias priorizadas por impacto
Checklist:
  - "[ ] Verificar consistência da paleta de cores"
  - "[ ] Verificar hierarquia tipográfica"
  - "[ ] Checar alinhamento e espaçamento"
  - "[ ] Avaliar contraste e acessibilidade"
  - "[ ] Verificar responsividade (mobile/tablet/desktop)"
  - "[ ] Avaliar qualidade visual geral"
  - "[ ] Verificar consistência de componentes"
---

# *ui-review

Revisa a UI implementada com olhar sênior, identificando inconsistências e oportunidades de melhoria.

## Critérios de avaliação

| Critério | Peso | O que verificar |
|----------|------|-----------------|
| Consistência visual | Alta | Cores, fontes, espaçamento padronizados |
| Hierarquia | Alta | Clareza na ordem de leitura |
| Contraste | Alta | Legibilidade em todos os elementos |
| Alinhamento | Média | Grid limpo, sem elementos desalinhados |
| Espaçamento | Média | Respiração adequada, não sufocado |
| Responsividade | Alta | Funcional em todos os breakpoints |
| Microinterações | Baixa | Hover, focus, transições suaves |

## Output

```markdown
# Revisão UI — [Projeto]

## Score por critério
| Critério | Score | Status |
|----------|-------|--------|
| Consistência | X/10 | ✅/⚠️/❌ |
[...]

## Issues por seção
### [Seção]
- ⚠️ [issue]
- ❌ [issue crítico]

## Top 5 melhorias prioritárias
1. [melhoria de maior impacto]
[...]
```
