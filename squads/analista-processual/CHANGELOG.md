# Changelog — Analista Processual Squad

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
