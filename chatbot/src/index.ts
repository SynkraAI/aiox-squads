/**
 * AIOX Squads — Chatbot CLI
 *
 * Ambiente de conversação com agentes do repositório aiox-squads.
 * Suporta: streaming, upload de arquivos (Files API), troca de agente,
 * histórico de sessão e múltiplos squads.
 *
 * Uso:
 *   npm run dev
 *
 * Variável necessária:
 *   ANTHROPIC_API_KEY=sk-ant-...
 */

import readline from "readline";
import Anthropic from "@anthropic-ai/sdk";
import { loadAllSquads, flatAgentList, Agent, Squad } from "./agents";
import { uploadFile, deleteFile, supportedExtensions, UploadedFile } from "./files";
import { ChatSession } from "./chat";

// ── Cores ANSI simples (sem dependência extra) ────────────────────────────────
const c = {
  reset: "\x1b[0m",
  bold: "\x1b[1m",
  dim: "\x1b[2m",
  cyan: "\x1b[36m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  magenta: "\x1b[35m",
  red: "\x1b[31m",
  white: "\x1b[37m",
  bgBlue: "\x1b[44m",
};

function header(text: string): string {
  return `\n${c.bold}${c.cyan}${text}${c.reset}`;
}
function success(text: string): string {
  return `${c.green}✓${c.reset} ${text}`;
}
function warn(text: string): string {
  return `${c.yellow}⚠${c.reset}  ${text}`;
}
function info(text: string): string {
  return `${c.blue}ℹ${c.reset}  ${text}`;
}
function prompt(text: string): string {
  return `${c.bold}${c.magenta}${text}${c.reset}`;
}
function agentTag(squad: string, name: string): string {
  return `${c.bgBlue}${c.white} ${squad.toUpperCase()} ${c.reset} ${c.bold}${name}${c.reset}`;
}

// ── Readline ──────────────────────────────────────────────────────────────────
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: true,
});

function ask(question: string): Promise<string> {
  return new Promise((resolve) => rl.question(question, resolve));
}

// ── Seleção de agente ─────────────────────────────────────────────────────────
async function selectAgent(squads: Squad[]): Promise<Agent> {
  const agents = flatAgentList(squads);

  console.log(header("═══════════════════════════════════════════"));
  console.log(header("   AIOX SQUADS — Agentes disponíveis"));
  console.log(header("═══════════════════════════════════════════"));

  let i = 1;
  for (const squad of squads) {
    console.log(`\n  ${c.bold}${c.yellow}Squad: ${squad.id}${c.reset}`);
    for (const agent of squad.agents) {
      console.log(
        `  ${c.dim}[${i}]${c.reset} ${c.cyan}${agent.name}${c.reset} ${c.dim}(${agent.id})${c.reset}`
      );
      i++;
    }
  }

  console.log("");
  const input = await ask(prompt("  Escolha um agente (número): "));
  const idx = parseInt(input.trim(), 10) - 1;

  if (isNaN(idx) || idx < 0 || idx >= agents.length) {
    console.log(warn("Número inválido. Usando o primeiro agente."));
    return agents[0];
  }
  return agents[idx];
}

// ── Banner de ajuda ───────────────────────────────────────────────────────────
function printHelp(): void {
  console.log(header("\n  Comandos disponíveis no chatbot"));
  console.log(`
  ${c.cyan}/help${c.reset}               — Mostra esta ajuda
  ${c.cyan}/agent${c.reset}              — Trocar de agente
  ${c.cyan}/upload <caminho>${c.reset}   — Envia um arquivo para análise
  ${c.cyan}/files${c.reset}              — Lista arquivos enviados nesta sessão
  ${c.cyan}/reset${c.reset}              — Limpa o histórico da conversa
  ${c.cyan}/status${c.reset}             — Exibe agente ativo e stats da sessão
  ${c.cyan}/exit${c.reset}               — Encerra o chatbot

  ${c.dim}Formatos suportados: ${supportedExtensions().join(", ")}${c.reset}
  `);
}

