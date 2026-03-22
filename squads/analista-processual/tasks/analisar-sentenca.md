# analisar-sentenca

## Task: Análise Estruturada de Sentença Judicial

### Metadata
- **executor:** analista-processual
- **elicit:** true
- **mode:** single-pass
- **output:** analise-sentenca.md

### Objetivo
Estruturar e analisar sentença judicial em suas três partes obrigatórias (relatório, fundamentação, dispositivo), identificar o resultado para cada parte, prazos para recurso e pontos relevantes para estratégia recursal.

### Inputs Necessários
```
sentenca: Texto completo da sentença
processo: Número do processo (opcional — extraído do documento)
```

### Passos de Execução

1. Identificar as três partes da sentença (art. 489, CPC/2015)
2. Extrair o dispositivo (procedência parcial/total/improcedência)
3. Mapear cada pedido vs resultado obtido
4. Identificar condenações (valor, juros, correção, honorários, custas)
5. Identificar fundamentos da decisão
6. Calcular prazos para recurso (apelação: 15 dias úteis)
7. Identificar pontos passíveis de recurso (omissão, contradição, obscuridade → embargos de declaração)

### Formato de Saída

```markdown
# Análise de Sentença

**Processo:** {número}
**Juiz(a):** {nome}
**Data da sentença:** {data}
**Data de publicação/intimação:** {data}

---

## Resultado Geral

**Dispositivo:** {Procedente | Procedente em parte | Improcedente | Extinção sem mérito}
**Resultado para o Autor:** {favorável | parcialmente favorável | desfavorável}
**Resultado para o Réu:** {favorável | parcialmente favorável | desfavorável}

---

## Análise por Pedido

| # | Pedido | Resultado | Observação |
|---|--------|-----------|-----------|
| 1 | {pedido principal} | Procedente/Improcedente/Parcial | |
| 2 | {pedido subsidiário} | | |

---

## Condenações (Dispositivo)

| Item | Valor/Condição | Base Legal |
|------|---------------|-----------|
| Principal | R$ {valor} ou {obrigação} | |
| Juros | {taxa} desde {data} | |
| Correção monetária | {índice} desde {data} | |
| Honorários advocatícios | {%} sobre {base} | Art. 85, CPC |
| Custas processuais | Sucumbência de {parte} | Art. 86/87, CPC |

---

## Fundamentos da Decisão

### Questões Preliminares Decididas
{listar ou "Nenhuma"}

### Fundamentos de Mérito
{Resumo dos fundamentos jurídicos centrais da sentença — 3-5 pontos principais}

---

## Prazos Recursais

| Recurso | Prazo | Início | Vencimento | Legitimado |
|---------|-------|--------|-----------|-----------|
| Embargos de Declaração | 5 dias úteis | {data pub.} | {data} | Qualquer parte |
| Apelação | 15 dias úteis | {data pub.} | {data} | Sucumbente |

---

## Pontos para Análise Recursal

### Possíveis Embargos de Declaração
{omissão, contradição, obscuridade ou erro material identificados — art. 1.022, CPC}

### Pontos para Apelação
{aspectos da sentença favoráveis à revisão em 2º grau}

---

## Documentos Necessários para Recurso
- [ ] Certidão de intimação (data da publicação)
- [ ] Cópia da sentença autenticada
- [ ] Procuração com poderes para recorrer (verificar se já consta nos autos)
- [ ] Preparo recursal (valor = {base de cálculo conforme TJXX})

---
*Análise factual da sentença. Não constitui orientação sobre estratégia recursal — responsabilidade do advogado.*
```

### Regras de Qualidade
- NUNCA omitir o dispositivo — é o elemento mais importante da sentença
- SEMPRE calcular e informar o prazo para embargos de declaração (5 dias úteis) mesmo que a parte não pretenda recorrer
- SE sentença omissa sobre algum pedido: sinalizar como PONTO DE ATENÇÃO para embargos
- SE condenação em honorários: especificar base de cálculo e percentual
