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

// ── HTML UI (embutido) ─────────────────────────────────────────────────────────
// ── HTML UI mobile-first (embutido) ───────────────────────────────────────────
const HTML_UI = `<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover"/>
<meta name="apple-mobile-web-app-capable" content="yes"/>
<meta name="theme-color" content="#161b22"/>
<title>AIOX Squads</title>
<style>
:root{
  --bg:#0d1117;--bg2:#161b22;--bg3:#21262d;--border:#30363d;
  --text:#e6edf3;--dim:#8b949e;--accent:#58a6ff;--green:#3fb950;
  --yellow:#d29922;--red:#f85149;--user-bg:#1f3a5f;--agent-bg:#1a2433;
  --r:12px;--font:'Segoe UI',system-ui,sans-serif;
  --safe-bottom:env(safe-area-inset-bottom,0px);
  --safe-top:env(safe-area-inset-top,0px);
}
*{box-sizing:border-box;margin:0;padding:0;-webkit-tap-highlight-color:transparent;}
html,body{height:100%;overflow:hidden;}
body{background:var(--bg);color:var(--text);font-family:var(--font);
  display:flex;flex-direction:column;overscroll-behavior:none;}

/* ── Header ── */
header{background:var(--bg2);border-bottom:1px solid var(--border);
  padding:10px 14px;display:flex;align-items:center;gap:10px;flex-shrink:0;
  padding-top:calc(10px + var(--safe-top));}
#menu-btn{background:none;border:none;color:var(--dim);font-size:22px;
  cursor:pointer;padding:4px 6px;border-radius:8px;line-height:1;flex-shrink:0;}
#menu-btn:hover{background:var(--bg3);color:var(--text);}
header h1{font-size:15px;font-weight:700;color:var(--accent);letter-spacing:-.3px;}
#agent-pill{font-size:12px;font-weight:600;background:rgba(88,166,255,.15);
  color:var(--accent);padding:3px 10px;border-radius:20px;
  border:1px solid rgba(88,166,255,.3);white-space:nowrap;overflow:hidden;
  text-overflow:ellipsis;max-width:140px;}
.hdr-spacer{flex:1;}
#hdr-badge{font-size:11px;color:var(--dim);white-space:nowrap;}

/* ── Overlay ── */
#overlay{position:fixed;inset:0;background:rgba(0,0,0,.55);z-index:40;
  display:none;transition:opacity .2s;}
#overlay.show{display:block;}

/* ── Drawer ── */
#drawer{position:fixed;top:0;left:0;bottom:0;width:min(300px,85vw);
  background:var(--bg2);border-right:1px solid var(--border);
  z-index:50;transform:translateX(-100%);transition:transform .25s ease;
  display:flex;flex-direction:column;overflow:hidden;
  padding-top:var(--safe-top);}
#drawer.open{transform:translateX(0);}
.drawer-header{padding:14px 16px 10px;display:flex;align-items:center;
  justify-content:space-between;border-bottom:1px solid var(--border);flex-shrink:0;}
.drawer-header h2{font-size:13px;font-weight:700;text-transform:uppercase;
  letter-spacing:.6px;color:var(--dim);}
#close-drawer{background:none;border:none;color:var(--dim);font-size:22px;
  cursor:pointer;padding:2px 6px;border-radius:6px;line-height:1;}
#close-drawer:hover{background:var(--bg3);color:var(--text);}
#agent-list{flex:1;overflow-y:auto;padding:6px 0;}
.squad-label{font-size:10px;font-weight:700;text-transform:uppercase;
  letter-spacing:.6px;color:var(--yellow);padding:10px 16px 4px;}
.agent-btn{display:flex;align-items:center;gap:8px;width:100%;text-align:left;
  background:none;border:none;color:var(--text);font:14px var(--font);
  padding:10px 16px;cursor:pointer;transition:background .12s;}
.agent-btn:hover,.agent-btn:active{background:var(--bg3);}
.agent-btn.active{background:rgba(88,166,255,.12);color:var(--accent);
  border-left:3px solid var(--accent);}
.agent-btn.active{padding-left:13px;}
.agent-dot{width:7px;height:7px;border-radius:50%;background:var(--dim);flex-shrink:0;}
.agent-btn.active .agent-dot{background:var(--accent);}
.drawer-footer{padding:12px 16px;border-top:1px solid var(--border);flex-shrink:0;
  padding-bottom:calc(12px + var(--safe-bottom));}
.btn-outline{background:var(--bg3);border:1px solid var(--border);color:var(--dim);
  font:13px var(--font);padding:8px 14px;border-radius:8px;cursor:pointer;
  width:100%;transition:background .12s;}
.btn-outline:hover{background:#2d333b;color:var(--text);}

/* ── Chat area ── */
.chat-area{flex:1;display:flex;flex-direction:column;min-height:0;overflow:hidden;}

/* ── Messages ── */
#messages{flex:1;overflow-y:auto;padding:16px;display:flex;
  flex-direction:column;gap:14px;scroll-behavior:smooth;
  overscroll-behavior:contain;}
.msg{max-width:82%;display:flex;flex-direction:column;gap:3px;}
.msg.user{align-self:flex-end;}
.msg.agent{align-self:flex-start;}
.msg-lbl{font-size:11px;color:var(--dim);padding:0 4px;}
.msg.user .msg-lbl{text-align:right;}
.msg-bbl{padding:10px 14px;border-radius:var(--r);line-height:1.65;
  font-size:14px;white-space:pre-wrap;word-break:break-word;}
.msg.user .msg-bbl{background:var(--user-bg);border-bottom-right-radius:3px;}
.msg.agent .msg-bbl{background:var(--agent-bg);border:1px solid var(--border);
  border-bottom-left-radius:3px;}
.msg-bbl.typing::after{content:'▋';animation:blink .7s infinite;color:var(--accent);}
@keyframes blink{0%,100%{opacity:1}50%{opacity:0}}

/* ── System msg ── */
.sys-msg{text-align:center;font-size:12px;color:var(--dim);padding:2px 0;}

/* ── Welcome ── */
.welcome{flex:1;display:flex;flex-direction:column;align-items:center;
  justify-content:center;text-align:center;padding:32px 20px;gap:10px;color:var(--dim);}
.welcome h2{font-size:20px;font-weight:700;color:var(--text);}
.welcome p{font-size:14px;max-width:320px;line-height:1.5;}
.welcome .hint{font-size:12px;margin-top:4px;}

/* ── File chips ── */
#file-chips{display:flex;flex-wrap:wrap;gap:6px;padding:0 14px 6px;min-height:0;}
.chip{background:rgba(88,166,255,.1);border:1px solid rgba(88,166,255,.25);
  border-radius:20px;padding:4px 10px 4px 8px;font-size:12px;color:var(--accent);
  display:flex;align-items:center;gap:5px;}
.chip button{background:none;border:none;color:var(--dim);cursor:pointer;
  font-size:15px;line-height:1;padding:0;}
.chip button:hover{color:var(--red);}

/* ── Input area ── */
.input-wrap{padding:8px 10px;border-top:1px solid var(--border);background:var(--bg2);
  flex-shrink:0;padding-bottom:calc(8px + var(--safe-bottom));}
.input-row{display:flex;gap:6px;align-items:flex-end;}
#msg-input{flex:1;background:var(--bg3);border:1px solid var(--border);
  border-radius:10px;color:var(--text);font:15px var(--font);padding:11px 13px;
  resize:none;min-height:46px;max-height:140px;outline:none;
  transition:border-color .15s;-webkit-appearance:none;}
#msg-input:focus{border-color:var(--accent);}
#msg-input::placeholder{color:var(--dim);}
.icon-btn{background:none;border:none;cursor:pointer;color:var(--dim);
  font-size:22px;padding:6px;border-radius:8px;height:46px;width:46px;
  display:flex;align-items:center;justify-content:center;flex-shrink:0;
  transition:color .15s,background .15s;}
.icon-btn:hover,.icon-btn:active{color:var(--accent);background:var(--bg3);}
#send-btn{background:var(--accent);color:#0d1117;border:none;border-radius:10px;
  padding:0 16px;height:46px;font:600 15px var(--font);cursor:pointer;
  flex-shrink:0;transition:opacity .15s;white-space:nowrap;}
#send-btn:disabled{opacity:.38;cursor:default;}
#send-btn:not(:disabled):hover{opacity:.85;}
#file-input{display:none;}

/* ── Toast ── */
#toast{position:fixed;bottom:calc(80px + var(--safe-bottom));left:50%;
  transform:translateX(-50%);background:var(--bg3);border:1px solid var(--border);
  border-radius:10px;padding:9px 18px;font-size:13px;display:none;z-index:99;
  white-space:nowrap;box-shadow:0 4px 20px rgba(0,0,0,.5);}
#toast.err{border-color:var(--red);color:var(--red);}
#toast.ok{border-color:var(--green);color:var(--green);}

/* ── Scrollbar ── */
::-webkit-scrollbar{width:5px;}
::-webkit-scrollbar-thumb{background:var(--border);border-radius:3px;}

/* ── Desktop sidebar ── */
@media(min-width:768px){
  #menu-btn{display:none;}
  #agent-pill{max-width:200px;}
  .layout{display:flex;flex:1;min-height:0;overflow:hidden;}
  .chat-area{flex:1;}
  #drawer{position:static;transform:none!important;border-right:1px solid var(--border);
    transition:none;width:260px;}
  #overlay{display:none!important;}
  body{flex-direction:column;}
  .layout{display:flex;flex:1;overflow:hidden;}
}
@media(max-width:767px){
  .msg{max-width:90%;}
}
</style>
</head>
<body>

<header>
  <button id="menu-btn" onclick="toggleDrawer()" aria-label="Menu">☰</button>
  <h1>⬡ AIOX</h1>
  <span id="agent-pill">Selecione →</span>
  <span class="hdr-spacer"></span>
  <span id="hdr-badge">0 msgs</span>
</header>

<div class="layout">
  <!-- Overlay (mobile) -->
  <div id="overlay" onclick="toggleDrawer()"></div>

  <!-- Drawer / Sidebar -->
  <nav id="drawer">
    <div class="drawer-header">
      <h2>Agentes</h2>
      <button id="close-drawer" onclick="toggleDrawer()" aria-label="Fechar">×</button>
    </div>
    <div id="agent-list"></div>
    <div class="drawer-footer">
      <button class="btn-outline" onclick="resetHistory()">🗑  Limpar histórico</button>
    </div>
  </nav>

  <!-- Chat -->
  <div class="chat-area">
    <div id="messages">
      <div class="welcome" id="welcome">
        <h2>AIOX Squads</h2>
        <p>Toque em ☰ para selecionar um agente e começar a conversa.</p>
        <p class="hint">Suporta PDF, imagens, CSV e JSON via 📎.</p>
      </div>
    </div>

    <div id="file-chips"></div>

    <div class="input-wrap">
      <div class="input-row">
        <label for="file-input" class="icon-btn" title="Anexar arquivo">📎</label>
        <input type="file" id="file-input"
          accept=".pdf,.txt,.md,.json,.csv,.png,.jpg,.jpeg,.webp,.gif" multiple/>
        <textarea id="msg-input" placeholder="Mensagem…" rows="1"
          autocomplete="off" autocorrect="on" autocapitalize="sentences"
          spellcheck="true"></textarea>
        <button id="send-btn" onclick="sendMessage()">↑</button>
      </div>
    </div>
  </div>
</div>

<div id="toast"></div>

<script>
const SESSION_ID='sess-'+Math.random().toString(36).slice(2,10);
let activeAgent=null,pendingFiles=[],msgCount=0,streaming=false;

// ── Drawer ────────────────────────────────────────────────────────────────────
function toggleDrawer(){
  const d=document.getElementById('drawer');
  const o=document.getElementById('overlay');
  const open=d.classList.toggle('open');
  o.classList.toggle('show',open);
  if(open)document.body.style.overflow='hidden';
  else document.body.style.overflow='';
}

// ── Init ──────────────────────────────────────────────────────────────────────
async function init(){
  const res=await fetch('/api/agents');
  const squads=await res.json();
  const list=document.getElementById('agent-list');

  squads.forEach(s=>{
    const lbl=document.createElement('div');
    lbl.className='squad-label';
    lbl.textContent=s.id;
    list.appendChild(lbl);

    s.agents.forEach(a=>{
      const btn=document.createElement('button');
      btn.className='agent-btn';
      btn.dataset.id=a.id;
      btn.innerHTML=\`<span class="agent-dot"></span>\${a.name}\`;
      btn.onclick=()=>selectAgent(a.id,a.name,s.id,btn);
      list.appendChild(btn);
    });
  });
}

// ── Selecionar agente ─────────────────────────────────────────────────────────
async function selectAgent(id,name,squad,btn){
  if(streaming)return;
  document.querySelectorAll('.agent-btn').forEach(b=>b.classList.remove('active'));
  btn.classList.add('active');
  document.getElementById('agent-pill').textContent=name;
  document.getElementById('welcome')?.remove();
  activeAgent={id,name};

  await fetch('/api/session/agent',{
    method:'POST',headers:{'Content-Type':'application/json'},
    body:JSON.stringify({sessionId:SESSION_ID,agentId:id})
  });
  appendSys(\`\${name} [\${squad}] ativado\`);

  // Fecha drawer no mobile
  if(window.innerWidth<768)toggleDrawer();
}

// ── Reset ─────────────────────────────────────────────────────────────────────
async function resetHistory(){
  if(!activeAgent)return;
  await fetch('/api/session/reset',{
    method:'POST',headers:{'Content-Type':'application/json'},
    body:JSON.stringify({sessionId:SESSION_ID})
  });
  msgCount=0;badge();
  appendSys('Histórico limpo.');
  if(window.innerWidth<768)toggleDrawer();
}

// ── Upload ────────────────────────────────────────────────────────────────────
document.getElementById('file-input').addEventListener('change',async e=>{
  for(const f of Array.from(e.target.files))await uploadFile(f);
  e.target.value='';
});

async function uploadFile(file){
  toast('Enviando '+file.name+'…');
  const fd=new FormData();
  fd.append('file',file);
  fd.append('sessionId',SESSION_ID);
  if(activeAgent)fd.append('agentId',activeAgent.id);
  try{
    const r=await fetch('/api/upload',{method:'POST',body:fd});
    const d=await r.json();
    if(!r.ok)throw new Error(d.error);
    pendingFiles.push({fileId:d.fileId,filename:d.filename});
    renderChips();
    toast(d.filename+' ('+d.sizeKb+' KB)','ok');
  }catch(e){toast('Erro: '+e.message,'err');}
}

function renderChips(){
  const c=document.getElementById('file-chips');
  c.innerHTML='';
  pendingFiles.forEach((f,i)=>{
    const d=document.createElement('div');
    d.className='chip';
    d.innerHTML=\`📄 \${f.filename} <button onclick="removeFile(\${i})">×</button>\`;
    c.appendChild(d);
  });
}

function removeFile(i){pendingFiles.splice(i,1);renderChips();}

// ── Enviar ────────────────────────────────────────────────────────────────────
async function sendMessage(){
  if(streaming)return;
  if(!activeAgent){toast('Selecione um agente.','err');return;}
  const inp=document.getElementById('msg-input');
  const text=inp.value.trim();
  if(!text)return;
  inp.value='';resize(inp);

  appendMsg('user','Você',text);
  const fids=pendingFiles.map(f=>f.fileId).join(',');
  pendingFiles=[];renderChips();

  const bubble=appendMsg('agent',activeAgent.name,'',true);
  streaming=true;
  document.getElementById('send-btn').disabled=true;

  const url='/api/chat?'+new URLSearchParams({
    sessionId:SESSION_ID,agentId:activeAgent.id,message:text,fileIds:fids
  });
  const es=new EventSource(url);
  let full='';

  es.addEventListener('chunk',e=>{
    full+=JSON.parse(e.data).text;
    bubble.textContent=full;
    scrollBot();
  });
  es.addEventListener('done',()=>{
    es.close();finish(bubble);
    msgCount+=2;badge();
  });
  es.addEventListener('error',e=>{
    es.close();
    if(e.data){bubble.textContent='⚠ '+JSON.parse(e.data).message;bubble.style.color='var(--red)';}
    finish(bubble);
  });
  es.onerror=()=>{if(es.readyState===EventSource.CLOSED)return;es.close();finish(bubble);};
}

function finish(b){
  b.classList.remove('typing');
  streaming=false;
  document.getElementById('send-btn').disabled=false;
  scrollBot();
}

// ── Helpers ───────────────────────────────────────────────────────────────────
function appendMsg(role,label,text,typing=false){
  const m=document.getElementById('messages');
  const d=document.createElement('div');
  d.className='msg '+role;
  const l=document.createElement('div');l.className='msg-lbl';l.textContent=label;
  const b=document.createElement('div');
  b.className='msg-bbl'+(typing?' typing':'');
  b.textContent=text;
  d.appendChild(l);d.appendChild(b);m.appendChild(d);
  scrollBot();return b;
}
function appendSys(t){
  const m=document.getElementById('messages');
  const d=document.createElement('div');d.className='sys-msg';d.textContent='— '+t+' —';
  m.appendChild(d);scrollBot();
}
function scrollBot(){
  const m=document.getElementById('messages');
  m.scrollTo({top:m.scrollHeight,behavior:'smooth'});
}
function badge(){document.getElementById('hdr-badge').textContent=msgCount+' msgs';}
function toast(msg,type=''){
  const el=document.getElementById('toast');
  el.textContent=msg;el.className=type;el.style.display='block';
  clearTimeout(el._t);el._t=setTimeout(()=>{el.style.display='none';},2800);
}

// ── Textarea auto-resize ──────────────────────────────────────────────────────
const ta=document.getElementById('msg-input');
function resize(el){el.style.height='auto';el.style.height=Math.min(el.scrollHeight,140)+'px';}
ta.addEventListener('input',()=>resize(ta));
ta.addEventListener('keydown',e=>{
  if(e.key==='Enter'&&!e.shiftKey&&window.innerWidth>=768){
    e.preventDefault();sendMessage();
  }
});

// ── Swipe-to-close drawer (mobile) ───────────────────────────────────────────
let tx0=null;
document.getElementById('drawer').addEventListener('touchstart',e=>{tx0=e.touches[0].clientX;},{passive:true});
document.getElementById('drawer').addEventListener('touchend',e=>{
  if(tx0===null)return;
  const dx=e.changedTouches[0].clientX-tx0;
  if(dx<-50)toggleDrawer();
  tx0=null;
},{passive:true});

// ── Cleanup ───────────────────────────────────────────────────────────────────
window.addEventListener('beforeunload',()=>{
  navigator.sendBeacon('/api/session/'+SESSION_ID);
});

init();
</script>
</body>
</html>`;
