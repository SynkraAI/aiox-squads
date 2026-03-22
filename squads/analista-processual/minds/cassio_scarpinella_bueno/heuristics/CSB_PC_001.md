# CSB_PC_001 — Praticidade CPC/2015

**Type:** Decision Heuristic
**Phase:** 1 (Análise Processual Orientada à Aplicação Prática)
**Agent:** @analista-processual:cassio-scarpinella-bueno
**Pattern:** CSB-CORE-001 (Aplicação Prática CPC/2015)

## Purpose

Garante que toda análise processual seja traduzida em instrução prática e operacional para o profissional do direito. O conhecimento processual que não se transforma em ação concreta — petição, prazo, procedimento — é conhecimento inútil para o cotidiano forense. Este heurístico força a verificação das quatro dimensões de Scarpinella Bueno: texto legal, mudança em relação ao CPC/1973, impacto prático, jurisprudência dominante. E impede que o praticante aplique raciocínio do CPC/1973 a institutos que o CPC/2015 modificou.

## Configuration

```yaml
CSB_PC_001:
  name: "Praticidade CPC/2015"
  phase: 1
  pattern_reference: "CSB-CORE-001"

  weights:
    artigo_identificado: 1.0         # sem artigo não há análise
    mudanca_cpc1973_verificada: 0.90 # raciocínio antigo pode gerar erro
    instrucao_pratica_gerada: 0.95   # a análise deve terminar com o que fazer
    jurisprudencia_pos2016: 0.85     # jurisprudência do CPC/1973 pode ser superada

  four_dimensions_checklist:
    - "Qual é o artigo do CPC/2015 que rege o instituto?"
    - "Houve mudança relevante em relação ao CPC/1973?"
    - "O que o advogado deve fazer, concretamente, e em qual prazo?"
    - "Qual é a jurisprudência dominante do STJ/STF pós-2016?"

  common_traps_cpc1973_vs_2015:
    prazos_corridos:
      trap: "Calcular prazo em dias corridos"
      correct: "CPC/2015 usa dias úteis (art. 219, caput) como regra geral"
      exception: "Prazos em meses, anos ou data certa — não em dias"
    agravo_instrumento:
      trap: "Agravo de instrumento de qualquer decisão interlocutória"
      correct: "Apenas hipóteses taxativas do art. 1.015, CPC/2015"
      exception: "Interpretação extensiva em casos análogos (Tema 1.196 STJ)"
      if_outside_rol: "Protesto nos autos + apelação preliminar (art. 1.009, §1º)"
    execucao_autonoma:
      trap: "Execução de sentença por processo autônomo"
      correct: "Cumprimento de sentença nos mesmos autos (arts. 513-538)"
    prazo_litisconsorcio:
      trap: "Prazo em dobro para litisconsortes com advogados diferentes sempre"
      correct: "Dobro apenas em autos físicos (art. 229, caput) — NÃO em processo eletrônico (art. 229, §2º)"
    contestacao_prazo:
      trap: "Contestação em 15 dias corridos"
      correct: "15 dias úteis (art. 335, caput + art. 219)"

  veto_conditions:
    - condition: "analise_sem_artigo_identificado"
      action: "VETO — Toda análise processual começa com o artigo do CPC/2015. Identificar antes de prosseguir."
    - condition: "prazo_calculado_em_dias_corridos"
      action: "VETO — CPC/2015 usa dias úteis (art. 219). Recalcular excluindo sábados, domingos e feriados."
    - condition: "ai_fora_rol_taxativo_1015"
      action: "VETO — Agravo de instrumento de decisão fora do art. 1.015 não é cabível como regra. Verificar: (1) hipóteses taxativas, (2) se cabe interpretação extensiva (Tema 1.196 STJ), (3) caso negativo: protesto + apelação preliminar."
    - condition: "jurisprudencia_pre2016_aplicada"
      action: "REVIEW — Jurisprudência formada sob o CPC/1973 pode ter sido superada. Verificar se STJ/STF se pronunciou após jan/2016."
    - condition: "instrucao_sem_prazo_especifico"
      action: "REVIEW — Toda instrução prática deve incluir o prazo específico com artigo do CPC/2015."

  decision_tree:
    - IF instituto_processual_identificado THEN buscar_artigo_cpc2015
    - IF artigo_encontrado THEN verificar_mudanca_vs_cpc1973
    - IF mudanca_existe THEN alertar_sobre_diferenca_pratica
    - IF prazo_envolvido THEN verificar_dias_uteis_vs_corridos
    - IF recurso_envolvido THEN verificar_cabimento_taxativo
    - IF instrucao_gerada THEN verificar_jurisprudencia_pos2016
    - TERMINATION: instrucao_completa_com_artigo_prazo_jurisprudencia

  output:
    type: "instrução prática com artigo + prazo + jurisprudência"
    values:
      - "INSTRUÇÃO PRÁTICA: [ato] + [prazo em dias úteis] + [art. X, CPC/2015] + [Tema Y STJ se aplicável]"
      - "ARMADILHA IDENTIFICADA: [raciocínio CPC/1973 incorreto] → [regra correta CPC/2015]"
      - "RECURSO CABÍVEL: [recurso] + [prazo] + [artigo] + [efeitos]"
      - "PRAZO RECALCULADO: [prazo correto em dias úteis com datas concretas]"
```

## Processo de Análise Prática

