# Setup — Analista Processual Squad

> v1.1.0 | Domínio: Direito Processual Civil Brasileiro

---

## Pré-requisitos

- Framework [AIOX](https://github.com/SynkraAI/aiox-core) instalado (`npx aios-core init`)
- Windows com Google Drive sincronizado (para uso com sistema de pastas)
- Ou: qualquer IDE/CLI suportada (Claude Code, Cursor, Codex CLI, Gemini CLI) sem Google Drive

---

## Instalação

### Via CLI do AIOX (recomendado)
```bash
@squad-chief
*download-squad analista-processual
```

### Manual
```bash
git clone https://github.com/SynkraAI/aiox-squads.git
cp -r aiox-squads/squads/analista-processual ./squads/analista-processual
```

---

## Configuração do Sistema de Pastas (Windows + Google Drive)

Crie a estrutura raiz no Google Drive:

```
K:\Meu Drive\Processos_Judiciais_IA\
├── Biblioteca de Conhecimento\
│   ├── 01_Direito_Civil\
│   ├── 02_Direito_Processual_Civil\
│   ├── 03_Direito_Trabalhista\
│   ├── 04_Direito_Tributario_e_Fiscal\
│   ├── 05_Direito_Administrativo\
│   ├── 06_Direito_Constitucional\
│   ├── 07_Direito_do_Consumidor\
│   ├── 08_Direito_Empresarial\
│   ├── 09_Direito_Imobiliario\
│   ├── 10_Direito_Previdenciario\
│   ├── 11_Direito_Penal\
│   ├── 12_Jurisprudencia\
│   ├── 13_Doutrina_e_Livros\
│   ├── 14_Modelos_e_Minutas\
│   └── 15_Pesquisas_e_Analises\
```

Para cada processo, crie uma pasta numerada:
```
K:\Meu Drive\Processos_Judiciais_IA\
└── 1. Nome da Demanda\
    ├── 01_Processo\        ← arquivo do processo (formato CNJ)
    ├── 02_Peticoes\
    ├── 03_Decisoes\
    ├── 04_Documentos_Probatorios\
    ├── 05_Intimacoes\
    ├── 06_Minutas\
    ├── 07_Cronograma_Prazos\
    ├── 08_Relatorios_Analise\
    ├── 09_Correspondencias\
    └── 10_Notas_Internas\
```

Convença de nome do arquivo de processo: `NNNNNNN-DD.AAAA.J.TT.OOOO.pdf`

---

## Uso sem Google Drive (Claude Code / Perplexity)

Cole os documentos diretamente no chat. Veja `analista-processual-perplexity.zip` para guia completo de uso no Perplexity.

---

## Ativação

```bash
@analista-processual
```

O squad lista automaticamente as 10 últimas demandas e solicita seleção antes de qualquer análise.

---

## Comandos Principais

```
*analisar-processo    → Análise completa
*mapear-prazos        → Tabela de prazos
*resumir-processo     → Resumo executivo
*analisar-sentenca    → Análise de sentença
*contestacao          → Minuta de contestação
*recurso apelacao     → Minuta de apelação
*pesquisar-biblioteca → Buscar na biblioteca jurídica
*help                 → Todos os comandos
```

---

## Personalização

Edite `data/paths-config.yaml` para alterar o caminho raiz se sua letra de drive for diferente de `K:` ou se usar Linux/Mac.

---

## Limitações

- Não acessa PJe, e-SAJ ou PROJUDI diretamente
- Minutas são rascunhos — revisão do advogado é obrigatória
- Feriados locais não calculados automaticamente — informar ao agente
- Caminho padrão: `K:\Meu Drive\Processos_Judiciais_IA\` (Windows)

---

## Contribuindo

Consulte [CONTRIBUTING](../../README.md#contribuindo) no README principal do repositório.

---

*Analista Processual Squad v1.1.0 — AIOX Squads Community | MIT License*
