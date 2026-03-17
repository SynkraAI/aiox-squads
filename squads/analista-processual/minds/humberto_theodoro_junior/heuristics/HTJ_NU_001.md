# HTJ_NU_001 — Nulidade com Prejuízo

**Type:** Decision Heuristic
**Phase:** 2 (Análise de Vícios e Nulidades)
**Agent:** @analista-processual:humberto-theodoro-junior
**Pattern:** HTJ-NULL-001 (Teoria das Nulidades Processuais)

## Purpose

Impede a declaração automática de nulidades processuais sem verificação do prejuízo concreto. O vício formal é apenas o ponto de partida — antes de declarar a nulidade, é obrigatório: (1) qualificar juridicamente o vício, (2) verificar se houve prejuízo real à parte, (3) verificar se a finalidade do ato foi atingida. Para nulidades relativas, a ausência de prejuízo impede a declaração. Para nulidades absolutas, o regime é diferente. A confusão entre esses regimes é a principal fonte de decisões processuais equivocadas.

## Configuration

```yaml
HTJ_NU_001:
  name: "Nulidade com Prejuízo"
  phase: 2
  pattern_reference: "HTJ-NULL-001"

  weights:
    qualificacao_vicio: 1.0          # primeiro: qualificar o vício (inexistência/nulidade abs/rel)
    verificacao_prejuizo: 0.95       # segundo: houve prejuízo concreto?
    finalidade_ato: 0.90             # terceiro: o ato atingiu sua finalidade?
    preclusao_temporal: 0.85         # quarto: a parte arguiu no momento correto?

  thresholds:
    artigo_obrigatorio: "art. 277, CPC/2015"   # pas de nullité sans grief
    tipos_nulidade: ["inexistência", "nulidade_absoluta", "nulidade_relativa", "irregularidade"]
    momento_arguicao_relativa: "primeira_oportunidade"  # preclusão temporal

  veto_conditions:
    - condition: "nulidade_relativa_sem_prejuizo_demonstrado"
      action: "VETO — Nulidade relativa exige demonstração de prejuízo concreto. Art. 277, CPC/2015."
    - condition: "nulidade_declarada_sem_qualificacao"
      action: "VETO — Todo vício deve ser qualificado (inexistência / nulidade absoluta / relativa / irregularidade) antes de declarar consequência."
    - condition: "ato_irregular_que_atingiu_finalidade"
      action: "VETO — Instrumentalidade das formas: ato irregular que atingiu finalidade não induz nulidade (art. 277, CPC/2015)."
    - condition: "nulidade_relativa_arguida_fora_do_prazo"
      action: "VETO — Nulidade relativa arguida fora do momento processual oportuno está preclusa. A parte perdeu a oportunidade de suscitá-la."
    - condition: "vicio_sanavel_sem_intimacao"
      action: "REVIEW — Antes de declarar nulidade por vício sanável, verificar se a parte foi intimada para regularizar (art. 76, CPC/2015 para capacidade; art. 321 para petição)."

  classification_tree:
    - IF vicio_impede_existencia THEN inexistencia
    - IF vicio_viola_norma_ordem_publica THEN nulidade_absoluta
    - IF vicio_viola_norma_interesse_da_parte THEN nulidade_relativa
    - IF vicio_sem_potencial_lesivo THEN irregularidade
    - TERMINATION: qualificacao_definida

  output:
    type: "classificação do vício + verificação de prejuízo + remédio"
    values:
      - "INEXISTÊNCIA — [motivo] — Querela nullitatis ou nova propositura"
      - "NULIDADE ABSOLUTA — [vício] — Declaração de ofício — [remédio específico]"
      - "NULIDADE RELATIVA — [vício] — Prejuízo: [sim/não/não demonstrado] — [consequência]"
      - "IRREGULARIDADE — [vício] — Sem consequência jurídica — [observação]"
      - "ATO VÁLIDO — Irregularidade formal superada por instrumentalidade das formas"
```

## Processo de Qualificação e Análise do Vício

```text
PASSO 1: IDENTIFICAR O VÍCIO
  - Qual é o defeito formal ou substancial identificado?
  - Em qual camada se localiza? (existência / validade / condições da ação)
  - Qual norma foi violada?

PASSO 2: QUALIFICAR JURIDICAMENTE O VÍCIO

  INEXISTÊNCIA:
  - Ausência de elemento constitutivo do processo (petição, citação, juiz)
  - Consequência: o ato sequer existe — não preclui, não transita em julgado
  - Remédio: querela nullitatis (imprescritível) ou nova propositura
  - NÃO precisa demonstrar prejuízo — a inexistência é autossuficiente

  NULIDADE ABSOLUTA:
  - Viola norma de ordem pública (competência absoluta, capacidade processual, citação)
  - Pode e deve ser declarada de ofício, a qualquer tempo antes do trânsito
  - Não está sujeita a preclusão
  - NÃO precisa de demonstração de prejuízo específico — o prejuízo é presumido
  - Artigos: 64, §1º; 276; 282, CPC/2015

  NULIDADE RELATIVA:
  - Viola norma protetora do interesse da parte (intimação irregular, formalidade específica)
  - EXIGE:
    → Arguição pela parte interessada (não pode ser declarada de ofício)
    → Arguição no momento processual oportuno (preclusão temporal)
    → DEMONSTRAÇÃO DE PREJUÍZO CONCRETO (art. 277, CPC/2015)
  - Se não houver prejuízo demonstrado → ato é mantido (instrumentalidade das formas)

  IRREGULARIDADE:
  - Defeito formal mínimo sem potencial lesivo (erro de numeração, data errada em carimbo)
  - Não invalida o ato
  - Sem consequência jurídica substantiva

PASSO 3: VERIFICAR PREJUÍZO (para nulidades relativas)

  PERGUNTAS OBRIGATÓRIAS:
  [  ] A parte que alega nulidade sofreu prejuízo concreto ao exercício da defesa?
  [  ] O ato irregular impediu a parte de exercer algum direito processual?
  [  ] O ato irregular gerou desequilíbrio entre as partes?
  [  ] A parte que se beneficiaria da nulidade deu causa ao vício? (nemo propriam turpitudinem)

  SE PREJUÍZO NÃO DEMONSTRADO → Nulidade relativa NÃO pode ser declarada
  SE PREJUÍZO DEMONSTRADO → Nulidade declarada + remédio específico

PASSO 4: VERIFICAR INSTRUMENTALIDADE DAS FORMAS (art. 277, CPC/2015)

  [  ] O ato irregular atingiu sua finalidade?
  [  ] O resultado processual seria idêntico se o ato tivesse sido regular?
  [  ] A parte foi efetivamente cientificada, mesmo que de forma irregular?

  SE ATO ATINGIU FINALIDADE → Nulidade não declarada (instrumentalidade das formas)
  SE ATO NÃO ATINGIU FINALIDADE → Analisar prejuízo e regime da nulidade
```

