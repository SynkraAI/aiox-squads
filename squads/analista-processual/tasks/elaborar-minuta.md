# elaborar-minuta

## Task: Elaboração de Minutas de Peças Processuais

### Metadata
- **executor:** analista-processual (com apoio de gestor-biblioteca para modelos)
- **elicit:** true
- **mode:** interativo + geração
- **output:** minuta salva em {demanda_ativa}\06_Minutas\

### Objetivo
Elaborar minutas de peças processuais com base nos documentos da demanda ativa,
precedentes e modelos da Biblioteca de Conhecimento, adaptadas ao caso concreto.

### Importante
- A minuta é um **rascunho** — responsabilidade final é do advogado subscritor
- O squad gera a estrutura técnica e argumentos jurídicos, mas o advogado deve revisar, adaptar e assinar
- Após elaboração, uma versão genérica é salva na Biblioteca de Conhecimento

---

## Tipos de Minutas Suportadas

### 1. CONTESTAÇÃO
**Acionar:** `*contestacao`

**Estrutura padrão (CPC/2015, art. 335-342):**
```
I.   QUALIFICAÇÃO DO RÉU
II.  PRELIMINARES (se cabíveis)
     2.1 Incompetência (se aplicável)
     2.2 Ilegitimidade de parte (se aplicável)
     2.3 Inépcia da petição inicial (se aplicável)
     2.4 Outras preliminares
III. NO MÉRITO
     3.1 Impugnação dos fatos
     3.2 Fundamentos jurídicos do réu
     3.3 Jurisprudência favorável
IV.  RECONVENÇÃO (se cabível — art. 343)
V.   DOS PEDIDOS
     - Acolhimento das preliminares (se houver)
     - Improcedência dos pedidos do autor
     - Condenação do autor em custas e honorários (art. 85, CPC)
VI.  REQUERIMENTOS
     - Produção de provas
     - Juntada de documentos
     - Outros
VII. VALOR DA CAUSA (reconvencional, se for o caso)
```

**Elicitação para contestação:**
```
Para elaborar a contestação, responda:

1. O réu tem preliminares a arguir? (incompetência, ilegitimidade, etc.)
   > [usuário responde]

2. Quais são os principais fatos impugnados?
   > [usuário responde ou "extrair do processo"]

3. Qual a tese jurídica principal do réu?
   > [usuário responde]

4. Há reconvenção a apresentar?
   > [s/n]

5. Quais provas serão requeridas?
   > [usuário responde]
```

---

### 2. APELAÇÃO
**Acionar:** `*recurso apelacao`

**Estrutura padrão (CPC/2015, art. 1.009-1.014):**
```
EXMO(A). SR(A). DESEMBARGADOR(A) RELATOR(A)...

I.   TEMPESTIVIDADE
II.  CABIMENTO E LEGITIMIDADE
III. PREPARO (comprovante em anexo)
IV.  DOS FATOS E DA DECISÃO RECORRIDA
     (resumo dos fatos e da sentença)
V.   RAZÕES DE REFORMA
     5.1 [Primeiro fundamento]
     5.2 [Segundo fundamento]
     5.3 Violação ao art. {X}, CPC/2015 (se cabível)
VI.  DA JURISPRUDÊNCIA FAVORÁVEL
VII. DO PEDIDO
     - Reforma total/parcial da sentença
     - Condenação em custas ao recorrido
```

---

### 3. EMBARGOS DE DECLARAÇÃO
**Acionar:** `*recurso embargos`

**Estrutura (CPC/2015, art. 1.022-1.026):**
```
I.   TEMPESTIVIDADE (5 dias úteis, art. 1.023)
II.  DO VÍCIO APONTADO
     - Omissão: "A decisão silenciou sobre [pedido/questão]..."
     - Contradição: "A decisão afirma X no parágrafo Y, mas Z no parágrafo W..."
     - Obscuridade: "Não está claro se a decisão..."
     - Erro material: "A decisão indica [X], porém o correto é [Y]..."
III. DO PEDIDO
     - Sanação do vício apontado
     - Efeito infringente (se cabível e justificado)
```

---

### 4. AGRAVO DE INSTRUMENTO
**Acionar:** `*recurso agravo`