// ── Loop de chat principal ────────────────────────────────────────────────────
async function chatLoop(
  client: Anthropic,
  session: ChatSession,
  squads: Squad[]
): Promise<void> {
  const uploadedFiles: UploadedFile[] = [];
  const pendingFiles: UploadedFile[] = []; // arquivos a incluir na próxima mensagem

  console.log(header("\n  Chatbot iniciado!"));
  console.log(
    info(`Agente: ${agentTag(session.getAgent().squad, session.getAgent().name)}`)
  );
  console.log(info(`Digite /help para ver os comandos disponíveis.\n`));

  while (true) {
    const agentName = session.getAgent().name;
    const userInput = await ask(
      prompt(`\nVocê > `)
    );

    const trimmed = userInput.trim();
    if (!trimmed) continue;

    // ── Comandos especiais ───────────────────────────────────────────────────
    if (trimmed === "/exit") {
      console.log(success("\nAté logo! Sessão encerrada.\n"));
      break;
    }

    if (trimmed === "/help") {
      printHelp();
      continue;
    }

    if (trimmed === "/reset") {
      session.resetHistory();
      console.log(success("Histórico limpo."));
      continue;
    }

    if (trimmed === "/status") {
      console.log(
        info(
          `Agente: ${agentTag(session.getAgent().squad, session.getAgent().name)}`
        )
      );
      console.log(info(`Mensagens no histórico: ${session.historyLength()}`));
      console.log(info(`Arquivos na sessão: ${uploadedFiles.length}`));
      console.log(info(`Aguardando envio: ${pendingFiles.length}`));
      continue;
    }

    if (trimmed === "/files") {
      if (uploadedFiles.length === 0) {
        console.log(info("Nenhum arquivo enviado nesta sessão."));
      } else {
        console.log(info("Arquivos enviados:"));
        uploadedFiles.forEach((f, i) => {
          const isPending = pendingFiles.some((p) => p.fileId === f.fileId);
          console.log(
            `  ${c.dim}[${i + 1}]${c.reset} ${f.filename} ${c.dim}(${(f.sizeBytes / 1024).toFixed(1)} KB)${c.reset}${isPending ? c.yellow + " [pendente]" + c.reset : ""}`
          );
        });
      }
      continue;
    }

    if (trimmed === "/agent") {
      const newAgent = await selectAgent(squads);
      session.switchAgent(newAgent);
      console.log(
        success(
          `Agente alterado para: ${agentTag(newAgent.squad, newAgent.name)}`
        )
      );
      continue;
    }

    if (trimmed.startsWith("/upload ")) {
      const filePath = trimmed.slice("/upload ".length).trim();
      console.log(info(`Enviando ${filePath}...`));
      try {
        const uploaded = await uploadFile(client, filePath);
        uploadedFiles.push(uploaded);
        pendingFiles.push(uploaded);
        console.log(
          success(
            `Arquivo enviado: ${uploaded.filename} (${(uploaded.sizeBytes / 1024).toFixed(1)} KB)`
          )
        );
        console.log(
          info(`O arquivo será incluído na sua próxima mensagem.`)
        );
      } catch (err: any) {
        console.log(
          `${c.red}✗${c.reset} Erro ao enviar arquivo: ${err.message}`
        );
      }
      continue;
    }

    // Aviso se comando desconhecido
    if (trimmed.startsWith("/")) {
      console.log(warn(`Comando desconhecido. Digite /help para ajuda.`));
      continue;
    }

    // ── Envio de mensagem ao agente ──────────────────────────────────────────
    const filesToSend = [...pendingFiles];
    pendingFiles.length = 0; // limpa pendentes

    if (filesToSend.length > 0) {
      console.log(
        info(
          `Incluindo ${filesToSend.length} arquivo(s) na mensagem.`
        )
      );
    }

    console.log(
      `\n${c.bold}${c.cyan}${agentName}${c.reset} ${c.dim}▶${c.reset} `
    );

    try {
      await session.send(trimmed, filesToSend, (chunk) => {
        process.stdout.write(chunk);
      });
      console.log(""); // nova linha após streaming
    } catch (err: any) {
      console.log(`\n${c.red}✗ Erro: ${err.message}${c.reset}`);
    }
  }

  // Cleanup: deleta arquivos da Files API
  if (uploadedFiles.length > 0) {
    console.log(info(`Limpando ${uploadedFiles.length} arquivo(s) da API...`));
    for (const f of uploadedFiles) {
      try {
        await deleteFile(client, f.fileId);
      } catch {
        // silencioso
      }
    }
  }
}

// ── Entrypoint ────────────────────────────────────────────────────────────────
async function main(): Promise<void> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    console.error(
      `${c.red}✗${c.reset} ANTHROPIC_API_KEY não configurada.\n` +
        `  Defina com: export ANTHROPIC_API_KEY=sk-ant-...\n`
    );
    process.exit(1);
  }

  console.log(header("\n  ╔═══════════════════════════════════╗"));
  console.log(header("  ║   AIOX Squads — Chatbot v1.0      ║"));
  console.log(header("  ╚═══════════════════════════════════╝"));
  console.log(info("Carregando squads..."));

  const squads = loadAllSquads();

  if (squads.length === 0) {
    console.error(warn("Nenhum squad encontrado em ./squads/"));
    process.exit(1);
  }

  const totalAgents = squads.reduce((n, s) => n + s.agents.length, 0);
  console.log(
    success(
      `${squads.length} squad(s) carregado(s) com ${totalAgents} agente(s).`
    )
  );

  const client = new Anthropic({ apiKey });

  const selectedAgent = await selectAgent(squads);
  const session = new ChatSession(client, selectedAgent);

  console.log(
    success(
      `Agente selecionado: ${agentTag(selectedAgent.squad, selectedAgent.name)}`
    )
  );

  await chatLoop(client, session, squads);
  rl.close();
}

main().catch((err) => {
  console.error(`\n${c.red}Erro fatal: ${err.message}${c.reset}\n`);
  process.exit(1);
});
