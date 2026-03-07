#!/usr/bin/env python3
"""
Squad Registry Refresh Script

Deterministic operations for updating the ecosystem registry:
- Scan squads/ directory
- Count components recursively (agents, tasks, workflows, etc.)
- Read canonical config.yaml metadata (fallback: squad.yaml)
- Update registry with factual data

Usage:
    python scripts/refresh-registry.py [--output json|yaml|summary] [--squads-path PATH]
    python scripts/refresh-registry.py --write [--registry-path PATH]
"""

import fnmatch
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional

import yaml

from squad_utils import (
    MATURITY_DEVELOPING,
    MATURITY_DRAFT,
    MATURITY_OPERATIONAL,
    detect_squad_usage,
    resolve_maturity_validated,
)

DEFAULT_SQUAD_VERSION = "0.0.0"
UNKNOWN_VERSION_VALUES = {
    "",
    "unknown",
    "n/a",
    "na",
    "none",
    "null",
    "undefined",
    "-",
}

SKIP_DIRS = {".DS_Store", "__pycache__", "node_modules", ".git", "artifacts"}
EXCLUDED_MARKDOWN = {"readme.md", "template.md", "_template.md"}
REGISTRY_PATH_ENV = "AIOX_ECOSYSTEM_REGISTRY_PATH"
DEFAULT_REGISTRY_REL_PATH = Path(".aiox") / "squad-runtime" / "ecosystem-registry.yaml"

SECTION_PATTERNS = {
    "agents": ["*.md"],
    "tasks": ["*.md"],
    "workflows": ["*.md", "*.yaml", "*.yml"],
    "templates": ["*.md", "*.yaml", "*.yml"],
    "checklists": ["*.md"],
    "data_files": ["*.md", "*.yaml", "*.yml", "*.json"],
}


def get_project_root() -> Path:
    """Get project root (parent of squads/)."""
    script_dir = Path(__file__).parent.parent.parent
    if (script_dir / "squad-creator").exists():
        return script_dir.parent

    cwd = Path.cwd()
    if (cwd / "squads").exists():
        return cwd
    if cwd.name == "squads":
        return cwd.parent

    return cwd


def get_squads_path() -> Path:
    """Get the squads directory path."""
    script_dir = Path(__file__).parent.parent.parent
    if (script_dir / "squad-creator").exists():
        return script_dir

    cwd = Path.cwd()
    if (cwd / "squads").exists():
        return cwd / "squads"
    if cwd.name == "squads":
        return cwd

    raise FileNotFoundError("Could not find squads/ directory")


def _iter_files_recursive(directory: Path) -> Iterable[Path]:
    if not directory.exists() or not directory.is_dir():
        return []

    files: List[Path] = []
    for file in directory.rglob("*"):
        if not file.is_file():
            continue
        relative = file.relative_to(directory)
        if any(part.startswith(".") for part in relative.parts):
            continue
        files.append(file)
    return files


def count_files(directory: Path, patterns: List[str]) -> int:
    """Count files matching patterns recursively in a directory."""
    return count_files_filtered(directory, patterns)


def count_files_filtered(
    directory: Path,
    patterns: List[str],
    exclude_names: Optional[Iterable[str]] = None,
) -> int:
    """Count files recursively, with optional filename exclusions."""
    if not directory.exists() or not directory.is_dir():
        return 0

    excludes = {name.lower() for name in (exclude_names or [])}
    total = 0

    for file in _iter_files_recursive(directory):
        name_lower = file.name.lower()
        if name_lower in excludes:
            continue
        if any(fnmatch.fnmatch(file.name, pattern) for pattern in patterns):
            total += 1

    return total


def has_explicit_version(value: Any) -> bool:
    """True when value is a real version (not unknown/null placeholders)."""
    if value is None:
        return False
    normalized = str(value).strip().lower()
    return normalized not in UNKNOWN_VERSION_VALUES


def normalize_version(value: Any) -> str:
    """Normalize any missing/unknown version to DEFAULT_SQUAD_VERSION."""
    if not has_explicit_version(value):
        return DEFAULT_SQUAD_VERSION
    return str(value).strip()


