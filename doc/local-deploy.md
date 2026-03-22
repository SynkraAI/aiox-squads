# Local Deploy (dl) — Ambiente de Desenvolvimento Local

> Repositório: [local-deploy/dl](https://github.com/local-deploy/dl)
> Documentação oficial: [local-deploy.github.io](https://local-deploy.github.io/)

## O que é o dl?

O `dl` é uma CLI que simplifica o deploy local de projetos usando Docker Compose. Ele abstrai a complexidade de configurar serviços (PHP, MySQL, Redis, Nginx, Traefik) para desenvolvimento local, permitindo replicar o ambiente de produção em um único comando.

**Funciona como**: wrapper sobre `docker-compose` com suporte a múltiplos projetos simultâneos via Traefik como reverse proxy.

## Pré-requisitos

| Dependência | Versão mínima | Verificação |
|-------------|---------------|-------------|
| Docker | v22+ | `docker --version` |
| Docker Compose v2 (plugin) | qualquer | `docker compose version` |

## Instalação Rápida

```bash
# Usando o script deste repositório
bash setup-local-deploy.sh
```

### Instalação manual (Linux amd64)

```bash
DL_VERSION="1.2.0"
curl -fL "https://github.com/local-deploy/dl/releases/download/${DL_VERSION}/dl-${DL_VERSION}-linux-amd64.tar.gz" \
  -o /tmp/dl.tar.gz
tar -xzf /tmp/dl.tar.gz -C /tmp
sudo install -m 755 /tmp/dl /usr/local/bin/dl
dl version
```

**Resultado da instalação neste ambiente:**
```
✓ Docker 29.2
✓ Docker Compose v2 (plugin): 5.0.2
✓ dl version: DL v1.2.0 — instalado em /usr/local/bin/dl
```

## Workflow de uso

```
dl service up       # 1. Sobe serviços globais (Traefik, Portainer, MailHog)
dl env              # 2. Gera arquivo .env com configurações do projeto
# edite .env conforme necessário
dl deploy           # 3. (opcional) Baixa DB e arquivos da produção
dl up               # 4. Sobe o projeto
```

### Comandos principais

```bash
dl service up       # Inicia serviços base (Traefik, DNS, mail)
dl service down     # Para serviços base
dl up               # Sobe o projeto atual
dl down             # Para o projeto atual
dl env              # Gera .env do projeto
dl deploy           # Sincroniza dados de produção (DB, arquivos)
dl bash             # Acessa o container PHP
dl exec <cmd>       # Executa comando no container PHP
dl ps               # Lista containers do projeto
dl status           # Exibe status do dl e serviços
dl cert install     # Instala CA para HTTPS local
dl self-update      # Atualiza o dl para a versão mais recente
```

## Configurar HTTPS local

Para sites acessíveis via `*.localhost` e `*.nip.io` com HTTPS:

```bash
dl service up       # serviços precisam estar rodando
dl cert install     # instala certificado CA no sistema
```

## Stacks suportadas

| Serviço | Versões |
|---------|---------|
| PHP + Apache | 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4 |
| PHP-FPM + Nginx | 7.3–8.4 |
| MySQL | 5.7, 8.0 |
| MariaDB | 10.x |
| PostgreSQL | 12–16 |
| Redis | 6, 7 |
| Memcached | 1.6 |

## Integração com AIOX

O `dl` é útil para desenvolvedores usando o AIOX que precisam de um ambiente local completo para testar squads que interagem com serviços web (PHP, banco de dados, APIs).

### Uso com o squad de desenvolvimento

```
@squad-chief
*setup-local-env
```

O squad pode usar o `dl` para provisionar o ambiente de desenvolvimento automaticamente antes de executar tarefas que requerem infraestrutura local.

## Referências

- [Repositório GitHub](https://github.com/local-deploy/dl)
- [Documentação oficial](https://local-deploy.github.io/)
- [Releases](https://github.com/local-deploy/dl/releases)
- [Script de setup](../setup-local-deploy.sh)
