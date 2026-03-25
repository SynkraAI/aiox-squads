---
task: Executar TENET™ — Princípios Comportamentais
responsavel: "@expressao"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - SELF_PERSONALIDADE: Artefato de SELF™
  - GENE_DNA: Artefato de E1
Saida: |
  - TENET_PRINCIPIOS: Artefato com princípios comportamentais da marca
Checklist:
  - "[ ] Ler SELF_PERSONALIDADE e GENE_DNA"
  - "[ ] Derivar princípios dos valores e traços de personalidade"
  - "[ ] Cada princípio deve ser acionável (não apenas declarativo)"
  - "[ ] Incluir lado_negativo em cada princípio"
  - "[ ] Verificar coerência com SELF™"
---

# *execute-tenet

Executa TENET™ — define os princípios comportamentais que guiam como a marca age.

## Output: TENET_PRINCIPIOS

```yaml
TENET_PRINCIPIOS:
  principios:
    - nome: string
      descricao: string
      comportamento_concreto: string  # O que isso significa na prática
      lado_negativo: string           # O que esse princípio nos impede de fazer
      ancora_e1: string
  regras_integridade_verificadas: [string]
```
