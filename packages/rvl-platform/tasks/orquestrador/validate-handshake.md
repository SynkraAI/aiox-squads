---
task: Validar Handshake
responsavel: "@orquestrador"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - MSG-01_HANDSHAKE: Mensagem enviada por agente
  - fase: E1 | E2 | E3
Saida: |
  - validacao_status: "aprovado" | "rejeitado"
  - campos_falhados: [] (se rejeitado)
  - proxima_acao: MSG-02 ou MSG-04
Checklist:
  - "[ ] Verificar todos os campos obrigatórios presentes"
  - "[ ] Verificar regras_integridade_verificadas preenchidas"
  - "[ ] Verificar ausência de campos vazios"
  - "[ ] Verificar formato e tipos dos campos"
  - "[ ] Avaliar condicionais_detectadas sinalizadas"
  - "[ ] Emitir MSG-02 (aprovado) ou MSG-04 (rejeitado)"
---

# *validate-handshake

Valida MSG-01 recebido contra regras de integridade dos schemas de artefatos.

## Princípio

Árbitro de processo, não de qualidade de conteúdo.
Se as regras de integridade estão sendo cumpridas → autoriza.
A qualidade estratégica é responsabilidade dos outros agentes.

## Processo

```
Para cada artefato em MSG-01:
  1. Verificar campos obrigatórios presentes
  2. Verificar tipos corretos
  3. Verificar regras específicas (ex: proposito 15-25 palavras)
  4. Registrar resultado
```

## Output

```yaml
VALIDACAO:
  status: "aprovado" | "rejeitado"
  campos_falhados:
    - campo: string
      regra: string
      valor_recebido: string
  condicionais_para_avaliar: []
  proxima_acao: "emitir_msg02" | "emitir_msg04"
```
