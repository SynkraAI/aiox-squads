# ⚖️ Analista Processual Squad

> Análise estruturada de processos judiciais brasileiros — extração de dados, mapeamento de prazos e identificação de riscos com base no CPC/2015.

**Versão:** 1.1.0 | **Domínio:** Direito Processual Civil | **Status:** 🟢 OPERATIONAL | **Score:** 9.2/10

---

## O que este Squad faz

O **Analista Processual** é um sistema completo para gestão e análise de processos judiciais brasileiros, com:

- **Pastas fixas** organizadas em `K:\Meu Drive\Processos_Judiciais_IA`
- **Análise processual** completa com base no CPC/2015
- **Elaboração de minutas** de peças processuais
- **Biblioteca de Conhecimento** jurídico indexada e reutilizável

**Base intelectual:** Humberto Theodoro Júnior, Ada Pellegrini Grinover, Cássio Scarpinella Bueno e o CPC/2015.

---

## Sistema de Pastas

```
K:\Meu Drive\Processos_Judiciais_IA\
├── 1. Execução Compulsória Extrajudicial\
│   ├── 01_Processo\          ← Processo principal (formato CNJ = identificação)
│   ├── 02_Peticoes\
│   ├── 03_Decisoes\
│   ├── 04_Documentos_Probatorios\
│   ├── 05_Intimacoes\
│   ├── 06_Minutas\           ← Minutas geradas pelo squad
│   ├── 07_Cronograma_Prazos\
│   ├── 08_Relatorios_Analise\
│   ├── 09_Correspondencias\
│   ├── 10_Notas_Internas\
│   └── 1.1 Ação de Imissão na Posse\  ← Subpasta correlata
│       └── (mesma estrutura)
├── 2. Ação de Cobrança XYZ\
│   └── ...
└── Biblioteca de Conhecimento\
    ├── 01_Direito_Civil\
    ├── 02_Direito_Processual_Civil\
    ├── ...
    └── 15_Pesquisas_e_Analises\
```

**Ao iniciar:** O squad lista automaticamente as 10 últimas demandas e pergunta em qual trabalhar.

---

## Quando usar

| Situação | Comando |
|----------|---------|
| Iniciar sessão / trocar demanda | `*selecionar-demanda` |
| Novo processo chegou na carteira | `*analisar-processo` |
| Advogado precisa de resumo rápido | `*resumir-processo` |
| Verificar todos os prazos correntes | `*mapear-prazos` |
| Recebeu uma sentença para analisar | `*analisar-sentenca` |
| Identificar riscos do processo | `*riscos` |
| Elaborar contestação | `*contestacao` |
| Elaborar recurso | `*recurso apelacao` |
| Buscar jurisprudência e doutrina | `*pesquisar-biblioteca {tema}` |

---

## Agentes

```
Tier 0 — Orquestração
  └── analista-processual (Chief)
      Análise completa, minutas, coordenação

Tier 1 — Especialistas
  ├── navegador-arquivos       ← Seleção de demanda e gestão de pastas (automático)
  ├── extrator-documentos      ← Extração estruturada de peças processuais
  ├── calculador-prazos        ← Cálculo de prazos (CPC/2015 + legislação especial)
  ├── mapeador-riscos          ← Riscos, vícios, nulidades e pressupostos processuais
  └── gestor-biblioteca        ← Indexação e pesquisa na Biblioteca de Conhecimento
```

---

## Quickstart

```bash
# Ativar o agente principal
@analista-processual
# → O squad lista as últimas demandas e pede seleção automáticamente

# Análise completa
*analisar-processo

# Mapear prazos
*mapear-prazos

# Elaborar contestação
*contestacao

# Pesquisar na biblioteca
*pesquisar-biblioteca responsabilidade civil nexo causal
```

---

## Comandos Disponíveis

### Navegação
| Comando | O que faz |
|---------|-----------|
| `*selecionar-demanda` | Selecionar/trocar a demanda ativa |
| `*listar-demandas [n]` | Listar as N últimas demandas (padrão: 10) |
| `*criar-demanda` | Criar nova pasta com estrutura padrão |
| `*demanda-ativa` | Ver demanda e caminho ativos na sessão |

### Análise Processual
| Comando | O que faz |
|---------|-----------|
| `*analisar-processo` | Análise completa: partes, prazos, cronologia, riscos |
| `*resumir-processo` | Resumo executivo de 1 página |
| `*mapear-prazos` | Tabela de prazos com datas-limite calculadas |
| `*cronologia` | Linha do tempo de todos os atos |
| `*riscos` | Mapeamento de riscos e vícios processuais |
| `*analisar-sentenca` | Análise estruturada de sentença |
| `*analisar-peticao` | Análise de petição inicial ou contestação |

