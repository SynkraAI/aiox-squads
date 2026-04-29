---
task:
  name: analyzePRD()
  responsavel: "@prd-analyst"
  responsavel_type: Agente
  atomic_layer: Organism

inputs:
  - campo: prd_content
    tipo: string
    origem: User Input
    obrigatorio: true
    validacao: "Texto não-vazio com descrição de produto ou funcionalidade"
  - campo: conversation_content
    tipo: string
    origem: User Input
    obrigatorio: false
    validacao: "Texto de conversa ou contexto adicional"

outputs:
  - campo: prd_structure
    tipo: object
    destino: Memory
    persistido: true
    descricao: "PRD parseado com fluxos, ações, integrações e regras de negócio identificadas"

executionModes:
  default: interactive
  interactive:
    enabled: true
    prompts: "3-7"
    description: "Analisa com perguntas de esclarecimento quando ambíguo"
  yolo:
    enabled: true
    prompts: "0"
    description: "Analisa sem perguntas, marca ambiguidades para revisão posterior"

preConditions:
  - condition: "PRD fornecido pelo usuário"
    errorMessage: "Nenhum PRD foi fornecido. Por favor, cole o PRD ou informe o caminho do arquivo."

Saida:
  - prd_structure (object → Memory)

Checklist:
  - "[ ] Ler e estruturar o PRD"
  - "[ ] Integrar conversa de contexto"
  - "[ ] Resolver ambiguidades"
  - "[ ] Gerar prd_structure final"

steps:
  - id: "1"
    description: "Ler e estruturar o PRD"
    actions:
      - "Identificar seções do PRD (objetivo, fluxos, requisitos, integrações)"
      - "Mapear todos os verbos de ação (buscar, confirmar, enviar, verificar, calcular)"
      - "Listar todos os sistemas externos mencionados"
      - "Extrair regras de negócio explícitas"
    validation: "Pelo menos um fluxo ou ação identificada"
    onFailure: escalate

  - id: "2"
    description: "Ler e integrar a conversa de contexto (se fornecida)"
    actions:
      - "Identificar definições que esclarecem termos vagos do PRD"
      - "Extrair decisões de implementação mencionadas na conversa"
      - "Anotar qualquer contradicão entre PRD e conversa"
    validation: "Conversa processada e pontos de esclarecimento anotados"
    onFailure: skip

  - id: "3"
    description: "Resolver ambiguidades"
    actions:
      - "Listar termos vagos que não foram esclarecidos pela conversa"
      - "Para cada ambiguidade: formular pergunta específica ao usuário"
      - "Aguardar resposta antes de continuar (modo interactive)"
    validation: "Zero ambiguidades críticas pendentes"
    onFailure: escalate

  - id: "4"
    description: "Gerar estrutura final do PRD"
    actions:
      - "Consolidar: fluxos, ações, integrações externas, regras de negócio, dados manipulados"
      - "Associar cada elemento ao domínio de negócio correspondente"
      - "Persistir em memória como prd_structure"
    validation: "prd_structure gerado com pelo menos: fluxos[], acoes[], integracoes[], regras[]"
    onFailure: halt

autoClaude:
  version: "3.0"
  deterministic: false
  elicit: true
  composable: true
  pipelinePhase: analysis
  complexity: standard
  selfCritique:
    required: true
    phases: ["3", "4"]
  recovery:
    maxRetries: 2
    rollbackOnFailure: false
---

# analyzePRD()

Lê e estrutura um PRD (e conversa de contexto) para extração de oportunidades de automação.

## Entrada Esperada

O usuário pode fornecer o PRD como:
- Texto colado diretamente no chat
- Caminho de arquivo (.md, .txt, .pdf)
- Descrição verbal do que o produto deve fazer

## Saída

```json
{
  "fluxos": ["fluxo 1", "fluxo 2"],
  "acoes": [
    {"verbo": "buscar", "objeto": "horários disponíveis", "sistema": "Trinks"}
  ],
  "integracoes": ["Trinks API", "WhatsApp"],
  "regras": ["não confirmar sem disponibilidade", "notificar 24h antes"],
  "dados": ["cliente_id", "service_id", "horario"],
  "dominios": ["agendamento", "notificação"],
  "ambiguidades": []
}
```
