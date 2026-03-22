# Template — Relatório de Análise Processual
> executor: analista-processual | squad: analista-processual v1.1.0

---

## IDENTIFICAÇÃO DO PROCESSO

| Campo | Valor |
|---|---|
| Número do Processo | {numero_processo} |
| Tribunal / Vara | {tribunal_vara} |
| Comarca | {comarca} |
| Classe Processual | {classe_processual} |
| Assunto Principal | {assunto_cnj} |
| Fase Processual | {fase_atual} |
| Data da Distribuição | {data_distribuicao} |
| Data da Análise | {data_analise} |
| Analista | {nome_analista} |

> Instrução: Preencha o número no formato CNJ (NNNNNNN-NN.AAAA.J.TT.OOOO). Consulte a classe e o assunto conforme tabelas unificadas do CNJ.

---

## 1. PARTES

### 1.1 Polo Ativo

| # | Nome | CPF/CNPJ | Qualificação | Advogado(s) | OAB |
|---|---|---|---|---|---|
| 1 | {nome_autor_1} | {cpf_cnpj_autor_1} | {qualificacao_autor_1} | {advogado_autor_1} | {oab_autor_1} |
| 2 | {nome_autor_2} | {cpf_cnpj_autor_2} | {qualificacao_autor_2} | {advogado_autor_2} | {oab_autor_2} |

> Instrução: Liste todos os autores, litisconsortes ativos e assistentes. Inclua qualificação completa (estado civil, profissão, endereço) conforme petição inicial.

### 1.2 Polo Passivo

| # | Nome | CPF/CNPJ | Qualificação | Advogado(s) | OAB |
|---|---|---|---|---|---|
| 1 | {nome_reu_1} | {cpf_cnpj_reu_1} | {qualificacao_reu_1} | {advogado_reu_1} | {oab_reu_1} |
| 2 | {nome_reu_2} | {cpf_cnpj_reu_2} | {qualificacao_reu_2} | {advogado_reu_2} | {oab_reu_2} |

> Instrução: Liste todos os réus, litisconsortes passivos e denunciados à lide.

### 1.3 Terceiros Intervenientes

| Nome | Tipo de Intervenção | Representante Legal |
|---|---|---|
| {nome_terceiro_1} | {tipo_intervencao} | {representante_1} |

> Instrução: Inclua assistentes, opoentes, chamados ao processo, amici curiae, MP (quando fiscal da ordem), etc.

---

## 2. OBJETO DA AÇÃO

### 2.1 Fundamento Legal da Ação

> Instrução: Identifique o tipo de ação, o fundamento legal principal e os pedidos cumulados. Seja objetivo.

**Tipo de Ação:** {tipo_acao}

**Base Legal:** {base_legal_principal} — {descricao_base_legal}

**Valor da Causa:** R$ {valor_causa}

### 2.2 Pedidos Formulados

| # | Pedido | Valor Estimado | Natureza | Status |
|---|---|---|---|---|
| 1 | {descricao_pedido_1} | R$ {valor_pedido_1} | {natureza_1} | {status_pedido_1} |
| 2 | {descricao_pedido_2} | R$ {valor_pedido_2} | {natureza_2} | {status_pedido_2} |
| 3 | {descricao_pedido_3} | R$ {valor_pedido_3} | {natureza_3} | {status_pedido_3} |

> Instrução: Natureza pode ser: Condenatório, Declaratório, Constitutivo, Cautelar, Inibitório. Status: Pendente / Parcialmente Deferido / Deferido / Indeferido.

### 2.3 Tutelas de Urgência

| Tipo | Objeto | Data Requerimento | Decisão | Data Decisão |
|---|---|---|---|---|
| {tipo_tutela} | {objeto_tutela} | {data_req_tutela} | {decisao_tutela} | {data_dec_tutela} |

> Instrução: Registre tutelas antecipadas, cautelares preparatórias ou incidentais e medidas liminares.

---

## 3. CRONOLOGIA PROCESSUAL

> Instrução: Liste os atos processuais relevantes em ordem cronológica. Omita despachos de mero expediente.

