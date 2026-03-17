# Changelog — Analista Processual Squad

## [1.2.0] — 2026-03-17

### Adicionado — Templates (9 arquivos)
- `templates/relatorio-analise-processual-tmpl.md` — Template de relatório completo (6 seções: Identificação, Partes, Objeto, Cronologia, Prazos, Riscos)
- `templates/relatorio-prazos-tmpl.md` — Template tabular de prazos com alertas de urgência (🔴🟡🟠🟢✅⬛)
- `templates/relatorio-riscos-tmpl.md` — Template de relatório de riscos com pressupostos processuais em 5 níveis
- `templates/resumo-executivo-tmpl.md` — Template de resumo executivo de 1 página
- `templates/analise-sentenca-tmpl.md` — Template de análise de sentença (relatório/fundamentação/dispositivo, Art. 489 CPC/2015)
- `templates/minuta-contestacao-tmpl.md` — Template de contestação (Arts. 335-342 CPC/2015)
- `templates/minuta-apelacao-tmpl.md` — Template de apelação (Arts. 1.009-1.014 CPC/2015)
- `templates/minuta-embargos-declaracao-tmpl.md` — Template de Embargos de Declaração, prazo 5 dias úteis (Arts. 1.022-1.026)
- `templates/minuta-agravo-instrumento-tmpl.md` — Template de Agravo de Instrumento com verificação do rol taxativo do Art. 1.015
- `templates/minuta-manifestacao-tmpl.md` — Template multi-modelo para manifestações (5 modelos: resposta, juntada, prazo, laudo, endereço)

### Adicionado — Tasks (4 arquivos)
- `tasks/cronologia.md` — Task `*cronologia`: extração de linha do tempo processual
- `tasks/riscos.md` — Task `*riscos`: mapeamento standalone de riscos e vícios em 5 níveis
- `tasks/analisar-peticao.md` — Task `*analisar-peticao`: análise estruturada de petição (checklist Art. 319 CPC/2015)
- `tasks/extrair-partes.md` — Task `*extrair-partes`: identificação de partes com validação CPF/CNPJ/OAB

### Adicionado — Workflows (3 arquivos)
- `workflows/wf-analisar-processo.yaml` — Orquestração multi-agente: analista + extrator + calculador-prazos + mapeador-riscos
- `workflows/wf-elaborar-minuta.yaml` — Workflow de minutas: pré-check prazo → busca-modelo → elicitação → elaboração → sinalização → salvamento
- `workflows/wf-indexar-biblioteca.yaml` — Indexação de biblioteca em 2 modos (completa + incremental com protocolo de generalização)

### Adicionado — Checklists / Quality Gates (3 arquivos)
- `checklists/checklist-minuta.md` — 4 seções, 18 itens para minutas
- `checklists/checklist-prazo.md` — 4 seções, 17 itens para cálculo de prazos
- `checklists/quality-gate.md` — 5 seções, 16 itens — gate final para todos os outputs

### Adicionado — Minds / Voice DNA de Juristas (21 arquivos, 3 especialistas)
- `minds/humberto_theodoro_junior/` — 7 arquivos: voice_dna.yaml, thinking_dna.yaml, framework-primary.md, signature-phrases.md, voice-identity.md, HTJ_PP_001.md (Pressupostos Primeiro), HTJ_NU_001.md (Pas de nullité sans grief)
- `minds/ada_pellegrini_grinover/` — 7 arquivos: voice_dna.yaml, thinking_dna.yaml, framework-primary.md (garantias CF/1988), signature-phrases.md, voice-identity.md, APG_CF_001.md (Constituição Antes), APG_CT_001.md (Contraditório Efetivo)
- `minds/cassio_scarpinella_bueno/` — 7 arquivos: voice_dna.yaml, thinking_dna.yaml, framework-primary.md (inovações CPC/2015), signature-phrases.md, voice-identity.md, CSB_PC_001.md (Praticidade CPC/2015), CSB_AR_001.md (Artigo + Regra)