### Minutas
| Comando | O que faz |
|---------|-----------|
| `*contestacao` | Elaborar minuta de contestação |
| `*recurso {tipo}` | Elaborar recurso (apelação, agravo, embargos) |
| `*manifestacao` | Elaborar manifestação ou petição simples |
| `*peticao-inicial` | Elaborar minuta de petição inicial |

### Biblioteca de Conhecimento
| Comando | O que faz |
|---------|-----------|
| `*pesquisar-biblioteca {tema}` | Buscar documentos por tema |
| `*pesquisar-jurisprudencia {tema} {tribunal}` | Buscar precedentes indexados |
| `*salvar-conhecimento` | Salvar conteúdo gerado (versão genérica) |
| `*indexar-biblioteca` | Reindexar documentos da biblioteca |

---

## Base Normativa

| Norma | Aplicação |
|-------|-----------|
| **CPC/2015** (Lei 13.105/2015) | Referência primária para prazos e procedimentos |
| **CF/1988** | Garantias processuais fundamentais |
| **CLT** | Processos trabalhistas |
| **CDC** — Lei 8.078/1990 | Processos consumeristas |
| **Lei 6.830/1980** | Execução Fiscal |
| **Lei 9.099/1995** | Juizados Especiais |

---

## Regra de Contagem de Prazos

A partir do CPC/2015 (vigente desde 18/03/2016), **todos os prazos processuais são em dias úteis** (art. 219), salvo disposição expressa em contrário.

```
Intimação em:       {Dia X}
Início do prazo:    {Dia X + 1 dia útil}
Prazo de:           {N dias úteis}
Vencimento:         {data calculada}

Se vencer em dia não útil → prorroga para o próximo dia útil (art. 224, §1º)
```

---

## Sistema de Alertas

| Nível | Símbolo | Descrição |
|-------|---------|-----------|
| CRÍTICO | 🔴 | Prescrição, decadência, nulidade absoluta, prazo fatal iminente |
| ATENÇÃO | 🟡 | Vícios sanáveis, competência questionável, documentação incompleta |
| OBSERVAÇÃO | 🟢 | Informações complementares e boas práticas |

---

## Biblioteca de Conhecimento

15 áreas jurídicas organizadas em `K:\Meu Drive\Processos_Judiciais_IA\Biblioteca de Conhecimento\`:

| # | Área |
|---|------|
| 01 | Direito Civil |
| 02 | Direito Processual Civil |
| 03 | Direito Trabalhista |
| 04 | Direito Tributário e Fiscal |
| 05 | Direito Administrativo |
| 06 | Direito Constitucional |
| 07 | Direito do Consumidor |
| 08 | Direito Empresarial |
| 09 | Direito Imobiliário |
| 10 | Direito Previdenciário |
| 11 | Direito Penal |
| 12 | Jurisprudência (STF, STJ, TST, TRFs, TJs, TRTs) |
| 13 | Doutrina e Livros (PDF) |
| 14 | Modelos e Minutas |
| 15 | Pesquisas e Análises |

O squad **indexa, pesquisa e salva** conhecimento na biblioteca. Cada análise e minuta é generalizada e armazenada para reutilização em demandas futuras similares.

---

## Limitações Importantes

- **Não acessa** sistemas judiciais (PJe, e-SAJ, PROJUDI) diretamente
- **Não emite** pareceres jurídicos — análise factual e processual apenas
- **Minutas são rascunhos** — revisão e assinatura do advogado são obrigatórias
- **Feriados locais** devem ser informados pelo usuário para cálculo preciso
- **Requer** que os arquivos estejam no caminho `K:\Meu Drive\Processos_Judiciais_IA`
- **Sempre confirmar** datas no sistema judicial antes de qualquer ato processual

---

## Exemplo de Uso

```
@analista-processual
*analisar-processo

[Sistema solicita número do processo e documentos]

Processo: 1234567-89.2024.8.26.0100
[Cola a petição inicial e a última decisão]

[Sistema gera relatório completo com partes, prazos, cronologia e riscos]
```

---

## Contribuindo

Para melhorar este squad:
1. Abra uma issue descrevendo a melhoria
2. Fork e implemente
3. Abra um PR referenciando a issue

---

*Licença MIT — AIOX Squads Community*
