# mapear-prazos

## Task: Mapeamento Completo de Prazos Processuais

### Metadata
- **executor:** calculador-prazos (com supervisão de analista-processual)
- **elicit:** true
- **mode:** single-pass
- **output:** tabela-prazos.md

### Objetivo
Identificar, calcular e organizar todos os prazos processuais vigentes e futuros previsíveis, com datas-limite precisas e alertas de urgência.

### Inputs Necessários
```
processo: Número do processo
ultimo_ato: Data e descrição do último ato intimado
tribunal: Tribunal (para considerar calendário local)
documentos: Peças que gerem prazos (decisão, despacho, citação, etc.)
```

### Passos de Execução

1. Identificar todos os atos que geraram ou gerarão prazos nos documentos
2. Para cada ato: aplicar prazo legal com base no CPC/2015 ou lei especial
3. Calcular data-início (D+1 útil após intimação)
4. Calcular data-limite considerando dias úteis e feriados informados
5. Classificar urgência: VENCIDO | CRÍTICO (<3 dias) | URGENTE (<5 dias) | ATENÇÃO (<10 dias) | OK
6. Ordenar por urgência crescente (mais urgente primeiro)

### Regras de Contagem

**CPC/2015 (padrão):**
- Início: primeiro dia útil após a intimação/publicação (art. 224)
- Contagem: dias úteis (art. 219)
- Prorrogação: se vencer em não-útil, próximo dia útil (art. 224, §1º)

**Exceções em dias corridos:**
- Prazo constitucional (Habeas Corpus)
- Prazos de legislação especial que expressamente preveem dias corridos

### Formato de Saída

```markdown
# Mapeamento de Prazos Processuais

**Processo:** {número}
**Tribunal/Vara:** {identificação}
**Mapeamento gerado em:** {data}
**Base normativa:** CPC/2015, arts. 212-232 (dias úteis, salvo exceção indicada)

---

## Alertas de Urgência

{Só mostrar esta seção se houver prazos VENCIDOS ou CRÍTICOS}

🔴 CRÍTICO: {prazo} vence em {data} ({N dias úteis restantes})

---

## Tabela de Prazos

| # | Prazo | Ato-Gatilho | Data Intimação | Início Contagem | Data-Limite | Dias Restantes | Base Legal | Status |
|---|-------|------------|---------------|----------------|-------------|---------------|-----------|--------|
| 1 | | | | | | | | 🔴/🟡/🟢/✅ |

**Legenda:**
- 🔴 CRÍTICO — menos de 3 dias úteis
- 🟡 URGENTE — 3 a 5 dias úteis
- 🟠 ATENÇÃO — 6 a 10 dias úteis
- 🟢 OK — mais de 10 dias úteis
- ✅ CUMPRIDO — ato já praticado
- ⬛ VENCIDO — prazo expirado sem ato registrado

---

## Observações sobre Suspensões
{Informar se há suspensão de prazos em vigor: férias forenses, recesso, acordo entre partes}

---
*Datas calculadas com base nas informações fornecidas. Confirmar no sistema judicial (PJe/e-SAJ) antes de qualquer ato.*
```

### Condições de Veto
- NUNCA calcular prazo sem identificar a data de intimação/publicação
- SE não houver informação de feriados locais: alertar que o cálculo pode divergir do calendário real
- SE prazo já vencido: destacar como VENCIDO e orientar verificação imediata com advogado
