# selecionar-demanda

## Task: Seleção de Demanda Ativa para a Sessão

### Metadata
- **executor:** navegador-arquivos (acionado automaticamente pelo analista-processual ao iniciar)
- **elicit:** true
- **mode:** interactive
- **trigger:** automático ao iniciar qualquer sessão do squad
- **output:** demanda_ativa registrada no contexto da sessão

### Objetivo
Identificar em qual demanda/processo o squad deve focar, garantindo que todos os agentes
trabalhem com os arquivos corretos durante toda a sessão.

### Passos de Execução

#### Passo 1 — Listar Demandas Disponíveis

Ler o conteúdo de: `K:\Meu Drive\Processos_Judiciais_IA\`

Apresentar as **10 mais recentes** (por data de modificação):

```
## Selecione a Demanda

Base: K:\Meu Drive\Processos_Judiciais_IA\

| # | Demanda | Subpastas correlatas | Última modificação |
|---|---------|---------------------|-------------------|
| 1 | {nome_pasta} | {n} correlatas | {data} |
| 2 | {nome_pasta} | — | {data} |
...
| 10| {nome_pasta} | {n} correlatas | {data} |

Digite:
- [número] para selecionar
- "mais" para ver próximas 10
- "todas" para listar todas as demandas
- "nova" para criar nova demanda
- "biblioteca" para acessar a Biblioteca de Conhecimento
```

#### Passo 2 — Seleção e Confirmação

Após seleção do usuário:

```
✅ Demanda selecionada: {N}. {Nome da Demanda}
Caminho: K:\Meu Drive\Processos_Judiciais_IA\{pasta}

Subpastas correlatas encontradas:
  - {N}.1 {nome_subpasta}
  - {N}.2 {nome_subpasta}
  (Acessíveis como contexto complementar)

Arquivos na pasta principal:
  📄 {arquivo_processo_cnj}.pdf  ← Processo principal
  📁 02_Peticoes\ ({n} arquivos)
  📁 03_Decisoes\ ({n} arquivos)
  ...

Confirmar? [s/n] ou selecionar subpasta específica?
```

#### Passo 3 — Subpasta (se demanda correlata)

Se o usuário quiser focar em subpasta correlata:

```
Focando em: {N}.{S} {Nome da Subpasta}
Caminho ativo: K:\Meu Drive\Processos_Judiciais_IA\{pasta}\{subpasta}

Acesso complementar disponível:
  ✅ Pasta pai: {nome_pasta_pai}
  ✅ Outras subpastas: {lista}
  ✅ Biblioteca de Conhecimento

Confirmar como demanda ativa? [s/n]
```

#### Passo 4 — Registrar no Contexto

Após confirmação, registrar:
```yaml
sessao_ativa:
  demanda: "{N}. {Nome}"
  path: "K:\\Meu Drive\\Processos_Judiciais_IA\\{pasta}"
  subpasta_ativa: "{subpasta ou null}"
  path_ativo: "{path da subpasta ativa ou da pasta principal}"
  correlatas_acessiveis: ["{lista de paths de outras subpastas}"]
  arquivo_processo: "{nome_arquivo_cnj}.pdf ou null"
  iniciado_em: "{timestamp}"
```

Informar ao usuário:
```
🚀 Squad configurado.
Demanda ativa: {nome}
Caminho: {path_ativo}

Próximos passos sugeridos:
1. *analisar-processo — Análise completa do processo
2. *mapear-prazos — Verificar prazos vigentes
3. *resumir-processo — Gerar resumo executivo
4. *pesquisar-biblioteca {tema} — Buscar subsídios na biblioteca
```

### Criar Nova Demanda

Se usuário escolher "nova", executar wizard:

```
NOVA DEMANDA

1. Nome da demanda:
   > [usuário informa]
   Sugestão de formato: "{Tipo de Ação} — {Parte Contrária}"
   Exemplo: "Ação de Indenização — João Silva vs Empresa X"

2. É derivada/correlata de outra demanda?
   [lista as demandas existentes numeradas]
   > [usuário escolhe ou "não"]

3. Número a ser atribuído: {N} (próximo disponível)
   Pasta será criada como: "{N}. {Nome Informado}"
   Caminho: K:\Meu Drive\Processos_Judiciais_IA\{N}. {Nome}

   Se correlata:
   Subpasta: {N_pai}.{S}. {Nome}
   Dentro de: K:\Meu Drive\Processos_Judiciais_IA\{pasta_pai}

4. Confirmar criação? [s/n]

[Após confirmação]
✅ Estrutura criada:
K:\Meu Drive\Processos_Judiciais_IA\{N}. {Nome}\
├── 01_Processo\
├── 02_Peticoes\
├── 03_Decisoes\
├── 04_Documentos_Probatorios\
├── 05_Intimacoes\
├── 06_Minutas\
├── 07_Cronograma_Prazos\
├── 08_Relatorios_Analise\
├── 09_Correspondencias\
└── 10_Notas_Internas\

Próximo passo: Salve o arquivo do processo em 01_Processo\
com o nome no formato CNJ: NNNNNNN-DD.AAAA.J.TT.OOOO.pdf
```

### Condições de Veto
- NUNCA iniciar análise sem demanda ativa confirmada
- SE pasta vazia (sem arquivos em 01_Processo): alertar antes de prosseguir
- SE arquivo de processo sem formato CNJ: alertar e sugerir renomeação
