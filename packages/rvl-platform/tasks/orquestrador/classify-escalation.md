---
task: Classificar Escalada
responsavel: "@orquestrador"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - MSG-03_ESCALADA: Mensagem de escalada enviada por agente
Saida: |
  - natureza_classificada: Tipo da escalada
  - encaminhamento: Próxima ação e agente responsável
Checklist:
  - "[ ] Ler MSG-03 ESCALADA completa"
  - "[ ] Classificar natureza da escalada"
  - "[ ] Decidir encaminhamento"
  - "[ ] Registrar no log"
  - "[ ] Comunicar decisão ao agente escalante"
---

# *classify-escalation

Classifica MSG-03 ESCALADA e decide encaminhamento correto.

## Tipos de Escalada

| Natureza | Definição | Encaminhamento |
|----------|-----------|----------------|
| `invalida_posicionamento` | Corrigir E2 não resolve, precisa tocar E1 | Retornar ao ESTRATEGISTA |
| `invalida_expressao` | Corrigir E2 resolve sem tocar E1 | Retornar ao EXPRESSÃO |
| `muda_arquetipo` | Arquétipo identificado parece errado | Retornar ao INTAKE |
| `condicional_necessaria` | Agente detectou necessidade de ferramenta condicional | Avaliar ativação |

## Critério Crítico

Distinguir `invalida_posicionamento` de `invalida_expressao`:
- Se corrigir E2 resolve → `invalida_expressao`
- Se corrigir E2 apenas mascara o problema → `invalida_posicionamento`

## Output

```yaml
CLASSIFICACAO_ESCALADA:
  natureza: "invalida_posicionamento" | "invalida_expressao" | "muda_arquetipo" | "condicional_necessaria"
  justificativa: string
  encaminhamento:
    agente: string
    instrucao: string
  timestamp: datetime
```
