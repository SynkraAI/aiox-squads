# Tech Stack — lib-forge

## Runtime

| Componente | Versão Mínima | Uso |
|---|---|---|
| Python | >=3.10 | Geração e execução dos scripts da biblioteca |
| Node.js | >=18.0.0 | Runtime do AIOX e scripts de orquestração |

## Python — Bibliotecas de Suporte

Estas bibliotecas podem ser geradas nos scripts dependendo do domínio:

| Biblioteca | Uso típico |
|---|---|
| `requests` | Integrações HTTP com APIs externas |
| `httpx` | HTTP assíncrono |
| `pydantic` | Validação de dados e type hints |
| `python-dotenv` | Leitura de variáveis de ambiente |
| `PyYAML` | Leitura de arquivos YAML de configuração |

> O @lib-architect decide quais dependências incluir com base nas oportunidades mapeadas.
> Nunca adicionar dependência não aprovada no design.

## Convenções de Código

- **Linguagem dos identificadores:** português (nomes de funções, variáveis, parâmetros)
- **Linguagem dos comentários:** português
- **Type hints:** obrigatório em todos os parâmetros e retornos
- **Docstrings:** obrigatório em todas as funções, formato Google Style em português
- **Estilo:** PEP 8 + snake_case
- **Encoding:** UTF-8

## Estrutura de Saída

Os scripts gerados são publicados em:

```
../victor-libs/
└── {dominio}/
    ├── {modulo}.py
    └── README.md
```

## Compatibilidade

Scripts gerados devem funcionar em:
- macOS 13+
- Ubuntu 22.04+
- Python 3.10, 3.11, 3.12

---

*Referência para @lib-architect e @script-writer ao tomar decisões técnicas*
