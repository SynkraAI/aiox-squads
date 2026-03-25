---
task: Enviar Handshake E1
responsavel: "@estrategista"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - GENE_DNA: Artefato validado
  - LENS_DIFERENCIAL: Artefato validado
  - FRAME_PLATAFORMA: Artefato validado
Saida: |
  - MSG-01_HANDSHAKE_E1: Mensagem de handshake para ORQUESTRADOR
Checklist:
  - "[ ] Verificar todos os campos obrigatórios de GENE_DNA"
  - "[ ] Verificar todos os campos obrigatórios de LENS_DIFERENCIAL"
  - "[ ] Verificar todos os campos obrigatórios de FRAME_PLATAFORMA"
  - "[ ] Confirmar regras_integridade_verificadas em cada artefato"
  - "[ ] Formatar MSG-01 HANDSHAKE"
  - "[ ] Aguardar MSG-02 AUTORIZAÇÃO antes de qualquer E2"
---

# *send-handshake-e1

Valida todos os artefatos de E1 e envia MSG-01 ao ORQUESTRADOR para autorização de E2.

## MSG-01 HANDSHAKE E1

```yaml
MSG-01_HANDSHAKE_E1:
  de: estrategista
  para: orquestrador
  fase: E1
  artefatos:
    - GENE_DNA
    - LENS_DIFERENCIAL
    - FRAME_PLATAFORMA
  condicionais_detectadas: []  # Lista ferramentas condicionais que o agente detectou necessidade
  status: "pronto_para_validacao"
```

## Regra Absoluta

Não avançar para E2 sem receber `MSG-02_AUTORIZACAO` do ORQUESTRADOR.
Aguardar em estado `bloqueado_aguardando_autorizacao`.
