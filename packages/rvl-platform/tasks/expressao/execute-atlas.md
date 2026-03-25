---
task: Executar ATLAS™ — Manual Vivo
responsavel: "@expressao"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - SELF_PERSONALIDADE: Artefato de SELF™
  - TENET_PRINCIPIOS: Artefato de TENET™
  - ECHO_TOM_DE_VOZ: Artefato de ECHO™
  - SIGNA_IDENTIDADE_VISUAL: Artefato de SIGNA™
Saida: |
  - ATLAS_MANUAL_VIVO: Manual completo de identidade da marca
  - atlas_completude: boolean
Checklist:
  - "[ ] Consolidar todos os artefatos de E2"
  - "[ ] Verificar que ATLAS™ cobre todos elementos de E2"
  - "[ ] Garantir atlas_modo correto"
  - "[ ] Definir atlas_completude (true/false)"
  - "[ ] ATLAS™ incompleto BLOQUEIA E3"
---

# *execute-atlas

Executa ATLAS™ — consolida toda E2 em manual vivo de identidade.

## Regra Crítica

`atlas_completude == false` bloqueia E3 completamente.
EXPERIÊNCIA não pode mapear touchpoints de marca sem sistema completo documentado.

## Output: ATLAS_MANUAL_VIVO

```yaml
ATLAS_MANUAL_VIVO:
  secoes:
    - estrategia: {GENE_DNA_ref, LENS_DIFERENCIAL_ref, FRAME_PLATAFORMA_ref}
    - personalidade: {SELF_PERSONALIDADE_ref, TENET_PRINCIPIOS_ref}
    - verbal: {ECHO_TOM_DE_VOZ_ref}
    - visual: {SIGNA_IDENTIDADE_VISUAL_ref}
  atlas_completude: true | false
  elementos_faltantes: []  # Preenchido se atlas_completude == false
  atlas_modo: "construcao" | "auditoria"
  regras_integridade_verificadas: [string]
```
