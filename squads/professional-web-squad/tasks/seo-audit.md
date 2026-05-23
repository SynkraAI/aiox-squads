---
task: Auditoria SEO On-Page
agent: seo-specialist
responsavel: "@seo-specialist"
responsavel_type: agent
atomic_layer: task
icon: "📈"
elicit: true
Entrada: |
  - url_ou_html_pagina: URL da página publicada ou HTML para análise
Saida: |
  - relatorio_seo: Relatório completo de SEO on-page
  - issues_criticos: Lista de problemas críticos
  - recomendacoes: Recomendações priorizadas
Checklist:
  - "[ ] Verificar estrutura de headings (H1→H2→H3)"
  - "[ ] Avaliar densidade de keywords"
  - "[ ] Checar atributos alt em imagens"
  - "[ ] Verificar links internos e externos"
  - "[ ] Avaliar velocidade de carregamento"
  - "[ ] Verificar mobile-friendliness"
  - "[ ] Checar meta tags"
  - "[ ] Verificar Schema Markup"
---

# *audit-seo

Audita o SEO on-page da página e gera relatório com issues e recomendações priorizadas.

## Checklist de Auditoria

### Técnico
- [ ] H1 único e com keyword
- [ ] Hierarquia de headings lógica
- [ ] Meta title dentro de 60 chars
- [ ] Meta description dentro de 160 chars
- [ ] Imagens com alt text descritivo
- [ ] URL amigável e com keyword
- [ ] HTTPS ativo
- [ ] Sitemap.xml presente
- [ ] robots.txt configurado

### Conteúdo
- [ ] Keyword na primeira frase
- [ ] Densidade de keyword 1-2%
- [ ] Conteúdo original (sem duplicação)
- [ ] Links internos relevantes
- [ ] Links externos de autoridade

## Output

```markdown
# Relatório SEO — [Projeto]

## Score Geral: [X/100]

## Issues Críticos
- [ ] [issue]

## Recomendações
| Prioridade | Ação | Impacto |
|------------|------|---------|
| Alta | [ação] | [impacto] |
```
