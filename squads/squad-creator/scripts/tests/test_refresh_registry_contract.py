#!/usr/bin/env python3
"""Contract tests for refresh-registry deterministic essentials."""

from __future__ import annotations

import copy
import importlib.util
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[4]
SCRIPT_PATH = REPO_ROOT / "squads" / "squad-creator" / "scripts" / "refresh-registry.py"

spec = importlib.util.spec_from_file_location("refresh_registry", SCRIPT_PATH)
assert spec is not None and spec.loader is not None
refresh_registry = importlib.util.module_from_spec(spec)
spec.loader.exec_module(refresh_registry)


scan_squad = refresh_registry.scan_squad
merge_with_existing = refresh_registry.merge_with_existing


def test_default_registry_path_is_canonical_runtime_path() -> None:
    expected = Path(".aiox") / "squad-runtime" / "ecosystem-registry.yaml"
    assert refresh_registry.DEFAULT_REGISTRY_REL_PATH == expected


def test_scan_squad_creator_essential_version_and_counts() -> None:
    squad_path = REPO_ROOT / "squads" / "squad-creator"
    result = scan_squad(squad_path, project_root=REPO_ROOT)

    assert result["config"]["version"] == "4.0.0"
    assert result["counts"]["tasks"] == 24
    assert result["counts"]["workflows"] == 3


def test_merge_policy_keeps_fresh_semantics_for_squad_creator() -> None:
    fresh = {
        "squads": {
            "squad-creator": {
                "description": "fresh description",
                "highlights": ["fresh highlight"],
                "domain": "fresh-domain",
                "keywords": ["fresh"],
                "example_use": "fresh example",
                "quality_score": "fresh",
                "validated": False,
                "validated_explicit": False,
                "maturity": "DEVELOPING",
                "auto_promoted": False,
            }
        }
    }

    existing = {
        "squads": {
            "squad-creator": {
                "description": "stale description",
                "highlights": ["stale highlight"],
                "domain": "old-domain",
                "keywords": ["old"],
                "example_use": "old example",
                "quality_score": "old",
                "validated": False,
                "validated_explicit": False,
                "maturity": "DEVELOPING",
                "auto_promoted": False,
            }
        }
    }

    merged = merge_with_existing(copy.deepcopy(fresh), existing)
    entry = merged["squads"]["squad-creator"]

    assert entry["description"] == "fresh description"
    assert entry["highlights"] == ["fresh highlight"]


def test_merge_policy_preserves_description_when_fresh_is_empty() -> None:
    fresh = {
        "squads": {
            "alpha": {
                "description": "",
                "highlights": [],
                "validated": False,
                "validated_explicit": False,
                "maturity": "DEVELOPING",
                "auto_promoted": False,
            }
        }
    }
    existing = {
        "squads": {
            "alpha": {
                "description": "manual description",
                "highlights": ["manual highlight"],
                "validated": False,
                "validated_explicit": False,
                "maturity": "DEVELOPING",
                "auto_promoted": False,
            }
        }
    }

    merged = merge_with_existing(copy.deepcopy(fresh), existing)
    entry = merged["squads"]["alpha"]

    assert entry["description"] == "manual description"
    assert entry["highlights"] == ["manual highlight"]