**Estrutura (CPC/2015, art. 1.015-1.020):**
```
I.   CABIMENTO (art. 1.015 — verificar rol taxativo)
II.  TEMPESTIVIDADE (15 dias úteis)
III. DA DECISÃO AGRAVADA
IV.  DA URGÊNCIA (se requerer efeito suspensivo)
V.   RAZÕES DE REFORMA
VI.  DO PEDIDO
     - Concessão de efeito suspensivo (se urgente)
     - Reforma da decisão agravada
```

---

### 5. MANIFESTAÇÃO / PETIÇÃO SIMPLES
**Acionar:** `*manifestacao`

**Usos comuns:**
- Resposta a intimação
- Juntada de documentos
- Requerimento de prazo
- Indicação de provas
- Impugnação de laudo pericial

**Estrutura:**
```
[ENDEREÇAMENTO]

[PARTE], nos autos do processo em epígrafe, vem respeitosamente
perante Vossa Excelência, por seu advogado infra-assinado,
[OBJETO DA PETIÇÃO]:

[DESENVOLVIMENTO]

Nestes termos, pede deferimento.
[LOCAL], [DATA].
[ADVOGADO/OAB]
```

---

### 6. PETIÇÃO INICIAL
**Acionar:** `*peticao-inicial`

**Estrutura (CPC/2015, art. 319-320):**
```
I.   ENDEREÇAMENTO
II.  QUALIFICAÇÃO DAS PARTES (art. 319, II)
III. FATOS E FUNDAMENTOS JURÍDICOS (art. 319, III)
     3.1 Dos fatos
     3.2 Do direito aplicável
     3.3 Da jurisprudência favorável
IV.  DOS PEDIDOS (art. 319, IV)
     - Principal
     - Subsidiários/cumulados
V.   VALOR DA CAUSA (art. 291-293)
VI.  DOS REQUERIMENTOS (art. 319, VI)
     - Produção de provas
     - Citação do réu
     - Tutela de urgência (se cabível — art. 300)
     - Gratuidade (se aplicável)
VII. DOCUMENTOS QUE INSTRUEM A INICIAL (art. 320)
```

---

## Fluxo de Elaboração

### Para qualquer minuta:

1. **Verificar biblioteca** — Buscar modelo existente em `14_Modelos_e_Minutas`
2. **Elicitar informações** — Perguntar o que não consta nos documentos do processo
3. **Carregar contexto** — Usar análise do processo como base
4. **Pesquisar jurisprudência** — Buscar em `12_Jurisprudencia` + fontes externas se necessário
5. **Elaborar minuta** — Seguir estrutura padrão + adaptar ao caso
6. **Apresentar ao usuário** — Com pontos que exigem atenção do advogado sinalizados
7. **Salvar na demanda** — `{demanda_ativa}\06_Minutas\{tipo}_v1_{data}.md`
8. **Salvar na biblioteca** — Versão genérica em `14_Modelos_e_Minutas\{subarea}\`

### Formato do arquivo gerado
```
Nome: {tipo_minuta}_v{N}_{YYYY-MM-DD}.md
Exemplo: contestacao_v1_2026-03-14.md
         apelacao_v2_2026-03-15.md

Salvo em:
  Demanda:   K:\Meu Drive\Processos_Judiciais_IA\{demanda}\06_Minutas\
  Biblioteca: K:\Meu Drive\Processos_Judiciais_IA\Biblioteca de Conhecimento\14_Modelos_e_Minutas\{subpasta}\
```

### Sinalização de Pontos para o Advogado

Na minuta elaborada, sinalizar com marcadores:
```
⚠️ REVISAR: [descrição do ponto que o advogado deve checar/adaptar]
📋 COMPLETAR: [informação que não constava nos documentos e deve ser inserida]
⚖️ ESTRATÉGIA: [ponto de decisão estratégica — múltiplas abordagens possíveis]
📄 DOCUMENTO: [documento que deve ser juntado em anexo]
```

### Condições de Veto
- NUNCA gerar minuta sem demanda ativa selecionada
- NUNCA apresentar minuta como peça final — sempre como rascunho para revisão do advogado
- SEMPRE verificar prazo antes de elaborar recurso — alertar se prazo < 3 dias úteis
- SEMPRE verificar o cabimento do recurso antes de elaborar (rol taxativo do art. 1.015 para agravo)
