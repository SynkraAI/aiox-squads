---
task: Executar RITUAL™ — Jornadas Intencionais
responsavel: "@experiencia"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - FRAME_PLATAFORMA: Artefato de E1
  - SELF_PERSONALIDADE: Artefato de E2
  - ATLAS_MANUAL_VIVO: Artefato de E2 (atlas_completude == true)
Saida: |
  - RITUAL_JORNADAS: Mapa de jornadas intencionais da marca
Checklist:
  - "[ ] Confirmar atlas_completude == true"
  - "[ ] Identificar jornadas principais do público"
  - "[ ] Definir momentos de marca em cada jornada"
  - "[ ] Cada momento deve ter responsável real"
  - "[ ] Alimenta TRACE™ com pontos de contato identificados"
---

# *execute-ritual

Executa RITUAL™ — mapeia as jornadas intencionais da marca com o público.

## Output: RITUAL_JORNADAS

```yaml
RITUAL_JORNADAS:
  jornadas:
    - nome: string
      publico: string
      etapas:
        - etapa: string
          momento_de_marca: string
          responsavel: string  # Pessoa/perfil real, não cargo hipotético
          touchpoints: [string]
  regras_integridade_verificadas: [string]
```
