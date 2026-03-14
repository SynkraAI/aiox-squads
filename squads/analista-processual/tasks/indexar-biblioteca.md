# indexar-biblioteca

## Task: Indexação e Gestão da Biblioteca de Conhecimento

### Metadata
- **executor:** gestor-biblioteca
- **elicit:** true
- **mode:** batch ou interativo
- **output:** _indice.yaml atualizado + relatório de indexação

### Objetivo
Indexar documentos presentes na Biblioteca de Conhecimento (adicionados pelo usuário ou gerados pelos agentes),
tornando-os pesquisáveis e reutilizáveis em demandas futuras.

### Modos de Operação

#### Modo A — Indexação Completa (re-scan de toda a biblioteca)
Acionado por: `*indexar-biblioteca`

```
Escaneando: K:\Meu Drive\Processos_Judiciais_IA\Biblioteca de Conhecimento\

Progresso:
  ✅ 01_Direito_Civil\           — {n} documentos
  ✅ 02_Direito_Processual_Civil\ — {n} documentos
  ...
  ✅ 15_Pesquisas_e_Analises\    — {n} documentos

Total: {N} documentos indexados
Novos (não indexados antes): {n}
Atualizados: {n}
Sem alteração: {n}

Índice salvo em: K:\Meu Drive\Processos_Judiciais_IA\Biblioteca de Conhecimento\_indice.yaml
```

#### Modo B — Indexar Novo Documento (pós-análise)
Acionado automaticamente pelo squad após gerar conteúdo.

Passos:
1. Receber conteúdo gerado (análise, minuta, pesquisa)
2. Identificar área jurídica principal
3. Generalizar conteúdo (remover dados das partes)
4. Definir nome de arquivo genérico
5. Confirmar pasta de destino com usuário
6. Salvar arquivo versionado (_v1, _v2...)
7. Adicionar ao índice

```
SALVAR NA BIBLIOTECA DE CONHECIMENTO

Conteúdo gerado: {tipo} — {descrição breve}
Área identificada: {área}
Subárea: {subárea}

Proposta de salvamento:
  Arquivo: {nome_generico_v1}.md
  Pasta: K:\Meu Drive\Processos_Judiciais_IA\Biblioteca de Conhecimento\{area}\{subarea}\

Generalização aplicada:
  ✅ Dados das partes removidos
  ✅ Número do processo removido
  ✅ Datas específicas generalizadas
  ✅ Conteúdo jurídico preservado

Palavras-chave: [{lista}]
Resumo: {2-3 linhas}

Salvar? [s/n/editar-nome]
```

#### Modo C — Pesquisa na Biblioteca
Acionado por: `*pesquisar-biblioteca {tema}`

Algoritmo de busca (em ordem de prioridade):
1. Busca exata no título dos documentos
2. Busca nas palavras-chave indexadas
3. Busca no resumo dos documentos
4. Busca por área + subárea relacionada ao tema

```
PESQUISA: "{tema}"

Encontrado em {N} documentos:

ALTA RELEVÂNCIA (palavras-chave = tema):
  1. {nome} — {area} — {path}
     "{resumo}"

MÉDIA RELEVÂNCIA (área relacionada):
  2. {nome} — {area} — {path}
     "{resumo}"

Deseja abrir algum documento? [número]
Deseja salvar esta pesquisa? [s/n]
```

### Protocolo Completo de Generalização

Ao salvar qualquer documento gerado em análise de processo específico:

```
ANTES (específico):
  "João Silva (CPF 123.456.789-00) move ação contra Empresa X LTDA (CNPJ 00.000.000/0001-00)
   no processo 1234567-89.2024.8.26.0100 na 3ª Vara Cível de São Paulo..."

DEPOIS (genérico — para biblioteca):
  "[PARTE AUTORA] move ação contra [PARTE RÉ] alegando [CAUSA DE PEDIR].
   O pedido de [TIPO DE PEDIDO] fundamenta-se nos seguintes argumentos jurídicos:..."
```

**Regras de substituição:**
| Dado específico | Placeholder genérico |
|----------------|---------------------|
| Nome da parte | [PARTE AUTORA] / [PARTE RÉ] |
| CPF/CNPJ | [CPF/CNPJ DA PARTE] |
| Número do processo | [NUP] |
| Vara/Tribunal específico | [VARA/TRIBUNAL] |
| Valor específico | [VALOR DA CAUSA] |
| Datas específicas | [DATA DO ATO] |
| Nomes de testemunhas/peritos | [NOME DO PERITO/TESTEMUNHA] |

**O que PRESERVAR (não generalizar):**
- Citações legais (artigos, leis, decretos)
- Jurisprudências e ementas
- Argumentos jurídicos
- Estrutura da peça
- Cálculos e metodologias (sem os valores específicos)

### Estrutura do Índice (_indice.yaml)

```yaml
# _indice.yaml — Biblioteca de Conhecimento
# Atualizado automaticamente pelo gestor-biblioteca
# Última atualização: {timestamp}

versao: "1.0"
total_documentos: {N}
ultima_indexacao: "YYYY-MM-DD"

documentos:
  - id: "001"
    nome: "modelo_contestacao_responsabilidade_civil_v1.md"
    path: "K:\\Meu Drive\\...\\14_Modelos_e_Minutas\\02_Contestacoes\\"
    area: "Direito Civil"
    subarea: "Responsabilidade Civil"
    tipo: "modelo"
    palavras_chave: ["contestação", "responsabilidade civil", "dano moral", "nexo causal"]
    data_inclusao: "2026-03-14"
    incluido_por: "analista-processual"
    versao: "v1"
    contexto_original: "Demanda: 1. Ação de Indenização (generalizado)"
    resumo: "Modelo de contestação para ações de responsabilidade civil, com estrutura de preliminares, mérito e pedido de improcedência."

  - id: "002"
    ...
```

### Condições de Veto
- NUNCA salvar na biblioteca sem generalizar primeiro
- NUNCA sobrescrever versão anterior — sempre incrementar versão
- SE pasta de destino não existir: criar automaticamente e alertar
- SE documento já existe na biblioteca (conteúdo similar): sugerir atualização de versão existente
