---
task: Autorizar Próxima Fase
responsavel: "@orquestrador"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - VALIDACAO: Output de validate-handshake (status: aprovado)
  - fase_atual: intake | E1 | E2
Saida: |
  - MSG-02_AUTORIZACAO: Autorização para próxima fase
Checklist:
  - "[ ] Confirmar status == aprovado"
  - "[ ] Identificar próxima fase e agente responsável"
  - "[ ] Emitir MSG-02 AUTORIZAÇÃO"
  - "[ ] Atualizar PROJETO_ESTADO"
  - "[ ] Registrar decisão no log"
---

# *authorize-phase

Emite MSG-02 AUTORIZAÇÃO liberando próxima fase após validação aprovada.

## Output: MSG-02

```yaml
MSG-02_AUTORIZACAO:
  de: orquestrador
  para: "{proximo_agente}"
  fase_autorizada: "E1" | "E2" | "E3"
  condicionais_ativas: []
  instrucoes_especiais: null | string
  timestamp: datetime
```
