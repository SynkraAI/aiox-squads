---
task: Executar LENS™ — Diferencial Estratégico
responsavel: "@estrategista"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - GENE_DNA: Artefato da ferramenta GENE™
  - material_competitivo: Pesquisa de mercado e concorrência (quando disponível)
Saida: |
  - LENS_DIFERENCIAL: Artefato com diferencial central e arena competitiva
Checklist:
  - "[ ] Ler GENE_DNA completo"
  - "[ ] Mapear arena competitiva"
  - "[ ] Identificar diferencial central"
  - "[ ] Avaliar copiabilidade do diferencial (1-5)"
  - "[ ] Avaliar valor_percebido do diferencial (1-5)"
  - "[ ] Verificar: diferencial com score 1 não é defensável"
  - "[ ] Verificar regras de integridade"
---

# *execute-lens

Executa LENS™ — mapeia o diferencial estratégico no contexto competitivo.

## Output: LENS_DIFERENCIAL

```yaml
LENS_DIFERENCIAL:
  arena: string  # Mercado/segmento onde compete
  diferencial_central: string
  copiabilidade: 1-5  # 1=fácil copiar, 5=muito difícil
  valor_percebido: 1-5  # 1=baixo, 5=alto
  evidencias: [string]
  lens_modo: "mercado_existente" | "mercado_novo"
  regras_integridade_verificadas: [string]
```

## Alerta de Integridade

Diferencial com `copiabilidade: 1` ou `valor_percebido: 1` não é diferencial defensável.
Se o material não sustenta diferencial forte → sinalizar nas regras_integridade e escalar.
