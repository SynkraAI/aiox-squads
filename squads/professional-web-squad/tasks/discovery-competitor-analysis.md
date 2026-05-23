---
task: Análise de Concorrentes
agent: discovery
responsavel: "@discovery"
responsavel_type: agent
atomic_layer: task
icon: "🔍"
elicit: true
Entrada: |
  - segmento: Mercado/nicho do projeto
  - concorrentes_conhecidos: Lista de concorrentes mencionados pelo cliente
Saida: |
  - analise_competitiva: Tabela comparativa dos concorrentes
  - oportunidades: Gaps e oportunidades identificadas
  - gaps: O que os concorrentes não oferecem
Checklist:
  - "[ ] Listar 3-5 concorrentes diretos"
  - "[ ] Analisar posicionamento de cada um"
  - "[ ] Avaliar copy e proposta de valor"
  - "[ ] Identificar padrões de design"
  - "[ ] Mapear gaps e oportunidades"
---

# *competitor-analysis

Analisa os principais concorrentes para identificar oportunidades de posicionamento e diferenciação.

## Análise por concorrente

Para cada concorrente, avaliar:
- Proposta de valor principal
- Público-alvo declarado
- Pontos fortes do site
- Pontos fracos do site
- CTA principal
- Tom de voz

## Output

```markdown
# Análise Competitiva

| Concorrente | Proposta | Pontos Fortes | Pontos Fracos | CTA |
|-------------|----------|---------------|---------------|-----|
| [nome]      | [...]    | [...]         | [...]         | [...] |

## Oportunidades identificadas
- [oportunidade 1]
- [oportunidade 2]

## Gaps do mercado
- [gap 1]
- [gap 2]
```
