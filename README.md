<p align="center">
  <img src="doc/assets/header.jpg" alt="AIOX Squad" width="720" />
</p>

<p align="center">
  <a href="#quickstart"><strong>Quickstart</strong></a> &middot;
  <a href="#catálogo-de-squads"><strong>Catálogo</strong></a> &middot;
  <a href="https://github.com/SynkraAI/aiox-squads"><strong>GitHub</strong></a> &middot;
  <a href="https://github.com/SynkraAI/aiox-squads/discussions"><strong>Discussões</strong></a>
</p>

<p align="center">
  <a href="https://github.com/SynkraAI/aiox-squads/blob/main/LICENSE"><img src="https://img.shields.io/badge/licença-MIT-blue" alt="MIT License" /></a>
  <a href="https://github.com/SynkraAI/aiox-squads/stargazers"><img src="https://img.shields.io/github/stars/SynkraAI/aiox-squads?style=flat" alt="Stars" /></a>
</p>

<p align="center">
  <a href="doc/README.en.md">🇺🇸 English version</a>
</p>

<br/>

## O que é AIOX Squads?

# O repositório da comunidade para squads AIOX

**Se um agente de IA é um _funcionário_, um Squad é um _departamento_ inteiro.**

Este é o repositório oficial da comunidade para compartilhar, descobrir e contribuir squads para o framework [AIOX](https://github.com/SynkraAI/aiox-core). Squads são pacotes self-contained de agentes IA especializados — com Voice DNA, heurísticas de decisão e quality gates — que qualquer usuário AIOX pode instalar, usar e compartilhar.

**Encontre squads. Compartilhe squads. Construa juntos.**

|        | Passo               | Exemplo                                                            |
| ------ | ------------------- | ------------------------------------------------------------------ |
| **01** | Navegue o catálogo  | _"Preciso de copywriting de elite."_                                |
| **02** | Instale             | `*download-squad copy` — um comando dentro do AIOX.                 |
| **03** | Ative o chief       | `@copy-chief` — o orquestrador roteia seu trabalho para o especialista certo. |
| **04** | Contribua de volta  | Criou um squad? Abra um PR e compartilhe com a comunidade.          |

<br/>

> **O AIOX (framework) vive em [aiox-core](https://github.com/SynkraAI/aiox-core).** Este repositório é onde a comunidade publica e descobre squads — como o npm é para pacotes Node.js.

<br/>

<div align="center">
<table>
  <tr>
    <td align="center"><strong>Funciona<br/>com</strong></td>
    <td align="center"><img src="https://cdn.simpleicons.org/anthropic/181818/FFFFFF" width="28" alt="Claude Code" /><br/><sub>Claude Code</sub></td>
    <td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="doc/assets/logos/openai-light.svg"><img src="doc/assets/logos/openai-dark.svg" width="28" alt="Codex CLI" /></picture><br/><sub>Codex CLI</sub></td>
    <td align="center"><img src="https://cdn.simpleicons.org/google/181818/FFFFFF" width="28" alt="Gemini CLI" /><br/><sub>Gemini CLI</sub></td>
    <td align="center"><img src="https://cdn.simpleicons.org/cursor/181818/FFFFFF" width="28" alt="Cursor" /><br/><sub>Cursor</sub></td>
  </tr>
</table>

<em>Qualquer IDE ou CLI suportada pelo <a href="https://github.com/SynkraAI/aiox-core">AIOX</a>.</em>

</div>

<br/>

## Este repositório é pra você se

- ✅ Você usa o **[AIOX](https://github.com/SynkraAI/aiox-core)** e quer **squads prontos** para instalar no seu projeto
- ✅ Você precisa de **conhecimento específico de domínio** — copywriting, segurança, dados, branding — não respostas genéricas
- ✅ Você quer agentes que **pensam como especialistas reais**, com frameworks clonados e heurísticas
- ✅ Você **criou um squad** e quer compartilhar com a comunidade
- ✅ Você quer **aprender** como squads são construídos e se inspirar nos exemplos existentes
- ✅ Você quer **compor múltiplos squads** — copy + brand + data — no mesmo projeto

<br/>

## O que é um Squad?

Um squad é um pacote self-contained de agentes IA que trabalham juntos em um domínio. Não são prompts soltos — são sistemas completos:

<table>
<tr>
<td align="center" width="33%">
<h3>🧬 Clonagem de Especialistas</h3>
Agentes carregam Voice DNA e Thinking DNA de especialistas reais. Não são prompts genéricos — são frameworks reais.
</td>
<td align="center" width="33%">
<h3>📦 Drop-in Ready</h3>
Instale com <code>*download-squad</code> ou copie a pasta. Cada squad é totalmente self-contained — agentes, tasks, templates, dados.
</td>
<td align="center" width="33%">
<h3>🏗️ Arquitetura de Tiers</h3>
Chief roteia → Masters executam → Specialists assistem → Support valida. Cadeia de comando clara.
</td>
</tr>
<tr>
<td align="center">
<h3>✅ Quality Gates</h3>
Todo squad é pontuado e validado. Sistema de qualidade em 4 tiers garante que os agentes realmente entregam.
</td>
<td align="center">
<h3>🔀 Composável</h3>
Misture squads livremente. Rode copy + brand + data no mesmo projeto. Eles sabem fazer handoff entre si.
</td>
<td align="center">
<h3>🎯 Determinístico</h3>
Heurísticas com regras SE/ENTÃO e condições de veto. Agentes seguem playbooks provados, não vibes.
</td>
</tr>
</table>

<br/>

## Quickstart

### Pré-requisito

Squads rodam sobre o framework [AIOX](https://github.com/SynkraAI/aiox-core). Se ainda não tem:

```bash
npx aios-core init meu-projeto
```

### Instalar um Squad deste repositório

```bash
# Opção 1: Via CLI do AIOX (recomendado)
@squad-chief
*download-squad copy

# Opção 2: Manual
git clone https://github.com/SynkraAI/aiox-squads.git
cp -r aiox-squads/squads/copy ./squads/copy
```

### Usar

```bash
# Ative o chief do squad
@copy-chief

# Veja os comandos disponíveis
*help

# Rode uma task
*create-sales-page
```

> **Compatível com:** Claude Code, Codex CLI, Gemini CLI, Cursor — qualquer IDE suportada pelo [AIOX](https://github.com/SynkraAI/aiox-core).

<br/>

## Catálogo de Squads

Squads publicados pela comunidade neste repositório.

| Squad | O que faz | Status |
|-------|-----------|--------|
| [**analista-processual**](squads/analista-processual/) | Análise de processos judiciais brasileiros: extração de dados, mapeamento de prazos (CPC/2015) e identificação de riscos processuais | 🟢 OPERATIONAL |

> Tem um squad pronto? [Abra um PR](#contribuindo) e compartilhe com a comunidade.

### Squad Creator: Free vs Pro

O AIOX já vem com o **Squad Creator Free** — 1 agente, 24 tasks, criação template-driven. Para quem precisa de mais, existe o **Squad Creator Pro**: mind cloning, model routing, 3 agentes especialistas e axioma assessment.

Veja o [comparativo completo](squads/squad-creator-pro/).

<br/>

## Como Squads Funcionam

### O Sistema de Tiers

Todo squad segue uma cadeia de comando clara:

```
  Tier 0 — Chief (Orquestrador)
  ├── Recebe a missão, classifica a intenção, roteia pro especialista certo.
  │
  ├── Tier 1 — Masters
  │   Especialistas primários. Executam as missões core do domínio.
  │
  ├── Tier 2 — Specialists
  │   Especialistas de nicho. Acionados pelo Tier 1 para sub-tarefas específicas.
  │
  └── Tier 3 — Support
      Utilidades compartilhadas. Quality gates, templates, analytics.
```

### Anatomia de um Agente (6 Camadas)

Todo agente é um arquivo `.md` estruturado com:

```yaml
agent:       # Identidade — nome, id, tier
persona:     # Função e estilo de comunicação
voice_dna:   # Vocabulário clonado, padrões de frase, anti-patterns
heuristics:  # Regras de decisão SE/ENTÃO com condições de veto
examples:    # Pares concretos de input/output (mín. 3)
handoffs:    # Quando parar e delegar para outro agente
```

### Níveis de Maturidade

Squads neste repositório passam por validação e ganham badges de maturidade:

| Nível | Critérios | Badge |
|-------|-----------|-------|
| **DRAFT** | Estrutura básica, score < 7.0 | 🔴 |
| **DEVELOPING** | Score ≥ 7.0, agentes funcionais, tasks executáveis | 🟡 |
| **OPERATIONAL** | Score ≥ 9.0, testado em produção, uso real comprovado | 🟢 |

<br/>

## Contribuindo

Este é um repositório da comunidade — **sua contribuição é o que faz ele crescer**.

### Publicar um Squad

1. Fork este repositório
2. Crie seu squad seguindo a [estrutura padrão AIOX](https://github.com/SynkraAI/aiox-core)
3. Rode `*validate-squad {nome}` e garanta score ≥ 7.0
4. Abra um PR com: descrição do domínio, score de validação e pelo menos 1 exemplo de uso real

### Melhorar um Squad Existente

1. Abra uma issue descrevendo a melhoria
2. Fork e implemente
3. Rode `*validate-squad` para garantir que não quebrou nada
4. Abra um PR referenciando a issue

### Criar um Squad do Zero

Use o squad-creator dentro do AIOX:

```
@squad-chief
*create-squad {domínio}
```

Workflow guiado de 6 fases: Detecção de Tipo → Elicitação de Domínio → Carregamento de Templates → Proposta de Arquitetura → Criação → Validação.

<br/>

## FAQ

**Isso aqui é o AIOX?**
Não. O framework AIOX vive em [aiox-core](https://github.com/SynkraAI/aiox-core). Este repositório é onde a comunidade compartilha squads — como o npm é para pacotes Node.js.

**Preciso do AIOX pra usar squads?**
Sim. Squads são pacotes que rodam sobre o framework [AIOX](https://github.com/SynkraAI/aiox-core). Instale com `npx aios-core init`.

**Preciso de todos os squads?**
Não. Cada squad é self-contained. Instale apenas o que precisa.

**Funciona só no Claude Code?**
Não. O AIOX suporta Claude Code, Codex CLI, Gemini CLI e Cursor. A compatibilidade varia por IDE — Claude Code tem suporte completo.

**Posso usar em projetos comerciais?**
Sim. Licença MIT.

**Como atualizo um squad?**
Rode `*download-squad {nome}` novamente ou substitua a pasta manualmente. O `CHANGELOG.md` de cada squad documenta breaking changes.

**Como contribuo com um squad?**
Fork, crie seu squad, valide com `*validate-squad`, abra um PR. Veja a seção [Contribuindo](#contribuindo).

**O que é Voice DNA?**
É como clonamos o estilo de comunicação de um especialista. Sentence starters, regras de vocabulário, anti-patterns — pra que agentes não só saibam *o que* dizer, mas *como* dizer do jeito que o especialista real diria.

<br/>

## Licença

MIT &copy; 2026 AIOX Squads

<br/>

---

<p align="center">
  <sub>Open source sob MIT. Repositório da comunidade para squads <a href="https://github.com/SynkraAI/aiox-core">AIOX</a>.</sub>
</p>