### Adicionado — Data Files (4 arquivos)
- `data/prazos-cpc2015.yaml` — Tabela machine-readable de prazos processuais (CPC/2015 + legislação especial: Juizados, LEF, CDC)
- `data/feriados-nacionais.yaml` — Feriados nacionais 2026/2027 + férias forenses (Art. 220 CPC/2015)
- `data/tribunais.yaml` — Códigos CNJ de todos os tribunais: STJ, STF, 6 TRFs, 27 TJs, TST e TRTs principais
- `data/classes-cnj.yaml` — Classes processuais e assuntos (Tabelas Processuais Unificadas — Resolução CNJ 46/2007)

### Adicionado — Documentação
- `HEADLINE.md` — One-liner descritivo para exibição no AIOX marketplace
- `SETUP.md` — Guia de instalação com estrutura de pastas Windows, comandos CLI, limitações e personalização

### Adicionado — Exportação Perplexity
- `analista-processual-perplexity.zip` — Pacote exportado para uso no Perplexity (Habilidades), incluindo guia de adaptação de fluxo sem acesso ao sistema de arquivos

### Modificado
- `config.yaml` atualizado para v1.2.0 com referências a: workflows, templates, checklists, minds e data files
- `CHANGELOG.md` com documentação completa das mudanças v1.2.0

---

## [1.1.0] — 2026-03-14

### Adicionado
- `navegador-arquivos` (Tier 1) — Gestor de pastas fixas, seleção de demandas e navegação entre correlatas
- `gestor-biblioteca` (Tier 1) — Indexação, pesquisa e curadoria da Biblioteca de Conhecimento
- `data/paths-config.yaml` — Configuração completa de caminhos, estrutura de pastas e convenções de nomenclatura
- Task `selecionar-demanda` — Seleção interativa de demanda ativa ao iniciar sessão (automático)
- Task `indexar-biblioteca` — Indexação em lote e salvamento de conhecimento na biblioteca
- Task `elaborar-minuta` — Elaboração de minutas (contestação, apelação, embargos, agravo, manifestação, petição inicial)

### Sistema de Pastas Fixas
- Raiz: `K:\Meu Drive\Processos_Judiciais_IA\`
- Convenção de demandas: `{N}. {Nome da Demanda}`
- Convenção de correlatas: `{N}.{S} {Nome da Demanda Correlata}`
- 10 subpastas padrão por demanda (01_Processo a 10_Notas_Internas)
- Acesso cruzado entre demandas correlatas para contexto complementar

### Biblioteca de Conhecimento
- 15 áreas jurídicas organizadas com subpastas temáticas
- Indexação via `_indice.yaml` mantido pelo gestor-biblioteca
- Protocolo de generalização para reutilização de conteúdo
- Versionamento de documentos (v1, v2...)

### Modificado
- `analista-processual` (chief) atualizado para v1.1.0 com:
  - Seleção obrigatória de demanda ao iniciar sessão
  - Novos comandos de navegação, minutas e biblioteca
  - Integração com paths-config.yaml
- `config.yaml` atualizado para v1.1.0 com arquitetura completa

---

Todas as mudanças relevantes deste squad são documentadas aqui.

## [1.0.0] — 2026-03-14

### Adicionado
- `analista-processual` (Tier 0) — Agente principal, orquestrador de análise processual completa
- `extrator-documentos` (Tier 1) — Especialista em extração estruturada de peças processuais
- `calculador-prazos` (Tier 1) — Especialista em cálculo de prazos com base no CPC/2015
- `mapeador-riscos` (Tier 1) — Especialista em identificação de riscos e vícios processuais
- Task `analisar-processo` — Análise completa em 5 fases (identificação, extração, prazos, riscos, relatório)
- Task `resumir-processo` — Resumo executivo de 1 página para equipes jurídicas
- Task `mapear-prazos` — Mapeamento tabular de prazos com alertas de urgência
- Task `analisar-sentenca` — Análise estruturada de sentença (relatório/fundamentação/dispositivo)
- `config.yaml` com metadados completos, base normativa e casos de uso
- `README.md` com documentação completa do squad

### Base normativa
- CPC/2015 (Lei 13.105/2015) como referência primária
- Suporte a prazos da CLT, CDC, Lei 6.830/1980 e Lei 9.099/1995

### Maturidade inicial
- Score: 9.2/10
- Status: 🟢 OPERATIONAL