def extract_config_version(config: Optional[Dict[str, Any]]) -> Any:
    """Extract version from known manifest styles (root, metadata, pack, squad)."""
    if not isinstance(config, dict):
        return None

    metadata = config.get("metadata")
    pack = config.get("pack")
    squad = config.get("squad")

    candidates = [
        config.get("version"),
        metadata.get("version") if isinstance(metadata, dict) else None,
        pack.get("version") if isinstance(pack, dict) else None,
        squad.get("version") if isinstance(squad, dict) else None,
    ]

    for candidate in candidates:
        if has_explicit_version(candidate):
            return candidate
    return candidates[0]


def extract_version_from_raw_yaml(squad_path: Path) -> Any:
    """
    Best-effort textual version extraction when YAML parsing fails.
    Prioritizes root `version:` then nested `version:` occurrences.
    """
    patterns = [
        re.compile(r'^version:\s*["\']?([0-9A-Za-z._-]+)["\']?\s*$', re.MULTILINE),
        re.compile(r'^\s+version:\s*["\']?([0-9A-Za-z._-]+)["\']?\s*$', re.MULTILINE),
    ]

    manifest_file = squad_path / "config.yaml"
    if not manifest_file.exists():
        manifest_file = squad_path / "squad.yaml"  # legacy fallback
    if not manifest_file.exists():
        return None

    try:
        raw = manifest_file.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return None

    for pattern in patterns:
        match = pattern.search(raw)
        if match:
            value = match.group(1)
            if has_explicit_version(value):
                return value

    return None


def _clamp_score(value: float) -> float:
    return max(0.0, min(10.0, value))


def compute_squad_score(counts: Dict[str, int], has_readme: bool, has_version: bool) -> float:
    """Deterministic squad score in 0..10 range."""
    agents = max(0, counts.get("agents", 0))
    tasks = max(0, counts.get("tasks", 0))
    workflows = max(0, counts.get("workflows", 0))
    checklists = max(0, counts.get("checklists", 0))

    score = (
        (min(agents, 5) / 5) * 2.5
        + (min(tasks, 8) / 8) * 2.0
        + (min(workflows, 4) / 4) * 2.0
        + (min(checklists, 4) / 4) * 1.5
        + (1.0 if has_readme else 0.0)
        + (1.0 if has_version else 0.0)
    )

    return round(_clamp_score(score), 1)


def read_config_yaml(squad_path: Path) -> Optional[Dict[str, Any]]:
    """Read and parse canonical squad manifest (config.yaml, fallback squad.yaml)."""
    manifest_file = squad_path / "config.yaml"
    if not manifest_file.exists():
        manifest_file = squad_path / "squad.yaml"  # legacy fallback
    if not manifest_file.exists():
        return None

    try:
        with open(manifest_file, "r", encoding="utf-8") as file:
            parsed = yaml.safe_load(file)
            return parsed if isinstance(parsed, dict) else None
    except Exception as error:
        print(f"Warning: Could not parse {manifest_file}: {error}", file=sys.stderr)
        return None


def list_agents(squad_path: Path) -> List[str]:
    """List all agent identifiers from squad/agents recursively."""
    agents_dir = squad_path / "agents"
    if not agents_dir.exists() or not agents_dir.is_dir():
        return []

    agents: List[str] = []
    for file in sorted(_iter_files_recursive(agents_dir)):
        if file.suffix.lower() != ".md":
            continue
        if file.name.lower() in EXCLUDED_MARKDOWN:
            continue

        relative = file.relative_to(agents_dir).as_posix()
        agents.append(re.sub(r"\.md$", "", relative, flags=re.IGNORECASE))

    return agents


def _extract_manifest_field(config: Optional[Dict[str, Any]], key: str, default: str = "") -> str:
    if not isinstance(config, dict):
        return default

    candidates = [
        config.get(key),
        (config.get("metadata") or {}).get(key) if isinstance(config.get("metadata"), dict) else None,
        (config.get("squad") or {}).get(key) if isinstance(config.get("squad"), dict) else None,
    ]

    for candidate in candidates:
        if isinstance(candidate, str) and candidate.strip():
            return candidate.strip()

    return default


