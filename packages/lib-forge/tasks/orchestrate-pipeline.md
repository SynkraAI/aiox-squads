---
task:
  name: orchestratePipeline()
  responsavel: "@lib-forge-chief"
  responsavel_type: Agente
  atomic_layer: Page

Entrada:
  - prd_source (string → User Input, obrigatório)
  - conversation_source (string → User Input, opcional)
  - profile (string → User Input, default: full)

inputs:
  - campo: prd_source
    tipo: string
    origem: User Input
    obrigatorio: true
    validacao: "Texto colado, caminho de arquivo (.md/.txt/.pdf) ou descrição verbal do produto"
  - campo: conversation_source
    tipo: string
    origem: User Input
    obrigatorio: false
    validacao: "Conversa de contexto adicional — recomendado mas não obrigatório"
  - campo: profile
    tipo: string
    origem: User Input
    obrigatorio: false
    validacao: "full | analysis-only | generate-only (default: full)"

Saida:
  - pipeline_status (object → Memory)
  - delivery_summary (string → User)

Checklist:
  - "[ ] Receber e confirmar material com usuário"
  - "[ ] Selecionar perfil de execução"
  - "[ ] Coordenar todas as fases do pipeline"
  - "[ ] Monitorar e reportar estado entre fases"
  - "[ ] Entregar resultado final ao usuário"

outputs:
  - campo: pipeline_status
    tipo: object
    destino: Memory
    persistido: true
    descricao: "Estado atual do pipeline: fase corrente, checkpoints concluídos, bloqueios"
  - campo: delivery_summary
    tipo: string
    destino: User
    persistido: false
    descricao: "Resumo do que foi entregue ao final do pipeline"

preConditions:
  - condition: "PRD ou material de contexto fornecido pelo usuário"
    errorMessage: "Nenhum material fornecido. Cole o PRD ou descreva o que o produto deve fazer."

steps:
  - id: "1"
    description: "Receber e confirmar material"
    actions:
      - "Exibir estado atual do pipeline antes de qualquer ação"
      - "Identificar se PRD foi fornecido (arquivo, texto ou descrição verbal)"
      - "Identificar se conversa de contexto foi fornecida"
      - "Confirmar material com o usuário antes de avançar"
    validation: "Usuário confirmou que o material está completo"
    onFailure: request_more_input

  - id: "2"
    description: "Selecionar perfil de execução"
    actions:
      - "Se perfil explicitado → usar perfil indicado"
      - "Se não explicitado → usar perfil 'full'"
      - "Informar ao usuário qual perfil está sendo usado e o que cada fase fará"
    validation: "Perfil selecionado é válido (full | analysis-only | generate-only)"
    onFailure: default_to_full

  - id: "3"
    description: "Executar pipeline conforme wf-prd-to-lib.yaml"
    actions:
      - "PHASE_1: Confirmar material recebido (esta task)"
      - "PHASE_2: Delegar análise para @prd-analyst (tasks/analyze-prd.md + extract-opportunities.md)"
      - "PHASE_3: Delegar design para @lib-architect (tasks/design-lib-structure.md) + aguardar aprovação humana"
      - "PHASE_4: Delegar geração para @script-writer (tasks/generate-scripts.md)"
      - "PHASE_5: Delegar validação para @lib-validator (tasks/validate-scripts.md)"
      - "PHASE_6: Executar publicação (tasks/publish-to-victor-libs.md)"
    validation: "Cada fase conclui com checkpoint aprovado antes de avançar"
    onFailure: halt_and_report

  - id: "4"
    description: "Monitorar e reportar estado"
    actions:
      - "Atualizar pipeline_status a cada transição de fase"
      - "Apresentar progresso ao usuário entre fases"
      - "Em caso de bloqueio: reportar fase, motivo e opções de resolução"
    validation: "Usuário tem visibilidade do estado em todo momento"
    onFailure: escalate

  - id: "5"
    description: "Entregar resultado final"
    actions:
      - "Listar scripts publicados em victor-libs/"
      - "Resumir oportunidades atendidas vs total mapeado"
      - "Informar localização dos arquivos gerados"
      - "Sugerir próximos passos se houver oportunidades não atendidas"
    validation: "Usuário recebeu resumo claro do que foi entregue"
    onFailure: retry_delivery

autoClaude:
  version: "3.0"
  deterministic: true
  elicit: true
  composable: false
  pipelinePhase: orchestration
  complexity: standard
  recovery:
    maxRetries: 1
    rollbackOnFailure: false
---

# orchestratePipeline()

Ponto de entrada principal do lib-forge. Recebe o material do usuário, confirma o contexto e
coordena todas as fases do pipeline PRD → biblioteca, delegando cada fase ao agente responsável.

## Quando usar

Esta task é executada automaticamente quando o usuário inicia o lib-forge ou digita
qualquer comando de início de sessão (ex: "quero gerar uma lib", "analisa este PRD").

## Estado do Pipeline

O Forge sempre exibe o estado antes de agir:

```
🔥 lib-forge Pipeline
━━━━━━━━━━━━━━━━━━━━━
✅ PHASE_1: Recepção         [concluída]
⏳ PHASE_2: Análise          [em andamento]
⏸  PHASE_3: Design           [aguardando]
⏸  PHASE_4: Geração          [aguardando]
⏸  PHASE_5: Validação        [aguardando]
⏸  PHASE_6: Entrega          [aguardando]
```

## Veto Conditions

| ID | Condição | Ação |
|---|---|---|
| LF_VETO_001 | Usuário não aprovou design em PHASE_3 | BLOQUEAR geração |
| LF_VETO_002 | Script gerado com função fora do design | BLOQUEAR e reportar desvio |
| LF_VETO_003 | Script sem docstring chega na validação | BLOQUEAR e retornar para @script-writer |
| LF_VETO_004 | Zero oportunidades identificadas em PHASE_2 | BLOQUEAR e pedir mais contexto |
