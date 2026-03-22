# riscos

## Task: Mapeamento de Riscos Processuais

### Metadata
- **executor:** mapeador-riscos (com supervisão de analista-processual)
- **elicit:** true
- **mode:** sequential
- **output:** relatorio-riscos.md

### Objetivo
Mapeamento completo de riscos processuais em 5 níveis de pressupostos, classificados por severidade, com base documental obrigatória para cada risco identificado.

### Inputs Necessários
```
processo: Número do processo (formato CNJ ou livre)
documentos: Texto ou conteúdo das peças processuais (petição inicial, contestação, decisões, certidões, procurações)
```

### Elicitação
```
Qual o número do processo?
> [usuário informa]

Cole ou descreva os documentos processuais disponíveis para análise:
> [usuário fornece]
```

### Passos de Execução

#### Nível 1: Existência do Processo
1. Verificar validade formal da petição inicial (presença dos requisitos mínimos)
2. Verificar se houve citação válida do réu
3. Verificar se o juízo possui jurisdição sobre a matéria e as partes
4. Registrar achados com classificação e base documental

#### Nível 2: Validade Processual
1. Verificar competência absoluta (matéria, pessoa, funcional)
2. Verificar competência relativa (territorial, valor)
3. Verificar capacidade processual das partes (ser parte vs. estar em juízo)
4. Verificar regularidade da representação por advogado e número OAB
5. Registrar achados com classificação e base documental

#### Nível 3: Condições da Ação
1. Verificar legitimidade ativa e passiva (partes corretas na relação processual)
2. Verificar interesse processual (utilidade + necessidade da tutela jurisdicional)
3. Verificar possibilidade jurídica do pedido
4. Registrar achados com classificação e base documental

#### Nível 4: Objeções Substanciais
1. Verificar prescrição: prazo e marco inicial conforme código material aplicável
2. Verificar decadência: prazo e natureza do direito
3. Verificar coisa julgada: identidade de partes, causa de pedir e pedido
4. Verificar litispendência: processo idêntico em curso
5. Verificar perempção: três extinções anteriores por abandono (art. 486, §3º, CPC)
6. Registrar achados com classificação e base documental

#### Nível 5: Regularidade Formal
1. Verificar regularidade das citações e intimações realizadas
2. Verificar observância de prazos processuais pelas partes e pelo juízo
3. Verificar completude dos documentos obrigatórios (art. 320, CPC/2015)
4. Verificar validade e abrangência da procuração (poderes gerais/especiais)
5. Verificar recolhimento de custas e preparo
6. Registrar achados com classificação e base documental

#### Fase de Consolidação
1. Compilar todos os riscos identificados nos 5 níveis
2. Ordenar por criticidade: CRÍTICO primeiro, depois ATENÇÃO, depois OBSERVAÇÃO
3. Gerar relatório no formato de saída

### Condições de Veto
- RISCOS CRÍTICOS devem aparecer no INÍCIO do relatório, antes de qualquer outro dado
- NUNCA afirmar risco sem base documental — cada risco deve citar o documento e trecho de origem
- NUNCA omitir nível mesmo que não haja riscos — registrar "Nenhum risco identificado neste nível"
- SE documentos insuficientes para avaliar um nível: indicar "Documentação insuficiente — análise parcial"

### Formato de Saída

```markdown
# Relatório de Riscos Processuais

**Processo:** {número CNJ}
**Tribunal/Vara:** {tribunal} — {vara}
**Relatório gerado em:** {data}

---

## 🔴 RISCOS CRÍTICOS

{Listar imediatamente, antes de qualquer outro dado, ou "Nenhum risco crítico identificado"}

| # | Risco | Nível | Fundamento | Base Documental |
|---|-------|-------|------------|-----------------|
| 1 | {descrição} | {nível 1-5} | {art./lei/súmula} | {documento + trecho} |

---

## Análise por Nível de Pressuposto

### Nível 1 — Existência do Processo

| Risco | Classificação | Fundamento | Base Documental |
|-------|--------------|------------|-----------------|
| {descrição ou "Nenhum risco identificado neste nível"} | 🔴/🟡/🟢 | | |

### Nível 2 — Validade Processual

| Risco | Classificação | Fundamento | Base Documental |
|-------|--------------|------------|-----------------|
| {descrição ou "Nenhum risco identificado neste nível"} | 🔴/🟡/🟢 | | |

### Nível 3 — Condições da Ação

| Risco | Classificação | Fundamento | Base Documental |
|-------|--------------|------------|-----------------|
| {descrição ou "Nenhum risco identificado neste nível"} | 🔴/🟡/🟢 | | |

### Nível 4 — Objeções Substanciais

| Risco | Classificação | Fundamento | Base Documental |
|-------|--------------|------------|-----------------|
| {descrição ou "Nenhum risco identificado neste nível"} | 🔴/🟡/🟢 | | |

### Nível 5 — Regularidade Formal

| Risco | Classificação | Fundamento | Base Documental |
|-------|--------------|------------|-----------------|
| {descrição ou "Nenhum risco identificado neste nível"} | 🔴/🟡/🟢 | | |

---

**Legenda:**
- 🔴 CRÍTICO — risco de extinção do processo ou nulidade absoluta
- 🟡 ATENÇÃO — vícios sanáveis, exigem providência
- 🟢 OBSERVAÇÃO — boas práticas, impacto limitado

---
*Análise factual com base nos documentos fornecidos. Não constitui parecer jurídico.*
*Responsabilidade do advogado subscritor verificar e confirmar todos os dados no sistema judicial.*
```
