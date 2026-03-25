---
task: Executar SELF™ — Personalidade de Marca
responsavel: "@expressao"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - FRAME_PLATAFORMA: Artefato de E1
  - GENE_DNA: Artefato de E1
  - MSG-02_AUTORIZACAO: Autorização do ORQUESTRADOR para E2
Saida: |
  - SELF_PERSONALIDADE: Artefato com traços, arquétipo e tom geral
Checklist:
  - "[ ] Confirmar MSG-02 AUTORIZAÇÃO recebida"
  - "[ ] Ler todos os artefatos de E1"
  - "[ ] Derivar traços de personalidade (ancorados em E1)"
  - "[ ] Identificar arquétipo de marca"
  - "[ ] Definir self_modo com base no arquétipo do projeto"
  - "[ ] Cada traço deve ter âncora explícita em campo de E1"
  - "[ ] Verificar regras de integridade"
---

# *execute-self

Executa SELF™ — deriva personalidade de marca a partir da estratégia de E1.

## Princípio de Derivação

Cada traço de personalidade precisa de âncora explícita em E1.
Se não consegue apontar a âncora → a decisão é criativa, não derivada → escalar.

## Output: SELF_PERSONALIDADE

```yaml
SELF_PERSONALIDADE:
  arquetipo_marca: string  # Ex: Sábio, Criador, Herói
  tracos:
    - nome: string
      descricao: string
      ancora_e1: string  # Campo específico de GENE_DNA ou FRAME_PLATAFORMA
  self_modo: "construcao" | "auditoria" | "refinamento"
  regras_integridade_verificadas: [string]
```
