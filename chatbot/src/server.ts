/**
 * AIOX Squads — Web Server
 *
 * Servidor Express com:
 *  - SSE para streaming de respostas
 *  - Upload de arquivos via Multer → Files API
 *  - Frontend HTML embutido (chat UI responsivo)
 *  - API REST para listagem de agentes e sessões
 */

import express, { Request, Response } from "express";
import multer from "multer";
import path from "path";
import os from "os";
import fs from "fs";
import Anthropic from "@anthropic-ai/sdk";

import { loadAllSquads, flatAgentList, Squad, Agent } from "./agents";
import { uploadFile, deleteFile } from "./files";
import { ChatSession } from "./chat";

// ── Config ─────────────────────────────────────────────────────────────────────
const PORT = parseInt(process.env.PORT ?? "3000", 10);
const API_KEY = process.env.ANTHROPIC_API_KEY ?? "";

// ── State ──────────────────────────────────────────────────────────────────────
const client = new Anthropic({ apiKey: API_KEY });
const squads: Squad[] = loadAllSquads();
const agents: Agent[] = flatAgentList(squads);

// sessionId → ChatSession + uploaded file IDs
const sessions = new Map<
  string,
  { session: ChatSession; fileIds: string[] }
>();

function getOrCreateSession(sessionId: string, agentId: string) {
  if (!sessions.has(sessionId)) {
    const agent =
      agents.find((a) => a.id === agentId) ?? agents[0];
    sessions.set(sessionId, {
      session: new ChatSession(client, agent),
      fileIds: [],
    });
  }
  return sessions.get(sessionId)!;
}

// ── Upload (tmp disk) ──────────────────────────────────────────────────────────
const upload = multer({ dest: os.tmpdir() });

// ── App ────────────────────────────────────────────────────────────────────────
const app = express();
app.use(express.json());

// ── API: listar squads/agentes ─────────────────────────────────────────────────
app.get("/api/agents", (_req: Request, res: Response) => {
  const list = squads.map((s) => ({
    id: s.id,
    agents: s.agents.map((a) => ({ id: a.id, name: a.name, squad: a.squad })),
  }));
  res.json(list);
});

// ── API: trocar agente ────────────────────────────────────────────────────────
app.post("/api/session/agent", (req: Request, res: Response) => {
  const { sessionId, agentId } = req.body as {
    sessionId: string;
    agentId: string;
  };
  const newAgent = agents.find((a) => a.id === agentId);
  if (!newAgent) {
    res.status(404).json({ error: "Agent not found" });
    return;
  }
  const entry = sessions.get(sessionId);
  if (entry) {
    entry.session.switchAgent(newAgent);
  }
  res.json({ ok: true, agent: { id: newAgent.id, name: newAgent.name } });
});

// ── API: resetar histórico ────────────────────────────────────────────────────
app.post("/api/session/reset", (req: Request, res: Response) => {
  const { sessionId } = req.body as { sessionId: string };
  const entry = sessions.get(sessionId);
  if (entry) entry.session.resetHistory();
  res.json({ ok: true });
});

// ── API: upload de arquivo → Files API ────────────────────────────────────────
app.post(
  "/api/upload",
  upload.single("file"),
  async (req: Request, res: Response) => {
    const sessionId = req.body.sessionId as string;
    const agentId = (req.body.agentId as string) ?? agents[0].id;

    if (!req.file) {
      res.status(400).json({ error: "No file provided" });
      return;
    }

    // Renomeia o arquivo temporário para preservar a extensão
    const ext = path.extname(req.file.originalname);
    const tmpWithExt = req.file.path + ext;
    fs.renameSync(req.file.path, tmpWithExt);

    try {
      const uploaded = await uploadFile(client, tmpWithExt);
      const entry = getOrCreateSession(sessionId, agentId);
      entry.fileIds.push(uploaded.fileId);
      fs.unlinkSync(tmpWithExt);
      res.json({
        ok: true,
        fileId: uploaded.fileId,
        filename: uploaded.filename,
        sizeKb: (uploaded.sizeBytes / 1024).toFixed(1),
      });
    } catch (err: any) {
      fs.unlinkSync(tmpWithExt);
      res.status(500).json({ error: err.message });
    }
  }
);

