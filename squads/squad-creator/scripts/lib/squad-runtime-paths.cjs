#!/usr/bin/env node
/**
 * Shared runtime path resolver for Squad Creator Base/Pro.
 *
 * Canonical runtime root:
 *   .aiox/squad-runtime
 *
 * Optional override:
 *   AIOX_RUNTIME_ROOT
 */

const fs = require('fs');
const path = require('path');

const WORKSPACE_ROOT = path.resolve(__dirname, '..', '..', '..', '..');
const DEFAULT_RUNTIME_ROOT = path.join(WORKSPACE_ROOT, '.aiox', 'squad-runtime');
const DEFAULT_WORKFLOW = 'create-squad';

function toPosix(value) {
  return value.split(path.sep).join('/');
}

function toWorkspaceRelative(targetPath) {
  const relative = path.relative(WORKSPACE_ROOT, targetPath);
  if (!relative) return '.';
  if (relative.startsWith('..') || path.isAbsolute(relative)) {
    return toPosix(path.resolve(targetPath));
  }
  return toPosix(relative);
}

function resolveRuntimeRoot() {
  const override = (process.env.AIOX_RUNTIME_ROOT || '').trim();
  if (!override) return DEFAULT_RUNTIME_ROOT;
  if (path.isAbsolute(override)) return override;
  return path.resolve(WORKSPACE_ROOT, override);
}

function getWorkflowRuntimeRoot(workflow = DEFAULT_WORKFLOW) {
  return path.join(resolveRuntimeRoot(), workflow);
}

function getRuntimeDirForSlug(slug, workflow = DEFAULT_WORKFLOW) {
  return path.join(getWorkflowRuntimeRoot(workflow), slug);
}

function getCanonicalStatePath(slug, workflow = DEFAULT_WORKFLOW) {
  return path.join(getRuntimeDirForSlug(slug, workflow), 'state.json');
}

function getCanonicalActiveSquadPath() {
  return path.join(resolveRuntimeRoot(), 'active-squad.json');
}

function getLegacyActiveSquadPath() {
  return path.join(WORKSPACE_ROOT, 'outputs', 'squad-creator', 'active-squad.json');
}

function getLegacyStatePath(slug, workflow = DEFAULT_WORKFLOW) {
  return path.join(WORKSPACE_ROOT, 'outputs', 'squad-creator', workflow, slug, 'state.json');
}

function readJsonFile(filePath) {
  try {
    if (!fs.existsSync(filePath)) return null;
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch {
    return { __corrupted: true, __path: filePath };
  }
}

function ensureParentDir(filePath) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
}

function readActiveSquadRecord() {
  const canonicalPath = getCanonicalActiveSquadPath();
  const canonical = readJsonFile(canonicalPath);

  if (canonical && !canonical.__corrupted) {
    if (typeof canonical === 'string' && canonical.trim()) {
      return {
        slug: canonical.trim(),
        workflow: DEFAULT_WORKFLOW,
        source: 'canonical-string',
      };
    }

    if (typeof canonical.slug === 'string' && canonical.slug.trim()) {
      return {
        ...canonical,
        slug: canonical.slug.trim(),
        source: canonical.source || 'canonical',
      };
    }
  }

  // Legacy fallback
  const legacyPath = getLegacyActiveSquadPath();
  const legacy = readJsonFile(legacyPath);
  if (legacy && !legacy.__corrupted) {
    if (typeof legacy === 'string' && legacy.trim()) {
      return { slug: legacy.trim(), workflow: DEFAULT_WORKFLOW, source: 'legacy-string' };
    }
    if (typeof legacy.slug === 'string' && legacy.slug.trim()) {
      return { ...legacy, slug: legacy.slug.trim(), source: 'legacy' };
    }
  }

  return null;
}

function readActiveSquad() {
  const record = readActiveSquadRecord();
  return record ? record.slug : null;
}

function writeActiveSquad(slug, workflow = DEFAULT_WORKFLOW, extra = {}) {
  const activePath = getCanonicalActiveSquadPath();
  ensureParentDir(activePath);
  const payload = {
    slug,
    workflow,
    updated_at: new Date().toISOString(),
    ...extra,
  };
  fs.writeFileSync(activePath, JSON.stringify(payload, null, 2));
  return activePath;
}

function readStateWithLegacyFallback(slug, options = {}) {
  const { workflow = DEFAULT_WORKFLOW } = options;
  const canonicalPath = getCanonicalStatePath(slug, workflow);
  const canonical = readJsonFile(canonicalPath);

  if (canonical && !canonical.__corrupted) {
    return {
      state: canonical,
      source: 'canonical',
      path: canonicalPath,
      migrated: false,
    };
  }

  // Legacy fallback
  const legacyPath = getLegacyStatePath(slug, workflow);
  const legacy = readJsonFile(legacyPath);
  if (legacy && !legacy.__corrupted) {
    return {
      state: legacy,
      source: 'legacy',
      path: legacyPath,
      migrated: false,
    };
  }

  return {
    state: null,
    source: null,
    path: canonicalPath,
    migrated: false,
  };
}

function writeCanonicalState(slug, state, workflow = DEFAULT_WORKFLOW) {
  const statePath = getCanonicalStatePath(slug, workflow);
  ensureParentDir(statePath);
  fs.writeFileSync(statePath, JSON.stringify(state, null, 2));
  return statePath;
}

module.exports = {
  DEFAULT_WORKFLOW,
  WORKSPACE_ROOT,
  resolveRuntimeRoot,
  getWorkflowRuntimeRoot,
  getRuntimeDirForSlug,
  getCanonicalStatePath,
  getCanonicalActiveSquadPath,
  readActiveSquadRecord,
  readActiveSquad,
  writeActiveSquad,
  readStateWithLegacyFallback,
  writeCanonicalState,
  toWorkspaceRelative,
  toPosix,
};
