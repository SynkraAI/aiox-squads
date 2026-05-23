---
task: Pesquisa de Keywords
agent: seo-specialist
responsavel: "@seo-specialist"
responsavel_type: agent
atomic_layer: task
icon: "📈"
elicit: true
Entrada: |
  - segmento: Mercado/nicho do projeto
  - proposta_de_valor: Proposta de valor definida
  - localizacao: Localização geográfica alvo (Brasil, SP, etc.)
Saida: |
  - keywords_primarias: 3-5 keywords principais com volume estimado
  - keywords_secundarias: 10-20 keywords de cauda longa
  - volume_busca: Estimativa de volume mensal
Checklist:
  - "[ ] Pesquisar keywords principais do segmento"
  - "[ ] Identificar intenção de busca"
  - "[ ] Mapear keywords de cauda longa"
  - "[ ] Verificar competitividade (baixa/média/alta)"
  - "[ ] Organizar por prioridade"
---

# *keyword-research

Pesquisa e mapeia as melhores keywords para posicionar o site nos mecanismos de busca.

## Tipos de intenção de busca

| Intenção | Exemplo | Objetivo |
|----------|---------|----------|
| Informacional | "como criar landing page" | Topo do funil |
| Navegacional | "criação de sites SP" | Meio do funil |
| Transacional | "contratar designer de sites" | Fundo do funil |
| Comercial | "melhor agência landing page" | Decisão de compra |

## Output

```markdown
# Keywords — [Projeto]

## Keywords Primárias
| Keyword | Volume/mês | Dificuldade | Intenção |
|---------|-----------|-------------|----------|
| [kw]    | [vol]     | [baixa/média/alta] | [tipo] |

## Keywords Secundárias (cauda longa)
- [keyword 1]
- [keyword 2]
[...]

## Recomendação de foco
**Keyword principal:** [kw]
**Justificativa:** [razão da escolha]
```