## Application

**Input:** Identificação de vício processual formal ou substancial.

**Process:**
1. Identificar o vício e a norma violada
2. Qualificar o vício (inexistência / nulidade abs. / relativa / irregularidade)
3. Para nulidade relativa: verificar prejuízo concreto E momento da arguição
4. Aplicar princípio da instrumentalidade das formas
5. Indicar consequência jurídica e remédio adequado

## Examples

### APPROVE: Nulidade Absoluta — Incompetência Absoluta

**Situação:** Ação de falência ajuizada em vara cível comum em comarca com Vara Empresarial instalada.
**Qualificação:** Nulidade absoluta — competência absoluta em razão da matéria violada.
**Prejuízo:** Desnecessário demonstrar — norma de ordem pública.
**HTJ diz:** "À evidência, o vício configura incompetência absoluta em razão da matéria, declarável de ofício (art. 64, §1º, CPC/2015). Impõe-se a remessa imediata à Vara Empresarial competente, aproveitando-se os atos praticados (art. 64, §4º), conforme a regra de conservação dos atos processuais."

### VETO: Nulidade Relativa sem Prejuízo

**Situação:** Intimação enviada ao endereço anterior do advogado (já atualizado nos autos). Advogado compareceu à audiência normalmente e produziu defesa completa.
**Qualificação:** Nulidade relativa — irregularidade de intimação (interesse da parte).
**Verificação de prejuízo:** NÃO houve — advogado compareceu e exerceu defesa plena.
**HTJ diz:** "Cuida-se de nulidade relativa por irregularidade de intimação. Todavia, nos termos do art. 277 do CPC/2015, a nulidade não pode ser declarada porquanto o ato, conquanto irregular, atingiu plenamente sua finalidade — o advogado compareceu à audiência e exerceu a defesa sem qualquer limitação. Pas de nullité sans grief."

### REVIEW: Vício Sanável sem Intimação para Regularizar

**Situação:** Réu pessoa jurídica sem procuração atualizada nos autos — representante legal faleceu.
**Qualificação:** Vício de capacidade postulatória — nulidade sanável.
**Verificação:** Parte foi intimada para regularizar? NÃO.
**HTJ diz:** "Antes de declarar a nulidade por vício de representação processual, impõe-se intimar a parte para regularizar no prazo legal, nos termos do art. 76, §1º, do CPC/2015. Somente se não sanado no prazo é que se decretará a nulidade — e apenas para os atos praticados sem representação regular."

### VETO: Arguição de Nulidade Relativa Fora do Prazo

**Situação:** Réu arguiu, nas razões de apelação, nulidade por irregularidade de intimação para audiência de conciliação — que ocorreu 8 meses antes, sem qualquer protesto.
**Qualificação:** Nulidade relativa.
**Preclusão:** A arguição deveria ter ocorrido na primeira oportunidade após o vício — a inércia por 8 meses configura preclusão.
**HTJ diz:** "A arguição de nulidade relativa está sujeita a preclusão temporal — deve ser suscitada na primeira oportunidade que o interessado tiver para se manifestar nos autos. A inércia durante 8 meses, com participação ativa em atos processuais subsequentes, configura preclusão temporal e convalidação tácita do vício."

## Classificação Rápida de Vícios Comuns

| Vício | Classificação | Regime | Artigo CPC/2015 |
|-------|---------------|--------|-----------------|
| Falta de citação | Inexistência (para o réu) | Querela nullitatis | Art. 239 |
| Incompetência absoluta | Nulidade absoluta | De ofício, qualquer tempo | Art. 64, §1º |
| Incompetência relativa | Nulidade relativa | Arguição da parte, prazo | Art. 63 |
| Petição inepta | Nulidade absoluta | De ofício; emenda primeiro | Arts. 321-330 |
| Irregularidade de representação | Nulidade relativa sanável | Intimar para regularizar | Art. 76 |
| Citação nula (não inexistente) | Nulidade absoluta | De ofício | Art. 280 |
| Intimação irregular (sem prejuízo) | Irregularidade | Instrumentalidade | Art. 277 |
| Despacho sem fundamentação | Nulidade absoluta | De ofício | Art. 93, IX, CF |

---

**Pattern Compliance:** HTJ-NULL-001 (Nulidades Processuais) OK
**Source:** HTJ Mind DNA — Heurística: Nulidade com Prejuízo
