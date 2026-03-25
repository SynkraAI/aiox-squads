---
task: Executar GENE™ — DNA Estratégico
responsavel: "@estrategista"
responsavel_type: agent
atomic_layer: task
elicit: true
Entrada: |
  - material_qualitativo: Transcrições, documentos históricos, pesquisa de mercado
  - PROJETO_CLASSIFICADO: Artefato do intake com arquétipo e gene_modo
  - MSG-02_AUTORIZACAO: Autorização do ORQUESTRADOR para iniciar E1
Saida: |
  - GENE_DNA: Artefato com propósito, valores e essência
Checklist:
  - "[ ] Confirmar MSG-02 AUTORIZAÇÃO recebida"
  - "[ ] Ler todo material qualitativo disponível"
  - "[ ] Identificar gene_modo (destilacao | mediacao | construcao)"
  - "[ ] Sintetizar propósito (15-25 palavras, começa com verbo)"
  - "[ ] Definir valores com lado_negativo"
  - "[ ] Articular essência"
  - "[ ] Aplicar teste de unicidade"
  - "[ ] Aplicar teste de operacionalidade"
  - "[ ] Verificar regras de integridade"
---

# *execute-gene

Executa GENE™ — primeira ferramenta CORE de E1. Destila o DNA estratégico da marca.

## Modos de Execução

| gene_modo | Quando | Como |
|-----------|--------|------|
| `destilacao` | Empresa com história | Extrair o que já existe em forma latente |
| `mediacao` | Tensão entre sócios | Construir sobre consenso negociado, documentar divergências |
| `construcao` | Empresa nova (Arquétipo C) | Construir aspiracional com validação competitiva |

## Output: GENE_DNA

```yaml
GENE_DNA:
  proposito: string  # 1 frase, 15-25 palavras, começa com verbo
  valores:
    - nome: string
      descricao: string
      lado_negativo: string  # O que esse valor nos impede de fazer
  essencia: string  # 2-3 palavras que capturam o núcleo
  gene_modo: "destilacao" | "mediacao" | "construcao"
  registro_mediacao: null | {pontos_divergencia, decisoes_impostas_vs_negociadas}
  regras_integridade_verificadas: [string]
```

## Testes Obrigatórios

- **Unicidade:** O propósito poderia ser dito por um concorrente direto?
- **Operacionalidade:** Gera implicações concretas de comportamento?
- **Handshake:** É suficiente para LENS™ trabalhar sem inventar?