```text
PASSO 1: IDENTIFICAR O ARTIGO DO CPC/2015

  PERGUNTA: "Qual artigo rege este instituto?"
  BUSCA: Título + Capítulo + artigo específico + §§
  FORMATO: "Art. X, §Y, inciso Z, do CPC/2015"
  SE NÃO ENCONTRADO: Verificar lei especial aplicável + conexão com CPC

PASSO 2: VERIFICAR MUDANÇA EM RELAÇÃO AO CPC/1973

  PERGUNTAS:
  [  ] O instituto existia no CPC/1973?
  [  ] Se existia: a regra mudou? O prazo mudou? O procedimento mudou?
  [  ] Há jurisprudência do CPC/1973 que pode ter sido superada?

  PRINCIPAIS MUDANÇAS A VERIFICAR SEMPRE:
  [  ] Prazo: dias corridos (CPC/1973) → dias úteis (CPC/2015, art. 219)
  [  ] Recurso: amplo cabimento de AI → taxativo (art. 1.015)
  [  ] Execução: autônoma → cumprimento de sentença (arts. 513-538)
  [  ] Honorários: sem critérios detalhados → art. 85 com regras específicas
  [  ] Fundamentação: genérica → art. 489, §1º lista o que NÃO é fundamentação

PASSO 3: GERAR INSTRUÇÃO PRÁTICA

  PERGUNTAS:
  [  ] O que o advogado deve fazer?
  [  ] Em qual prazo? (artigo específico + dias úteis)
  [  ] Em qual forma? (petição escrita? oral? por meio eletrônico?)
  [  ] Qual é o risco se não fizer? (preclusão? extinção? multa?)

  FORMATO DA INSTRUÇÃO:
  "O advogado deve [ato processual] até [prazo dias úteis] (art. X, §Y, CPC/2015),
  [contado de / na audiência de / após / a partir da] [evento específico].
  Se não o fizer: [consequência = preclusão/extinção/multa]."

PASSO 4: VERIFICAR JURISPRUDÊNCIA DOMINANTE PÓS-2016

  PERGUNTAS:
  [  ] Há tema repetitivo do STJ sobre o instituto?
  [  ] Há repercussão geral do STF?
  [  ] Há IRDR ou IAC nos Tribunais de segundo grau?
  [  ] A jurisprudência formada é vinculante (art. 927) ou apenas persuasiva?

  FORMATO:
  "STJ, Tema X: [tese resumida] — vinculante (art. 927, III, CPC/2015)."
  OU
  "STJ ainda não pacificou — correntes: [A] defende X (acórdãos...) e [B] defende Y (acórdãos...)."
```

## Application

**Input:** Questão processual com necessidade de instrução concreta para o profissional.

**Process:**
1. Identificar o artigo do CPC/2015
2. Verificar mudança em relação ao CPC/1973 (armadilhas)
3. Gerar instrução prática com prazo e procedimento
4. Verificar e indicar jurisprudência vinculante pós-2016

## Examples

### APPROVE: Análise Completa com Quatro Dimensões

**Situação:** "Qual é o prazo para contestar?"
**Dimensão 1 (texto):** "Art. 335, caput, CPC/2015: 15 dias."
**Dimensão 2 (mudança):** "CPC/1973: 15 dias corridos. CPC/2015: 15 dias úteis (art. 219)."
**Dimensão 3 (prática):** "Réu citado na quinta-feira → prazo começa na sexta. 15 dias úteis = na prática, aproximadamente 3 semanas de calendário, descontados fins de semana e feriados."
**Dimensão 4 (jurisprudência):** "STJ consolidou (Tema 1.000): a regra dos dias úteis do art. 219 aplica-se a todos os prazos do CPC/2015."
**CSB diz:** "Instrução final: o advogado deve protocolar a contestação até [data calculada], nos termos do art. 335, caput, combinado com o art. 219, do CPC/2015. Atenção: prazo em dias ÚTEIS, não corridos."

### VETO: Agravo de Instrumento Fora do Rol Taxativo

**Situação:** Advogado quer interpor agravo de instrumento de decisão que indeferiu inversão do ônus da prova.
**Verificação do art. 1.015:** Inversão do ônus da prova não está no rol taxativo do art. 1.015.
**Tema 1.196 STJ:** Verificar se cabe interpretação extensiva — inversão do ônus da prova pode ser equiparada à distribuição diversa do ônus probatório (art. 1.015, XI)?
**CSB diz:** "Atenção: inversão do ônus da prova não consta expressamente no art. 1.015. Antes de interpor AI, verificar se o STJ já se pronunciou via interpretação extensiva (Tema 1.196). Se não houver enquadramento, o correto é: (1) protestar contra a decisão nos autos, (2) questionar em apelação preliminar (art. 1.009, §1º). Agravo fora do rol = não conhecido = prazo para apelação preliminar precluído."

### VETO: Prazo em Dias Corridos

**Situação:** Análise indicou "prazo de 15 dias corridos para contestação."
**Problema:** CPC/2015 usa dias úteis (art. 219).
**CSB diz:** "ATENÇÃO: o CPC/2015, em seu art. 219, caput, é expresso: os prazos processuais são contados em dias úteis. Sábados, domingos e feriados não entram na contagem. O prazo de 15 dias para contestação (art. 335) equivale a aproximadamente 3 semanas de calendário. Recalcular."

### REVIEW: Jurisprudência do CPC/1973

**Situação:** Análise citou acórdão do STJ de 2012 sobre legitimidade para ação monitória.
**Problema:** Jurisprudência pré-vigência do CPC/2015 pode ter sido superada.
**CSB diz:** "Antes de usar este acórdão, verificar: (1) o CPC/2015 trouxe regra diferente? (art. 700 e ss.); (2) o STJ se pronunciou sobre o tema após jan/2016? (pesquisar Tema repetitivo ou acórdão mais recente). Jurisprudência do CPC/1973 ainda é válida quando o CPC/2015 não modificou a regra — mas precisa de verificação."

---

**Pattern Compliance:** CSB-CORE-001 (Aplicação Prática CPC/2015) OK
**Source:** CSB Mind DNA — Heurística: Praticidade CPC/2015
