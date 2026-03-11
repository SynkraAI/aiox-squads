import Anthropic, { toFile } from "@anthropic-ai/sdk";
import fs from "fs";
import path from "path";

const SUPPORTED_MIME: Record<string, string> = {
  ".pdf": "application/pdf",
  ".txt": "text/plain",
  ".md": "text/plain",
  ".json": "application/json",
  ".csv": "text/csv",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".webp": "image/webp",
  ".gif": "image/gif",
};

export interface UploadedFile {
  fileId: string;
  filename: string;
  mimeType: string;
  sizeBytes: number;
}

/** Faz upload de um arquivo local para a Files API e retorna o file_id */
export async function uploadFile(
  client: Anthropic,
  filePath: string
): Promise<UploadedFile> {
  const absolutePath = path.resolve(filePath);
  if (!fs.existsSync(absolutePath)) {
    throw new Error(`Arquivo não encontrado: ${absolutePath}`);
  }

  const ext = path.extname(absolutePath).toLowerCase();
  const mimeType = SUPPORTED_MIME[ext] ?? "application/octet-stream";
  const filename = path.basename(absolutePath);
  const stats = fs.statSync(absolutePath);

  const fileStream = fs.createReadStream(absolutePath);
  const uploadedFile = await toFile(fileStream, filename, { type: mimeType });

  const result = await (client.beta.files as any).upload(
    { file: uploadedFile },
    { headers: { "anthropic-beta": "files-api-2025-04-14" } }
  );

  return {
    fileId: result.id,
    filename,
    mimeType,
    sizeBytes: stats.size,
  };
}

/** Cria um bloco de conteúdo para a mensagem com base no tipo do arquivo */
export function buildFileContentBlock(
  uploaded: UploadedFile
): Anthropic.Beta.BetaContentBlockParam {
  if (uploaded.mimeType.startsWith("image/")) {
    return {
      type: "image",
      source: { type: "file", file_id: uploaded.fileId } as any,
    } as any;
  }
  // PDF, text, CSV, JSON → document
  return {
    type: "document",
    source: { type: "file", file_id: uploaded.fileId } as any,
    title: uploaded.filename,
  } as any;
}

/** Deleta um arquivo da Files API */
export async function deleteFile(
  client: Anthropic,
  fileId: string
): Promise<void> {
  await (client.beta.files as any).delete(fileId, {
    headers: { "anthropic-beta": "files-api-2025-04-14" },
  });
}

/** Lista extensões suportadas */
export function supportedExtensions(): string[] {
  return Object.keys(SUPPORTED_MIME);
}
