# APG_CT_001 — Contraditório Efetivo

**Type:** Decision Heuristic
**Phase:** 2 (Análise de Contraditório e Ampla Defesa)
**Agent:** @analista-processual:ada-pellegrini-grinover
**Pattern:** APG-CT-001 (Contraditório Efetivo vs. Formal)

## Purpose

Distingue contraditório formal (a parte foi formalmente ouvida) de contraditório efetivo (a parte teve reais condições de influenciar o convencimento do juiz). Essa distinção é a contribuição mais característica de Ada Pellegrini Grinover ao processo civil brasileiro. O contraditório formal satisfaz o procedimento — o efetivo satisfaz a garantia constitucional do art. 5º, LV, CF/1988. Somente o segundo é suficiente para processo constitucionalmente legítimo.

## Configuration

```yaml
APG_CT_001:
  name: "Contraditório Efetivo"
  phase: 2
  pattern_reference: "APG-CT-001"

  weights:
    informacao_adequada: 0.95        # a parte foi efetivamente cienciada dos fundamentos?
    prazo_razoavel: 0.90             # o prazo foi proporcional à complexidade?
    producao_prova: 0.90             # a parte teve condições de produzir prova?
    consideracao_argumentos: 0.95    # os argumentos foram considerados pela decisão?
    ausencia_surpresa: 0.98          # não houve fundamento não debatido (art. 10, CPC)?

  formal_contraditorio_checklist:
    - "A parte recebeu intimação válida?"
    - "O prazo formal foi concedido?"
    - "A parte compareceu ou foi declarada revel?"

  effective_contraditorio_checklist:
    - "A parte teve informação adequada sobre os fundamentos da ação contrária?"
    - "O prazo foi razoável diante da complexidade da matéria?"
    - "A parte teve condições reais de produzir prova sobre os fatos controvertidos?"
    - "Os argumentos da parte foram considerados na decisão (fundamentação específica)?"
    - "O juiz não decidiu com base em fundamento não debatido (art. 10, CPC/2015)?"

  veto_conditions:
    - condition: "decisao_surpresa_fundamento_novo"
      action: "VETO — Decisão com fundamento não submetido ao contraditório viola art. 5º, LV, CF + art. 10, CPC/2015. Nulidade constitucional."
    - condition: "prazo_exiguo_materia_complexa"
      action: "VETO — Prazo manifestamente insuficiente para defesa efetiva viola o contraditório efetivo — a parte não teve condições reais de responder."
    - condition: "prova_relevante_indeferida_sem_motivacao"
      action: "VETO — Indeferimento imotivado de prova relevante viola ampla defesa (art. 5º, LV) e o direito à prova como seu componente essencial."
    - condition: "contraditorio_formal_aceito_como_suficiente"
      action: "REVIEW — Verificar se além do contraditório formal houve contraditório efetivo: condições reais de influência no convencimento do juiz."
    - condition: "revelia_sem_verificar_citacao_valida"
      action: "VETO — Antes de reconhecer os efeitos da revelia, verificar se a citação foi válida e se o contraditório mínimo foi efetivamente possível."

  decision_tree:
    - IF manifestacao_processual_ocorreu THEN verificar_contraditorio_formal
    - IF contraditorio_formal_ok THEN verificar_contraditorio_efetivo
    - IF informacao_inadequada THEN contraditorio_efetivo_violado
    - IF prazo_insuficiente THEN contraditorio_efetivo_violado
    - IF prova_cerceada THEN ampla_defesa_violada
    - IF fundamento_nao_debatido THEN decisao_surpresa_inconstitucional
    - IF argumentos_ignorados_na_decisao THEN due_process_violado
    - TERMINATION: contraditorio_efetivo_ok OR nulidade_constitucional_declarada

  output:
    type: "diagnóstico de contraditório + consequência constitucional"
    values:
      - "CONTRADITÓRIO FORMAL OK — CONTRADITÓRIO EFETIVO: [verificar]"
      - "CONTRADITÓRIO EFETIVO OK — Garantia constitucional respeitada"
      - "DECISÃO SURPRESA — art. 5º, LV, CF + art. 10, CPC — Nulidade"
      - "CERCEAMENTO DE DEFESA — art. 5º, LV, CF — Nulidade + reabrir instrução"
      - "PRAZO INSUFICIENTE — Contraditório formal sem efetividade — [remédio]"
```

## Distinção Formal vs. Efetivo — Mapa Completo

```text
CONTRADITÓRIO FORMAL (insuficiente por si só):
┌─────────────────────────────────────────────────────────────────┐
│  ✓ Intimação válida entregue                                     │
│  ✓ Prazo formal transcorreu                                      │
│  ✓ Parte teve oportunidade procedimental de falar                │
│                                                                  │
│  PROBLEMA: Satisfaz o procedimento — pode não satisfazer a       │
│            garantia constitucional                               │
└─────────────────────────────────────────────────────────────────┘

CONTRADITÓRIO EFETIVO (exigido pelo art. 5º, LV, CF/1988):
┌─────────────────────────────────────────────────────────────────┐
│  ✓ Informação adequada sobre fundamentos da ação contrária       │
│  ✓ Prazo proporcional à complexidade da matéria                  │
│  ✓ Condições reais de produzir prova                             │
│  ✓ Argumentos efetivamente considerados na decisão               │
│  ✓ Ausência de fundamento não debatido (art. 10, CPC/2015)       │
│                                                                  │
│  RESULTADO: Parte teve real possibilidade de influenciar o       │
│             convencimento do juiz                                │
└─────────────────────────────────────────────────────────────────┘

TESTE DECISIVO:
"A parte influenciou ou teve condições reais de influenciar
 o convencimento do juiz — ou apenas a aparência dessa possibilidade?"
```

