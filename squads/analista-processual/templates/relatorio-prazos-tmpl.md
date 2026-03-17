# Template — Relatório de Mapeamento de Prazos
> executor: analista-processual | squad: analista-processual v1.1.0

---

## IDENTIFICAÇÃO

| Campo | Valor |
|---|---|
| Número do Processo | {numero_processo} |
| Tribunal / Vara | {tribunal_vara} |
| Partes | {polo_ativo} × {polo_passivo} |
| Cliente / Polo Monitorado | {cliente_polo} |
| Data de Geração do Relatório | {data_geracao} |
| Próxima Revisão Sugerida | {data_proxima_revisao} |

---

## ⚠️ ALERTAS DE URGÊNCIA

> Instrução: Preencha esta seção APENAS se existirem prazos com status CRÍTICO (🟠) ou VENCIDO (🔴). Caso não haja, substitua pelo bloco abaixo.

> **Sem alertas de urgência no momento.** Todos os prazos ativos estão dentro do prazo normal (🟢).

| Prioridade | Ato Pendente | Data-Limite | Dias Restantes | Responsável |
|---|---|---|---|---|
| 🔴 VENCIDO | {ato_vencido} | {data_limite_vencido} | VENCIDO | {responsavel_vencido} |
| 🟠 CRÍTICO | {ato_critico} | {data_limite_critico} | {dias_critico} | {responsavel_critico} |

> Instrução: Encaminhe imediatamente ao advogado responsável qualquer item com status 🔴 ou 🟠.

---

## 1. TABELA PRINCIPAL DE PRAZOS

> Instrução: Liste todos os prazos ativos e os vencidos nos últimos 30 dias. Ordene por Data-Limite crescente (mais urgentes primeiro).

| # | Prazo | Ato-Gatilho | Data Intimação | Início Contagem | Data-Limite | Dias Restantes | Base Legal | Status |
|---|---|---|---|---|---|---|---|---|
| 1 | {prazo_1} | {ato_gatilho_1} | {data_intim_1} | {inicio_cont_1} | {data_limite_1} | {dias_rest_1} | {base_legal_1} | {status_1} |
| 2 | {prazo_2} | {ato_gatilho_2} | {data_intim_2} | {inicio_cont_2} | {data_limite_2} | {dias_rest_2} | {base_legal_2} | {status_2} |
| 3 | {prazo_3} | {ato_gatilho_3} | {data_intim_3} | {inicio_cont_3} | {data_limite_3} | {dias_rest_3} | {base_legal_3} | {status_3} |
| 4 | {prazo_4} | {ato_gatilho_4} | {data_intim_4} | {inicio_cont_4} | {data_limite_4} | {dias_rest_4} | {base_legal_4} | {status_4} |
| 5 | {prazo_5} | {ato_gatilho_5} | {data_intim_5} | {inicio_cont_5} | {data_limite_5} | {dias_rest_5} | {base_legal_5} | {status_5} |

> Instrução: "Início Contagem" deve considerar a regra do art. 231 CPC (dia útil seguinte à disponibilização no Diário). "Dias Restantes" deve ser calculado em dias úteis para prazos processuais e dias corridos apenas quando a lei expressamente determinar.

**Referências de Prazos Comuns (CPC/2015):**

| Ato | Prazo | Base Legal | Tipo |
|---|---|---|---|
| Contestação | 15 dias úteis | Art. 335 CPC | Úteis |
| Réplica | 15 dias úteis | Art. 351 CPC | Úteis |
| Embargos de Declaração | 5 dias úteis | Art. 1.023 CPC | Úteis |
| Apelação | 15 dias úteis | Art. 1.003, §5º CPC | Úteis |
| Agravo de Instrumento | 15 dias úteis | Art. 1.003, §5º CPC | Úteis |
| Agravo Interno | 15 dias úteis | Art. 1.021 CPC | Úteis |
| Recurso Especial / Extraordinário | 15 dias úteis | Art. 1.003, §5º CPC | Úteis |
| Cumprimento de Sentença (impugnar) | 15 dias úteis | Art. 525 CPC | Úteis |
| Embargos à Execução | 15 dias úteis | Art. 915 CPC | Úteis |
| Pagamento voluntário (cumprimento) | 15 dias corridos | Art. 523 CPC | Corridos |

---

## 2. PRAZOS CUMPRIDOS (ÚLTIMOS 30 DIAS)

> Instrução: Registre os prazos cumpridos para fins de auditoria e histórico.

| # | Prazo | Data-Limite | Data Cumprimento | Ato Praticado | Responsável |
|---|---|---|---|---|---|
| 1 | {prazo_cumprido_1} | {data_limite_c1} | {data_cumprimento_1} | {ato_praticado_1} | {responsavel_c1} |
| 2 | {prazo_cumprido_2} | {data_limite_c2} | {data_cumprimento_2} | {ato_praticado_2} | {responsavel_c2} |

---

## 3. SUSPENSÕES E FERIADOS

> Instrução: Liste as suspensões de prazo ativas ou previstas no período de análise. Consulte o calendário do tribunal e o art. 220 CPC (recesso de 20/12 a 20/01).

### 3.1 Suspensões por Decisão Judicial

| Decisão | Data Início Suspensão | Data Fim Suspensão | Fundamento | Processos Afetados |
|---|---|---|---|---|
| {decisao_suspensao_1} | {inicio_susp_1} | {fim_susp_1} | {fundamento_susp_1} | {processos_afetados_1} |

### 3.2 Feriados e Recesso no Período

| Data | Motivo | Abrangência | Impacto nos Prazos |
|---|---|---|---|
| {data_feriado_1} | {motivo_feriado_1} | {abrangencia_1} | {impacto_1} |
| {data_feriado_2} | {motivo_feriado_2} | {abrangencia_2} | {impacto_2} |

> Instrução: Informe se o feriado é nacional, estadual ou municipal. Verifique a portaria do tribunal para feriados forenses locais.

### 3.3 Suspensões por Acordo das Partes

| Período | Objeto | Base Legal | Homologado? |
|---|---|---|---|
| {periodo_acordo} | {objeto_acordo} | Art. 313, II CPC | {homologado} |

---

## 4. METODOLOGIA DE CÁLCULO

> Instrução: Descreva o método utilizado para o cálculo dos prazos neste relatório.

- **Tipo de prazo:** {dias_uteis_ou_corridos}
- **Regra de início:** Dia útil seguinte à disponibilização no sistema (art. 231 CPC), exceto intimações pessoais (art. 183 CPC — dia da ciência).
- **Regra de fim:** Último dia do prazo; se cair em dia não útil, prorroga-se para o primeiro dia útil subsequente (art. 224, §1º CPC).
- **Fonte de consulta de feriados:** {fonte_feriados}
- **Sistema consultado:** {sistema_tribunal}
- **Data/hora da consulta:** {data_hora_consulta}

---

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

*⚠️ Esta minuta é um rascunho. Revisão e assinatura do advogado são obrigatórias antes do protocolo.*
*Analista Processual Squad v1.1.0 — AIOX Squads*
