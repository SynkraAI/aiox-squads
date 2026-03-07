#!/usr/bin/env python3
"""
Squad Analytics Script

Generates detailed analytics report for all squads in the ecosystem.
Shows: agents, tasks, workflows, templates, checklists, data files, scripts.

Usage:
    python scripts/squad-analytics.py [--format table|json] [--sort-by agents|tasks|total]
    python scripts/squad-analytics.py --squad hormozi --detailed
    python scripts/squad-analytics.py --squad hormozi --line-counts
    python scripts/squad-analytics.py --squad hormozi --quality-audit
    python scripts/squad-analytics.py --registry-path .aiox/squad-runtime/ecosystem-registry.yaml
"""

import fnmatch
import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple

try:
    import yaml
    YAML_AVAILABLE = True
except ImportError:  # pragma: no cover - runtime fallback
    YAML_AVAILABLE = False

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

CONTENT_EXTENSIONS = {
    "agents": [".md"],
    "tasks": [".md"],
    "workflows": [".md", ".yaml", ".yml"],
    "templates": [".md", ".yaml", ".yml"],
    "checklists": [".md"],
    "data": [".md", ".yaml", ".yml", ".json"],
    "scripts": [".py", ".js", ".ts", ".sh"],
}


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


def resolve_registry_path(squads_path: Path, registry_path: Optional[Path] = None) -> Path:
    """Resolve ecosystem registry path from CLI arg, env var, or default output location."""
    if registry_path is not None:
        expanded = registry_path.expanduser()
        return expanded if expanded.is_absolute() else (Path.cwd() / expanded)

    env_path = os.getenv(REGISTRY_PATH_ENV, "").strip()
    if env_path:
        env_registry_path = Path(env_path).expanduser()
        return env_registry_path if env_registry_path.is_absolute() else (Path.cwd() / env_registry_path)

    project_root = squads_path.parent if squads_path.name == "squads" else squads_path
    return project_root / DEFAULT_REGISTRY_REL_PATH


def count_lines(file_path: Path) -> int:
    """Count lines in a file."""
    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as file:
            return sum(1 for _ in file)
    except (IOError, OSError, UnicodeDecodeError):
        return 0


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


def count_files_by_extension(
    directory: Path,
    extensions: List[str],
    exclude_names: Optional[Iterable[str]] = None,
) -> int:
    """Count files with specific extensions recursively in directory."""
    if not directory.exists() or not directory.is_dir():
        return 0

    excludes = {name.lower() for name in (exclude_names or [])}
    normalized_ext = [ext if ext.startswith(".") else f".{ext}" for ext in extensions]

    total = 0
    for file in _iter_files_recursive(directory):
        if file.name.lower() in excludes:
            continue
        if file.suffix.lower() in normalized_ext:
            total += 1
    return total


def count_md_files(directory: Path) -> int:
    """Count markdown files recursively excluding boilerplate files."""
    return count_files_by_extension(directory, [".md"], EXCLUDED_MARKDOWN)


def list_files(
    directory: Path,
    extensions: List[str],
    exclude: Optional[List[str]] = None,
) -> List[str]:
    """List files recursively with specific extensions (relative, without extension)."""
    if not directory.exists() or not directory.is_dir():
        return []

    excludes = {name.lower() for name in (exclude or ["readme.md", "template.md", "_template.md"])}
    normalized_ext = [ext if ext.startswith(".") else f".{ext}" for ext in extensions]

    files: List[str] = []
    for file in _iter_files_recursive(directory):
        if file.name.lower() in excludes:
            continue
        if file.suffix.lower() not in normalized_ext:
            continue

        relative = file.relative_to(directory).as_posix()
        files.append(relative[: -len(file.suffix)])

    return sorted(files)


