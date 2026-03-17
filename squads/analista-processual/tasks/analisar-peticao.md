# analisar-peticao

## Task: Análise Estruturada de Petição

### Metadata
- **executor:** analista-processual (com extrator-documentos)
- **elicit:** true
- **mode:** single-pass
- **output:** analise-peticao.md

### Objetivo
Análise estruturada de petição inicial ou contestação — identificar partes, causa de pedir, pedidos, fundamentos, provas e pontos de vulnerabilidade da peça, com verificação dos requisitos legais aplicáveis.

### Inputs Necessários
```
peticao: Texto completo da petição a ser analisada
tipo: Tipo da peça (inicial | contestação | recurso)
processo: Número do processo (opcional — extraído da peça se disponível)
```

### Elicitação
```
Cole o texto da petição a ser analisada:
> [usuário fornece]

Qual o tipo da peça? (inicial / contestação / recurso)
> [usuário informa]

Qual o número do processo? (opcional)
> [usuário informa ou deixa em branco]
```

### Passos de Execução

#### Fase 1: Identificação do Tipo de Peça
1. Confirmar o tipo de peça informado pelo usuário (inicial | contestação | recurso)
2. Se não informado: identificar o tipo com base no conteúdo
3. Registrar tipo identificado antes de prosseguir com a análise
4. NUNCA prosseguir sem identificar o tipo de peça

#### Fase 2a: Verificação de Requisitos — Petição Inicial
*(Executar apenas se tipo = inicial)*
1. Verificar endereçamento ao juízo competente (art. 319, I, CPC/2015)
2. Verificar qualificação das partes: nome, CPF/CNPJ, endereço, estado civil, profissão (art. 319, II)
3. Verificar descrição dos fatos e fundamentos jurídicos (causa de pedir — art. 319, III)
4. Verificar formulação dos pedidos com especificidade (art. 319, IV)
5. Verificar indicação do valor da causa (art. 319, V)
6. Verificar requerimento de provas (art. 319, VI)
7. Verificar opção por audiência de conciliação ou mediação (art. 319, VII)
8. Verificar documentos indispensáveis à propositura da ação (art. 320)

#### Fase 2b: Verificação de Requisitos — Contestação
*(Executar apenas se tipo = contestação)*
1. Identificar preliminares arguidas (art. 337, CPC/2015) e verificar cabimento de cada uma
2. Verificar se impugnações são específicas ou genéricas (art. 341 — impugnação específica obrigatória)
3. Identificar fatos não impugnados (efeito da confissão ficta — art. 341, parágrafo único)
4. Verificar fundamentos de defesa: diretos (negam fatos) vs. indiretos (fatos impeditivos, modificativos, extintivos)
5. Verificar pedidos formulados na contestação (improcedência, extinção, reconvenção se houver)

#### Fase 2c: Verificação de Requisitos — Recurso
*(Executar apenas se tipo = recurso)*
1. Identificar tipo de recurso (apelação, agravo, embargos, etc.)
2. Verificar tempestividade com base na data da intimação se informada
3. Verificar regularidade formal: preparo, petição de interposição, razões
4. Identificar pedido recursal: reforma, anulação, integração
5. Verificar fundamentos: error in judicando vs. error in procedendo

#### Fase 3: Análise de Fundamentos e Provas
1. Listar todos os fundamentos jurídicos invocados (artigos, leis, súmulas, jurisprudências)
2. Verificar se cada fundamento está corretamente aplicado ao caso
3. Listar provas requeridas ou apresentadas
4. Verificar coerência entre fatos narrados, fundamentos jurídicos e pedidos formulados

#### Fase 4: Pontos de Vulnerabilidade
1. Identificar argumentos frágeis ou sem respaldo legal suficiente
2. Identificar omissões relevantes (requisitos ausentes, fatos não narrados, provas não requeridas)
3. Identificar contradições internas na peça
4. Classificar cada vulnerabilidade: CRÍTICA | RELEVANTE | MENOR
5. NUNCA emitir opinião sobre estratégia processual — apenas identificar pontos técnicos

### Condições de Veto
- SEMPRE identificar o tipo de peça antes de iniciar a análise
- NUNCA emitir opinião sobre estratégia processual — análise técnica e factual apenas
- NUNCA afirmar ausência de requisito sem verificar o texto integral da peça
- SE texto incompleto ou truncado: alertar e indicar que a análise pode estar prejudicada

### Formato de Saída

```markdown
# Análise de Petição

**Tipo de Peça:** {inicial | contestação | recurso — especificar}
**Processo:** {número CNJ ou "Não informado"}
**Análise gerada em:** {data}

---

## 1. Identificação da Peça

| Campo | Dado |
|-------|------|
| Tipo | {inicial/contestação/recurso} |
| Autor/Recorrente | {nome} |
| Réu/Recorrido | {nome} |
| Advogado subscritor | {nome e OAB} |
| Data da peça | {data ou "Não identificada"} |

---

## 2. Requisitos Formais

| Requisito | Presente | Observação |
|-----------|----------|------------|
| {requisito legal} | Sim / Não / Parcial | {observação se necessário} |

---

## 3. Causa de Pedir

**Fatos narrados:**
{resumo dos fatos conforme a peça}

**Fundamentos jurídicos invocados:**
| Fundamento | Aplicação | Observação |
|-----------|-----------|------------|
| {art./lei/súmula} | Adequada / Inadequada / Parcial | {observação} |

---

## 4. Pedidos

| # | Pedido | Classificação | Respaldo nos Fatos |
|---|--------|--------------|-------------------|
| 1 | {pedido principal} | Principal | Sim / Não / Parcial |
| 2 | {pedido} | Subsidiário/Cumulado | Sim / Não / Parcial |

**Valor da causa:** R$ {valor ou "Não informado"}

---

## 5. Provas

| Prova | Tipo | Finalidade |
|-------|------|-----------|
| {prova} | {documental/pericial/testemunhal/outro} | {fato que pretende provar} |

---

## 6. Pontos de Vulnerabilidade

### CRÍTICO
{listar ou "Nenhum identificado"}

### RELEVANTE
{listar ou "Nenhum identificado"}

### MENOR
{listar ou "Nenhum identificado"}

---
*Análise técnica com base no texto fornecido. Não constitui parecer jurídico.*
*Responsabilidade do advogado subscritor verificar e confirmar todos os dados processuais.*
```
