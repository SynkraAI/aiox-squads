#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const {
  getCanonicalStatePath,
  toWorkspaceRelative,
} = require('./squad-runtime-paths.cjs');

const WORKFLOW = 'validate-squad';

function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (!arg.startsWith('--')) continue;
    const key = arg.slice(2);
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) {
      out[key] = 'true';
      continue;
    }
    out[key] = next;
    i += 1;
  }
  return out;
}

function toBool(value) {
  if (typeof value !== 'string') return Boolean(value);
  return ['1', 'true', 'yes', 'on'].includes(value.trim().toLowerCase());
}

function readState(filePath) {
  if (!fs.existsSync(filePath)) return null;
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch {
    return null;
  }
}

function writeState(filePath, state) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify(state, null, 2));
}

function ensurePhase(state, phase, now) {
  if (!state.phases) state.phases = {};
  if (!state.phases[phase]) {
    state.phases[phase] = {
      status: 'pending',
      started_at: null,
      completed_at: null,
    };
  }

  if (!state.phase_order) state.phase_order = [];
  if (!state.phase_order.includes(phase)) state.phase_order.push(phase);

  if (!state.phases[phase].started_at) {
    state.phases[phase].started_at = now;
  }
}

function cmdStart(flags) {
  const squad = (flags.squad || '').trim();
  if (!squad) throw new Error('Missing --squad');

  const now = new Date().toISOString();
  const filePath = getCanonicalStatePath(squad, WORKFLOW);
  const existing = readState(filePath);

  const state = existing && typeof existing === 'object'
    ? existing
    : {
      workflow: WORKFLOW,
      squad_name: squad,
      created_at: now,
      phases: {},
      phase_order: [],
    };

  state.workflow = WORKFLOW;
  state.squad_name = squad;
  state.status = 'in_progress';
  state.current_phase = 'init';
  state.updated_at = now;
  state.started_at = state.started_at || now;
  state.completed_at = null;
  state.result = null;
  state.final_score = null;
  state.exit_code = null;
  state.error = null;
  state.phases = {};
  state.phase_order = [];
  state.summary = null;

  state.options = {
    mode: flags.mode || state.options?.mode || 'hybrid',
    model: flags.model || state.options?.model || 'opus',
    quick: toBool(flags.quick ?? String(state.options?.quick ?? false)),
    verbose: toBool(flags.verbose ?? String(state.options?.verbose ?? false)),
    json: toBool(flags.json ?? String(state.options?.json ?? false)),
  };

  writeState(filePath, state);

  console.log(JSON.stringify({
    success: true,
    action: 'start',
    state_file: toWorkspaceRelative(filePath),
  }));
}

function cmdPhase(flags) {
  const squad = (flags.squad || '').trim();
  const phase = (flags.phase || '').trim();
  const status = (flags.status || '').trim();

  if (!squad) throw new Error('Missing --squad');
  if (!phase) throw new Error('Missing --phase');
  if (!status) throw new Error('Missing --status');

  const now = new Date().toISOString();
  const filePath = getCanonicalStatePath(squad, WORKFLOW);
  const state = readState(filePath) || {
    workflow: WORKFLOW,
    squad_name: squad,
    created_at: now,
    started_at: now,
    phases: {},
    phase_order: [],
  };

  state.workflow = WORKFLOW;
  state.squad_name = squad;
  state.updated_at = now;
  state.status = status === 'failed' ? 'failed' : 'in_progress';
  state.current_phase = phase;

  ensurePhase(state, phase, now);
  state.phases[phase].status = status;
  if (status === 'completed') {
    state.phases[phase].completed_at = now;
  }

  writeState(filePath, state);

  console.log(JSON.stringify({
    success: true,
    action: 'phase',
    state_file: toWorkspaceRelative(filePath),
  }));
}

function cmdComplete(flags) {
  const squad = (flags.squad || '').trim();
  if (!squad) throw new Error('Missing --squad');

  const now = new Date().toISOString();
  const filePath = getCanonicalStatePath(squad, WORKFLOW);
  const state = readState(filePath) || {
    workflow: WORKFLOW,
    squad_name: squad,
    created_at: now,
    started_at: now,
    phases: {},
    phase_order: [],
  };

  state.workflow = WORKFLOW;
  state.squad_name = squad;
  state.updated_at = now;
  state.completed_at = now;
  state.current_phase = (flags.phase || '').trim() || 'phase_7_final_scoring';
  state.status = (flags.status || '').trim() || 'completed';
  state.result = (flags.result || '').trim() || null;
  state.final_score = Number.isFinite(Number(flags['final-score']))
    ? Number(flags['final-score'])
    : null;
  state.exit_code = Number.isFinite(Number(flags['exit-code']))
    ? Number(flags['exit-code'])
    : null;

  state.summary = {
    warnings: Number.isFinite(Number(flags.warnings)) ? Number(flags.warnings) : 0,
    tier1_fail: Number.isFinite(Number(flags['tier1-fail'])) ? Number(flags['tier1-fail']) : 0,
    security_fail: Number.isFinite(Number(flags['security-fail'])) ? Number(flags['security-fail']) : 0,
    workflow_contract_fail: Number.isFinite(Number(flags['workflow-contract-fail']))
      ? Number(flags['workflow-contract-fail'])
      : 0,
    xref_fail: Number.isFinite(Number(flags['xref-fail'])) ? Number(flags['xref-fail']) : 0,
  };

  if (flags.message) {
    state.error = String(flags.message);
  }

  ensurePhase(state, state.current_phase, now);
  state.phases[state.current_phase].status = state.status === 'failed' ? 'failed' : 'completed';
  state.phases[state.current_phase].completed_at = now;

  writeState(filePath, state);

  console.log(JSON.stringify({
    success: true,
    action: 'complete',
    state_file: toWorkspaceRelative(filePath),
  }));
}

function main() {
  const [command, ...rest] = process.argv.slice(2);
  const flags = parseArgs(rest);

  if (!command || ['--help', '-h'].includes(command)) {
    console.log([
      'Usage:',
      '  node validate-runtime-state.cjs start --squad <name> [--mode hybrid|quick] [--model opus|haiku] [--quick true|false] [--verbose true|false] [--json true|false]',
      '  node validate-runtime-state.cjs phase --squad <name> --phase <phase_id> --status in_progress|completed|failed',
      '  node validate-runtime-state.cjs complete --squad <name> --status completed|failed --result PASS|FAIL|CONDITIONAL --final-score <0-10> --exit-code <int> [--phase phase_7_final_scoring]',
    ].join('\n'));
    process.exit(0);
  }

  if (command === 'start') {
    cmdStart(flags);
    return;
  }

  if (command === 'phase') {
    cmdPhase(flags);
    return;
  }

  if (command === 'complete') {
    cmdComplete(flags);
    return;
  }

  throw new Error(`Unknown command: ${command}`);
}

try {
  main();
} catch (error) {
  console.error(JSON.stringify({
    success: false,
    error: error.message,
  }));
  process.exit(1);
}
