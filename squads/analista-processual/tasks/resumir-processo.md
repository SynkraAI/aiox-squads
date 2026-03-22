# resumir-processo

## Task: Resumo Executivo de Processo Judicial

### Metadata
- **executor:** analista-processual
- **elicit:** true
- **mode:** single-pass
- **output:** resumo-executivo.md

### Objetivo
Produzir um resumo executivo conciso (1-2 páginas) do processo para leitura rápida por advogados e gestores jurídicos. Foco em: quem, o que pede, onde está, prazos imediatos e riscos.

### Inputs Necessários
```
processo: Número do processo
documentos: Peça(s) processual(is) a resumir
destinatario: (opcional) advogado | gestor | cliente — para nível de tecnicidade
```

### Passos de Execução

1. Identificar processo e fase atual
2. Extrair as 5 informações essenciais:
   - Quem são as partes
   - O que se discute (objeto)
   - Onde está (fase/instância)
   - Quais prazos correm agora
   - Quais os riscos imediatos
3. Redigir resumo em formato estruturado
4. Ajustar tecnicidade ao destinatário (se informado)

### Formato de Saída

```markdown
# Resumo Executivo — Processo {número}

**Data:** {data} | **Analista:** Analista Processual

---

## Em Uma Linha
{descrição da ação em 1 frase: "Ação de [tipo] movida por [autor] contra [réu] por [motivo central]."}

## Situação Atual
- **Fase:** {fase processual}
- **Tribunal/Vara:** {identificação}
- **Último ato:** {data} — {descrição do último ato}
- **Próximo passo esperado:** {o que deve acontecer a seguir}

## Partes
- **Autor(a):** {nome} — {advogado responsável}
- **Réu/Ré:** {nome} — {advogado responsável}

## O que está em discussão
{2-4 linhas descrevendo o objeto e os pedidos principais. Linguagem clara, sem excesso de juridiquês.}

**Valor estimado em disputa:** R$ {valor}

## Prazos Imediatos

| Prazo | Vencimento | Urgência |
|-------|-----------|---------|
| {ato} | {data} | 🔴/🟡/🟢 |

## Pontos de Atenção
{Máximo 3 itens. Só o mais crítico de cada categoria.}
- 🔴 {risco crítico, se houver}
- 🟡 {atenção, se houver}
- 🟢 {observação relevante}

---
*Resumo para acompanhamento interno. Não substitui análise completa nem parecer jurídico.*
```

### Regras de Qualidade
- Resumo completo em no máximo 1 página impressa
- Proibido: parágrafos longos, jargão sem explicação, omitir prazos ativos
- Obrigatório: data do resumo, número do processo, flag de urgência se houver prazo < 5 dias
