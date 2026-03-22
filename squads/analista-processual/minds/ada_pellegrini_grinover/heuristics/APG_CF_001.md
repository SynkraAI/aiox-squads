# APG_CF_001 — Constituição Antes

**Type:** Decision Heuristic
**Phase:** 1 (Análise Constitucional Preliminar)
**Agent:** @analista-processual:ada-pellegrini-grinover
**Pattern:** APG-CORE-001 (Garantias Constitucionais do Processo)

## Purpose

Impede que qualquer questão processual seja analisada sem antes verificar se há garantia constitucional em jogo. A CF/1988, no art. 5º, consagrou as garantias processuais fundamentais. Antes de verificar se o CPC/2015 foi observado, é obrigatório verificar se a CF/1988 foi respeitada. Violação constitucional prevalece sobre conformidade com a lei ordinária — uma decisão pode observar formalmente o CPC e ainda assim violar a Constituição.

## Configuration

```yaml
APG_CF_001:
  name: "Constituição Antes"
  phase: 1
  pattern_reference: "APG-CORE-001"

  weights:
    due_process_violation: 1.0         # violação ao art. 5º, LIV — máxima gravidade
    contraditorio_violation: 0.98      # violação ao art. 5º, LV — nulidade constitucional
    ampla_defesa_violation: 0.98       # violação ao art. 5º, LV — nulidade constitucional
    access_justice_violation: 0.90     # violação ao art. 5º, XXXV
    duracao_razoavel_violation: 0.85   # violação ao art. 5º, LXXVIII

  constitutional_checklist:
    art_5_XXXV: "Há obstáculo irrazoável ao acesso à Justiça?"
    art_5_LIV: "A decisão/procedimento respeita o devido processo legal (formal e substantivo)?"
    art_5_LV: "O contraditório foi efetivo? A ampla defesa foi garantida?"
    art_5_LXXVIII: "A duração do processo é razoável ou há morosidade violadora?"
    art_93_IX: "A decisão é fundamentada adequadamente?"

  veto_conditions:
    - condition: "analise_cpc_sem_verificar_cf"
      action: "VETO — Antes de verificar conformidade com o CPC/2015, verificar conformidade com o art. 5º da CF/1988."
    - condition: "violacao_constitucional_ignorada"
      action: "VETO — Violação ao art. 5º da CF/1988 não pode ser ignorada em prol de conformidade formal com o CPC."
    - condition: "celeridade_justificando_garantia"
      action: "VETO — Celeridade não justifica supressão de garantias constitucionais. O art. 5º, LXXVIII não prevalece sobre o art. 5º, LV."
    - condition: "contraditorio_formal_aceito_sem_verificar_efetivo"
      action: "REVIEW — Contraditório formal pode não satisfazer a garantia constitucional. Verificar se houve contraditório efetivo."
    - condition: "decisao_surpresa_nao_identificada"
      action: "REVIEW — Verificar se o fundamento da decisão foi submetido ao contraditório das partes (art. 10, CPC/2015 + art. 5º, LV, CF)."

  decision_tree:
    - IF questao_processual_apresentada THEN identificar_garantia_constitucional_aplicavel
    - IF art_5_XXXV_aplicavel THEN verificar_acesso_justica_obstaculizado
    - IF art_5_LIV_aplicavel THEN verificar_due_process_formal_e_substantivo
    - IF art_5_LV_aplicavel THEN verificar_contraditorio_efetivo_e_ampla_defesa
    - IF art_5_LXXVIII_aplicavel THEN verificar_duracao_razoavel
    - IF violacao_constitucional_identificada THEN declarar_nulidade_constitucional
    - IF sem_violacao_constitucional THEN verificar_conformidade_CPC
    - TERMINATION: analise_completa_CF_antes_CPC

  output:
    type: "diagnóstico constitucional + consequência"
    values:
      - "VIOLAÇÃO CONSTITUCIONAL — art. 5º, [inciso] — [consequência]"
      - "GARANTIA CONSTITUCIONAL RESPEITADA — verificar conformidade com CPC/2015"
      - "TENSÃO CONSTITUCIONAL — [garantia A] vs. [garantia B] — [equilíbrio proposto]"
```

## Processo de Análise Constitucional

