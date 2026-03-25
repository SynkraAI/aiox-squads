---
task: Verificar Atlas Completude antes de E3
responsavel: "@experiencia"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - ATLAS_MANUAL_VIVO: Artefato de ATLAS™
  - MSG-02_AUTORIZACAO: Autorização do ORQUESTRADOR para E3
Saida: |
  - atlas_completude_status: boolean + ação
Checklist:
  - "[ ] Confirmar MSG-02 AUTORIZAÇÃO recebida"
  - "[ ] Verificar atlas_completude no artefato"
  - "[ ] Se false → primeira ação de LIFT™ é completar ATLAS™"
  - "[ ] Se false → enviar handshake de bloqueio ao ORQUESTRADOR"
  - "[ ] Se true → prosseguir para RITUAL™"
---

# *check-atlas-completude

Verificação obrigatória antes de qualquer execução em E3.

## Regra Absoluta

`atlas_completude == false` → PARAR. Não iniciar nenhuma ferramenta de E3.
Primeira ação do LIFT™ será completar o ATLAS™.

## Output

```yaml
ATLAS_CHECK:
  atlas_completude: true | false
  acao: "prosseguir_para_ritual" | "bloquear_aguardar_atlas"
  atlas_completude_recebida: true | false  # Para sinalizar ao ORQUESTRADOR
```
