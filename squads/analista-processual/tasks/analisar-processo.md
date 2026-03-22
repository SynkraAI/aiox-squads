# analisar-processo

## Task: Análise Completa de Processo Judicial

### Metadata
- **executor:** analista-processual (com apoio de extrator-documentos, calculador-prazos, mapeador-riscos)
- **elicit:** true
- **mode:** sequencial
- **output:** relatorio-processual.md

### Inputs Necessários
```
processo: Número do processo (formato CNJ ou livre)
documentos: Texto ou conteúdo das peças processuais a analisar
tribunal: Tribunal/vara (opcional — extraído do documento se disponível)
objetivo: Foco da análise (opcional — padrão: análise completa)
```

### Elicitação
```
Qual o número do processo?
> [usuário informa]

Cole ou descreva os documentos a analisar (petição inicial, decisão, etc.):
> [usuário fornece]

Há algum foco específico para a análise? (prazos, riscos, partes, resumo executivo)
> [usuário responde ou "análise completa"]
```

### Passos de Execução

#### Fase 1: Identificação
1. Extrair número do processo no formato CNJ
2. Identificar: tribunal, vara/câmara, instância, classe processual
3. Identificar fase processual atual
4. Confirmar dados com usuário antes de prosseguir

#### Fase 2: Extração de Dados (extrator-documentos)
1. Identificar tipo de cada documento fornecido
2. Extrair partes (polo ativo, polo passivo, terceiros, advogados)
3. Extrair objeto da ação (pedidos + fundamentos)
4. Extrair cronologia de atos processuais
5. Extrair citações legais e jurisprudenciais

#### Fase 3: Cálculo de Prazos (calculador-prazos)
1. Identificar o último ato intimado
2. Calcular prazos correntes com base no CPC/2015
3. Identificar prazos fatais (< 5 dias úteis)
4. Gerar tabela de prazos com datas-limite

#### Fase 4: Mapeamento de Riscos (mapeador-riscos)
1. Verificar pressupostos processuais (5 níveis)
2. Verificar competência
3. Analisar prescrição/decadência
4. Identificar nulidades e vícios formais
5. Classificar riscos por severidade (CRÍTICO | ATENÇÃO | OBSERVAÇÃO)

#### Fase 5: Síntese e Relatório
1. Consolidar dados das fases anteriores
2. Ordenar alertas por criticidade (CRÍTICO primeiro)
3. Gerar relatório no formato padrão
4. Apresentar relatório ao usuário

### Condições de Veto
- NUNCA iniciar análise sem ao menos o número do processo ou a peça processual
- SE documentos insuficientes: alertar e listar o que está faltando antes de prosseguir
- SE prazo CRÍTICO identificado: destacar no INÍCIO do relatório, antes de qualquer outro dado

### Formato de Saída

```markdown
# Relatório de Análise Processual

**Processo:** {número CNJ}
**Tribunal/Vara:** {tribunal} — {vara}
**Instância:** {1º grau | 2º grau | STJ | STF}
**Classe:** {classe processual CNJ}
**Fase atual:** {fase}
**Análise gerada em:** {data}

---

⚠️ ALERTAS CRÍTICOS (se houver)
{listar apenas se existirem prazos ou riscos CRÍTICOS}

---

## 1. Identificação do Processo

| Campo | Dado |
|-------|------|
| Número (CNJ) | |
| Tribunal | |
| Vara/Câmara | |
| Juiz/Relator | |
| Distribuído em | |
| Fase atual | |

## 2. Partes

| Polo | Nome | CPF/CNPJ | Advogado | OAB |
|------|------|----------|----------|-----|
| Ativo | | | | |
| Passivo | | | | |

## 3. Objeto da Ação

**Tipo de ação:** {denominação}
**Pedido principal:** {descrever}
**Pedidos subsidiários/cumulados:**
  1. {pedido}
  2. {pedido}

**Fundamentos jurídicos invocados:**
  - {artigo/lei}

**Valor da causa:** R$ {valor}

## 4. Cronologia Processual

| Data | Ato | Responsável | Prazo Gerado |
|------|-----|-------------|-------------|
| | | | |

## 5. Prazos em Curso

| Prazo | Evento-Gatilho | Data-Início | Data-Limite | Base Legal | Status |
|-------|---------------|-------------|-------------|-----------|--------|
| | | | | | 🔴/🟡/🟢 |

*Contagem: dias úteis (art. 219, CPC/2015), salvo exceção indicada.*

## 6. Riscos Processuais

### 🔴 CRÍTICO
{listar ou "Nenhum identificado"}

### 🟡 ATENÇÃO
{listar ou "Nenhum identificado"}

### 🟢 OBSERVAÇÃO
{listar ou "Nenhum identificado"}

---
*Análise factual com base nos documentos fornecidos. Não constitui parecer jurídico.*
*Responsabilidade do advogado subscritor verificar e confirmar todos os dados no sistema judicial.*
```
