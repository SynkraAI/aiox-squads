---
task: Verificar Core Web Vitals
agent: seo-specialist
responsavel: "@seo-specialist"
responsavel_type: agent
atomic_layer: task
icon: "📈"
elicit: true
Entrada: |
  - url_pagina: URL da página publicada
Saida: |
  - scores_cwv: Scores de LCP, FID/INP e CLS
  - itens_melhoria: Lista de elementos a otimizar
  - prioridades: Ordem de correção por impacto
Checklist:
  - "[ ] Medir LCP (Largest Contentful Paint)"
  - "[ ] Medir INP (Interaction to Next Paint)"
  - "[ ] Medir CLS (Cumulative Layout Shift)"
  - "[ ] Identificar elementos problemáticos"
  - "[ ] Gerar plano de otimização"
---

# *check-core-web-vitals

Verifica as métricas Core Web Vitals do Google e gera recomendações de otimização.

## Metas (Google Pass)

| Métrica | Meta | Descrição |
|---------|------|-----------|
| **LCP** | ≤ 2.5s | Maior elemento visível carregado |
| **INP** | ≤ 200ms | Resposta a interações do usuário |
| **CLS** | ≤ 0.1 | Estabilidade visual da página |

## Causas comuns de falha

**LCP alto:**
- Imagens hero sem lazy loading ou compressão
- Web fonts bloqueando renderização
- Servidor lento (TTFB > 600ms)

**CLS alto:**
- Imagens sem width/height definidos
- Anúncios/embeds sem espaço reservado
- Fontes causando layout shift (FOUT)

## Output

```markdown
# Core Web Vitals — [Projeto]

| Métrica | Score | Meta | Status |
|---------|-------|------|--------|
| LCP | [X]s | ≤2.5s | ✅/⚠️/❌ |
| INP | [X]ms | ≤200ms | ✅/⚠️/❌ |
| CLS | [X] | ≤0.1 | ✅/⚠️/❌ |

## Ações prioritárias
1. [ação com maior impacto]
2. [...]
```