def list_files_with_lines(
    directory: Path,
    extensions: List[str],
    exclude: Optional[List[str]] = None,
) -> List[Tuple[str, int]]:
    """List files recursively with specific extensions and line counts."""
    if not directory.exists() or not directory.is_dir():
        return []

    excludes = {name.lower() for name in (exclude or ["readme.md", "template.md", "_template.md"])}
    normalized_ext = [ext if ext.startswith(".") else f".{ext}" for ext in extensions]

    files: List[Tuple[str, int]] = []
    for file in _iter_files_recursive(directory):
        if file.name.lower() in excludes:
            continue
        if file.suffix.lower() not in normalized_ext:
            continue

        relative = file.relative_to(directory).as_posix()
        files.append((relative, count_lines(file)))

    return sorted(files, key=lambda value: (-value[1], value[0]))


def simple_yaml_parse(content: str) -> Dict[str, str]:
    """Legacy simple parser for key: value pairs."""
    result: Dict[str, str] = {}
    for line in content.split("\n"):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if ":" not in stripped:
            continue
        key, _, value = stripped.partition(":")
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and not key.startswith("-"):
            result[key] = value
    return result


def _has_explicit_version(value: Any) -> bool:
    if value is None:
        return False
    normalized = str(value).strip().lower()
    return normalized not in UNKNOWN_VERSION_VALUES


def _normalize_version(value: Any) -> str:
    if not _has_explicit_version(value):
        return DEFAULT_SQUAD_VERSION
    return str(value).strip()


def _extract_manifest_value(config: Optional[Dict[str, Any]], key: str, default: str = "") -> str:
    if not isinstance(config, dict):
        return default

    metadata = config.get("metadata") if isinstance(config.get("metadata"), dict) else {}
    squad = config.get("squad") if isinstance(config.get("squad"), dict) else {}

    for candidate in [config.get(key), metadata.get(key), squad.get(key)]:
        if isinstance(candidate, str) and candidate.strip():
            return candidate.strip()

    return default


def _extract_manifest_version(config: Optional[Dict[str, Any]]) -> str:
    if not isinstance(config, dict):
        return DEFAULT_SQUAD_VERSION

    metadata = config.get("metadata") if isinstance(config.get("metadata"), dict) else {}
    squad = config.get("squad") if isinstance(config.get("squad"), dict) else {}

    candidates = [
        config.get("version"),
        metadata.get("version"),
        squad.get("version"),
    ]

    for candidate in candidates:
        if _has_explicit_version(candidate):
            return _normalize_version(candidate)

    return _normalize_version(candidates[0] if candidates else None)


def read_config(squad_path: Path) -> Optional[Dict[str, Any]]:
    """Read canonical squad manifest (config.yaml, fallback squad.yaml)."""
    manifest_file = squad_path / "config.yaml"
    if not manifest_file.exists():
        manifest_file = squad_path / "squad.yaml"  # legacy fallback
    if not manifest_file.exists():
        return None

    try:
        with open(manifest_file, "r", encoding="utf-8") as file:
            if YAML_AVAILABLE:
                parsed = yaml.safe_load(file)
                return parsed if isinstance(parsed, dict) else None
            return simple_yaml_parse(file.read())
    except (IOError, OSError, UnicodeDecodeError):
        return None


def _count_components(squad_path: Path) -> Dict[str, int]:
    return {
        "agents": count_files_by_extension(squad_path / "agents", CONTENT_EXTENSIONS["agents"], EXCLUDED_MARKDOWN),
        "tasks": count_files_by_extension(squad_path / "tasks", CONTENT_EXTENSIONS["tasks"], EXCLUDED_MARKDOWN),
        "workflows": count_files_by_extension(squad_path / "workflows", CONTENT_EXTENSIONS["workflows"], EXCLUDED_MARKDOWN),
        "templates": count_files_by_extension(squad_path / "templates", CONTENT_EXTENSIONS["templates"], EXCLUDED_MARKDOWN),
        "checklists": count_files_by_extension(squad_path / "checklists", CONTENT_EXTENSIONS["checklists"], EXCLUDED_MARKDOWN),
        "data": count_files_by_extension(squad_path / "data", CONTENT_EXTENSIONS["data"], EXCLUDED_MARKDOWN),
        "scripts": count_files_by_extension(squad_path / "scripts", CONTENT_EXTENSIONS["scripts"]),
    }


