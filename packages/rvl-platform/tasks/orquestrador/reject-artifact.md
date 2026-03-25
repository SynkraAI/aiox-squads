---
task: Rejeitar Artefato
responsavel: "@orquestrador"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - VALIDACAO: Output de validate-handshake (status: rejeitado)
  - campos_falhados: Lista de falhas
Saida: |
  - MSG-04_REJEICAO: Mensagem de rejeição com instrução precisa
Checklist:
  - "[ ] Confirmar status == rejeitado"
  - "[ ] Para cada campo falhado: formular instrução precisa de correção"
  - "[ ] Emitir MSG-04 REJEIÇÃO"
  - "[ ] Atualizar PROJETO_ESTADO"
  - "[ ] Registrar decisão no log"
---

# *reject-artifact

Emite MSG-04 REJEIÇÃO com instrução precisa de correção para o agente.

## Princípio

Instrução precisa, não vaga.
Não "o artefato está incompleto" — mas "o campo proposito tem 30 palavras, máximo é 25".

## Output: MSG-04

```yaml
MSG-04_REJEICAO:
  de: orquestrador
  para: "{agente_que_enviou}"
  artefato_rejeitado: string
  instrucoes_correcao:
    - campo: string
      problema: string
      instrucao: string
  status: "aguardando_correcao"
  timestamp: datetime
```
