---
task:
  name: designLibStructure()
  responsavel: "@lib-architect"
  responsavel_type: Agente
  atomic_layer: Template

Entrada:
  - opportunities_map (array → Memory, obrigatório)

inputs:
  - campo: opportunities_map
    tipo: array
    origem: Memory (from extractOpportunities)
    obrigatorio: true

Saida:
  - lib_design (object → Memory)
  - design_document (file → victor-libs/DESIGN.md)

Checklist:
  - "[ ] Agrupar oportunidades por domínio"
  - "[ ] Definir assinaturas de funções com type hints"
  - "[ ] Mapear dependências necessárias"
  - "[ ] Aguardar aprovação humana antes de avançar"

outputs:
  - campo: lib_design
    tipo: object
    destino: Memory
    persistido: true
  - campo: design_document
    tipo: string
    destino: File
    persistido: true
    path: "victor-libs/DESIGN.md"

human_gate:
  required: true
  message: "Design pronto para revisão. Confirme antes de gerar código."

steps:
  - id: "1"
    description: "Agrupar oportunidades por domínio"
    actions:
      - "Agrupar todas as oportunidades pelo campo domínio"
      - "Cada domínio vira uma pasta em victor-libs/"
      - "Dentro do domínio, agrupar por módulo funcional (disponibilidade, agendamento, notificações)"

  - id: "2"
    description: "Definir assinaturas de funções"
    actions:
      - "Para cada oportunidade: definir nome da função em snake_case português"
      - "Definir parâmetros com type hints Python"
      - "Definir tipo de retorno"
      - "Garantir: nome autoexplicativo, uma responsabilidade, sem abreviações"

  - id: "3"
    description: "Gerar documento de design"
    actions:
      - "Renderizar estrutura de pastas visual (usando árvore ASCII)"
      - "Para cada função: nome, assinatura tipada, descrição em 1 linha"
      - "Listar dependências pip necessárias"
      - "Apresentar ao usuário para aprovação"

  - id: "4"
    description: "Aguardar e processar aprovação"
    actions:
      - "Exibir design ao usuário"
      - "Aguardar: APROVADO ou lista de ajustes"
      - "Se ajustes: aplicar e reapresentar"
      - "Se APROVADO: persistir lib_design em memória"
    onFailure: escalate

autoClaude:
  deterministic: false
  elicit: true
  composable: true
  pipelinePhase: design
---

# designLibStructure()

Projeta a estrutura da biblioteca antes de gerar código.

## Exemplo de Documento de Design Gerado

```markdown
# Design — victor-libs/salao/

## Estrutura de Pastas

victor-libs/
└── salao/
    ├── disponibilidade.py
    ├── agendamento.py
    └── notificacoes.py

## Funções por Arquivo

### disponibilidade.py
buscar_horarios_disponiveis(service_id: str, data: str, api_url: str, api_key: str) -> list[dict]
→ Retorna slots disponíveis com profissional

verificar_profissional_disponivel(prof_id: str, horario: str, api_url: str, api_key: str) -> bool
→ Verifica se profissional está livre no horário

### agendamento.py
confirmar_agendamento(cliente_id: str, slot_id: str, api_url: str, api_key: str) -> dict
→ Confirma booking e retorna código de confirmação

cancelar_agendamento(booking_id: str, api_url: str, api_key: str) -> bool
→ Cancela booking, retorna True se sucesso

### notificacoes.py
enviar_confirmacao_whatsapp(numero: str, detalhes_agendamento: dict) -> bool
→ Envia mensagem de confirmação via WhatsApp

## Dependências
pip install requests python-dotenv

---
AGUARDANDO APROVAÇÃO ✋
```
