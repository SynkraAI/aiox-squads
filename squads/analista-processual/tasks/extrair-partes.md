# extrair-partes

## Task: Identificação e Qualificação das Partes do Processo

### Metadata
- **executor:** extrator-documentos
- **elicit:** true
- **mode:** single-pass
- **output:** partes-processo.md

### Objetivo
Identificação e qualificação completa de todas as partes do processo — polos, advogados, representantes e terceiros — com validação dos dados cadastrais e rastreabilidade da fonte documental de cada informação extraída.

### Inputs Necessários
```
documentos: Texto ou conteúdo das peças processuais (petição inicial, contestação, procurações, decisões)
processo: Número do processo (opcional — extraído dos documentos se disponível)
```

### Elicitação
```
Cole ou descreva os documentos processuais disponíveis (petição inicial, contestação, procurações, decisões):
> [usuário fornece]

Qual o número do processo? (opcional)
> [usuário informa ou deixa em branco]
```

### Passos de Execução

#### Fase 1: Identificação do Polo Ativo
1. Extrair nome completo do autor/requerente
2. Extrair CPF (formato XXX.XXX.XXX-XX) ou CNPJ (formato XX.XXX.XXX/XXXX-XX)
3. Extrair endereço completo
4. Identificar advogado(s) do polo ativo: nome, número OAB (formato OAB/UF NNNNN)
5. Registrar fonte documental de cada dado extraído

#### Fase 2: Identificação do Polo Passivo
1. Extrair nome completo do réu/requerido
2. Extrair CPF (formato XXX.XXX.XXX-XX) ou CNPJ (formato XX.XXX.XXX/XXXX-XX)
3. Extrair endereço completo
4. Identificar advogado(s) do polo passivo: nome, número OAB (formato OAB/UF NNNNN)
5. Registrar fonte documental de cada dado extraído

#### Fase 3: Identificação de Terceiros
1. Identificar intervenientes (assistentes, opoentes, denunciados à lide, chamados ao processo)
2. Identificar amicus curiae, se houver
3. Para cada terceiro: extrair qualificação completa com a mesma estrutura dos polos
4. Registrar base documental

#### Fase 4: Ministério Público
1. Verificar se há intervenção do MP (custos legis ou parte)
2. Identificar membro do MP e promotoria/procuradoria responsável, se informado
3. Registrar função processual: parte | fiscal da ordem jurídica

#### Fase 5: Perito
1. Verificar se há perito nomeado no processo
2. Extrair nome, especialidade e eventuais dados cadastrais informados
3. Registrar decisão ou despacho de nomeação como fonte

#### Fase 6: Validação dos Dados
1. Validar formato de OAB: padrão OAB/UF NNNNN — alertar se formato divergente
2. Validar formato de CPF: padrão XXX.XXX.XXX-XX — alertar se formato divergente
3. Validar formato de CNPJ: padrão XX.XXX.XXX/XXXX-XX — alertar se formato divergente
4. Para campos ausentes nos documentos: registrar "Não identificado" — nunca preencher com dados presumidos

### Condições de Veto
- SE campo ausente no documento: registrar "Não identificado" — NUNCA inventar ou presumir dados
- SEMPRE mencionar a fonte (nome do documento) de onde cada dado foi extraído
- NUNCA validar número de OAB ou CPF/CNPJ como válido sem que o dado esteja explicitamente presente nos documentos
- SE documentos insuficientes para qualificar uma das partes: alertar e indicar quais documentos são necessários

### Formato de Saída

```markdown
# Partes do Processo

**Processo:** {número CNJ ou "Não informado"}
**Extração realizada em:** {data}

---

## Polo Ativo

| Campo | Dado | Fonte |
|-------|------|-------|
| Nome | {nome completo} | {documento de origem} |
| CPF / CNPJ | {CPF ou CNPJ formatado ou "Não identificado"} | {documento de origem} |
| Endereço | {endereço completo ou "Não identificado"} | {documento de origem} |
| Advogado(s) | {nome — OAB/UF NNNNN ou "Não identificado"} | {documento de origem} |

---

## Polo Passivo

| Campo | Dado | Fonte |
|-------|------|-------|
| Nome | {nome completo} | {documento de origem} |
| CPF / CNPJ | {CPF ou CNPJ formatado ou "Não identificado"} | {documento de origem} |
| Endereço | {endereço completo ou "Não identificado"} | {documento de origem} |
| Advogado(s) | {nome — OAB/UF NNNNN ou "Não identificado"} | {documento de origem} |

---

## Terceiros

| Nome | Qualidade | CPF / CNPJ | Advogado | Fonte |
|------|-----------|------------|---------|-------|
| {nome} | {assistente/opoente/denunciado/chamado/amicus curiae} | {dado ou "Não identificado"} | {nome — OAB ou "Não identificado"} | {documento} |

*(Se não houver terceiros: "Nenhum terceiro identificado nos documentos fornecidos")*

---

## Ministério Público

| Campo | Dado | Fonte |
|-------|------|-------|
| Intervenção | {Sim — custos legis | Sim — parte | Não identificado} | {documento} |
| Membro / Promotoria | {nome e promotoria ou "Não identificado"} | {documento} |

---

## Perito

| Campo | Dado | Fonte |
|-------|------|-------|
| Nome | {nome ou "Não identificado"} | {documento} |
| Especialidade | {especialidade ou "Não identificado"} | {documento} |

---

## Alertas de Validação

{Listar campos com formato divergente ou ausente, ou "Nenhum alerta — todos os dados validados com sucesso"}

---
*Extração realizada com base nos documentos fornecidos. Confirmar dados cadastrais completos no sistema judicial (PJe/e-SAJ) e junto às partes.*
```
