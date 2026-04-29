---
task:
  name: validateScripts()
  responsavel: "@lib-validator"
  responsavel_type: Agente
  atomic_layer: Organism

Entrada:
  - generated_scripts (array → File, obrigatório)
  - lib_design (object → Memory, obrigatório)

inputs:
  - campo: generated_scripts
    tipo: array
    origem: File (from generateScripts)
    obrigatorio: true
  - campo: lib_design
    tipo: object
    origem: Memory
    obrigatorio: true

Saida:
  - validation_report (object → Memory)
  - approved_scripts (array → Memory)

Checklist:
  - "[ ] Validar docstrings e type hints por função"
  - "[ ] Verificar compliance com design aprovado"
  - "[ ] Checar tratamento de erros em chamadas externas"
  - "[ ] Gerar relatório final com APROVADO/BLOQUEADO por script"

outputs:
  - campo: validation_report
    tipo: object
    destino: Memory
    persistido: true
  - campo: approved_scripts
    tipo: array
    destino: Memory
    persistido: true

steps:
  - id: "1"
    description: "Validar cada script contra checklist bloqueante"
    actions:
      - "Para cada função: verificar presença de docstring em português"
      - "Para cada parâmetro e retorno: verificar type hints"
      - "Para chamadas externas (requests, db): verificar try/except"
      - "Verificar consistência do tipo de retorno em todos os paths"

  - id: "2"
    description: "Validar compliance com design"
    actions:
      - "Checar que cada função do design foi implementada"
      - "Checar que nenhuma função extra foi adicionada sem aprovação"
      - "Verificar nomes correspondem exatamente ao design"

  - id: "3"
    description: "Gerar relatório"
    actions:
      - "Para cada script: APROVADO ou BLOQUEADO com motivo"
      - "Para cada item BLOQUEADO: explicar problema em português simples e como corrigir"
      - "Calcular: N scripts, N aprovados, N bloqueados"

  - id: "4"
    description: "Decidir próximo passo"
    actions:
      - "Se todos APROVADOS → notificar Forge para publicar"
      - "Se algum BLOQUEADO → retornar para @script-writer com relatório"

autoClaude:
  deterministic: true
  elicit: false
  composable: true
  pipelinePhase: validation
---

# validateScripts()

Valida scripts gerados contra critérios de qualidade obrigatórios.

## Critérios Bloqueantes

| # | Critério | Como verificar |
|---|---------|----------------|
| 1 | Docstring presente | Função tem `"""..."""` após `def` |
| 2 | Parâmetros tipados | Todos params têm `: tipo` |
| 3 | Retorno tipado | Tem `-> tipo` na assinatura |
| 4 | Erro em chamadas externas | requests/db envolvidos em try/except |
| 5 | Retorno consistente | Todos paths retornam mesmo tipo |
| 6 | Compliance com design | Sem funções extras não aprovadas |
