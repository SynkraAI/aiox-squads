---
task: Planejar Seções da Página
agent: web-designer
responsavel: "@web-designer"
responsavel_type: agent
atomic_layer: task
icon: "🖥️"
elicit: true
Entrada: |
  - briefing_completo: Briefing do projeto
  - objetivo_conversao: Objetivo principal da página
Saida: |
  - estrutura_pagina: Lista ordenada de seções
  - ordem_secoes: Justificativa para ordem escolhida
  - hierarquia: Importância visual de cada seção
Checklist:
  - "[ ] Definir tipo de página (landing / site completo)"
  - "[ ] Selecionar seções necessárias"
  - "[ ] Ordenar por jornada do visitante"
  - "[ ] Definir hierarquia visual"
  - "[ ] Validar com objetivo de conversão"
---

# *plan-sections

Planeja a estrutura e ordem das seções da página com base na jornada do visitante e no objetivo de conversão.

## Seções padrão (landing page de conversão)

```
1. Hero           → Capturar atenção (acima da dobra)
2. Problema       → Identificar a dor do visitante
3. Solução        → Apresentar o produto/serviço
4. Benefícios     → Detalhar o valor entregue
5. Como funciona  → Reduzir fricção e incerteza
6. Prova social   → Depoimentos e resultados
7. Oferta/Preço   → Apresentar a proposta comercial
8. FAQ            → Quebrar objeções finais
9. CTA Final      → Provocar a conversão
10. Rodapé        → Confiança e informações legais
```

## Output

```markdown
# Estrutura da Página — [Projeto]

| Ordem | Seção | Objetivo | Prioridade |
|-------|-------|----------|------------|
| 1 | Hero | [objetivo] | Alta |
[...]

## Justificativa da ordem
[Explicação da jornada do visitante]
```