// ── API: chat com SSE streaming ───────────────────────────────────────────────
app.get("/api/chat", async (req: Request, res: Response) => {
  const q = req.query;
  const sessionId = String(q.sessionId ?? "");
  const agentId = String(q.agentId ?? "");
  const message = String(q.message ?? "");
  const rawFileIds = q.fileIds ? String(q.fileIds) : undefined;

  if (!sessionId || !message) {
    res.status(400).json({ error: "sessionId and message required" });
    return;
  }

  // SSE headers
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.flushHeaders();

  const send = (event: string, data: unknown) => {
    res.write(`event: ${event}\ndata: ${JSON.stringify(data)}\n\n`);
  };

  const entry = getOrCreateSession(sessionId, agentId ?? agents[0].id);
  const { session } = entry;

  // Constrói lista de UploadedFile a partir dos fileIds enviados
  const pendingFileIds: string[] = rawFileIds
    ? rawFileIds.split(",").filter(Boolean)
    : [];

  const pendingFiles = pendingFileIds.map((id) => ({
    fileId: id,
    filename: id,
    mimeType: "application/octet-stream",
    sizeBytes: 0,
  }));

  try {
    send("start", { agent: session.getAgent().name });

    await session.send(message, pendingFiles, (chunk) => {
      send("chunk", { text: chunk });
    });

    send("done", { ok: true });
  } catch (err: any) {
    send("error", { message: err.message });
  } finally {
    res.end();
  }
});

// ── API: limpar sessão e arquivos ─────────────────────────────────────────────
app.delete("/api/session/:id", async (req: Request, res: Response) => {
  const id = String(req.params.id);
  const entry = sessions.get(id);
  if (entry) {
    for (const fid of entry.fileIds) {
      await deleteFile(client, fid).catch(() => {});
    }
    sessions.delete(id);
  }
  res.json({ ok: true });
});

// ── Frontend HTML ──────────────────────────────────────────────────────────────
app.get("/health", (_req: Request, res: Response) => {
  res.json({ status: "ok", uptime: process.uptime() });
});

app.get("/", (_req: Request, res: Response) => {
  res.setHeader("Content-Type", "text/html; charset=utf-8");
  res.send(HTML_UI);
});

// ── Start ──────────────────────────────────────────────────────────────────────
app.listen(PORT, "0.0.0.0", () => {
  const ip = Object.values(os.networkInterfaces())
    .flat()
    .find((i) => i?.family === "IPv4" && !i.internal)?.address;

  console.log(`\n  ╔══════════════════════════════════════════╗`);
  console.log(`  ║   AIOX Squads — Web Chatbot              ║`);
  console.log(`  ╠══════════════════════════════════════════╣`);
  console.log(`  ║  Local:   http://localhost:${PORT}          ║`);
  if (ip) {
    console.log(`  ║  Rede:    http://${ip}:${PORT}       ║`);
  }
  console.log(`  ╠══════════════════════════════════════════╣`);
  console.log(`  ║  Squads:  ${squads.length}                               ║`);
  console.log(`  ║  Agentes: ${agents.length}                              ║`);
  console.log(`  ╚══════════════════════════════════════════╝\n`);
});