def _list_components(squad_path: Path) -> Dict[str, List[str]]:
    return {
        "agents": list_files(squad_path / "agents", CONTENT_EXTENSIONS["agents"]),
        "tasks": list_files(squad_path / "tasks", CONTENT_EXTENSIONS["tasks"]),
        "workflows": list_files(squad_path / "workflows", CONTENT_EXTENSIONS["workflows"]),
        "templates": list_files(squad_path / "templates", CONTENT_EXTENSIONS["templates"]),
        "checklists": list_files(squad_path / "checklists", CONTENT_EXTENSIONS["checklists"]),
        "data": list_files(squad_path / "data", CONTENT_EXTENSIONS["data"]),
        "scripts": list_files(squad_path / "scripts", CONTENT_EXTENSIONS["scripts"], exclude=[]),
    }


def _list_component_lines(squad_path: Path) -> Dict[str, List[Tuple[str, int]]]:
    return {
        "agents": list_files_with_lines(squad_path / "agents", CONTENT_EXTENSIONS["agents"]),
        "tasks": list_files_with_lines(squad_path / "tasks", CONTENT_EXTENSIONS["tasks"]),
        "workflows": list_files_with_lines(squad_path / "workflows", CONTENT_EXTENSIONS["workflows"]),
        "templates": list_files_with_lines(squad_path / "templates", CONTENT_EXTENSIONS["templates"]),
        "checklists": list_files_with_lines(squad_path / "checklists", CONTENT_EXTENSIONS["checklists"]),
        "data": list_files_with_lines(squad_path / "data", CONTENT_EXTENSIONS["data"]),
        "scripts": list_files_with_lines(squad_path / "scripts", CONTENT_EXTENSIONS["scripts"], exclude=[]),
    }


def detect_extra_folders(squad_path: Path) -> Dict[str, Any]:
    """Detect squad-specific extra folders like data/minds/, docs/sops/, etc."""
    extras: Dict[str, Any] = {}

    minds_path = squad_path / "data" / "minds"
    if minds_path.exists():
        files = list_files_with_lines(minds_path, [".yaml", ".yml"], exclude=[])
        extras["dna_files"] = {
            "path": "data/minds/",
            "count": len(files),
            "files": files,
            "total_lines": sum(file[1] for file in files),
        }

    sops_path = squad_path / "docs" / "sops"
    if sops_path.exists():
        md_files = list_files_with_lines(sops_path, [".md"], exclude=[])
        yaml_files = list_files_with_lines(sops_path, [".yaml", ".yml"], exclude=[])
        extras["sops"] = {
            "path": "docs/sops/",
            "md_count": len(md_files),
            "yaml_count": len(yaml_files),
            "md_files": md_files,
            "yaml_files": yaml_files,
            "total_lines": sum(file[1] for file in md_files) + sum(file[1] for file in yaml_files),
        }

    docs_path = squad_path / "docs"
    if docs_path.exists():
        md_files = list_files_with_lines(docs_path, [".md"], exclude=[])
        extras["docs"] = {
            "path": "docs/",
            "count": len(md_files),
            "files": md_files,
            "total_lines": sum(file[1] for file in md_files),
        }

    pipelines_path = squad_path / "pipelines"
    if pipelines_path.exists():
        py_files = list_files_with_lines(pipelines_path, [".py"], exclude=[])
        extras["pipelines"] = {
            "path": "pipelines/",
            "count": len(py_files),
            "files": py_files,
            "total_lines": sum(file[1] for file in py_files),
        }

    return extras