def _count_components(squad_path: Path) -> Dict[str, int]:
    return {
        "agents": count_files_filtered(squad_path / "agents", SECTION_PATTERNS["agents"], EXCLUDED_MARKDOWN),
        "tasks": count_files_filtered(squad_path / "tasks", SECTION_PATTERNS["tasks"], EXCLUDED_MARKDOWN),
        "workflows": count_files_filtered(
            squad_path / "workflows",
            SECTION_PATTERNS["workflows"],
            EXCLUDED_MARKDOWN,
        ),
        "templates": count_files_filtered(
            squad_path / "templates",
            SECTION_PATTERNS["templates"],
            EXCLUDED_MARKDOWN,
        ),
        "checklists": count_files_filtered(
            squad_path / "checklists",
            SECTION_PATTERNS["checklists"],
            EXCLUDED_MARKDOWN,
        ),
        "data_files": count_files_filtered(
            squad_path / "data",
            SECTION_PATTERNS["data_files"],
            EXCLUDED_MARKDOWN,
        ),
    }


def scan_squad(
    squad_path: Path,
    project_root: Optional[Path] = None,
    existing_validated: bool = False,
    validated_explicit: bool = False,
) -> Dict[str, Any]:
    """Scan a single squad and extract deterministic data."""
    squad_name = squad_path.name

    manifest = read_config_yaml(squad_path)
    raw_version = extract_config_version(manifest)
    if not has_explicit_version(raw_version):
        raw_version = extract_version_from_raw_yaml(squad_path)

    counts = _count_components(squad_path)
    agent_names = list_agents(squad_path)

    has_readme = (squad_path / "README.md").exists()
    has_changelog = (squad_path / "CHANGELOG.md").exists()
    has_version = has_explicit_version(raw_version)
    version = normalize_version(raw_version)
    score = compute_squad_score(counts, has_readme, has_version)

    if project_root is None:
        project_root = squad_path.parent.parent
    usage_signals = detect_squad_usage(squad_name, project_root)

    maturity_result = resolve_maturity_validated(
        counts=counts,
        usage_signals=usage_signals,
        existing_validated=bool(existing_validated),
        validated_explicit=bool(validated_explicit),
    )

    result = {
        "name": squad_name,
        "path": f"squads/{squad_name}/",
        "has_config": manifest is not None,
        "config": {
            "name": _extract_manifest_field(manifest, "name", squad_name),
            "version": version,
            "short_title": _extract_manifest_field(manifest, "short-title"),
            "description": _extract_manifest_field(manifest, "description"),
            "slashPrefix": _extract_manifest_field(manifest, "slashPrefix"),
        },
        "counts": counts,
        "agent_names": agent_names,
        "has_readme": has_readme,
        "has_changelog": has_changelog,
        "has_explicit_version": has_version,
        "score": score,
        "total_components": sum(counts.values()),
        "maturity": maturity_result["maturity"],
        "validated": maturity_result["validated"],
        "validated_explicit": bool(validated_explicit),
        "auto_promoted": maturity_result["auto_promoted"],
        "usage_signals": usage_signals,
    }

    return result


def _resolve_existing_validation(entry: Dict[str, Any]) -> Dict[str, bool]:
    validated = bool(entry.get("validated", False))

    if "validated_explicit" in entry:
        explicit = bool(entry.get("validated_explicit"))
    else:
        # Backward compatibility: legacy validated=true should stay explicit.
        explicit = validated

    return {
        "validated": validated,
        "validated_explicit": explicit,
    }


