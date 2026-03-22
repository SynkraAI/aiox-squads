-- =============================================================================
-- AIOX Squads — Schema inicial do banco de dados
-- PostgreSQL 16 + pgvector
-- =============================================================================

-- Habilitar extensões
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";      -- pgvector: busca semântica
CREATE EXTENSION IF NOT EXISTS "pg_trgm";     -- busca por texto similar

-- =============================================================================
-- DEMANDAS (processos judiciais da carteira)
-- =============================================================================
CREATE TABLE IF NOT EXISTS demands (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          TEXT NOT NULL,                  -- ex: "Execução Compulsória Extrajudicial"
  process_number TEXT,                          -- número CNJ
  folder_path   TEXT,                           -- caminho local (K:\Meu Drive\...)
  parties       JSONB DEFAULT '{}',             -- {autor, reu, advogados}
  court         TEXT,                           -- tribunal
  status        TEXT DEFAULT 'active',          -- active | archived | closed
  metadata      JSONB DEFAULT '{}',             -- dados extras flexíveis
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SESSÕES (cada conversa com um agente)
-- =============================================================================
CREATE TABLE IF NOT EXISTS sessions (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  demand_id     UUID REFERENCES demands(id) ON DELETE SET NULL,
  agent_id      TEXT NOT NULL,                  -- ex: "analista-processual"
  agent_name    TEXT NOT NULL,
  squad_id      TEXT NOT NULL,                  -- ex: "analista-processual"
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  last_active   TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- MENSAGENS (histórico de conversas — memória de longo prazo)
-- =============================================================================
CREATE TABLE IF NOT EXISTS messages (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id    UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  role          TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content       TEXT NOT NULL,
  tokens_used   INT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_session ON messages(session_id, created_at);

-- =============================================================================
-- ARQUIVOS (documentos enviados ao agente)
-- =============================================================================
CREATE TABLE IF NOT EXISTS files (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id    UUID REFERENCES sessions(id) ON DELETE SET NULL,
  demand_id     UUID REFERENCES demands(id) ON DELETE SET NULL,
  filename      TEXT NOT NULL,
  file_id_api   TEXT,                           -- ID retornado pela Anthropic Files API
  mime_type     TEXT,
  size_kb       NUMERIC(10,2),
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- BIBLIOTECA DE CONHECIMENTO (memória semântica)
-- =============================================================================
CREATE TABLE IF NOT EXISTS knowledge_items (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  demand_id     UUID REFERENCES demands(id) ON DELETE SET NULL,
  area          TEXT,                           -- ex: "02_Direito_Processual_Civil"
  title         TEXT NOT NULL,
  content       TEXT NOT NULL,
  source        TEXT,                           -- nome do arquivo original
  tags          TEXT[] DEFAULT '{}',
  embedding     vector(1536),                   -- embedding para busca semântica
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Índice HNSW para busca por similaridade (melhor performance em produção)
CREATE INDEX IF NOT EXISTS idx_knowledge_embedding
  ON knowledge_items USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- Índice de texto completo
CREATE INDEX IF NOT EXISTS idx_knowledge_content_fts
  ON knowledge_items USING gin(to_tsvector('portuguese', title || ' ' || content));

-- =============================================================================
-- CONTEXTO ATIVO (estado da sessão — substituído pelo Redis, mas mantido como fallback)
-- =============================================================================
CREATE TABLE IF NOT EXISTS active_context (
  session_id    TEXT PRIMARY KEY,               -- ID de sessão do browser
  demand_id     UUID REFERENCES demands(id) ON DELETE SET NULL,
  agent_id      TEXT,
  data          JSONB DEFAULT '{}',             -- contexto adicional
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- PRAZOS (calculados e salvos pelos agentes)
-- =============================================================================
CREATE TABLE IF NOT EXISTS deadlines (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  demand_id     UUID NOT NULL REFERENCES demands(id) ON DELETE CASCADE,
  description   TEXT NOT NULL,
  deadline_date DATE NOT NULL,
  priority      TEXT DEFAULT 'normal' CHECK (priority IN ('critical', 'high', 'normal', 'low')),
  status        TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'done', 'expired')),
  legal_basis   TEXT,                           -- ex: "Art. 335 CPC/2015"
  notes         TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_deadlines_demand ON deadlines(demand_id, deadline_date);
CREATE INDEX IF NOT EXISTS idx_deadlines_upcoming ON deadlines(deadline_date) WHERE status = 'pending';

-- =============================================================================
-- Trigger: atualizar updated_at automaticamente
-- =============================================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_demands_updated
  BEFORE UPDATE ON demands
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_knowledge_updated
  BEFORE UPDATE ON knowledge_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- =============================================================================
-- Dados iniciais
-- =============================================================================
INSERT INTO demands (name, status, metadata)
VALUES ('Demanda de Exemplo', 'active', '{"note": "Criada automaticamente na inicialização"}')
ON CONFLICT DO NOTHING;