def analyze_squad(
    squad_path: Path,
    include_lines: bool = False,
    existing_validated: bool = False,
    validated_explicit: bool = False,
) -> Dict[str, Any]:
    """Analyze a single squad in detail."""
    name = squad_path.name
    config = read_config(squad_path)
    squads_path = squad_path.parent

    counts = _count_components(squad_path)
    components = _list_components(squad_path)
    line_counts = _list_component_lines(squad_path) if include_lines else {}
    extras = detect_extra_folders(squad_path)

    has_readme = (squad_path / "README.md").exists()
    has_changelog = (squad_path / "CHANGELOG.md").exists()
    has_config = config is not None

    usage_signals = detect_squad_usage(name, squads_path.parent)
    maturity_result = resolve_maturity_validated(
        counts=counts,
        usage_signals=usage_signals,
        existing_validated=bool(existing_validated),
        validated_explicit=bool(validated_explicit),
    )

    total = sum(counts.values())

    return {
        "name": name,
        "domain": _extract_manifest_value(config, "domain", _extract_manifest_value(config, "short-title")),
        "description": _extract_manifest_value(config, "description"),
        "version": _extract_manifest_version(config),
        "counts": counts,
        "components": components,
        "line_counts": line_counts,
        "extras": extras,
        "total": total,
        "has_readme": has_readme,
        "has_changelog": has_changelog,
        "has_config": has_config,
        "maturity": maturity_result["maturity"],
        "validated": maturity_result["validated"],
        "validated_explicit": bool(validated_explicit),
        "auto_promoted": maturity_result["auto_promoted"],
        "quality_score": calculate_quality_score(counts, has_readme, has_config),
    }


def calculate_quality_score(counts: Dict[str, int], has_readme: bool, has_config: bool) -> str:
    """Calculate legacy star score (kept for backward compatibility)."""
    score = 0

    if counts["agents"] > 0:
        score += 2
    if counts["tasks"] > 0:
        score += 2
    if counts["workflows"] > 0:
        score += 1
    if counts["templates"] > 0:
        score += 1
    if counts["checklists"] > 0:
        score += 1
    if counts["data"] > 0:
        score += 1

    if has_readme:
        score += 1
    if has_config:
        score += 1

    if score >= 9:
        return "⭐⭐⭐"
    if score >= 6:
        return "⭐⭐"
    if score >= 3:
        return "⭐"
    return "🔨"


def quality_audit(squad_data: Dict[str, Any]) -> Dict[str, Any]:
    """Run quality audit against AIOX standards."""
    audit = {
        "agents": {"min": 300, "results": [], "pass": 0, "fail": 0},
        "workflows": {"min": 500, "results": [], "pass": 0, "fail": 0},
        "tasks": {"min": 100, "results": [], "pass": 0, "fail": 0},
    }

    for component_type in ["agents", "workflows", "tasks"]:
        if component_type not in squad_data.get("line_counts", {}):
            continue

        min_lines = audit[component_type]["min"]
        for name, lines in squad_data["line_counts"][component_type]:
            passed = lines >= min_lines
            audit[component_type]["results"].append(
                {
                    "name": name,
                    "lines": lines,
                    "min": min_lines,
                    "passed": passed,
                }
            )
            if passed:
                audit[component_type]["pass"] += 1
            else:
                audit[component_type]["fail"] += 1

    return audit


def load_registry(registry_path: Path) -> Dict[str, Any]:
    """Load optional ecosystem registry for validated status."""
    if not YAML_AVAILABLE:
        return {}

    if not registry_path.exists():
        return {}

    try:
        with open(registry_path, "r", encoding="utf-8") as file:
            parsed = yaml.safe_load(file)
            return parsed if isinstance(parsed, dict) else {}
    except (IOError, OSError, yaml.YAMLError):
        return {}


def _resolve_existing_validation(entry: Dict[str, Any]) -> Dict[str, bool]:
    validated = bool(entry.get("validated", False))
    if "validated_explicit" in entry:
        explicit = bool(entry.get("validated_explicit"))
    else:
        explicit = validated
    return {
        "validated": validated,
        "validated_explicit": explicit,
    }