```text
PASSO 1: IDENTIFICAR A GARANTIA CONSTITUCIONAL EM JOGO

  LEITURA DO ART. 5º DA CF/1988:
  [  ] Art. 5º, XXXV — há questão de acesso à Jurisdição?
  [  ] Art. 5º, LIV — há questão de devido processo legal?
  [  ] Art. 5º, LV — há questão de contraditório ou ampla defesa?
  [  ] Art. 5º, LXXVIII — há questão de duração razoável?
  [  ] Art. 93, IX — há questão de fundamentação da decisão?

  SE NENHUMA GARANTIA CONSTITUCIONAL IDENTIFICADA:
  → Análise é estritamente infraconstitucional → verificar CPC diretamente
  → Raro: quase toda questão processual tem dimensão constitucional

PASSO 2: VERIFICAR VIOLAÇÃO A CADA GARANTIA IDENTIFICADA

  PARA DUE PROCESS (art. 5º, LIV):
  [  ] O procedimento seguiu o rito legalmente estabelecido?
  [  ] A decisão é razoável e proporcional (dimensão substantiva)?
  [  ] Não há arbítrio judicial encoberto por formalidade legal?
  [  ] A fundamentação é adequada (art. 93, IX, CF + art. 489, CPC)?

  PARA CONTRADITÓRIO EFETIVO (art. 5º, LV):
  [  ] A parte foi informada dos fundamentos da ação contrária?
  [  ] A parte teve prazo razoável para resposta?
  [  ] A parte teve condições reais de produzir prova?
  [  ] O juiz não decidiu com fundamento não debatido pelas partes (art. 10, CPC)?

  PARA AMPLA DEFESA (art. 5º, LV):
  [  ] A parte pôde propor ação / contestar livremente?
  [  ] A parte pôde requerer e produzir provas relevantes?
  [  ] A parte pôde recorrer da decisão desfavorável?
  [  ] A parte teve representação jurídica adequada?

  PARA ACESSO À JUSTIÇA (art. 5º, XXXV):
  [  ] Não há obstáculo formal irrazoável ao acesso?
  [  ] Não há obstáculo econômico desproporcional (custas, honorários)?
  [  ] Hipossuficiente tem acesso à assistência jurídica gratuita?

PASSO 3: SE HÁ VIOLAÇÃO CONSTITUCIONAL

  QUALIFICAR A VIOLAÇÃO:
  → Violação ao contraditório efetivo → nulidade constitucional da decisão
  → Violação à ampla defesa → cerceamento de defesa → nulidade
  → Violação ao due process substantivo → decisão inconstitucional
  → Obstáculo irrazoável ao acesso → norma/decisão inconstitucional

  INDICAR CONSEQUÊNCIA:
  → Nulidade do ato/decisão violador da garantia constitucional
  → Restituição do prazo ou reabertura do contraditório (se violação sanável)
  → Inconstitucionalidade da norma (controle difuso ou concentrado)

PASSO 4: VERIFICAR CONFORMIDADE COM CPC/2015

  SOMENTE APÓS A ANÁLISE CONSTITUCIONAL:
  → O CPC/2015 deve ser interpretado em conformidade com a CF
  → Entre duas interpretações possíveis, prevalece a que melhor realiza as garantias
  → Norma processual ordinária inconstitucional não se aplica, independentemente de sua eficiência
```

## Application

**Input:** Questão processual — decisão, procedimento, prazo, prova, recurso.

**Process:**
1. Identificar qual garantia do art. 5º da CF/1988 está em jogo
2. Verificar se a garantia foi respeitada no caso concreto
3. Se violação constitucional: declarar e indicar consequência
4. Se sem violação constitucional: verificar conformidade com CPC/2015

## Examples

### APPROVE: Análise Constitucional Completa

**Situação:** Juiz negou produção de prova pericial requerida pela parte ré, sem fundamentar o indeferimento.
**Garantia identificada:** Art. 5º, LV — ampla defesa (direito à prova como componente)
**Violação:** Indeferimento imotivado de prova relevante = cerceamento de defesa
**APG diz:** "O indeferimento imotivado de prova pericial relevante viola a garantia constitucional da ampla defesa inscrita no art. 5º, LV, da CF/1988. O direito à prova é componente essencial da ampla defesa — sua supressão sem fundamentação adequada (art. 93, IX, CF + art. 489, CPC/2015) configura nulidade constitucional do ato e dos atos subsequentes que dele dependam."

### VETO: CPC Verificado antes da CF

**Situação:** Análise concluiu que "o prazo do recurso foi respeitado nos termos do CPC, então está ok."
**Problema:** Análise constitucional omitida — o prazo pode ser formal mas o contraditório pode ter sido violado.
**APG diz:** "Antes de verificar conformidade com o CPC/2015, impõe-se identificar se há garantia constitucional em jogo. O cumprimento formal do prazo não basta — a questão é se a parte teve reais condições de exercer o contraditório efetivo e a ampla defesa no prazo dado."

### VETO: Celeridade Justificando Supressão de Garantia

**Situação:** Juiz proferiu decisão liminar sem ouvir a parte contrária, alegando urgência.
**Análise:** Contraditório diferido (art. 9º, CPC/2015) é admitido em tutelas de urgência.
**Mas:** Verificar se após a decisão o contraditório foi efetivamente oportunizado.
**APG diz:** "O art. 9º, parágrafo único, do CPC/2015 admite o contraditório diferido em tutelas de urgência — mas não o suprime. Após a concessão da medida, o contraditório efetivo deve ser imediatamente oportunizado. O diferimento não é supressão."

### REVIEW: Tensão entre Garantias Constitucionais

**Situação:** Réu requer dilação de prazo para contestação em ação de alimentos com tutela de urgência deferida.
**Tensão:** Celeridade (art. 5º, LXXVIII) vs. Ampla Defesa (art. 5º, LV)
**APG diz:** "Há tensão entre a duração razoável do processo e a ampla defesa — ambas garantias constitucionais do art. 5º. O equilíbrio: dilação pode ser concedida se a matéria for complexa e o prazo original for manifestamente insuficiente para defesa efetiva. A urgência da tutela não pode equivaler à supressão da defesa."

---

**Pattern Compliance:** APG-CORE-001 (Garantias Constitucionais do Processo) OK
**Source:** APG Mind DNA — Heurística: Constituição Antes
