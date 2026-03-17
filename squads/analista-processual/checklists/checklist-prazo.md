# Checklist — Prazo
> squad: analista-processual v1.1.0 | executor: agente-analista-processual

Use este checklist como quality gate antes de entregar qualquer cálculo ou mapeamento de prazos.

---

## INPUTS

- [ ] Data de intimação/publicação identificada
- [ ] Ato que gerou o prazo identificado (despacho, decisão interlocutória, sentença, acórdão etc.)
- [ ] Tribunal identificado (necessário para feriados locais)
- [ ] Tipo de prazo identificado (CPC/2015 = dias úteis, ou lei especial com regra própria)

---

## CÁLCULO

- [ ] Data-início = D+1 útil após intimação (art. 224, CPC/2015)
- [ ] Contagem em dias úteis (art. 219, CPC/2015)
- [ ] Vencimento em dia útil (se cair em dia não útil, prorrogar para o próximo — art. 224, §1º)
- [ ] Férias forenses verificadas (1 a 31 de janeiro / 1 a 31 de julho)
- [ ] Feriados nacionais descontados
- [ ] Feriados locais: informar se não foram considerados (risco de erro — confirmar no tribunal)

---

## ENTES ESPECIAIS

- [ ] Fazenda Pública identificada (prazo em dobro — art. 183, CPC/2015)
- [ ] Defensoria Pública identificada (prazo em dobro — art. 186, CPC/2015)
- [ ] Ministério Público identificado (prazo em dobro — art. 180, CPC/2015)
- [ ] Litisconsortes com advogados diferentes identificados (prazo em dobro — art. 229, CPC/2015)

---

## ALERTAS

- [ ] Prazos VENCIDOS identificados e sinalizados explicitamente
- [ ] Prazos < 3 dias úteis marcados 🔴 CRÍTICO
- [ ] Prazos entre 3 e 5 dias úteis marcados 🟡 URGENTE
- [ ] Base legal citada para cada prazo calculado
- [ ] Disclaimer de confirmação no tribunal presente no output