def analyze_all_squads(squads_path: Path, registry_path: Optional[Path] = None) -> Dict[str, Any]:
    """Analyze all squads."""
    resolved_registry_path = resolve_registry_path(squads_path, registry_path)
    registry = load_registry(resolved_registry_path)
    registry_squads = registry.get("squads", {}) if isinstance(registry, dict) else {}

    results: Dict[str, Any] = {
        "metadata": {
            "scan_date": datetime.now().isoformat(),
            "generated_by": "squad-analytics.py",
        },
        "squads": [],
        "totals": {
            "squads": 0,
            "agents": 0,
            "tasks": 0,
            "workflows": 0,
            "templates": 0,
            "checklists": 0,
            "data": 0,
            "scripts": 0,
            "total_components": 0,
        },
        "maturity_summary": {
            MATURITY_DRAFT: 0,
            MATURITY_DEVELOPING: 0,
            MATURITY_OPERATIONAL: 0,
        },
    }

    for item in sorted(squads_path.iterdir()):
        if not item.is_dir():
            continue
        if item.name in SKIP_DIRS or item.name.startswith("."):
            continue
        if not (item / "config.yaml").exists() and not (item / "squad.yaml").exists():
            continue

        existing_entry = registry_squads.get(item.name, {})
        if not isinstance(existing_entry, dict):
            existing_entry = {}

        validation = _resolve_existing_validation(existing_entry)

        squad_data = analyze_squad(
            item,
            existing_validated=validation["validated"],
            validated_explicit=validation["validated_explicit"],
        )
        results["squads"].append(squad_data)

        results["totals"]["squads"] += 1
        for key in ["agents", "tasks", "workflows", "templates", "checklists", "data", "scripts"]:
            results["totals"][key] += squad_data["counts"][key]
        results["totals"]["total_components"] += squad_data["total"]

        maturity = squad_data.get("maturity", MATURITY_DEVELOPING)
        results["maturity_summary"][maturity] = results["maturity_summary"].get(maturity, 0) + 1

    return results


def format_table(results: Dict[str, Any], detailed: bool = False) -> str:
    """Format results as ASCII table."""
    lines: List[str] = []

    lines.append("=" * 100)
    lines.append("📊 AIOX SQUAD ANALYTICS")
    lines.append(f"Generated: {results['metadata']['scan_date'][:10]}")
    lines.append("=" * 100)
    lines.append("")

    totals = results["totals"]
    maturity_summary = results.get("maturity_summary", {})

    lines.append("📈 ECOSYSTEM SUMMARY")
    lines.append(
        f"   Squads: {totals['squads']} | Agents: {totals['agents']} | Tasks: {totals['tasks']} | Workflows: {totals['workflows']}"
    )
    lines.append(
        "   Templates: {templates} | Checklists: {checklists} | Data: {data} | Scripts: {scripts}".format(
            templates=totals["templates"],
            checklists=totals["checklists"],
            data=totals["data"],
            scripts=totals["scripts"],
        )
    )
    lines.append(f"   Total Components: {totals['total_components']}")
    lines.append("")

    lines.append("📊 MATURITY DISTRIBUTION")
    lines.append(
        "   DRAFT: {draft} | DEVELOPING: {developing} | OPERATIONAL: {operational}".format(
            draft=maturity_summary.get(MATURITY_DRAFT, 0),
            developing=maturity_summary.get(MATURITY_DEVELOPING, 0),
            operational=maturity_summary.get(MATURITY_OPERATIONAL, 0),
        )
    )
    lines.append("")

    lines.append("-" * 100)
    header = (
        f"{'Squad':<20} {'Agents':>7} {'Tasks':>7} {'WFs':>5} {'Tmpls':>6} "
        f"{'Checks':>7} {'Data':>6} {'Scripts':>8} {'Total':>6} {'Maturity'}"
    )
    lines.append(header)
    lines.append("-" * 100)

    sorted_squads = sorted(results["squads"], key=lambda squad: squad["total"], reverse=True)

    for squad in sorted_squads:
        counts = squad["counts"]
        row = (
            f"{squad['name']:<20} {counts['agents']:>7} {counts['tasks']:>7} {counts['workflows']:>5} "
            f"{counts['templates']:>6} {counts['checklists']:>7} {counts['data']:>6} {counts['scripts']:>8} "
            f"{squad['total']:>6} {squad.get('maturity', MATURITY_DEVELOPING)}"
        )
        lines.append(row)

        if detailed and squad["total"] > 0:
            for component_type, component_list in squad["components"].items():
                if component_list:
                    suffix = f" (+{len(component_list)-5} more)" if len(component_list) > 5 else ""
                    lines.append(f"   └─ {component_type}: {', '.join(component_list[:5])}{suffix}")
            lines.append("")

    lines.append("-" * 100)
    lines.append("")
    lines.append("🏆 TOP SQUADS BY CATEGORY")
    lines.append("")

    categories = [
        ("agents", "Most Agents"),
        ("tasks", "Most Tasks"),
        ("workflows", "Most Workflows"),
        ("checklists", "Most Checklists"),
    ]

    for key, label in categories:
        top = sorted(results["squads"], key=lambda squad: squad["counts"][key], reverse=True)[:3]
        if top and top[0]["counts"][key] > 0:
            top_str = ", ".join(
                f"{squad['name']} ({squad['counts'][key]})" for squad in top if squad["counts"][key] > 0
            )
            lines.append(f"   {label}: {top_str}")

    lines.append("")
    lines.append("=" * 100)
    return "\n".join(lines)


