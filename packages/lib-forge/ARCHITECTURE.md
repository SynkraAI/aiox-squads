# Arquitetura — Lib Forge

## Visão Geral

```
ENTRADA                    PIPELINE                    SAÍDA
─────────                  ────────                    ─────
PRD (.md/.txt)  ──────→  🔍 Ana (análise)  ──────→  Mapa de oportunidades
Conversa        ──────→  🏗️ Arco (design)  ──────→  Design aprovado pelo usuário
                         ✍️ Script (gera)  ──────→  Arquivos .py
                         ✅ Val (valida)   ──────→  victor-libs/{dominio}/
```

## Fluxo de Dados

```
prd_content ──→ [analyzePRD] ──→ prd_structure (Memory)
                                        ↓
                              [extractOpportunities] ──→ opportunities_map (Memory)
                                        ↓
                              [designLibStructure] ──→ lib_design (Memory + File)
                                        ↓
                              [HUMAN GATE — aprovação]
                                        ↓
                              [generateScripts] ──→ .py files (File)
                                        ↓
                              [validateScripts] ──→ validation_report (Memory)
                                        ↓
                              [publishToVictorLibs] ──→ victor-libs/ (File)
```

## Princípios de Design

### Por que Python?
- Mais legível para não-programadores
- Excelente para processar textos e documentos (PRDs)
- Fácil de manter por qualquer dev
- Funciona com projetos Node via chamada de processo

### Por que organizar por domínio?
- `salao/` faz mais sentido que `integracoes/`
- Reflete a linguagem do negócio
- Facilita encontrar scripts por contexto

### Por que aprovação humana obrigatória?
- Design define o contrato — código implementa
- Evita retrabalho por mal-entendido
- Usuário não-programador pode revisar nomes e estrutura

## Integração com victor-libs

```
victor-libs/          ← repositório centralizado
  salao/              ← domínio do influence-labs-ia
    disponibilidade.py
    agendamento.py
    notificacoes.py
    README.md
  vendas/             ← domínio do ecoadventure-sdr-wpp
    qualificacao.py
    pacotes.py
    propostas.py
    README.md
  design/             ← domínio do studio-design
    validacao_componente.py
    publicacao.py
    README.md
  comum/              ← utilitários compartilhados
    formatacao.py
    validacoes.py
    README.md
```

Cada projeto importa da pasta do seu domínio ou copia para dentro do projeto quando necessário.

## Limites do Squad

**Faz:**
- Analisar PRDs e conversas de contexto
- Identificar oportunidades de automação
- Gerar scripts Python com qualidade verificada
- Organizar em victor-libs por domínio

**Não faz:**
- Executar os scripts gerados
- Fazer deploy de nenhum sistema
- Integrar com APIs diretamente (gera o script que faz isso)
- Criar testes automatizados completos (apenas testes básicos opcionais)
