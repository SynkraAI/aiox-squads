---
task:
  name: extractOpportunities()
  responsavel: "@prd-analyst"
  responsavel_type: Agente
  atomic_layer: Organism

inputs:
  - campo: prd_structure
    tipo: object
    origem: Memory (from analyzePRD)
    obrigatorio: true

outputs:
  - campo: opportunities_map
    tipo: array
    destino: Memory
    persistido: true
    descricao: "Lista de oportunidades de automação prontas para @lib-architect"

Checklist:
  - "[ ] Classificar cada ação do PRD por tipo de oportunidade"
  - "[ ] Enriquecer cada oportunidade com entrada, saída e domínio"
  - "[ ] Deduplicar e consolidar oportunidades"
  - "[ ] Apresentar mapa ao usuário para revisão"

steps:
  - id: "1"
    description: "Classificar cada ação do PRD por tipo de oportunidade"
    actions:
      - "Para cada acao[] em prd_structure: classificar como integração/validação/automação/notificação/cálculo/transformação"
      - "Para cada integração em integracoes[]: criar oportunidade de tipo 'integração'"
      - "Para cada regra em regras[]: criar oportunidade de tipo 'validação'"
    validation: "Cada elemento de prd_structure mapeado para pelo menos uma oportunidade"

  - id: "2"
    description: "Enriquecer cada oportunidade"
    actions:
      - "Definir entrada esperada (tipos e exemplos)"
      - "Definir saída esperada (tipo e estrutura)"
      - "Associar ao domínio de negócio"
      - "Atribuir prioridade (alta/média/baixa)"
      - "Citar trecho do PRD ou conversa que originou"

  - id: "3"
    description: "Deduplicar e consolidar"
    actions:
      - "Identificar oportunidades que se sobrepõem"
      - "Consolidar em uma única oportunidade quando possível"
      - "Numerar com ID sequencial (OP001, OP002...)"

autoClaude:
  deterministic: false
  elicit: false
  composable: true
  pipelinePhase: analysis
---

# extractOpportunities()

Transforma a estrutura do PRD em um mapa de oportunidades concretas de automação.

## Formato de Cada Oportunidade

```
ID: OP001
Tipo: integração
Domínio: agendamento
Descrição: Buscar horários disponíveis no Trinks para um serviço e data
Entrada: service_id (string), data (string)
Saída: lista de slots com horário e profissional
Prioridade: alta
Origem PRD: "mostrar horários antes de confirmar"
Origem Conversa: "API Trinks tem endpoint /availability"
```

## Tipos de Oportunidade

| Tipo | Gatilho no PRD |
|------|----------------|
| integração | "buscar de", "enviar para", "consultar", sistema externo mencionado |
| validação | "verificar se", "garantir que", regra de negócio |
| automação | ação repetitiva, "sempre que", "a cada" |
| notificação | "notificar", "avisar", "enviar mensagem" |
| cálculo | "calcular", "pontuar", "classificar" |
| transformação | "formatar", "converter", "organizar" |
