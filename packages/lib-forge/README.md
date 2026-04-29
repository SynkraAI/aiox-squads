# Lib Forge 🔥

**Transforma PRDs e conversas em bibliotecas de scripts Python organizadas.**

## O que faz

Você fornece um PRD (documento de produto) e opcionalmente uma conversa que dá contexto ao PRD. O lib-forge analisa, projeta e gera uma biblioteca de scripts Python prontos para uso, organizados no repositório `victor-libs/`.

## Agentes

| Agente | Nome | Função |
|--------|------|--------|
| 🔥 Orchestrator | Forge | Coordena o pipeline inteiro |
| 🔍 Tier 1 | Ana | Analisa PRD e conversa, extrai oportunidades |
| 🏗️ Tier 2 | Arco | Projeta estrutura da lib e assinaturas |
| ✍️ Tier 3 | Script | Escreve o código Python |
| ✅ Tier 4 | Val | Valida qualidade antes da entrega |

## Pipeline

```
PRD + Conversa
      ↓
🔍 Ana analisa e extrai oportunidades
      ↓
🏗️ Arco projeta estrutura e funções
      ↓
👤 VOCÊ APROVA o design
      ↓
✍️ Script gera os arquivos .py
      ↓
✅ Val valida qualidade
      ↓
📦 Entrega em victor-libs/
```

## Como usar

### Ativar o squad
```
@lib-forge
```

### Pipeline completo
```
*forge docs/meu-prd.md conversations/reuniao.txt
```

### Só analisar (sem gerar código)
```
*analyze docs/meu-prd.md
```

### Ver status do pipeline
```
*status
```

## Estrutura de Saída

```
victor-libs/
  salao/           ← scripts do influence-labs
  vendas/          ← scripts do ecoadventure
  design/          ← scripts do studio-design
  comum/           ← utilitários compartilhados
```

## Regras Importantes

1. **Você sempre aprova o design antes de qualquer código ser gerado**
2. Scripts em Python com docstrings em português
3. Organizado por domínio de negócio
4. Um script faz uma coisa só
5. Pode copiar pastas do victor-libs para dentro de qualquer projeto

## Versão

`1.0.0` — Gerado via squad-creator do AIOX
