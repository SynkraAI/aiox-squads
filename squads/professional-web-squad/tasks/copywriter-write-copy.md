---
task: Escrever Copy de Seção
agent: copywriter
responsavel: "@copywriter"
responsavel_type: agent
atomic_layer: task
icon: "✍️"
elicit: true
Entrada: |
  - briefing_completo: Briefing do projeto
  - persona_documento: Persona definida
  - secao_alvo: Qual seção será escrita (hero, benefícios, sobre, depoimentos, FAQ, CTA)
Saida: |
  - copy_secao: Copy completo da seção solicitada
  - alternativas: 2 variações alternativas
Checklist:
  - "[ ] Identificar objetivo da seção"
  - "[ ] Adaptar tom ao público-alvo"
  - "[ ] Escrever versão principal"
  - "[ ] Revisar clareza e persuasão"
  - "[ ] Gerar 2 variações alternativas"
---

# *write-copy

Escreve copy persuasivo para seções específicas da página, adaptado à persona e ao objetivo de conversão.

## Seções suportadas

| Seção | Objetivo | Tom |
|-------|----------|-----|
| Hero | Capturar atenção imediata | Direto, impactante |
| Benefícios | Convencer com lógica | Claro, específico |
| Sobre | Gerar confiança | Humano, autêntico |
| Depoimentos | Prova social | Natural, específico |
| FAQ | Quebrar objeções | Empático, direto |
| CTA Final | Provocar ação | Urgente, motivador |

## Princípios

- Escrever para a persona, não para o cliente
- Benefícios > Features
- Específico > Genérico
- Uma ideia por parágrafo
- CTA claro em toda seção