def scan_all_squads(squads_path: Path, existing_registry: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Scan all squads in the squads/ directory."""
    project_root = squads_path.parent

    results: Dict[str, Any] = {
        "metadata": {
            "scan_date": datetime.now().isoformat(),
            "squads_path": str(squads_path),
            "total_squads": 0,
        },
        "squads": {},
        "summary": {
            "total_agents": 0,
            "total_tasks": 0,
            "total_workflows": 0,
            "total_templates": 0,
            "total_checklists": 0,
            "total_data_files": 0,
        },
        "maturity_summary": {
            MATURITY_DRAFT: 0,
            MATURITY_DEVELOPING: 0,
            MATURITY_OPERATIONAL: 0,
        },
    }

    existing_squads = {}
    if isinstance(existing_registry, dict):
        existing_squads = existing_registry.get("squads", {}) or {}

    for item in sorted(squads_path.iterdir()):
        if not item.is_dir():
            continue
        if item.name in SKIP_DIRS or item.name.startswith("."):
            continue
        if not (item / "config.yaml").exists() and not (item / "squad.yaml").exists():
            continue

        existing_entry = existing_squads.get(item.name, {})
        if not isinstance(existing_entry, dict):
            existing_entry = {}

        validation_state = _resolve_existing_validation(existing_entry)

        squad_data = scan_squad(
            item,
            project_root,
            existing_validated=validation_state["validated"],
            validated_explicit=validation_state["validated_explicit"],
        )
        results["squads"][item.name] = squad_data

        results["summary"]["total_agents"] += squad_data["counts"]["agents"]
        results["summary"]["total_tasks"] += squad_data["counts"]["tasks"]
        results["summary"]["total_workflows"] += squad_data["counts"]["workflows"]
        results["summary"]["total_templates"] += squad_data["counts"]["templates"]
        results["summary"]["total_checklists"] += squad_data["counts"]["checklists"]
        results["summary"]["total_data_files"] += squad_data["counts"]["data_files"]

        maturity = squad_data.get("maturity", MATURITY_DEVELOPING)
        results["maturity_summary"][maturity] = results["maturity_summary"].get(maturity, 0) + 1

    results["metadata"]["total_squads"] = len(results["squads"])
    return results


def _normalize_validation_consistency(entry: Dict[str, Any]) -> None:
    validated = bool(entry.get("validated", False))
    validated_explicit = bool(entry.get("validated_explicit", False))
    maturity = entry.get("maturity", MATURITY_DEVELOPING)

    if validated:
        entry["validated"] = True
        entry["maturity"] = MATURITY_OPERATIONAL
        if validated_explicit:
            entry["auto_promoted"] = False
        return

    entry["validated"] = False
    if validated_explicit and maturity == MATURITY_OPERATIONAL:
        entry["maturity"] = MATURITY_DEVELOPING
        entry["auto_promoted"] = False
        return

    if not validated_explicit and maturity == MATURITY_OPERATIONAL:
        entry["validated"] = True
        entry["auto_promoted"] = True


def format_for_registry(scan_results: Dict[str, Any]) -> Dict[str, Any]:
    """Format scan results for ecosystem-registry.yaml structure."""
    stopwords = {
        "squad", "de", "da", "do", "dos", "das", "para", "com", "and", "the",
        "use", "using", "specialized", "especializado", "especializada", "team",
        "agent", "agents", "workflow", "workflows", "tasks", "task", "design",
    }

    def tokenize(text: str) -> List[str]:
        if not text:
            return []
        tokens = re.findall(r"[a-z0-9][a-z0-9-]{1,}", text.lower())
        return [token for token in tokens if token not in stopwords and len(token) > 2]

    def infer_domain(name: str, description: str) -> str:
        haystack = f"{name} {description}".lower()
        domain_rules = [
            ("design-system", ["design system", "tokens", "components", "wcag", "a11y"]),
            ("brand", ["brand", "logo", "positioning", "naming"]),
            ("content-visual", ["thumbnail", "youtube", "photo", "video", "lighting"]),
            ("database", ["database", "sql", "supabase", "migration", "rls"]),
            ("content", ["content", "blog", "course", "seo", "funnel"]),
            ("research", ["research", "analysis", "discovery"]),
        ]
        for domain, patterns in domain_rules:
            if any(pattern in haystack for pattern in patterns):
                return domain
        return name.replace("_", "-")

    def infer_keywords(name: str, entry: Dict[str, Any]) -> List[str]:
        keywords: List[str] = []
        keywords.extend(tokenize(name.replace("-", " ")))
        keywords.extend(tokenize(entry.get("description", "")))
        keywords.extend(tokenize(entry.get("slashPrefix", "")))
        for agent in entry.get("agent_names", []):
            keywords.extend(tokenize(agent.replace("-", " ")))

        seen = set()
        ordered: List[str] = []
        for keyword in keywords:
            if keyword in seen:
                continue
            seen.add(keyword)
            ordered.append(keyword)
            if len(ordered) >= 12:
                break
        return ordered

    def infer_highlights(entry: Dict[str, Any]) -> List[str]:
        counts = entry.get("counts", {})
        highlights = [f"{counts.get('agents', 0)} agents, {counts.get('tasks', 0)} tasks"]
        if counts.get("workflows", 0) > 0:
            highlights.append(f"{counts.get('workflows', 0)} workflows available")
        if entry.get("has_readme"):
            highlights.append("README documented")
        if entry.get("slashPrefix"):
            highlights.append(f"Command prefix /{entry.get('slashPrefix')}")
        return highlights[:4]

    def infer_example_use(name: str, entry: Dict[str, Any], domain: str) -> str:
        prefix = entry.get("slashPrefix", "")
        if prefix:
            return f"Use /{prefix} to execute {domain} workflows in {name}."
        return f"Use {name} for {domain} tasks."

    registry = {
        "metadata": {
            "version": "1.3.0",
            "last_updated": datetime.now().strftime("%Y-%m-%d"),
            "total_squads": scan_results["metadata"]["total_squads"],
            "maintainer": "squad-creator",
            "generated_by": "scripts/refresh-registry.py",
        },
        "squads": {},
        "domain_index": {},
        "summary": scan_results["summary"],
        "maturity_summary": scan_results.get("maturity_summary", {}),
    }

    for name, data in scan_results.get("squads", {}).items():
        domain = infer_domain(name, data["config"].get("description", ""))
        keywords = infer_keywords(
            name,
            {
                "description": data["config"].get("description", ""),
                "slashPrefix": data["config"].get("slashPrefix", ""),
                "agent_names": data.get("agent_names", []),
            },
        )

        entry = {
            "path": data["path"],
            "version": data["config"]["version"],
            "score": data.get("score", 0.0),
            "maturity": data.get("maturity", MATURITY_DEVELOPING),
            "validated": bool(data.get("validated", False)),
            "validated_explicit": bool(data.get("validated_explicit", False)),
            "auto_promoted": bool(data.get("auto_promoted", False)),
            "description": data["config"].get("description", ""),
            "slashPrefix": data["config"].get("slashPrefix", ""),
            "counts": data.get("counts", {}),
            "agent_names": data.get("agent_names", []),
            "has_readme": bool(data.get("has_readme", False)),
            "has_changelog": bool(data.get("has_changelog", False)),
            "domain": domain,
            "keywords": keywords,
            "highlights": infer_highlights(
                {
                    "counts": data.get("counts", {}),
                    "has_readme": data.get("has_readme", False),
                    "slashPrefix": data["config"].get("slashPrefix", ""),
                }
            ),
            "example_use": infer_example_use(
                name,
                {"slashPrefix": data["config"].get("slashPrefix", "")},
                domain,
            ),
        }

        _normalize_validation_consistency(entry)
        registry["squads"][name] = entry

        for term in [domain] + keywords:
            bucket = registry["domain_index"].setdefault(term, [])
            if name not in bucket:
                bucket.append(name)

    return registry


def get_registry_path(squads_path: Path, registry_path: Optional[Path] = None) -> Path:
    """Resolve ecosystem registry path from CLI arg, env var, or default output path."""
    project_root = squads_path.parent if squads_path.name == "squads" else get_project_root()

    if registry_path is not None:
        expanded = registry_path.expanduser()
        return expanded if expanded.is_absolute() else (project_root / expanded)

    env_registry_path = os.getenv(REGISTRY_PATH_ENV, "").strip()
    if env_registry_path:
        env_path = Path(env_registry_path).expanduser()
        return env_path if env_path.is_absolute() else (project_root / env_path)

    return project_root / DEFAULT_REGISTRY_REL_PATH


def load_existing_registry(registry_path: Path) -> Optional[Dict[str, Any]]:
    """Load existing registry for merge/preserve."""
    if not registry_path.exists():
        return None
    try:
        with open(registry_path, "r", encoding="utf-8") as file:
            parsed = yaml.safe_load(file)
            return parsed if isinstance(parsed, dict) else None
    except Exception as error:
        print(f"Warning: Could not load existing registry: {error}", file=sys.stderr)
        return None


# Merge policy contract (field-by-field):
# - always_preserve: keep existing manual enrichment whenever present.
# - preserve_if_fresh_empty: only keep existing value when fresh scan has no value.
#
# For semantic drift control, description/highlights are fresh-preferred. This avoids
# reintroducing stale text after deterministic refresh updates counts/version metadata.
MERGE_POLICY = {
    "description": "preserve_if_fresh_empty",
    "domain": "always_preserve",
    "keywords": "always_preserve",
    "highlights": "preserve_if_fresh_empty",
    "example_use": "always_preserve",
    "quality_score": "always_preserve",
}


def _should_preserve_manual_value(value: Any) -> bool:
    if value is None:
        return False
    if isinstance(value, str):
        return bool(value.strip())
    if isinstance(value, (list, dict, set, tuple)):
        return len(value) > 0
    return True


def _is_empty_value(value: Any) -> bool:
    if value is None:
        return True
    if isinstance(value, str):
        return not value.strip()
    if isinstance(value, (list, dict, set, tuple)):
        return len(value) == 0
    return False


def _should_preserve_field(
    squad_name: str,
    field: str,
    policy: str,
    fresh_value: Any,
    old_value: Any,
) -> bool:
    if not _should_preserve_manual_value(old_value):
        return False

    # SC-HARD-04 guardrail: squad-creator semantic text is always rebuilt from fresh scan.
    if squad_name == "squad-creator" and field in {"description", "highlights"}:
        return False

    if policy == "always_preserve":
        return True
    if policy == "preserve_if_fresh_empty":
        return _is_empty_value(fresh_value)

    return False


def merge_with_existing(fresh: Dict[str, Any], existing: Optional[Dict[str, Any]]) -> Dict[str, Any]:
    """Merge fresh scan with existing registry preserving manual enrichments."""
    if not isinstance(existing, dict):
        return fresh

    existing_squads = existing.get("squads", {})
    if not isinstance(existing_squads, dict):
        existing_squads = {}

    for squad_name, fresh_entry in fresh.get("squads", {}).items():
        old_entry = existing_squads.get(squad_name)
        if not isinstance(old_entry, dict):
            continue

        for field, policy in MERGE_POLICY.items():
            if field not in old_entry:
                continue
            old_value = old_entry.get(field)
            fresh_value = fresh_entry.get(field)
            if _should_preserve_field(squad_name, field, policy, fresh_value, old_value):
                fresh_entry[field] = old_value

        # Manual validation rule: explicit manual values win.
        if "validated_explicit" in old_entry:
            fresh_entry["validated_explicit"] = bool(old_entry.get("validated_explicit"))
            if "validated" in old_entry:
                fresh_entry["validated"] = bool(old_entry.get("validated"))
        elif old_entry.get("validated") is True:
            # Backward compatibility with old registries where explicit flag did not exist.
            fresh_entry["validated"] = True
            fresh_entry["validated_explicit"] = True

        _normalize_validation_consistency(fresh_entry)

    for section in ["gaps", "ecosystem_health", "quality_references", "conventions"]:
        if section in existing and section not in fresh:
            fresh[section] = existing[section]

    existing_index = existing.get("domain_index", {})
    fresh_index = fresh.get("domain_index", {})
    merged_index = dict(existing_index) if isinstance(existing_index, dict) else {}
    if isinstance(fresh_index, dict):
        for key, squads in fresh_index.items():
            if key not in merged_index:
                merged_index[key] = squads
    fresh["domain_index"] = merged_index

    return fresh


def write_registry(registry: Dict[str, Any], registry_path: Path) -> None:
    """Write registry to YAML file with stable formatting."""

    class CleanDumper(yaml.Dumper):
        pass

    def str_representer(dumper: yaml.Dumper, data: str):
        if "\n" in data:
            return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
        if any(char in data for char in ":{}[]&*?|>!%@`"):
            return dumper.represent_scalar("tag:yaml.org,2002:str", data, style='"')
        return dumper.represent_scalar("tag:yaml.org,2002:str", data)

    CleanDumper.add_representer(str, str_representer)

    registry_path.parent.mkdir(parents=True, exist_ok=True)
    with open(registry_path, "w", encoding="utf-8") as file:
        yaml.dump(
            registry,
            file,
            Dumper=CleanDumper,
            allow_unicode=True,
            default_flow_style=False,
            sort_keys=False,
            width=120,
        )


def _print_summary(results: Dict[str, Any]) -> None:
    metadata = results.get("metadata", {})
    summary = results.get("summary", {})
    squads = results.get("squads", {})

    scan_date = metadata.get("scan_date") or metadata.get("last_updated") or "unknown"
    total_squads = metadata.get("total_squads", len(squads))

    print("Squad Registry Scan Results")
    print("===========================")
    print(f"Scan Date: {scan_date}")
    print(f"Total Squads: {total_squads}")
    print()
    print("Component Totals:")
    for key, value in summary.items():
        print(f"  {key}: {value}")
    print()
    print("Squads Found:")
    for name, data in sorted(squads.items()):
        counts = data.get("counts", {})
        print(f"  {name}: {counts.get('agents', 0)} agents, {counts.get('tasks', 0)} tasks")


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Scan squads and generate ecosystem registry data")
    parser.add_argument("--output", choices=["json", "yaml", "summary"], default="yaml", help="Output format")
    parser.add_argument("--squads-path", type=Path, default=None, help="Path to squads/ directory")
    parser.add_argument(
        "--registry-format",
        action="store_true",
        help="Output in ecosystem registry schema format",
    )
    parser.add_argument(
        "--registry-path",
        type=Path,
        default=None,
        help=f"Target registry path (env fallback: {REGISTRY_PATH_ENV})",
    )
    parser.add_argument(
        "--write",
        action="store_true",
        help="Write directly to target registry path (merge with existing, preserve manual enrichments)",
    )

    args = parser.parse_args()

    try:
        squads_path = args.squads_path or get_squads_path()
    except FileNotFoundError as error:
        print(f"Error: {error}", file=sys.stderr)
        sys.exit(1)

    results = scan_all_squads(squads_path)

    if args.write:
        registry_path = get_registry_path(squads_path, args.registry_path)
        existing = load_existing_registry(registry_path)

        results = scan_all_squads(squads_path, existing)
        fresh = format_for_registry(results)
        fresh["metadata"]["version"] = "1.3.0"
        fresh["metadata"]["generated_by"] = "scripts/refresh-registry.py --write (100% deterministic)"

        merged = merge_with_existing(fresh, existing)
        write_registry(merged, registry_path)

        summary = merged.get("summary", {})
        maturity_summary = merged.get("maturity_summary", {})
        total_squads = merged.get("metadata", {}).get("total_squads", len(merged.get("squads", {})))

        print("Registry updated successfully!")
        print()
        print(f"Squads: {total_squads}")
        print(
            "Agents: {agents} | Tasks: {tasks} | Workflows: {workflows}".format(
                agents=summary.get("total_agents", 0),
                tasks=summary.get("total_tasks", 0),
                workflows=summary.get("total_workflows", 0),
            )
        )
        print(
            "Templates: {templates} | Checklists: {checklists} | Data: {data_files}".format(
                templates=summary.get("total_templates", 0),
                checklists=summary.get("total_checklists", 0),
                data_files=summary.get("total_data_files", 0),
            )
        )
        print()
        print(
            "Maturity: DRAFT={draft} | DEVELOPING={developing} | OPERATIONAL={operational}".format(
                draft=maturity_summary.get(MATURITY_DRAFT, 0),
                developing=maturity_summary.get(MATURITY_DEVELOPING, 0),
                operational=maturity_summary.get(MATURITY_OPERATIONAL, 0),
            )
        )
        print()

        if isinstance(existing, dict):
            old_squads = set((existing.get("squads") or {}).keys())
            new_squads = set((merged.get("squads") or {}).keys())
            added = new_squads - old_squads
            removed = old_squads - new_squads
            if added:
                print(f"New squads: {', '.join(sorted(added))}")
            if removed:
                print(f"Removed squads: {', '.join(sorted(removed))}")

            changes = []
            for name in sorted(new_squads & old_squads):
                old_counts = (existing.get("squads", {}).get(name, {}) or {}).get("counts", {})
                new_counts = (merged.get("squads", {}).get(name, {}) or {}).get("counts", {})
                diffs = []
                for key in ["agents", "tasks", "workflows", "templates", "checklists", "data_files"]:
                    old_value = old_counts.get(key, 0)
                    new_value = new_counts.get(key, 0)
                    if old_value != new_value:
                        diffs.append(f"{key}: {old_value}→{new_value}")
                if diffs:
                    changes.append(f"  {name}: {', '.join(diffs)}")

            if changes:
                print("Changes detected:")
                for change in changes:
                    print(change)
            elif not added and not removed:
                print("No changes detected. Registry is up to date.")

        print(f"\nWritten to: {registry_path}")
        return

    if args.registry_format:
        results = format_for_registry(results)

    if args.output == "json":
        print(json.dumps(results, indent=2, ensure_ascii=False))
    elif args.output == "yaml":
        print(yaml.dump(results, allow_unicode=True, default_flow_style=False, sort_keys=False))
    else:
        _print_summary(results)


if __name__ == "__main__":
    main()
