---
task: Classificar Projeto RVL™
responsavel: "@intake"
responsavel_type: agent
atomic_layer: task
elicit: true
Entrada: |
  - briefing: Material de abertura do projeto (texto, formulário ou transcrição)
  - material_adicional: Documentos históricos da marca (opcional)
Saida: |
  - PROJETO_CLASSIFICADO: Artefato com arquétipo, recipe e riscos
  - MSG-01_HANDSHAKE: Mensagem de handshake para ORQUESTRADOR
Checklist:
  - "[ ] Ler material de intake completo"
  - "[ ] Formular hipótese inicial de arquétipo"
  - "[ ] Aplicar 4 perguntas de reclassificação (P1-P4)"
  - "[ ] Verificar gatilhos automáticos"
  - "[ ] Registrar riscos identificados"
  - "[ ] Selecionar recipe inicial"
  - "[ ] Produzir PROJETO_CLASSIFICADO"
  - "[ ] Enviar MSG-01 HANDSHAKE ao ORQUESTRADOR"
---

# *classify-project

Aplica o protocolo completo de reclassificação RVL™ e produz o PROJETO_CLASSIFICADO.

## Protocolo

### Bloco 1 — Pergunta de Abertura
> "Me conta o que te fez chegar aqui agora. Por que este momento?"

### Blocos 2-5 — As 4 Perguntas
- **P1** — Teste de Fundação
- **P2** — Teste de Estabilidade
- **P3** — Teste de Material Existente
- **P4** — Teste de Urgência e Contexto

## Output: PROJETO_CLASSIFICADO

```
PROJETO_CLASSIFICADO {
  arquetipo: "A" | "B" | "C" | "D"
  recipe: [ferramentas_obrigatorias]
  condicionais_sinalizadas: [ferramentas_condicionais]
  riscos_identificados: [{descricao, severidade, evidencia}]
  justificativa: string
  gatilhos_ativados: [gatilho_id]
}
```
