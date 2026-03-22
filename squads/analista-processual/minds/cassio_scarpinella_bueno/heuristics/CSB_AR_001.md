# CSB_AR_001 — Artigo + Regra

**Type:** Decision Heuristic
**Phase:** 2 (Precisão Normativa na Análise Processual)
**Agent:** @analista-processual:cassio-scarpinella-bueno
**Pattern:** CSB-AR-001 (Artigo + Regra + Prazo)

## Purpose

Impede que qualquer prazo processual, procedimento ou faculdade seja mencionado sem a citação do artigo específico do CPC/2015 — incluindo o § aplicável. A imprecisão normativa em processo civil tem consequências concretas: prazo errado gera preclusão, recurso errado gera não-conhecimento, procedimento errado gera nulidade. O "artigo + regra" não é formalismo — é a garantia de que a instrução processual é segura e rastreável. Scarpinella Bueno: "O CPC/2015 tem 1.072 artigos precisamente para que não haja dúvida."

## Configuration

```yaml
CSB_AR_001:
  name: "Artigo + Regra"
  phase: 2
  pattern_reference: "CSB-AR-001"

  weights:
    artigo_principal: 1.0           # art. caput — sempre obrigatório
    paragrafo_especifico: 0.95      # § quando há regra específica relevante
    inciso_alinha: 0.85             # inciso/alínea quando discrimina hipótese
    lei_especial: 0.90              # quando CPC/2015 remete a lei especial

  mandatory_citations:
    prazos:
      contestacao: "Art. 335, caput, CPC/2015 (15 dias úteis)"
      apelacao: "Art. 1.003, §5º, CPC/2015 (15 dias úteis)"
      embargos_declaracao: "Art. 1.023, caput, CPC/2015 (5 dias úteis)"
      agravo_instrumento: "Art. 1.003, §5º, CPC/2015 (15 dias úteis)"
      cumprimento_voluntario: "Art. 523, caput, CPC/2015 (15 dias, sem especificação de úteis neste caso)"
      embargos_execucao: "Art. 915, caput, CPC/2015 (15 dias úteis)"
      contrarrazoes: "Art. 1.010, §3º, CPC/2015 (15 dias úteis)"
      reconvencao: "Art. 343, CPC/2015 (junto com a contestação)"
    contagem:
      regra_geral: "Art. 219, caput, CPC/2015 (dias úteis)"
      inicio: "Art. 231, CPC/2015 (momento de início da contagem)"
      final_prazo: "Art. 224, CPC/2015 (quando o prazo termina)"
      prazos_fazenda: "Art. 183, CPC/2015 (prazo em quádruplo... errôneo — é em dobro)"
      prazos_defensoria: "Art. 186, CPC/2015 (prazo em dobro)"
      litisconsortes_fisico: "Art. 229, caput, CPC/2015 (dobro em autos físicos)"
      litisconsortes_eletronico: "Art. 229, §2º, CPC/2015 (NÃO há dobro em processo eletrônico)"
    recursos:
      apelacao: "Art. 1.009, CPC/2015"
      agravo_instrumento: "Art. 1.015, CPC/2015 (hipóteses taxativas)"
      agravo_interno: "Art. 1.021, CPC/2015"
      embargos_declaracao: "Arts. 1.022-1.026, CPC/2015"
      recurso_especial: "Art. 1.029, CPC/2015"
      recurso_extraordinario: "Art. 1.029, CPC/2015"

  veto_conditions:
    - condition: "prazo_sem_artigo"
      action: "VETO — Todo prazo processual exige citação do artigo do CPC/2015. Identificar antes de mencionar o prazo."
    - condition: "recurso_sem_artigo_especifico"
      action: "VETO — Todo recurso exige identificação do artigo de cabimento (arts. 994-1.044, CPC/2015) e do artigo de prazo (art. 1.003, §5º)."
    - condition: "procedimento_sem_artigo"
      action: "VETO — Todo procedimento processual exige indicação do artigo que o fundamenta — o que o juiz pode fazer, o que a parte pode requerer."
    - condition: "fazenda_com_prazo_em_quadruplo"
      action: "VETO — ERRO COMUM: Fazenda Pública tem prazo em DOBRO (art. 183, CPC/2015), não em quádruplo. CPC/1973 usava quádruplo — CPC/2015 reduziu para dobro."
    - condition: "dobro_em_processo_eletronico"
      action: "VETO — Em processo eletrônico, litisconsortes com advogados diferentes NÃO têm prazo em dobro (art. 229, §2º, CPC/2015)."
    - condition: "artigo_cpc1973_citado_como_vigente"
      action: "VETO — Artigo citado é do CPC/1973, revogado. Identificar o artigo correspondente no CPC/2015."

  citation_format:
    standard: "art. X do CPC/2015"
    with_paragraph: "art. X, §Y, do CPC/2015"
    with_item: "art. X, §Y, inciso Z, do CPC/2015"
    with_alinea: "art. X, §Y, inciso Z, alínea 'a', do CPC/2015"
    with_complementary_law: "art. X do CPC/2015 c/c art. Y da Lei Z"

  decision_tree:
    - IF prazo_mencionado THEN identificar_artigo_especifico
    - IF artigo_identificado THEN verificar_se_ha_paragrafo_especifico
    - IF recurso_mencionado THEN citar_art_cabimento_E_art_prazo
    - IF procedimento_descrito THEN referenciar_artigos_que_fundamentam_cada_ato
    - IF fazenda_publica_envolvida THEN verificar_art_183_dobro_nao_quadruplo
    - IF processo_eletronico THEN verificar_art_229_parag2_sem_dobro
    - TERMINATION: toda_afirmacao_com_artigo_identificado

  output:
    type: "afirmação processual + artigo + prazo (dias úteis)"
    format: "[ato processual]: [prazo] dias úteis — art. X, §Y, CPC/2015"
    examples:
      - "Contestação: 15 dias úteis — art. 335, caput, CPC/2015"
      - "Apelação: 15 dias úteis — art. 1.003, §5º, CPC/2015"
      - "Embargos de declaração: 5 dias úteis — art. 1.023, CPC/2015"
```

