# AIOX Squads — Guia de Deploy na Hostinger

> Stack: Ubuntu 22.04 · Docker · PostgreSQL 16 + pgvector · Redis · Nginx + HTTPS

---

## PARTE 1 — Painel Hostinger (5 min)

### 1.1 Reinstalar o sistema operacional

1. Acesse **hpanel.hostinger.com** e faça login
2. No menu lateral clique em **VPS** → selecione sua VPS
3. Clique na aba **OS & Panel** (ou "Sistema Operacional")
4. Em "Operating System" selecione → **Ubuntu 22.04 LTS** (sem painel)
5. Clique **Reinstall** e confirme digitando o hostname
6. Aguarde **3-5 minutos** enquanto o SO é instalado

> A reinstalação apaga tudo. Certifique-se de não ter dados importantes na VPS.

---

### 1.2 Adicionar sua chave SSH (recomendado)

> Se preferir usar senha, pule para 1.3.

1. No painel da VPS clique em **SSH Keys** → **Add SSH Key**
2. Abra o terminal do seu computador e rode:
   ```bash
   # No seu computador (Mac/Linux):
   cat ~/.ssh/id_ed25519.pub
   # ou: cat ~/.ssh/id_rsa.pub
   ```
   Se não tiver chave SSH, crie uma:
   ```bash
   ssh-keygen -t ed25519 -C "aiox-deploy"
   cat ~/.ssh/id_ed25519.pub
   ```
3. Copie o conteúdo e cole no campo do painel Hostinger → **Save**

---

### 1.3 Obter dados de acesso

1. No painel da VPS clique em **Details** (ou "Visão Geral")
2. Anote:
   - **IP da VPS**: ex. `185.200.100.50`
   - **Usuário root**: geralmente `root`
   - **Senha root**: exibida após reinstalação (ou enviada por e-mail)

---

### 1.4 Apontar o DNS do domínio

1. Acesse o painel onde seu domínio está registrado
   (Hostinger Domínios, Registro.br, GoDaddy, Cloudflare, etc.)
2. Encontre a zona DNS do domínio
3. Adicione (ou edite) um registro do tipo **A**:

   | Tipo | Nome | Valor | TTL |
   |------|------|-------|-----|
   | A | `aiox` | `185.200.100.50` (IP da VPS) | 300 |

   > Isso cria o subdomínio `aiox.seuescritorio.com.br`

4. Salve e aguarde a propagação do DNS (**5-30 minutos**)

   Verifique se propagou:
   ```bash
   # No seu computador:
   dig aiox.seuescritorio.com.br +short
   # Deve retornar o IP da VPS
   ```

---

## PARTE 2 — Conectar na VPS via SSH (2 min)

### Mac / Linux

Abra o Terminal e execute:

```bash
ssh root@185.200.100.50
# Substitua pelo IP real da sua VPS
```

Se pediu "Are you sure you want to continue connecting?" → digite `yes` e pressione Enter.

### Windows (PowerShell ou Prompt de Comando)

```powershell
ssh root@185.200.100.50
```

> Se não tiver o comando `ssh`, instale o **Windows Terminal** pela Microsoft Store,
> ou use o **PuTTY** (putty.org).

### Terminal Web da Hostinger (alternativa)

1. No painel da VPS clique em **Terminal** (ícone de terminal no canto superior direito)
2. Isso abre um terminal diretamente no navegador — sem precisar instalar nada

---

## PARTE 3 — Executar o Setup (10-15 min automáticos)

Já conectado na VPS como `root`, execute **um único comando**:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/SEU_ORG/aiox-squads/main/deploy/setup-vps.sh)
```

> Substitua `SEU_ORG` pelo seu usuário/organização do GitHub.

O script vai **perguntar interativamente**:

```
? Qual é o domínio que vai usar?
  Domínio: aiox.seuescritorio.com.br        ← digite aqui

? URL do repositório Git (HTTPS):
  Repositório: https://github.com/...        ← cole aqui

? Seu e-mail (para o certificado SSL):
  E-mail: seuemail@gmail.com                 ← digite aqui

? Sua ANTHROPIC_API_KEY (começa com sk-ant-):
  API Key:                                    ← cole aqui (não aparece por segurança)
```

Depois confirma e o setup roda sozinho pelas 8 fases:

```
━━━ FASE 1 de 8 — Atualizando o sistema ━━━
  ✓  Sistema atualizado

