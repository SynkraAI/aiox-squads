---
task: Executar VAULT™ — Memória Institucional
responsavel: "@experiencia"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - GENE_DNA: Artefato E1
  - LENS_DIFERENCIAL: Artefato E1
  - FRAME_PLATAFORMA: Artefato E1
  - SELF_PERSONALIDADE: Artefato E2
  - TENET_PRINCIPIOS: Artefato E2
  - ECHO_TOM_DE_VOZ: Artefato E2
  - SIGNA_IDENTIDADE_VISUAL: Artefato E2
  - ATLAS_MANUAL_VIVO: Artefato E2
  - RITUAL_JORNADAS: Artefato E3
  - TRACE_TOUCHPOINTS: Artefato E3
  - LIFT_ROADMAP: Artefato E3
  - NORTH_GOVERNANCA: Artefato E3
Saida: |
  - VAULT_MEMORIA_INSTITUCIONAL: Repositório completo do projeto
Checklist:
  - "[ ] Consolidar TODOS os artefatos E1+E2+E3"
  - "[ ] Registrar decisões críticas com justificativa"
  - "[ ] Registrar log de reclassificações"
  - "[ ] Registrar versões de artefatos corrigidos"
  - "[ ] VAULT™ é terminal — representa entrega completa do projeto"
---

# *execute-vault

Executa VAULT™ — consolida todo o projeto em repositório de memória institucional.

## Regra Absoluta

VAULT™ não é só E3. É o repositório completo: E1, E2 e E3.
É a memória institucional do processo, não só da marca.

## Output: VAULT_MEMORIA_INSTITUCIONAL

```yaml
VAULT_MEMORIA_INSTITUCIONAL:
  projeto:
    cliente: string
    arquetipo_final: string
    data_inicio: date
    data_conclusao: date
  artefatos:
    e1: {GENE_DNA, LENS_DIFERENCIAL, FRAME_PLATAFORMA}
    e2: {SELF_PERSONALIDADE, TENET_PRINCIPIOS, ECHO_TOM_DE_VOZ, SIGNA_IDENTIDADE_VISUAL, ATLAS_MANUAL_VIVO}
    e3: {RITUAL_JORNADAS, TRACE_TOUCHPOINTS, LIFT_ROADMAP, NORTH_GOVERNANCA}
  log_decisoes:
    - decisao: string
      justificativa: string
      agente: string
      timestamp: datetime
  log_reclassificacoes: []
  versoes_corrigidas: []
```
