import Anthropic from "@anthropic-ai/sdk";
import { Agent } from "./agents";
import { UploadedFile, buildFileContentBlock } from "./files";

const MODEL = "claude-opus-4-6";

export interface ChatMessage {
  role: "user" | "assistant";
  content: Anthropic.MessageParam["content"];
}

export class ChatSession {
  private client: Anthropic;
  private agent: Agent;
  private history: ChatMessage[] = [];

  constructor(client: Anthropic, agent: Agent) {
    this.client = client;
    this.agent = agent;
  }

  getAgent(): Agent {
    return this.agent;
  }

  /** Troca de agente mantendo o histórico da conversa */
  switchAgent(newAgent: Agent): void {
    this.agent = newAgent;
  }

  /** Limpa o histórico (nova conversa) */
  resetHistory(): void {
    this.history = [];
  }

  /**
   * Envia uma mensagem (texto + arquivos opcionais) e retorna
   * a resposta do agente via streaming.
   *
   * @param text - Texto do usuário
   * @param files - Arquivos enviados (já upados na Files API)
   * @param onChunk - Callback chamado a cada token de texto recebido
   */
  async send(
    text: string,
    files: UploadedFile[],
    onChunk: (chunk: string) => void
  ): Promise<string> {
    // Monta o conteúdo da mensagem do usuário
    const userContent: Anthropic.MessageParam["content"] = [];

    // Adiciona blocos de arquivo primeiro
    for (const file of files) {
      userContent.push(buildFileContentBlock(file) as any);
    }

    // Adiciona o texto
    if (text.trim()) {
      userContent.push({ type: "text", text: text.trim() });
    }

    this.history.push({ role: "user", content: userContent });

    // Monta o array de mensagens para a API
    const messages: Anthropic.MessageParam[] = this.history.map((m) => ({
      role: m.role,
      content: m.content,
    }));

    // Streaming com Files API (beta)
    const stream = (this.client.beta.messages as any).stream(
      {
        model: MODEL,
        max_tokens: 8192,
        thinking: { type: "adaptive" },
        system: this.agent.systemPrompt,
        messages,
      },
      { headers: { "anthropic-beta": "files-api-2025-04-14" } }
    );

    let fullText = "";

    for await (const event of stream) {
      if (
        event.type === "content_block_delta" &&
        event.delta?.type === "text_delta"
      ) {
        const chunk: string = event.delta.text;
        fullText += chunk;
        onChunk(chunk);
      }
    }

    // Salva resposta no histórico
    this.history.push({
      role: "assistant",
      content: fullText || "(sem resposta)",
    });

    return fullText;
  }

  historyLength(): number {
    return this.history.length;
  }
}
