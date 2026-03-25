---
task: Produzir Classificação de Projeto
responsavel: "@intake"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - diagnostico_consolidado: Output de apply-decision-tree
  - hipotese_confirmada: Arquétipo resultante
Saida: |
  - PROJETO_CLASSIFICADO: Artefato estruturado completo
  - MSG-01_HANDSHAKE: Mensagem para ORQUESTRADOR
Checklist:
  - "[ ] Montar artefato PROJETO_CLASSIFICADO"
  - "[ ] Definir recipe baseado no arquétipo"
  - "[ ] Listar condicionais sinalizadas"
  - "[ ] Documentar riscos com severidade"
  - "[ ] Formatar MSG-01 HANDSHAKE"
  - "[ ] Enviar ao ORQUESTRADOR"
---

# *produce-classification

Gera o artefato final PROJETO_CLASSIFICADO e envia MSG-01 ao ORQUESTRADOR.

## Estrutura do Artefato

```yaml
PROJETO_CLASSIFICADO:
  arquetipo: "A" | "B" | "C" | "D"
  justificativa: string  # Por que este arquétipo
  gatilhos_ativados:
    - id: GT-01
      evidencia: string
  recipe:
    obrigatorias: [GENE, LENS, FRAME, SELF, ...]
    condicionais_sinalizadas: [ARCH, ARENA, ...]
  riscos_identificados:
    - descricao: string
      severidade: "baixa" | "media" | "alta" | "critica"
      evidencia: string
  modo_inicial:
    gene_modo: "destilacao" | "mediacao" | "construcao"
    lens_modo: "mercado_existente" | "mercado_novo"
    frame_modo: "reposicionamento" | "fundacao" | "lancamento"

MSG-01_HANDSHAKE:
  de: intake
  para: orquestrador
  artefato: PROJETO_CLASSIFICADO
  status: "pronto_para_validacao"
```

## Recipes por Arquétipo

| Arquétipo | Ferramentas Obrigatórias |
|-----------|------------------------|
| A | GENE™ + LENS™ + FRAME™ + SELF™ + TENET™ + ECHO™ + SIGNA™ + ATLAS™ + RITUAL™ + TRACE™ + LIFT™ + NORTH™ |
| B | A + ARCH™ + potencial SHIFT™ |
| C | ARENA™ antes de GENE™ + demais E1/E2/E3 |
| D | Auditoria de E2 existente + RITUAL™ + TRACE™ + LIFT™ + NORTH™ |