// ── HTML UI — 3 colunas (Upload | Chat | Preview + Atividade) ─────────────────
const HTML_UI = `<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<meta name="theme-color" content="#0d1117"/>
<title>AIOX Squads — Analista Processual</title>
<style>
/* ── Variables ── */
:root{
  --bg:#0d1117;--bg2:#161b22;--bg3:#21262d;--border:#30363d;
  --text:#e6edf3;--dim:#8b949e;--accent:#58a6ff;--green:#3fb950;
  --yellow:#d29922;--orange:#e3822a;--red:#f85149;
  --user-bg:#1f3a5f;--agent-bg:#161f2e;
  --r:10px;--font:'Segoe UI',system-ui,sans-serif;
  --left-w:260px;--right-w:360px;
}
*{box-sizing:border-box;margin:0;padding:0;}
html,body{height:100%;overflow:hidden;}
body{background:var(--bg);color:var(--text);font-family:var(--font);display:flex;flex-direction:column;}

/* ── Header ── */
header{
  background:var(--bg2);border-bottom:1px solid var(--border);
  height:50px;padding:0 16px;display:flex;align-items:center;gap:12px;flex-shrink:0;
}
.logo{font-size:15px;font-weight:800;color:var(--accent);letter-spacing:-.4px;}
.hdr-sep{width:1px;height:18px;background:var(--border);}
#agent-pill{
  font-size:12px;font-weight:600;background:rgba(88,166,255,.12);color:var(--accent);
  padding:3px 10px;border-radius:20px;border:1px solid rgba(88,166,255,.25);
  white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:180px;
}
.hdr-spacer{flex:1;}
.hdr-btn{
  background:none;border:1px solid var(--border);color:var(--dim);
  font:12px var(--font);padding:4px 10px;border-radius:6px;cursor:pointer;
}
.hdr-btn:hover{color:var(--text);border-color:var(--dim);}
#conn-dot{width:8px;height:8px;border-radius:50%;background:var(--dim);flex-shrink:0;}
#conn-dot.ok{background:var(--green);}
#conn-dot.busy{background:var(--orange);animation:pulse .8s infinite;}
@keyframes pulse{0%,100%{opacity:1}50%{opacity:.35}}

/* ── 3-column layout ── */
.layout{display:flex;flex:1;min-height:0;overflow:hidden;}

/* ── Panel base ── */
.panel{display:flex;flex-direction:column;overflow:hidden;}
.ph{/* panel-header */
  padding:8px 12px;font-size:10px;font-weight:700;text-transform:uppercase;
  letter-spacing:.7px;color:var(--dim);border-bottom:1px solid var(--border);
  flex-shrink:0;display:flex;align-items:center;justify-content:space-between;
}

/* ── LEFT PANEL ── */
#pl{width:var(--left-w);flex-shrink:0;background:var(--bg2);border-right:1px solid var(--border);}
#pl .panel-scroll{flex:1;overflow-y:auto;}

/* Agents list */
.squad-lbl{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--yellow);padding:8px 12px 3px;}
.agent-btn{
  display:flex;align-items:center;gap:8px;width:100%;text-align:left;
  background:none;border:none;color:var(--text);font:13px var(--font);
  padding:9px 12px;cursor:pointer;transition:background .12s;
}
.agent-btn:hover{background:var(--bg3);}
.agent-btn.active{background:rgba(88,166,255,.1);color:var(--accent);border-left:3px solid var(--accent);padding-left:9px;}
.agent-dot{width:6px;height:6px;border-radius:50%;background:var(--dim);flex-shrink:0;}
.agent-btn.active .agent-dot{background:var(--accent);}

/* Upload zone */
.upload-wrap{padding:12px;border-top:1px solid var(--border);}
.upload-zone{
  border:2px dashed var(--border);border-radius:var(--r);padding:16px 10px;
  text-align:center;cursor:pointer;transition:border-color .2s,background .2s;
}
.upload-zone:hover,.upload-zone.over{border-color:var(--accent);background:rgba(88,166,255,.04);}
.upload-zone .uz-icon{font-size:26px;margin-bottom:4px;}
.upload-zone p{font-size:12px;color:var(--dim);line-height:1.4;}
.upload-zone span{font-size:10px;color:var(--dim);opacity:.6;}
#fi{display:none;}

/* File list */
.file-list{padding:8px 12px;display:flex;flex-direction:column;gap:5px;}
.fitem{
  background:var(--bg3);border:1px solid var(--border);border-radius:8px;
  padding:7px 9px;display:flex;align-items:center;gap:7px;cursor:pointer;
  transition:border-color .15s;
}
.fitem:hover{border-color:var(--dim);}
.fitem.active{border-color:var(--accent);}
.ficon{font-size:18px;flex-shrink:0;}
.finfo{flex:1;min-width:0;}
.fname{font-size:12px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.fsize{font-size:10px;color:var(--dim);}
.fdot{width:6px;height:6px;border-radius:50%;flex-shrink:0;}
.fdot.uploading{background:var(--yellow);animation:pulse .7s infinite;}
.fdot.ready{background:var(--green);}
.fdot.error{background:var(--red);}

/* ── CENTER PANEL ── */
#pc{flex:1;min-width:0;background:var(--bg);border-right:1px solid var(--border);display:flex;flex-direction:column;}

#messages{flex:1;overflow-y:auto;padding:16px;display:flex;flex-direction:column;gap:14px;scroll-behavior:smooth;}
.msg{max-width:84%;display:flex;flex-direction:column;gap:3px;}
.msg.user{align-self:flex-end;}
.msg.agent{align-self:flex-start;}
.msg-lbl{font-size:11px;color:var(--dim);padding:0 4px;}
.msg.user .msg-lbl{text-align:right;}
.msg-bbl{
  padding:10px 14px;border-radius:var(--r);line-height:1.65;
  font-size:14px;white-space:pre-wrap;word-break:break-word;
}
.msg.user .msg-bbl{background:var(--user-bg);border-bottom-right-radius:3px;}
.msg.agent .msg-bbl{background:var(--agent-bg);border:1px solid var(--border);border-bottom-left-radius:3px;}
.msg-bbl.typing::after{content:'▋';animation:blink .7s infinite;color:var(--accent);}
@keyframes blink{0%,100%{opacity:1}50%{opacity:0}}
.msg-actions{display:flex;gap:5px;padding:2px 4px;opacity:0;transition:opacity .15s;}
.msg:hover .msg-actions{opacity:1;}
.mact{background:var(--bg3);border:1px solid var(--border);color:var(--dim);font:11px var(--font);padding:3px 8px;border-radius:5px;cursor:pointer;}
.mact:hover{color:var(--accent);border-color:var(--accent);}
.sys-msg{text-align:center;font-size:11px;color:var(--dim);padding:1px 0;}
.welcome{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:40px 24px;gap:10px;color:var(--dim);}
.welcome h2{font-size:20px;font-weight:700;color:var(--text);}
.welcome p{font-size:13px;max-width:280px;line-height:1.6;}

#chips{display:flex;flex-wrap:wrap;gap:5px;padding:0 12px 6px;}
.chip{background:rgba(88,166,255,.1);border:1px solid rgba(88,166,255,.2);border-radius:20px;padding:3px 9px 3px 7px;font-size:11px;color:var(--accent);display:flex;align-items:center;gap:4px;}
.chip button{background:none;border:none;color:var(--dim);cursor:pointer;font-size:14px;padding:0;line-height:1;}
.chip button:hover{color:var(--red);}

.input-wrap{padding:10px 12px;border-top:1px solid var(--border);background:var(--bg2);flex-shrink:0;}
.input-row{display:flex;gap:6px;align-items:flex-end;}
#msg-input{
  flex:1;background:var(--bg3);border:1px solid var(--border);border-radius:10px;
  color:var(--text);font:14px var(--font);padding:10px 12px;
  resize:none;min-height:44px;max-height:130px;outline:none;transition:border-color .15s;
}
#msg-input:focus{border-color:var(--accent);}
#msg-input::placeholder{color:var(--dim);}
.icon-btn{
  background:none;border:none;cursor:pointer;color:var(--dim);font-size:20px;
  padding:5px;border-radius:8px;height:44px;width:44px;
  display:flex;align-items:center;justify-content:center;flex-shrink:0;
}
.icon-btn:hover{color:var(--accent);background:var(--bg3);}
#fi2{display:none;}
#send-btn{
  background:var(--accent);color:#0d1117;border:none;border-radius:10px;
  padding:0 16px;height:44px;font:600 14px var(--font);cursor:pointer;flex-shrink:0;
}
#send-btn:disabled{opacity:.35;cursor:default;}
#send-btn:not(:disabled):hover{opacity:.85;}

/* ── RIGHT PANEL ── */
#pr{width:var(--right-w);flex-shrink:0;background:var(--bg2);display:flex;flex-direction:column;}

/* Activity */
.activity{flex-shrink:0;max-height:210px;display:flex;flex-direction:column;border-bottom:1px solid var(--border);}
#act-log{flex:1;overflow-y:auto;padding:6px 10px;display:flex;flex-direction:column;gap:3px;}
.aitem{display:flex;gap:7px;align-items:flex-start;animation:slideIn .18s ease;}
@keyframes slideIn{from{opacity:0;transform:translateY(-5px)}to{opacity:1;transform:none}}
.atime{font-size:10px;color:var(--dim);flex-shrink:0;padding-top:1px;font-variant-numeric:tabular-nums;}
.atxt{font-size:12px;line-height:1.4;}
.atxt.idle{color:var(--dim);}
.atxt.action{color:var(--text);}
.atxt.switch{color:var(--yellow);}
.atxt.done{color:var(--green);}
.atxt.err{color:var(--red);}
.atxt.upload{color:var(--accent);}

/* Working bar */
.working-bar{
  display:none;align-items:center;gap:8px;padding:5px 10px;
  background:rgba(88,166,255,.04);border-top:1px solid var(--border);flex-shrink:0;
}
.working-bar.show{display:flex;}
.wname{font-size:12px;font-weight:600;color:var(--accent);}
.wlabel{font-size:11px;color:var(--dim);}
.dots{display:flex;gap:3px;align-items:center;margin-left:auto;}
.dots span{width:5px;height:5px;border-radius:50%;background:var(--accent);animation:bounce 1.2s infinite;}
.dots span:nth-child(2){animation-delay:.2s;}
.dots span:nth-child(3){animation-delay:.4s;}
@keyframes bounce{0%,60%,100%{transform:translateY(0);opacity:.5}30%{transform:translateY(-5px);opacity:1}}

/* Preview */
.preview{flex:1;min-height:0;display:flex;flex-direction:column;}
.preview-tabs{display:flex;gap:4px;}
.ptab{background:none;border:1px solid var(--border);border-radius:5px;color:var(--dim);font:11px var(--font);padding:2px 8px;cursor:pointer;}
.ptab.active{background:var(--bg3);color:var(--accent);border-color:var(--accent);}
#preview-body{flex:1;overflow:auto;position:relative;}
.pempty{
  display:flex;flex-direction:column;align-items:center;justify-content:center;
  height:100%;padding:20px;text-align:center;color:var(--dim);gap:8px;
}
.pempty .picon{font-size:34px;opacity:.45;}
.pempty p{font-size:12px;line-height:1.5;}
#pframe{width:100%;height:100%;border:none;display:none;background:#fff;}
#pimg{max-width:100%;max-height:100%;object-fit:contain;display:none;padding:12px;}
#ptxt{padding:14px;font-size:12px;line-height:1.7;white-space:pre-wrap;color:var(--text);display:none;}
#pmd{padding:14px;font-size:13px;line-height:1.7;color:var(--text);display:none;}
#pmd h1{font-size:17px;margin-bottom:8px;color:var(--accent);border-bottom:1px solid var(--border);padding-bottom:5px;}
#pmd h2{font-size:14px;margin:12px 0 5px;color:var(--text);}
#pmd h3{font-size:13px;margin:10px 0 4px;color:var(--dim);}
#pmd p{margin-bottom:7px;}
#pmd table{width:100%;border-collapse:collapse;font-size:11px;margin:7px 0;}
#pmd th{background:var(--bg3);padding:5px 7px;text-align:left;border:1px solid var(--border);color:var(--accent);}
#pmd td{padding:4px 7px;border:1px solid var(--border);}
#pmd tr:nth-child(even) td{background:rgba(255,255,255,.02);}
#pmd code{background:var(--bg3);padding:1px 4px;border-radius:3px;font-size:11px;}
#pmd ul,#pmd ol{padding-left:16px;margin:5px 0;}
#pmd li{margin-bottom:2px;}
#pmd blockquote{border-left:3px solid var(--accent);padding-left:9px;color:var(--dim);margin:7px 0;}
#pmd hr{border:none;border-top:1px solid var(--border);margin:10px 0;}
#pmd strong{color:var(--text);}

/* ── Scrollbar ── */
::-webkit-scrollbar{width:4px;height:4px;}
::-webkit-scrollbar-thumb{background:var(--border);border-radius:2px;}

/* ── Toast ── */
#toast{position:fixed;bottom:72px;left:50%;transform:translateX(-50%);background:var(--bg3);border:1px solid var(--border);border-radius:10px;padding:8px 16px;font-size:13px;display:none;z-index:99;white-space:nowrap;box-shadow:0 4px 20px rgba(0,0,0,.5);}
#toast.err{border-color:var(--red);color:var(--red);}
#toast.ok{border-color:var(--green);color:var(--green);}

/* ── Responsive ── */
@media(max-width:900px){#pl{display:none;}}
@media(max-width:600px){#pl,#pr{display:none;}#pc{border-right:none;}}
</style>
</head>
<body>

<!-- ── HEADER ── -->
<header>
  <span class="logo">⬡ AIOX Squads</span>
  <span class="hdr-sep"></span>
  <span id="agent-pill">Selecione um agente →</span>
  <span class="hdr-spacer"></span>
  <button class="hdr-btn" onclick="resetHistory()">Limpar histórico</button>
  <span id="conn-dot" title="Status"></span>
</header>

<div class="layout">

  <!-- ── COL 1: AGENTES + UPLOAD ── -->
  <aside id="pl" class="panel">
    <div class="ph">Agentes</div>
    <div class="panel-scroll" style="flex:1;overflow-y:auto;">
      <div id="agent-list"></div>
      <div class="upload-wrap">
        <div class="ph" style="border:none;padding:8px 0 6px;">Arquivos do Processo</div>
        <div class="upload-zone" id="upload-zone" onclick="document.getElementById('fi').click()">
          <div class="uz-icon">📂</div>
          <p>Clique ou arraste arquivos</p>
          <span>PDF · TXT · MD · CSV · JSON · imagens</span>
        </div>
        <input type="file" id="fi" accept=".pdf,.txt,.md,.json,.csv,.png,.jpg,.jpeg,.webp,.gif" multiple/>
        <div class="file-list" id="file-list"></div>
      </div>
    </div>
  </aside>

  <!-- ── COL 2: CHAT ── -->
  <main id="pc">
    <div id="messages">
      <div class="welcome" id="welcome">
        <h2>⚖️ Analista Processual</h2>
        <p>Selecione um agente à esquerda, faça upload dos arquivos do processo e envie um comando.</p>
      </div>
    </div>
    <div id="chips"></div>
    <div class="input-wrap">
      <div class="input-row">
        <label for="fi2" class="icon-btn" title="Anexar arquivo">📎</label>
        <input type="file" id="fi2" accept=".pdf,.txt,.md,.json,.csv,.png,.jpg,.jpeg,.webp,.gif" multiple/>
        <textarea id="msg-input" placeholder="Mensagem para o agente… (Enter para enviar)" rows="1" autocorrect="on" spellcheck="true"></textarea>
        <button id="send-btn" onclick="sendMessage()">↑</button>
      </div>
    </div>
  </main>

  <!-- ── COL 3: ATIVIDADE + PREVIEW ── -->
  <aside id="pr">

    <!-- Activity panel -->
    <div class="activity">
      <div class="ph">
        Atividade dos Agentes
        <span id="act-badge" style="font-size:10px;color:var(--dim);font-weight:400;text-transform:none;letter-spacing:0;">aguardando</span>
      </div>
      <div id="act-log">
        <div class="aitem">
          <span class="atime">--:--:--</span>
          <span class="atxt idle">Sessão iniciada. Selecione um agente.</span>
        </div>
      </div>
      <div class="working-bar" id="working-bar">
        <span class="wname" id="wname"></span>
        <span class="wlabel">processando</span>
        <div class="dots"><span></span><span></span><span></span></div>
      </div>
    </div>

    <!-- Preview panel -->
    <div class="preview">
      <div class="ph">
        Visualização
        <div class="preview-tabs">
          <button class="ptab active" id="tab-doc" onclick="setTab('doc')">Documento</button>
          <button class="ptab" id="tab-out" onclick="setTab('out')">Resultado</button>
        </div>
      </div>
      <div id="preview-body">
        <div class="pempty" id="pempty">
          <div class="picon">📄</div>
          <p>Faça upload de um arquivo para visualizar aqui, ou clique em "Resultado" para ver a última resposta do agente.</p>
        </div>
        <iframe id="pframe" title="Documento"></iframe>
        <img id="pimg" alt="Preview"/>
        <div id="ptxt"></div>
        <div id="pmd"></div>
      </div>
    </div>

  </aside>
</div>

<div id="toast"></div>

<script>
const SID='sess-'+Math.random().toString(36).slice(2,10);
let activeAgent=null,pendingIds=[],uploadedFiles=[],lastOutput='',activeFile=null,previewTab='doc',streaming=false;

// ── INIT ──────────────────────────────────────────────────────────────────────
async function init(){
  try{
    const res=await fetch('/api/agents');
    const data=await res.json();
    const list=document.getElementById('agent-list');
    data.forEach(s=>{
      const lbl=document.createElement('div');lbl.className='squad-lbl';lbl.textContent=s.id;list.appendChild(lbl);
      s.agents.forEach(a=>{
        const btn=document.createElement('button');btn.className='agent-btn';btn.dataset.id=a.id;
        btn.innerHTML='<span class="agent-dot"></span>'+esc(a.name);
        btn.onclick=()=>selectAgent(a.id,a.name,s.id,btn);
        list.appendChild(btn);
      });
    });
    setConn('ok');
  }catch(e){setConn('');log('err','Erro ao carregar agentes: '+e.message);}
}

// ── AGENT ─────────────────────────────────────────────────────────────────────
async function selectAgent(id,name,squad,btn){
  if(streaming)return;
  document.querySelectorAll('.agent-btn').forEach(b=>b.classList.remove('active'));
  btn.classList.add('active');
  document.getElementById('agent-pill').textContent=name;
  document.getElementById('welcome')?.remove();
  activeAgent={id,name};
  await fetch('/api/session/agent',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({sessionId:SID,agentId:id})});
  appendSys(name+' ['+squad+'] ativado');
  log('switch',name+' ativado');
}

async function resetHistory(){
  if(!activeAgent)return;
  await fetch('/api/session/reset',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({sessionId:SID})});
  appendSys('Histórico limpo.');
  log('action','Histórico da sessão limpo');
}

// ── UPLOAD ────────────────────────────────────────────────────────────────────
function setupDrop(){
  const z=document.getElementById('upload-zone');
  z.addEventListener('dragover',e=>{e.preventDefault();z.classList.add('over');});
  z.addEventListener('dragleave',()=>z.classList.remove('over'));
  z.addEventListener('drop',e=>{e.preventDefault();z.classList.remove('over');Array.from(e.dataTransfer.files).forEach(doUpload);});
}
document.getElementById('fi').addEventListener('change',e=>{Array.from(e.target.files).forEach(doUpload);e.target.value='';});
document.getElementById('fi2').addEventListener('change',e=>{Array.from(e.target.files).forEach(doUpload);e.target.value='';});

async function doUpload(file){
  const tmpId='f'+Math.random().toString(36).slice(2,7);
  addFileRow(tmpId,file.name,null,'uploading');
  log('upload','Enviando: '+file.name);
  const fd=new FormData();
  fd.append('file',file);fd.append('sessionId',SID);
  if(activeAgent)fd.append('agentId',activeAgent.id);
  try{
    const r=await fetch('/api/upload',{method:'POST',body:fd});
    const d=await r.json();
    if(!r.ok)throw new Error(d.error);
    const url=URL.createObjectURL(file);
    const entry={fileId:d.fileId,filename:d.filename,sizeKb:d.sizeKb,mime:file.type,url,file};
    uploadedFiles.push(entry);
    pendingIds.push(d.fileId);
    updateFileRow(tmpId,entry,'ready');
    renderChips();
    log('done',d.filename+' ('+d.sizeKb+' KB) pronto');
    toast(d.filename+' enviado','ok');
    if(uploadedFiles.length===1)previewFile(entry);
  }catch(e){
    updateFileRow(tmpId,{filename:file.name},'error');
    log('err','Erro upload: '+e.message);
    toast('Erro: '+e.message,'err');
  }
}

function addFileRow(id,name,kb,status){
  const list=document.getElementById('file-list');
  const el=document.createElement('div');el.className='fitem';el.id=id;
  el.innerHTML=fileRowHTML(name,kb,status);list.appendChild(el);
}
function updateFileRow(id,entry,status){
  const el=document.getElementById(id);if(!el)return;
  el.innerHTML=fileRowHTML(entry.filename,entry.sizeKb||null,status);
  if(status==='ready')el.onclick=()=>previewFile(entry);
}
function fileRowHTML(name,kb,status){
  const icons={pdf:'📄',png:'🖼',jpg:'🖼',jpeg:'🖼',webp:'🖼',gif:'🎞',csv:'📊',json:'📋',md:'📝',txt:'📃'};
  const ext=name.split('.').pop()?.toLowerCase()||'';
  return '<span class="ficon">'+(icons[ext]||'📁')+'</span><div class="finfo"><div class="fname">'+esc(name)+'</div>'+(kb?'<div class="fsize">'+kb+' KB</div>':'')+'</div><div class="fdot '+status+'"></div>';
}

function renderChips(){
  const c=document.getElementById('chips');c.innerHTML='';
  pendingIds.forEach((id,i)=>{
    const f=uploadedFiles.find(u=>u.fileId===id);if(!f)return;
    const d=document.createElement('div');d.className='chip';
    d.innerHTML='📄 '+esc(f.filename)+' <button onclick="removeChip('+i+')">×</button>';
    c.appendChild(d);
  });
}
function removeChip(i){pendingIds.splice(i,1);renderChips();}

// ── SEND ──────────────────────────────────────────────────────────────────────
async function sendMessage(){
  if(streaming)return;
  if(!activeAgent){toast('Selecione um agente.','err');return;}
  const inp=document.getElementById('msg-input');
  const text=inp.value.trim();if(!text)return;
  inp.value='';resize(inp);
  appendMsg('user','Você',text);
  const fids=pendingIds.join(',');pendingIds=[];renderChips();
  const bubble=appendMsg('agent',activeAgent.name,'',true);
  streaming=true;setConn('busy');
  document.getElementById('send-btn').disabled=true;
  setWorking(activeAgent.name);
  log('action','Enviando para '+activeAgent.name+': '+text.slice(0,55)+(text.length>55?'…':''));

  const url='/api/chat?'+new URLSearchParams({sessionId:SID,agentId:activeAgent.id,message:text,fileIds:fids});
  const es=new EventSource(url);let full='';

  es.addEventListener('start',e=>{const d=JSON.parse(e.data);log('switch','Agente respondendo: '+d.agent);});

  es.addEventListener('chunk',e=>{
    full+=JSON.parse(e.data).text;
    bubble.textContent=full;
    // detect agent routing hints in stream
    const m=full.match(/\[([a-z][a-z0-9-]+)\]\s*[aA]tivado|→\s*([a-z][a-z0-9-]+)/);
    if(m){const n=m[1]||m[2];if(n&&n!==activeAgent.id){document.getElementById('wname').textContent=n;}}
    scrollBot();
  });

  es.addEventListener('done',()=>{
    es.close();lastOutput=full;finishStream(bubble);
    log('done','Resposta completa ('+full.length+' chars)');
    if(previewTab==='out')showMd(full);
  });

  es.addEventListener('error',e=>{
    es.close();
    if(e.data){const msg=JSON.parse(e.data).message;bubble.textContent='⚠ '+msg;bubble.style.color='var(--red)';log('err',msg);}
    finishStream(bubble);
  });

  es.onerror=()=>{if(es.readyState===EventSource.CLOSED)return;es.close();finishStream(bubble);};
}

function finishStream(b){
  b.classList.remove('typing');streaming=false;setConn('ok');
  document.getElementById('send-btn').disabled=false;
  setWorking(null);scrollBot();
}

// ── PREVIEW ───────────────────────────────────────────────────────────────────
function setTab(tab){
  previewTab=tab;
  document.getElementById('tab-doc').classList.toggle('active',tab==='doc');
  document.getElementById('tab-out').classList.toggle('active',tab==='out');
  if(tab==='out')showMd(lastOutput||'');
  else if(activeFile)previewFile(activeFile);
  else hideAllPreview();
}

function previewFile(entry){
  activeFile=entry;
  if(previewTab!=='doc')return;
  hideAllPreview();
  const mime=entry.mime||'';
  if(mime==='application/pdf'||entry.filename.toLowerCase().endsWith('.pdf')){
    const f=document.getElementById('pframe');f.src=entry.url;f.style.display='block';
  }else if(mime.startsWith('image/')){
    const img=document.getElementById('pimg');img.src=entry.url;img.style.display='block';
  }else if(entry.filename.endsWith('.md')){
    readAs(entry.file,'md');
  }else{
    readAs(entry.file,'txt');
  }
  document.querySelectorAll('.fitem').forEach(el=>el.classList.remove('active'));
  const row=Array.from(document.querySelectorAll('.fitem')).find(el=>el.querySelector('.fname')?.textContent===entry.filename);
  if(row)row.classList.add('active');
}

function readAs(file,type){
  const r=new FileReader();
  r.onload=e=>{
    if(type==='md')showMd(e.target.result);
    else{const el=document.getElementById('ptxt');el.textContent=e.target.result;el.style.display='block';}
  };
  r.readAsText(file);
}

function showMd(src){
  hideAllPreview();
  const el=document.getElementById('pmd');
  el.innerHTML=src?renderMd(src):'<div style="color:var(--dim);padding:20px;text-align:center">Nenhum resultado ainda.</div>';
  el.style.display='block';
}

function hideAllPreview(){
  ['pframe','pimg','ptxt','pmd','pempty'].forEach(id=>{const el=document.getElementById(id);if(el)el.style.display='none';});
}

function renderMd(md){
  return md
    .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
    .replace(/^# (.+)$/gm,'<h1>$1</h1>').replace(/^## (.+)$/gm,'<h2>$1</h2>').replace(/^### (.+)$/gm,'<h3>$1</h3>')
    .replace(/\*\*(.+?)\*\*/g,'<strong>$1</strong>').replace(/\*(.+?)\*/g,'<em>$1</em>')
    .replace(/\`(.+?)\`/g,'<code>$1</code>')
    .replace(/^> (.+)$/gm,'<blockquote>$1</blockquote>')
    .replace(/^---$/gm,'<hr/>')
    .replace(/^\|(.+)\|$/gm,(_,row)=>'<tr>'+row.split('|').map(c=>'<td>'+c.trim()+'</td>').join('')+'</tr>')
    .replace(/(<tr>[\s\S]*?<\/tr>\n?)+/g,m=>'<table>'+m+'</table>')
    .replace(/^[-*] (.+)$/gm,'<li>$1</li>')
    .replace(/(<li>[\s\S]*?<\/li>\n?)+/g,m=>'<ul>'+m+'</ul>')
    .replace(/\n\n/g,'<br/><br/>');
}

// ── ACTIVITY LOG ──────────────────────────────────────────────────────────────
function log(type,text){
  const now=new Date();
  const t=now.getHours().toString().padStart(2,'0')+':'+now.getMinutes().toString().padStart(2,'0')+':'+now.getSeconds().toString().padStart(2,'0');
  const log=document.getElementById('act-log');
  const d=document.createElement('div');d.className='aitem';
  d.innerHTML='<span class="atime">'+t+'</span><span class="atxt '+type+'">'+esc(text)+'</span>';
  log.appendChild(d);log.scrollTop=log.scrollHeight;
  while(log.children.length>60)log.removeChild(log.firstChild);
  const badge=document.getElementById('act-badge');
  if(type==='action'||type==='switch')badge.textContent='trabalhando…';
  else if(type==='done')badge.textContent='concluído';
  else if(type==='err')badge.textContent='erro';
}

function setWorking(name){
  const bar=document.getElementById('working-bar');
  const wn=document.getElementById('wname');
  if(name){bar.classList.add('show');wn.textContent=name;}
  else{bar.classList.remove('show');document.getElementById('act-badge').textContent='aguardando';}
}

// ── HELPERS ───────────────────────────────────────────────────────────────────
function appendMsg(role,label,text,typing=false){
  const m=document.getElementById('messages');
  const d=document.createElement('div');d.className='msg '+role;
  const l=document.createElement('div');l.className='msg-lbl';l.textContent=label;
  const b=document.createElement('div');b.className='msg-bbl'+(typing?' typing':'');b.textContent=text;
  d.appendChild(l);d.appendChild(b);
  if(role==='agent'){
    const acts=document.createElement('div');acts.className='msg-actions';
    const v=document.createElement('button');v.className='mact';v.textContent='↗ Ver no preview';
    v.onclick=()=>{lastOutput=b.textContent;setTab('out');};
    const cp=document.createElement('button');cp.className='mact';cp.textContent='📋 Copiar';
    cp.onclick=()=>{navigator.clipboard?.writeText(b.textContent);toast('Copiado!','ok');};
    acts.appendChild(v);acts.appendChild(cp);d.appendChild(acts);
  }
  m.appendChild(d);scrollBot();return b;
}
function appendSys(t){
  const m=document.getElementById('messages');
  const d=document.createElement('div');d.className='sys-msg';d.textContent='— '+t+' —';
  m.appendChild(d);scrollBot();
}
function scrollBot(){const m=document.getElementById('messages');m.scrollTo({top:m.scrollHeight,behavior:'smooth'});}
function setConn(state){document.getElementById('conn-dot').className=state;}
function esc(s){return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
function toast(msg,type=''){
  const el=document.getElementById('toast');el.textContent=msg;el.className=type;el.style.display='block';
  clearTimeout(el._t);el._t=setTimeout(()=>el.style.display='none',2600);
}
const ta=document.getElementById('msg-input');
function resize(el){el.style.height='auto';el.style.height=Math.min(el.scrollHeight,130)+'px';}
ta.addEventListener('input',()=>resize(ta));
ta.addEventListener('keydown',e=>{if(e.key==='Enter'&&!e.shiftKey){e.preventDefault();sendMessage();}});
window.addEventListener('beforeunload',()=>navigator.sendBeacon('/api/session/'+SID));

setupDrop();
init();
</script>
</body>
</html>`;