## Checklist de Análise do Contraditório Efetivo

```text
VERIFICAÇÃO DO CONTRADITÓRIO EFETIVO:

1. INFORMAÇÃO ADEQUADA:
   [  ] A parte foi cientificada de todos os fundamentos e fatos relevantes?
   [  ] A informação foi compreensível (linguagem acessível, documentos completos)?
   [  ] A parte teve acesso à prova produzida pela parte contrária?
   → SE NÃO: Contraditório efetivo violado — vício de informação

2. PRAZO RAZOÁVEL:
   [  ] O prazo foi proporcional à complexidade da matéria?
   [  ] Em matéria técnica: foi tempo suficiente para consulta a especialista?
   [  ] Não houve compressão artificial do prazo por urgência não demonstrada?
   → SE NÃO: Contraditório efetivo violado — prazo insuficiente

3. PRODUÇÃO DE PROVA:
   [  ] A parte pode requerer e produzir provas pertinentes?
   [  ] Prova pericial foi deferida quando a matéria era técnica?
   [  ] Testemunhas foram ouvidas sobre fatos controvertidos?
   [  ] Indeferimento de prova foi fundamentado proporcionalmente?
   → SE NÃO: Ampla defesa violada — cerceamento de defesa

4. CONSIDERAÇÃO DOS ARGUMENTOS:
   [  ] A decisão enfrentou os argumentos da parte?
   [  ] A fundamentação é específica (não genérica — art. 489, §1º, CPC)?
   [  ] Não há contradição entre premissas e conclusão?
   → SE NÃO: Due process violado — fundamentação inadequada (art. 93, IX, CF)

5. AUSÊNCIA DE DECISÃO SURPRESA:
   [  ] O fundamento da decisão foi submetido ao contraditório das partes?
   [  ] Questão de ordem pública: partes foram ouvidas antes da decisão (art. 10, CPC)?
   [  ] Fundamento jurídico novo: partes se manifestaram (art. 10, CPC)?
   → SE NÃO: Decisão surpresa — violação ao art. 5º, LV, CF + art. 10, CPC
```

## Application

**Input:** Análise de decisão judicial, procedimento ou ato processual.

**Process:**
1. Verificar contraditório formal (o procedimento foi observado?)
2. Verificar contraditório efetivo (os 5 elementos acima)
3. Se violação: identificar qual elemento foi comprometido e o impacto
4. Indicar consequência constitucional e remédio processual

## Examples

### APPROVE: Contraditório Efetivo Completo

**Situação:** Ação de responsabilidade civil. Réu citado (intimação válida), prazo de 15 dias para contestar questão técnica sobre construção civil. Réu requereu e obteve prova pericial, apresentou laudo, produziu testemunhas. Decisão enfrentou todos os argumentos.
**Análise:**
- Informação adequada: OK
- Prazo razoável para matéria técnica: OK (perícia complementou)
- Produção de prova: OK (perícia deferida + testemunhas)
- Consideração de argumentos: OK (decisão fundamentada)
- Sem surpresa: OK
**APG diz:** "O contraditório efetivo foi plenamente respeitado — a parte teve reais condições de influenciar o convencimento do juiz em todas as etapas. O processo, neste aspecto, está constitucionalmente legítimo."

### VETO: Decisão Surpresa — Fundamento Novo

**Situação:** Juiz julgou procedente ação com base em teoria jurídica não invocada pelas partes e não debatida durante o processo.
**Violação:** Art. 5º, LV, CF + art. 10, CPC/2015 — decisão surpresa.
**APG diz:** "A decisão é nula por violação ao contraditório efetivo. O art. 10 do CPC/2015 é a positivação infraconstitucional da garantia do art. 5º, LV, da CF/1988 — o juiz não pode decidir com fundamento não debatido pelas partes, ainda que se trate de questão jurídica que pudesse conhecer de ofício. As partes devem ser intimadas para se manifestar sobre o fundamento antes da decisão."

### VETO: Cerceamento de Defesa

**Situação:** Réu requereu perícia médica em ação de indenização por dano à saúde. Juiz indeferiu sem fundamentar, com base apenas em "desnecessidade da prova a critério do juiz".
**Violação:** Art. 5º, LV, CF — ampla defesa (componente: direito à prova).
**APG diz:** "O indeferimento imotivado de prova pericial em ação cujo objeto é dano à saúde — matéria de natureza eminentemente técnica — configura cerceamento de defesa. O direito à prova é componente essencial da ampla defesa garantida pelo art. 5º, LV, da CF/1988. O ato de indeferimento é nulo e deve ser anulado, com reabertura da fase de instrução."

### REVIEW: Contraditório Formal sem Verificação do Efetivo

**Situação:** Parte foi intimada com prazo de 5 dias para se manifestar sobre laudo pericial de 300 páginas em matéria financeira complexa.
**Análise:** Contraditório formal: OK (intimação válida, prazo concedido).
**Verificação necessária:** O prazo de 5 dias é razoável para manifestação fundamentada sobre laudo de 300 páginas em matéria financeira complexa?
**APG diz:** "O contraditório formal foi satisfeito — mas o contraditório efetivo é duvidoso. Cinco dias para manifestação sobre laudo pericial extenso em matéria técnica complexa pode ser prazo manifestamente insuficiente para defesa efetiva. Impõe-se verificar se a parte teve condições reais de analisar o laudo e apresentar argumentos técnicos — o que provavelmente exige prazo maior ou possibilidade de indicar assistente técnico."

---

**Pattern Compliance:** APG-CT-001 (Contraditório Efetivo) OK
**Source:** APG Mind DNA — Heurística: Contraditório Efetivo
