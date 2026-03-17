# Template — Análise de Sentença
> executor: analista-processual | squad: analista-processual v1.1.0

---

## IDENTIFICAÇÃO

| Campo | Valor |
|---|---|
| Número do Processo | {numero_processo} |
| Tribunal / Vara | {tribunal_vara} |
| Partes | {polo_ativo} × {polo_passivo} |
| Cliente / Polo Monitorado | {cliente_polo} |
| Data da Sentença | {data_sentenca} |
| Juiz Prolator | {nome_juiz} |
| Data da Publicação no DJe | {data_publicacao_dje} |
| Data da Análise | {data_analise} |
| Analista | {nome_analista} |

---

## 1. RESULTADO GERAL

> Instrução: Transcreva o dispositivo da sentença integralmente ou em sua parte essencial. Em seguida, classifique o resultado para cada polo.

### 1.1 Dispositivo da Sentença

> Instrução: Copie o trecho do dispositivo (parte da sentença que começa em "PELO EXPOSTO" ou "DIANTE DO EXPOSTO"). Use bloco de citação.

> "{dispositivo_sentenca}"

### 1.2 Resultado por Polo

| Polo | Parte | Resultado Geral | Observação |
|---|---|---|---|
| Ativo (Autor) | {nome_autor} | {resultado_autor} | {obs_resultado_autor} |
| Passivo (Réu) | {nome_reu} | {resultado_reu} | {obs_resultado_reu} |

> Instrução: Para "Resultado Geral", use: Procedente / Parcialmente Procedente / Improcedente / Extinto sem resolução do mérito / Homologado acordo.

---

## 2. ANÁLISE POR PEDIDO

> Instrução: Compare cada pedido formulado na inicial com o resultado obtido na sentença. Esta é a seção mais importante para o cliente.

| # | Pedido Formulado | Resultado na Sentença | Observação |
|---|---|---|---|
| 1 | {pedido_1} | {resultado_pedido_1} | {obs_pedido_1} |
| 2 | {pedido_2} | {resultado_pedido_2} | {obs_pedido_2} |
| 3 | {pedido_3} | {resultado_pedido_3} | {obs_pedido_3} |
| 4 | {pedido_4} | {resultado_pedido_4} | {obs_pedido_4} |
| 5 | {pedido_5} | {resultado_pedido_5} | {obs_pedido_5} |

> Instrução: Para "Resultado", use: Deferido / Parcialmente Deferido / Indeferido / Não apreciado / Prejudicado.

---

## 3. CONDENAÇÕES E OBRIGAÇÕES

> Instrução: Preencha apenas se houver condenação em valores ou obrigações de fazer/não fazer. Inclua todos os acessórios.

### 3.1 Condenações em Valor

| Item | Valor Principal | Juros | Correção Monetária | Termo Inicial | Base Legal |
|---|---|---|---|---|---|
| {item_condenacao_1} | R$ {valor_principal_1} | {juros_1} | {correcao_1} | {termo_inicial_1} | {base_legal_cond_1} |
| {item_condenacao_2} | R$ {valor_principal_2} | {juros_2} | {correcao_2} | {termo_inicial_2} | {base_legal_cond_2} |

> Instrução: Especifique o índice de correção monetária (IPCA-E, INPC, SELIC, etc.) e o percentual de juros moratórios fixados. Anote o termo inicial de incidência de cada acessório.

### 3.2 Honorários Advocatícios e Custas

| Item | Valor / Percentual | Responsável | Base Legal |
|---|---|---|---|
| Honorários advocatícios sucumbenciais | {honorarios_pct}% sobre {honorarios_base} | {responsavel_honorarios} | Art. 85 CPC |
| Custas processuais | R$ {valor_custas} | {responsavel_custas} | Art. 82 CPC |
| Despesas processuais | R$ {valor_despesas} | {responsavel_despesas} | Art. 82 CPC |

> Instrução: Verifique se o juiz fixou honorários em percentual sobre o valor da condenação (§2º) ou sobre o proveito econômico (§3º) ou por equidade (§8º). Atente para a possibilidade de honorários recursais (§11).

### 3.3 Obrigações de Fazer / Não Fazer

| # | Obrigação | Prazo de Cumprimento | Multa por Descumprimento (astreintes) | Responsável |
|---|---|---|---|---|
| 1 | {obrigacao_1} | {prazo_obrigacao_1} | R$ {multa_1}/dia | {responsavel_obrigacao_1} |
| 2 | {obrigacao_2} | {prazo_obrigacao_2} | R$ {multa_2}/dia | {responsavel_obrigacao_2} |

---

## 4. FUNDAMENTOS DA DECISÃO

> Instrução: Identifique os principais argumentos utilizados pelo juiz para fundamentar a decisão. Separe por tópico. Esta análise é essencial para a construção de eventual recurso.

### 4.1 Fundamentos Acolhidos

