---
task: Briefing Completo
agent: discovery
responsavel: "@discovery"
responsavel_type: agent
atomic_layer: task
icon: "🔍"
elicit: true
Entrada: |
  - objetivo_do_site: Qual o objetivo principal (vender, capturar leads, informar)
  - tipo_de_negocio: Produto, serviço, pessoal ou institucional
  - publico_alvo: Descrição inicial do público
Saida: |
  - briefing_completo: Documento de briefing estruturado
  - restricoes: Restrições de marca, prazo ou tecnologia
  - referencias: Sites de referência e inspiração
Checklist:
  - "[ ] Coletar objetivo do site"
  - "[ ] Identificar tipo de negócio"
  - "[ ] Mapear público-alvo inicial"
  - "[ ] Levantar referências visuais"
  - "[ ] Documentar restrições e prazos"
  - "[ ] Confirmar briefing com cliente"
---

# *briefing

Conduz o briefing inicial com o cliente para entender o objetivo, público-alvo e contexto do projeto antes de qualquer criação.

## Perguntas-chave

1. **Objetivo:** O que você quer que o visitante faça ao acessar o site?
2. **Negócio:** O que você vende/oferece? Qual o diferencial?
3. **Público:** Para quem é esse site? Qual a dor principal desse público?
4. **Referências:** Quais sites você admira? O que gosta e o que não gosta neles?
5. **Restrições:** Tem identidade visual? Cores obrigatórias? Prazo?

## Output

```markdown
# Briefing — [Nome do Projeto]

**Objetivo:** [capturar leads / vender / informar]
**Tipo:** [produto / serviço / pessoal / institucional]
**Público-alvo:** [descrição]
**Proposta inicial:** [o que torna único]
**Referências:** [links]
**Restrições:** [cores, prazos, tecnologias]
```
