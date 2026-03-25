---
task: Executar SIGNA™ — Identidade Visual
responsavel: "@expressao"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - SELF_PERSONALIDADE: Artefato de SELF™
  - ECHO_TOM_DE_VOZ: Artefato de ECHO™
Saida: |
  - SIGNA_IDENTIDADE_VISUAL: Artefato com diretrizes visuais ancoradas em estratégia
Checklist:
  - "[ ] NÃO usar referências estéticas sem ancoragem em SELF™"
  - "[ ] Derivar direção visual dos traços de personalidade"
  - "[ ] Definir princípios visuais com âncora explícita"
  - "[ ] Verificar coerência com ECHO™ (verbal ↔ visual)"
  - "[ ] Identificar signa_modo com base no arquétipo do projeto"
---

# *execute-signa

Executa SIGNA™ — direção de identidade visual derivada da estratégia.

## Princípio Central

A pergunta não é "que estilo visual combina com essa empresa?"
A pergunta é "quais escolhas visuais tornam perceptíveis os traços de personalidade X, Y e Z?"

## Output: SIGNA_IDENTIDADE_VISUAL

```yaml
SIGNA_IDENTIDADE_VISUAL:
  principios_visuais:
    - principio: string
      ancora_self: string
      implicacao_pratica: string
  direcao_cromatica: string
  direcao_tipografica: string
  direcao_fotografica: string
  signa_modo: "construcao" | "auditoria" | "refinamento"
  regras_integridade_verificadas: [string]
```