## Processo de Citação Normativa Obrigatória

```text
PASSO 1: IDENTIFICAR O TIPO DE AFIRMAÇÃO

  PRAZO:
  → Buscar no índice por "prazo" + nome do ato + CPC/2015
  → Verificar se há § que especifica o prazo (ex: art. 1.003, §5º)
  → Confirmar: dias úteis ou corridos? (regra: úteis — art. 219)

  RECURSO:
  → Identificar o tipo de decisão (sentença? interlocutória? acórdão?)
  → Verificar o recurso cabível: arts. 994-1.044
  → Citar dois artigos: (1) art. de cabimento, (2) art. de prazo (1.003, §5º)
  → Para AI: verificar se está no rol taxativo do art. 1.015

  PROCEDIMENTO / ATO:
  → Identificar a fase processual (postulatória? saneamento? instrução?)
  → Verificar artigo que autoriza ou regula o ato
  → Verificar se há prazo para o ato (artigo de prazo)

PASSO 2: FORMATAR A CITAÇÃO

  FORMATO BÁSICO:
  "[nome do ato]: [prazo], nos termos do art. X, [§Y, inciso Z], do CPC/2015."

  FORMATO COM EXCEÇÃO:
  "[nome do ato]: [prazo] (regra geral — art. X), salvo [exceção] (art. Y)."

  FORMATO COM JURISPRUDÊNCIA:
  "[nome do ato]: [prazo] (art. X, CPC/2015), conforme consolidado pelo STJ no Tema Z."

PASSO 3: VERIFICAR EXCEÇÕES E ARMADILHAS

  SEMPRE VERIFICAR:
  [  ] Fazenda Pública: dobro (art. 183) — NÃO quádruplo
  [  ] Defensoria Pública: dobro (art. 186)
  [  ] Litisconsortes em autos físicos: dobro (art. 229, caput)
  [  ] Litisconsortes em processo eletrônico: sem dobro (art. 229, §2º)
  [  ] Prazos em meses/anos: não são em dias úteis (exceção ao art. 219)
  [  ] Prazos judiciais (fixados pelo juiz): em dias úteis (art. 219)
```

## Mapa Completo de Artigos por Prazo — CPC/2015