def format_single_squad(
    squad_data: Dict[str, Any],
    line_counts: bool = False,
    quality_audit_flag: bool = False,
) -> str:
    """Format a single squad analysis."""
    lines: List[str] = []

    lines.append("=" * 80)
    lines.append(f"📊 SQUAD ANALYTICS: {squad_data['name'].upper()}")
    lines.append("=" * 80)
    lines.append("")

    counts = squad_data["counts"]
    lines.append("📈 OVERVIEW")
    lines.append(f"   Agents: {counts['agents']} | Tasks: {counts['tasks']} | Workflows: {counts['workflows']}")
    lines.append(f"   Templates: {counts['templates']} | Checklists: {counts['checklists']} | Data: {counts['data']}")
    lines.append(f"   Maturity: {squad_data.get('maturity', MATURITY_DEVELOPING)}")
    lines.append("")

    if squad_data.get("extras"):
        lines.append("📁 EXTRA FOLDERS DETECTED")
        for key, info in squad_data["extras"].items():
            if key == "dna_files":
                lines.append(
                    f"   └─ DNA Files ({info['path']}): {info['count']} files, {info['total_lines']:,} lines"
                )
            elif key == "sops":
                lines.append(
                    f"   └─ SOPs ({info['path']}): {info['md_count']} .md + {info['yaml_count']} .yaml = {info['total_lines']:,} lines"
                )
            elif key == "docs":
                lines.append(f"   └─ Docs ({info['path']}): {info['count']} files, {info['total_lines']:,} lines")
            elif key == "pipelines":
                lines.append(
                    f"   └─ Pipelines ({info['path']}): {info['count']} files, {info['total_lines']:,} lines"
                )
        lines.append("")

    if line_counts and squad_data.get("line_counts"):
        lines.append("-" * 80)
        lines.append("📏 LINE COUNTS BY COMPONENT")
        lines.append("-" * 80)

        for component_type, file_list in squad_data["line_counts"].items():
            if not file_list:
                continue

            total_lines = sum(file[1] for file in file_list)
            avg_lines = total_lines // len(file_list) if file_list else 0
            lines.append("")
            lines.append(
                f"📂 {component_type.upper()} ({len(file_list)} files, {total_lines:,} lines, avg {avg_lines})"
            )

            min_threshold = 300 if component_type == "agents" else (500 if component_type == "workflows" else 0)
            for file_name, file_lines in file_list[:15]:
                status = "✅" if file_lines >= min_threshold or min_threshold == 0 else "⚠️"
                lines.append(f"   {status} {file_name:<40} {file_lines:>5} lines")

            if len(file_list) > 15:
                lines.append(f"   ... and {len(file_list) - 15} more files")

    if quality_audit_flag and squad_data.get("line_counts"):
        audit = quality_audit(squad_data)
        lines.append("")
        lines.append("-" * 80)
        lines.append("🔍 QUALITY AUDIT (AIOX Standards)")
        lines.append("-" * 80)

        for component_type in ["agents", "workflows", "tasks"]:
            if not audit[component_type]["results"]:
                continue

            min_lines = audit[component_type]["min"]
            passed = audit[component_type]["pass"]
            failed = audit[component_type]["fail"]
            total = passed + failed
            status = "✅ ALL PASS" if failed == 0 else f"⚠️ {failed}/{total} BELOW MIN"

            lines.append("")
            lines.append(f"📋 {component_type.upper()} (min: {min_lines} lines) — {status}")
            for result in audit[component_type]["results"]:
                icon = "✅" if result["passed"] else "❌"
                lines.append(f"   {icon} {result['name']:<40} {result['lines']:>5} lines")

    lines.append("")
    lines.append("=" * 80)
    return "\n".join(lines)


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Generate squad analytics report")
    parser.add_argument("--format", choices=["table", "json"], default="table", help="Output format")
    parser.add_argument("--detailed", "-d", action="store_true", help="Show detailed component lists")
    parser.add_argument("--sort-by", choices=["name", "agents", "tasks", "total"], default="total", help="Sort squads by field")
    parser.add_argument("--squads-path", type=Path, default=None, help="Path to squads/ directory")
    parser.add_argument(
        "--registry-path",
        type=Path,
        default=None,
        help=f"Path to ecosystem registry (env fallback: {REGISTRY_PATH_ENV})",
    )
    parser.add_argument("--squad", "-s", type=str, default=None, help="Analyze a specific squad only")
    parser.add_argument("--line-counts", "-l", action="store_true", help="Show line counts per file (requires --squad)")
    parser.add_argument("--quality-audit", "-q", action="store_true", help="Run quality audit against AIOX standards (requires --squad)")

    args = parser.parse_args()

    try:
        squads_path = args.squads_path or get_squads_path()
    except FileNotFoundError as error:
        print(f"Error: {error}", file=sys.stderr)
        sys.exit(1)

    if args.squad:
        squad_path = squads_path / args.squad
        if not squad_path.exists():
            print(f"Error: Squad '{args.squad}' not found at {squad_path}", file=sys.stderr)
            sys.exit(1)

        include_lines = args.line_counts or args.quality_audit
        squad_data = analyze_squad(squad_path, include_lines=include_lines)

        if args.format == "json":
            print(json.dumps(squad_data, indent=2, ensure_ascii=False))
        else:
            print(
                format_single_squad(
                    squad_data,
                    line_counts=args.line_counts,
                    quality_audit_flag=args.quality_audit,
                )
            )
        return

    results = analyze_all_squads(squads_path, args.registry_path)

    if args.sort_by == "name":
        results["squads"].sort(key=lambda squad: squad["name"])
    elif args.sort_by in ["agents", "tasks"]:
        results["squads"].sort(key=lambda squad: squad["counts"][args.sort_by], reverse=True)
    else:
        results["squads"].sort(key=lambda squad: squad["total"], reverse=True)

    if args.format == "json":
        print(json.dumps(results, indent=2, ensure_ascii=False))
    else:
        print(format_table(results, detailed=args.detailed))


if __name__ == "__main__":
    main()
