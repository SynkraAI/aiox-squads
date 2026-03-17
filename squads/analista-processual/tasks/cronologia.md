# cronologia

## Task: Cronologia Processual Completa

### Metadata
- **executor:** analista-processual (com extrator-documentos)
- **elicit:** true
- **mode:** single-pass
- **output:** cronologia-processual.md

### Objetivo
Extrair e organizar todos os atos processuais em ordem cronológica com datas, responsáveis e prazos gerados, produzindo uma linha do tempo completa do processo.

### Inputs Necessários
```
processo: Número do processo (formato CNJ ou livre)
documentos: Texto ou conteúdo das peças processuais (petições, decisões, despachos, certidões, intimações)
```

### Elicitação
```
Qual o número do processo?
> [usuário informa]

Cole ou descreva os documentos processuais a serem analisados:
> [usuário fornece]
```

### Passos de Execução

#### Fase 1: Identificação do Processo
1. Extrair número do processo no formato CNJ
2. Identificar tribunal, vara/câmara, instância e classe processual
3. Confirmar número e dados básicos com usuário antes de prosseguir

#### Fase 2: Extração de Atos (extrator-documentos)
1. Varrer todos os documentos fornecidos
2. Identificar cada ato processual com data, tipo e responsável
3. Para atos sem data identificável: registrar como "Data não identificada" — nunca omitir
4. Classificar cada ato em: petição | decisão | despacho | certidão | intimação | outro

#### Fase 3: Identificação de Responsáveis
1. Para cada ato, identificar o responsável: juiz, relator, parte autora, parte ré, perito, MP, escrivão
2. Se responsável não identificável no documento: registrar "Não identificado"

#### Fase 4: Cálculo de Prazos Gerados
1. Para cada ato intimatório ou decisório, calcular o prazo gerado (se aplicável)
2. Aplicar regra do CPC/2015: início no primeiro dia útil após intimação (art. 224), contagem em dias úteis (art. 219)
3. Registrar prazo gerado e data-limite calculada
4. Se ato não gera prazo: registrar "—"

#### Fase 5: Ordenação Cronológica
1. Ordenar todos os atos do mais antigo ao mais recente
2. Atos com "Data não identificada" inserir ao final, após o último ato datado

#### Fase 6: Geração da Linha do Tempo
1. Consolidar todos os dados em tabela markdown no formato de saída
2. Destacar atos com prazos ativos ou vencidos

### Condições de Veto
- NUNCA omitir atos sem data — registrar como "Data não identificada"
- SEMPRE ordenar do mais antigo ao mais recente
- NUNCA inventar datas ou responsáveis não presentes nos documentos
- SE documentos insuficientes para identificar atos: alertar e listar o que está faltando

### Formato de Saída

```markdown
# Cronologia Processual

**Processo:** {número CNJ}
**Tribunal/Vara:** {tribunal} — {vara}
**Instância:** {1º grau | 2º grau | STJ | STF}
**Cronologia gerada em:** {data}

---

## Linha do Tempo

| Data | Ato | Tipo | Responsável | Prazo Gerado | Status |
|------|-----|------|-------------|--------------|--------|
| {data} | {descrição do ato} | {petição/decisão/despacho/certidão/intimação/outro} | {responsável} | {prazo + data-limite ou —} | {ativo/vencido/cumprido/—} |

---

## Atos Sem Data Identificada

| Ato | Tipo | Responsável | Observação |
|-----|------|-------------|------------|
| {descrição} | {tipo} | {responsável ou "Não identificado"} | {fonte/documento de origem} |

---
*Cronologia extraída com base nos documentos fornecidos. Confirmar sequência no sistema judicial (PJe/e-SAJ).*
```