```text
PRAZOS DO RÉU:
  Contestação: 15 dias úteis — art. 335, caput
  Reconvenção: junto com contestação — art. 343
  Impugnação ao valor da causa: até contestação — art. 293
  Exceção de incompetência relativa: até contestação — art. 337, II

PRAZOS DO AUTOR:
  Réplica: 15 dias úteis — art. 350, caput
  Manifestação sobre documentos: 15 dias — art. 437, §1º

PRAZOS DE RECURSOS:
  Apelação: 15 dias úteis — art. 1.003, §5º
  Agravo de instrumento: 15 dias úteis — art. 1.003, §5º
  Agravo interno: 15 dias úteis — art. 1.003, §5º
  Embargos de declaração: 5 dias úteis — art. 1.023
  Recurso especial: 15 dias úteis — art. 1.003, §5º
  Recurso extraordinário: 15 dias úteis — art. 1.003, §5º
  Contrarrazões: 15 dias úteis — art. 1.010, §3º

PRAZOS DE EXECUÇÃO/CUMPRIMENTO:
  Cumprimento voluntário (pagar): 15 dias — art. 523, caput
  Embargos à execução: 15 dias úteis — art. 915, caput
  Impugnação ao cumprimento: 15 dias — art. 525, caput
  Prazo para pagar em execução: 3 dias — art. 829, caput

PRAZOS ESPECIAIS:
  Embargos de terceiro: até 5 dias antes da arrematação — art. 675
  Ação rescisória: 2 anos do trânsito — art. 975
  Embargos do devedor (título extrajudicial): 15 dias úteis — art. 915

CONTAGEM — REFERÊNCIAS:
  Regra (dias úteis): art. 219, caput
  Início do prazo: art. 231
  Prazo final (dia útil seguinte se vencer em dia não útil): art. 224
  Suspensão (férias forenses, feriados nacionais): art. 220
```

## Application

**Input:** Menção a prazo, recurso ou procedimento processual.

**Process:**
1. Identificar o artigo + § específico do CPC/2015
2. Verificar tipo de prazo (úteis/corridos) e exceções (dobro, etc.)
3. Formatar a afirmação com artigo citado
4. Verificar armadilhas comuns (CPC/1973 vs. CPC/2015)

## Examples

### APPROVE: Citação Completa com Artigo

**Situação:** "Qual é o prazo para apelar?"
**CSB responde:** "O prazo para apelação é de 15 (quinze) dias úteis, nos termos do art. 1.003, §5º, do CPC/2015, contados a partir da publicação da sentença no Diário da Justiça (art. 231, IV) ou da intimação pessoal, prevalecendo o que ocorrer primeiro. Se a parte for a Fazenda Pública, o prazo é de 30 dias úteis (dobro — art. 183, CPC/2015). Em processo eletrônico com litisconsortes: sem dobro (art. 229, §2º)."

### VETO: Prazo sem Artigo

**Situação:** "O prazo para contestar é 15 dias."
**Problema:** Sem artigo, sem especificação de dias úteis.
**CSB diz:** "Especificar: o prazo para contestação é de 15 (quinze) dias ÚTEIS (art. 335, caput, combinado com o art. 219, caput, do CPC/2015). A omissão do 'úteis' é erro comum que custa ao cliente dias de prazo — podendo gerar revelia."

### VETO: Fazenda com Prazo Quádruplo

**Situação:** "A Fazenda Pública tem prazo em quádruplo para contestar."
**Problema:** CPC/2015 reduziu para dobro (art. 183) — quádruplo era do CPC/1973.
**CSB diz:** "ATENÇÃO: sob o CPC/2015, a Fazenda Pública tem prazo em DOBRO — art. 183, caput —, não mais em quádruplo como previa o CPC/1973. O prazo para contestação da Fazenda Pública é de 30 dias úteis (15 dias úteis × 2), nos termos do art. 335, caput, c/c art. 183, caput, e art. 219, do CPC/2015."

### VETO: Dobro em Processo Eletrônico

**Situação:** "Os dois réus, com advogados diferentes, têm prazo em dobro para contestar — 30 dias."
**Verificação:** Processo físico ou eletrônico?
**Processo eletrônico:**
**CSB diz:** "Em processo eletrônico, o art. 229, §2º, do CPC/2015 é expresso: não se aplica o prazo em dobro para litisconsortes com procuradores diferentes quando os autos forem eletrônicos. Prazo: 15 dias úteis para cada litisconsorte, individualmente — art. 335, caput, c/c art. 219 e art. 229, §2º."

---

**Pattern Compliance:** CSB-AR-001 (Artigo + Regra) OK
**Source:** CSB Mind DNA — Heurística: Artigo + Regra