| Data | Ato Processual | Autor do Ato | Resumo | Documento |
|---|---|---|---|---|
| {data_ato_1} | {tipo_ato_1} | {autor_ato_1} | {resumo_ato_1} | {ref_doc_1} |
| {data_ato_2} | {tipo_ato_2} | {autor_ato_2} | {resumo_ato_2} | {ref_doc_2} |
| {data_ato_3} | {tipo_ato_3} | {autor_ato_3} | {resumo_ato_3} | {ref_doc_3} |
| {data_ato_4} | {tipo_ato_4} | {autor_ato_4} | {resumo_ato_4} | {ref_doc_4} |
| {data_ato_5} | {tipo_ato_5} | {autor_ato_5} | {resumo_ato_5} | {ref_doc_5} |

> Instrução: Para "Autor do Ato" use: Juízo / Autor / Réu / Perito / MP / Oficial de Justiça. Para "Documento" referencie o ID ou número de folha no sistema.

---

## 4. PRAZOS EM CURSO

> Instrução: Liste apenas os prazos ativos ou iminentes. Consulte a seção de calendário do tribunal para suspensões.

| # | Ato Pendente | Data Intimação | Início Contagem | Data-Limite | Dias Restantes | Base Legal | Status |
|---|---|---|---|---|---|---|---|
| 1 | {ato_pendente_1} | {data_intim_1} | {inicio_cont_1} | {data_limite_1} | {dias_rest_1} | {base_legal_1} | {status_prazo_1} |
| 2 | {ato_pendente_2} | {data_intim_2} | {inicio_cont_2} | {data_limite_2} | {dias_rest_2} | {base_legal_2} | {status_prazo_2} |
| 3 | {ato_pendente_3} | {data_intim_3} | {inicio_cont_3} | {data_limite_3} | {dias_rest_3} | {base_legal_3} | {status_prazo_3} |

**Legenda de Status:**
| Símbolo | Significado |
|---|---|
| 🔴 | VENCIDO — prazo expirado sem cumprimento |
| 🟠 | CRÍTICO — vence em até 3 dias úteis |
| 🟡 | ATENÇÃO — vence em 4 a 7 dias úteis |
| 🟢 | NORMAL — vence em mais de 7 dias úteis |
| ✅ | CUMPRIDO — ato já realizado |
| ⬛ | SUSPENSO — prazo suspenso por decisão ou feriado |

---

## 5. RISCOS PROCESSUAIS

> Instrução: Avalie os riscos em função da fase atual, das decisões proferidas e dos prazos em aberto. Seja objetivo e fundamentado.

### 5.1 Riscos Identificados

| # | Descrição do Risco | Severidade | Fundamento | Recomendação |
|---|---|---|---|---|
| 1 | {descricao_risco_1} | {severidade_1} | {fundamento_risco_1} | {recomendacao_1} |
| 2 | {descricao_risco_2} | {severidade_2} | {fundamento_risco_2} | {recomendacao_2} |
| 3 | {descricao_risco_3} | {severidade_3} | {fundamento_risco_3} | {recomendacao_3} |

> Instrução: Severidade: 🔴 CRÍTICO / 🟡 ATENÇÃO / 🟢 OBSERVAÇÃO. Fundamente em dispositivos legais ou na jurisprudência do tribunal.

### 5.2 Pressupostos Processuais — Verificação

| Pressuposto | Status | Observação |
|---|---|---|
| Competência do juízo | {status_competencia} | {obs_competencia} |
| Capacidade processual das partes | {status_capacidade} | {obs_capacidade} |
| Legitimidade ad causam | {status_legitimidade} | {obs_legitimidade} |
| Interesse de agir | {status_interesse} | {obs_interesse} |
| Regularidade da representação | {status_representacao} | {obs_representacao} |

---

## 6. CONCLUSÃO E RECOMENDAÇÕES

> Instrução: Sintetize o estado do processo, os pontos críticos e as próximas providências a adotar. Máximo de 10 linhas.

**Situação Geral:** {situacao_geral}

**Próximas Providências:**

1. {providencia_1} — prazo: {prazo_providencia_1}
2. {providencia_2} — prazo: {prazo_providencia_2}
3. {providencia_3} — prazo: {prazo_providencia_3}

**Observações Adicionais:**

{observacoes_adicionais}

---

*⚠️ Esta minuta é um rascunho. Revisão e assinatura do advogado são obrigatórias antes do protocolo.*
*Analista Processual Squad v1.1.0 — AIOX Squads*
