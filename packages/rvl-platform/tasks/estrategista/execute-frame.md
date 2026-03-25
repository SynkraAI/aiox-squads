---
task: Executar FRAME™ — Plataforma de Marca
responsavel: "@estrategista"
responsavel_type: agent
atomic_layer: task
Entrada: |
  - GENE_DNA: Artefato da ferramenta GENE™
  - LENS_DIFERENCIAL: Artefato da ferramenta LENS™
Saida: |
  - FRAME_PLATAFORMA: Artefato com posicionamento, promessa e público
Checklist:
  - "[ ] Ler GENE_DNA e LENS_DIFERENCIAL"
  - "[ ] Sintetizar posicionamento"
  - "[ ] Articular promessa de marca"
  - "[ ] Definir público primário"
  - "[ ] Definir público secundário (quando aplicável)"
  - "[ ] NÃO incluir inferências de E2 no artefato"
  - "[ ] Aplicar teste de handshake para SELF™"
  - "[ ] Verificar regras de integridade"
---

# *execute-frame

Executa FRAME™ — sintetiza a plataforma de marca a partir de E1.

## Linha de Corte Crítica

Ao construir FRAME™, você verá com clareza como a personalidade deveria ser.
**Não registre isso em nenhum lugar do artefato.**
EXPRESSÃO derivará a personalidade. Contaminar E2 aqui remove uma camada de validação.

## Output: FRAME_PLATAFORMA

```yaml
FRAME_PLATAFORMA:
  posicionamento: string  # Como a marca se posiciona no mercado
  promessa: string        # O que a marca entrega ao público
  publico_primario:
    descricao: string
    job_to_be_done: string
  publico_secundario: null | {descricao, job_to_be_done}
  frame_modo: "reposicionamento" | "fundacao" | "lancamento" | "implementacao"
  regras_integridade_verificadas: [string]
```