━━━ FASE 2 de 8 — Criando usuário 'aiox' ━━━
  ┌─────────────────────────────────────────────┐
  │  SALVE ESTAS CREDENCIAIS AGORA!             │
  │  Usuário: aiox                              │
  │  Senha:   xK9mP2...                        │  ← anote!
  └─────────────────────────────────────────────┘

━━━ FASE 3 de 8 — Configurando segurança ━━━
  ✓  SSH: login por senha desabilitado
  ✓  UFW ativo — portas: 22, 80, 443
  ✓  Fail2ban: ban de 1h após 5 tentativas

━━━ FASE 4 de 8 — Instalando Docker ━━━
  ✓  Docker instalado: Docker version 27.x.x

━━━ FASE 5 de 8 — Nginx + Certbot ━━━
  ✓  Certificado SSL obtido para aiox.seuescritorio.com.br

━━━ FASE 6 de 8 — Clonando repositório ━━━
  ✓  Repositório clonado em /opt/aiox

━━━ FASE 7 de 8 — Configurando ambiente ━━━
  ✓  .env criado com senhas geradas automaticamente

━━━ FASE 8 de 8 — Iniciando serviços ━━━
  ✓  Serviços saudáveis após 20s
  ✓  Auto-start configurado (aiox.service)

  ╔══════════════════════════════╗
  ║  ✅ Instalação concluída!   ║
  ║  URL: https://aiox.seu...   ║
  ╚══════════════════════════════╝
```

---

## PARTE 4 — Verificar que está funcionando

Após o setup, acesse no navegador:

```
https://aiox.seuescritorio.com.br
```

Deve aparecer a interface do AIOX Squads com cadeado verde (HTTPS).

### Verificar os serviços na VPS

```bash
# Ver status de todos os containers
docker compose -f /opt/aiox/deploy/docker-compose.prod.yml ps

# Ver logs do chatbot em tempo real
docker compose -f /opt/aiox/deploy/docker-compose.prod.yml logs -f chatbot

# Testar o banco de dados
docker exec -it aiox-postgres psql -U aiox -d aiox -c "\dt"

# Testar o Redis
docker exec -it aiox-redis redis-cli -a $REDIS_PASSWORD ping
```

---

## PARTE 5 — Atualizar a aplicação (futuras versões)

Sempre que fizer uma nova versão, rode na VPS:

```bash
bash /opt/aiox/deploy/deploy.sh
```

O script faz automaticamente:
1. `git pull` — baixa o código novo
2. `docker compose build` — reconstrói a imagem
3. Reinicia apenas o chatbot (banco e Redis continuam no ar)
4. Verifica se o serviço está respondendo

---

## Referência rápida — Comandos do dia a dia

```bash
# ── Ver status ────────────────────────────────────────────────
systemctl status aiox

# ── Logs em tempo real ────────────────────────────────────────
docker compose -f /opt/aiox/deploy/docker-compose.prod.yml logs -f

# ── Reiniciar tudo ────────────────────────────────────────────
systemctl restart aiox

# ── Reiniciar só o chatbot (sem derrubar banco/Redis) ─────────
docker compose -f /opt/aiox/deploy/docker-compose.prod.yml restart chatbot

# ── Acessar o banco de dados ──────────────────────────────────
docker exec -it aiox-postgres psql -U aiox -d aiox

# ── Ver uso de recursos ───────────────────────────────────────
docker stats

# ── Renovar certificado SSL (automático, mas pode forçar) ─────
certbot renew --dry-run

# ── Atualizar aplicação ───────────────────────────────────────
bash /opt/aiox/deploy/deploy.sh
```

---

## Solução de problemas

### "502 Bad Gateway" no nginx
O chatbot ainda está iniciando, ou travou. Verifique:
```bash
docker compose -f /opt/aiox/deploy/docker-compose.prod.yml logs --tail=50 chatbot
```

### Certbot falhou (SSL não ativado)
O DNS ainda não propagou. Aguarde e rode:
```bash
certbot --nginx -d aiox.seuescritorio.com.br
```

### Container não sobe ("unhealthy")
Veja os logs do serviço específico:
```bash
docker compose -f /opt/aiox/deploy/docker-compose.prod.yml logs postgres
docker compose -f /opt/aiox/deploy/docker-compose.prod.yml logs redis
```

### Disco cheio
```bash
# Ver uso do disco
df -h
# Limpar imagens Docker não usadas
docker system prune -af
```
