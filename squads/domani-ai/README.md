# domani-ai Squad

> Squad de inteligência comercial e criação para a Domani.AI

## Descrição

Squad especializado em inteligência comercial e criação de conteúdo para a Domani.AI.
Cobre propostas, orçamentos, copy, prompts de IA, resposta a clientes, manuais, design e expertise em plataforma.

## Agentes

Os agentes deste squad estão em `agents/`. Cada agente cobre uma área de especialização comercial ou criativa.

## Uso

```
@domani-ai/{agent-name}
```

## Estrutura

```
squads/domani-ai/
├── squad.yaml          # Manifest do squad
├── README.md           # Este arquivo
├── config/
│   ├── coding-standards.md  # Padrões de trabalho
│   ├── tech-stack.md        # Stack e ferramentas
│   └── source-tree.md       # Estrutura documentada
└── agents/             # Agentes do squad
```

## Próximos Passos

1. Criar agentes em `agents/` conforme as especialidades necessárias
2. Validar: `@squad-creator *validate domani-ai`
3. Quando pronto para compartilhar: `@squad-creator *publish domani-ai`
