---
task: Aplicar Decision Tree RVL™
responsavel: "@intake"
responsavel_type: agent
atomic_layer: task
elicit: true
Entrada: |
  - abertura: Resposta à pergunta de abertura
  - respostas_p1_p4: Respostas às 4 perguntas de reclassificação
Saida: |
  - diagnostico_por_bloco: Diagnóstico e implicação de cada pergunta
  - gatilhos_ativados: Lista de gatilhos automáticos identificados
  - hipotese_confirmada: Arquétipo resultante
Checklist:
  - "[ ] Analisar Bloco 1 — Pergunta de abertura"
  - "[ ] Aplicar P1 — Teste de Fundação"
  - "[ ] Aplicar P2 — Teste de Estabilidade"
  - "[ ] Aplicar P3 — Teste de Material Existente"
  - "[ ] Aplicar P4 — Teste de Urgência e Contexto"
  - "[ ] Verificar gatilhos automáticos"
  - "[ ] Consolidar diagnóstico"
---

# *apply-decision-tree

Executa as 4 perguntas do Decision Tree RVL™ e mapeia os diagnósticos.

## Gatilhos Automáticos

| Gatilho | Condição | Resultado |
|---------|----------|-----------|
| GT-01 | Cliente trava ou divaga na P1 | Arquétipo A imediatamente |
| GT-02 | Mudança estrutural nos últimos 24 meses (P2) | Arquétipo B |
| GT-03 | "Nunca fizemos sentido" sobre material existente (P3) | Auditar FRAME™ antes |

## Matriz de Diagnóstico

### P1 — Teste de Fundação
| Resposta | Diagnóstico | Arquétipo |
|----------|-------------|-----------|
| Explica com clareza | Fundação existe | B ou D |
| Cada sócio falaria diferente | Fundação fragmentada | A ou B |
| Trava ou divaga | Fundação não existe | **A (gatilho GT-01)** |
| Lê de algum lugar | Feita, não internalizada | D com risco de B |

### P2 — Teste de Estabilidade
| Resposta | Diagnóstico | Arquétipo |
|----------|-------------|-----------|
| Pouca mudança | Empresa estável | A ou D |
| Expansão de serviços | Crescimento não integrado | B |
| Mudança de modelo | Reposicionamento necessário | B pesado |
| Mudança de sócio/M&A | Identidade em disputa | **B (gatilho GT-02)** |