| # | Argumento / Fundamento | Tese Jurídica | Precedente Citado |
|---|---|---|---|
| 1 | {fundamento_acolhido_1} | {tese_juridica_1} | {precedente_1} |
| 2 | {fundamento_acolhido_2} | {tese_juridica_2} | {precedente_2} |

### 4.2 Argumentos Rejeitados

| # | Argumento Apresentado pela Parte | Motivo da Rejeição pelo Juízo |
|---|---|---|
| 1 | {argumento_rejeitado_1} | {motivo_rejeicao_1} |
| 2 | {argumento_rejeitado_2} | {motivo_rejeicao_2} |

> Instrução: Os argumentos rejeitados são pontos de partida para Embargos de Declaração (se omissão ou obscuridade) ou para as razões de Apelação.

---

## 5. PRAZOS RECURSAIS

> Instrução: Calcule os prazos a partir da data de publicação no DJe. Confirme a data no sistema do tribunal antes de informar ao cliente.

| Recurso | Prazo | Início Contagem | Data-Limite | Status | Base Legal |
|---|---|---|---|---|---|
| Embargos de Declaração | 5 dias úteis | {inicio_embargo} | **{data_limite_embargo}** | {status_embargo} | Art. 1.023 CPC |
| Apelação | 15 dias úteis | {inicio_apelacao} | **{data_limite_apelacao}** | {status_apelacao} | Art. 1.003, §5º CPC |

> Instrução: Lembre-se de que a oposição de Embargos de Declaração interrompe (não suspende) o prazo para outros recursos (art. 1.026 CPC). Se houver Embargos, recalcule o prazo da Apelação a partir da publicação da decisão nos Embargos.

**Prazo de Apelação recalculado (caso haja ED):** {data_limite_apelacao_pos_ed}

---

## 6. PONTOS PARA ANÁLISE RECURSAL

> Instrução: Identifique os pontos da sentença que apresentam maior potencial recursal. Fundamente em dispositivos legais e jurisprudência. Seja objetivo e estratégico.

### 6.1 Possíveis Vícios para Embargos de Declaração

> Instrução: Verifique se há omissão (questão suscitada não apreciada), contradição (fundamentos incompatíveis com o dispositivo), obscuridade (texto ininteligível) ou erro material (erro de grafia, cálculo, etc.).

- [ ] **Omissão:** {descricao_omissao}
- [ ] **Contradição:** {descricao_contradicao}
- [ ] **Obscuridade:** {descricao_obscuridade}
- [ ] **Erro material:** {descricao_erro_material}

### 6.2 Possíveis Razões de Reforma em Apelação

| # | Ponto Recorrível | Fundamento para Reforma | Tese Contraposta | Probabilidade de Êxito |
|---|---|---|---|---|
| 1 | {ponto_recursal_1} | {fundamento_recursal_1} | {tese_contraposta_1} | {probabilidade_exito_1} |
| 2 | {ponto_recursal_2} | {fundamento_recursal_2} | {tese_contraposta_2} | {probabilidade_exito_2} |
| 3 | {ponto_recursal_3} | {fundamento_recursal_3} | {tese_contraposta_3} | {probabilidade_exito_3} |

> Instrução: Probabilidade de êxito: Alta / Média / Baixa. Fundamente em jurisprudência do tribunal competente para julgar a apelação.

---

## 7. DOCUMENTOS NECESSÁRIOS PARA O RECURSO

> Instrução: Marque os documentos já disponíveis e liste os que precisam ser providenciados.

### 7.1 Para Embargos de Declaração

- [ ] Cópia da sentença publicada no DJe
- [ ] Identificação do vício a ser apontado (omissão/contradição/obscuridade/erro material)
- [ ] Procuração atualizada em nome do advogado signatário

### 7.2 Para Apelação

- [ ] Cópia integral da sentença
- [ ] Comprovante de recolhimento do preparo (taxa judiciária + porte de remessa/retorno)
  - Valor estimado do preparo: R$ {valor_preparo}
  - Base de cálculo: {base_calculo_preparo}
  - Lei estadual aplicável: {lei_custas_estadual}
- [ ] Procuração com poderes para recorrer
- [ ] Documentos novos a juntar (art. 1.014 CPC): {documentos_novos}
- [ ] Rol de testemunhas para eventual instrução no tribunal (se aplicável)
- [ ] Comprovantes dos fatos alegados nas razões

> Instrução: O não recolhimento do preparo no prazo da apelação resulta em deserção (art. 1.007 CPC). Verifique se o cliente é beneficiário de justiça gratuita — nesse caso, o preparo é dispensado.

**Benefício da Justiça Gratuita:** {beneficio_jg} *(Sim / Não / Pleiteado)*

---

*⚠️ Esta minuta é um rascunho. Revisão e assinatura do advogado são obrigatórias antes do protocolo.*
*Analista Processual Squad v1.1.0 — AIOX Squads*
