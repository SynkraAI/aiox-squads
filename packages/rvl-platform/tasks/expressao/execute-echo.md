---
task: Executar ECHO™ — Tom de Voz
responsavel: "@expressao"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - SELF_PERSONALIDADE: Artefato de SELF™
  - TENET_PRINCIPIOS: Artefato de TENET™
Saida: |
  - ECHO_TOM_DE_VOZ: Artefato com tom, vocabulário e exemplos
Checklist:
  - "[ ] Derivar tom de voz dos traços de personalidade"
  - "[ ] Definir vocabulário característico"
  - "[ ] Definir vocabulário proibido"
  - "[ ] Criar exemplos de como/não como escrever"
  - "[ ] Verificar âncoras em SELF™ para cada diretriz"
---

# *execute-echo

Executa ECHO™ — define o sistema verbal da marca.

## Output: ECHO_TOM_DE_VOZ

```yaml
ECHO_TOM_DE_VOZ:
  tom_geral: string
  diretrizes:
    - diretriz: string
      exemplo_sim: string
      exemplo_nao: string
      ancora_self: string
  vocabulario_caracteristico: [string]
  vocabulario_proibido: [string]
  echo_modo: "construcao" | "auditoria"
  regras_integridade_verificadas: [string]
```
