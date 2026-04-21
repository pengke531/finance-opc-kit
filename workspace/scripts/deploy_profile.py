from __future__ import annotations

import argparse
import json
import shutil
from copy import deepcopy
from datetime import datetime
from pathlib import Path


def rewrite(value, domain_root: Path, target_root: Path):
    if isinstance(value, str):
        return (
            value.replace("__DOMAIN_ROOT__", str(domain_root).replace("\\", "/"))
            .replace("__PROFILE_ROOT__", str(target_root).replace("\\", "/"))
        )
    if isinstance(value, list):
        return [rewrite(v, domain_root, target_root) for v in value]
    if isinstance(value, dict):
        return {k: rewrite(v, domain_root, target_root) for k, v in value.items()}
    return value


def deep_fill(dst, src):
    if isinstance(dst, dict) and isinstance(src, dict):
        for key, value in src.items():
            if key not in dst:
                dst[key] = deepcopy(value)
            else:
                dst[key] = deep_fill(dst[key], value)
        return dst
    return dst


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--target-root", required=True)
    parser.add_argument("--package-root", required=True)
    args = parser.parse_args()

    package_root = Path(args.package_root).resolve()
    target_root = Path(args.target_root).expanduser().resolve()
    domain_root = target_root / "domains" / "finance-opc"
    config_path = target_root / "openclaw.json"
    backup_path = target_root / (
        f"openclaw.json.finance-opc-backup.{datetime.now():%Y%m%d-%H%M%S}.bak"
    )

    target_root.mkdir(parents=True, exist_ok=True)
    domain_root.mkdir(parents=True, exist_ok=True)

    for rel in ["agents", "workspace"]:
        src = package_root / rel
        dst = domain_root / rel
        if dst.exists():
            shutil.rmtree(dst)
        shutil.copytree(src, dst)

    env_template_src = package_root / ".env.template"
    env_template_dst = domain_root / ".env.template"
    env_dst = domain_root / ".env"
    if env_template_src.exists():
        shutil.copy2(env_template_src, env_template_dst)
        if not env_dst.exists():
            shutil.copy2(env_template_src, env_dst)

    overlay = json.loads((package_root / "openclaw.json").read_text(encoding="utf-8"))
    overlay = rewrite(overlay, domain_root, target_root)

    if config_path.exists():
        current = json.loads(config_path.read_text(encoding="utf-8-sig"))
        backup_path.write_text(
            json.dumps(current, ensure_ascii=False, indent=2), encoding="utf-8"
        )
    else:
        current = {}

    skills = current.setdefault("skills", {})
    skills_load = skills.setdefault("load", {})
    skills_load.setdefault("extraDirs", [])
    for skill_dir in overlay.get("skills", {}).get("load", {}).get("extraDirs", []):
        if skill_dir not in skills_load["extraDirs"]:
            skills_load["extraDirs"].append(skill_dir)

    agents = current.setdefault("agents", {})
    defaults = agents.setdefault("defaults", {})
    overlay_defaults = overlay.get("agents", {}).get("defaults", {})
    if "workspace" not in defaults and overlay_defaults.get("workspace"):
        defaults["workspace"] = overlay_defaults["workspace"]
    for key, value in overlay_defaults.items():
        if key == "workspace":
            continue
        if key not in defaults:
            defaults[key] = deepcopy(value)
        elif isinstance(value, dict) and isinstance(defaults[key], dict):
            defaults[key] = deep_fill(defaults[key], value)

    agents.setdefault("list", [])
    by_id = {agent.get("id"): agent for agent in agents["list"] if isinstance(agent, dict)}
    for overlay_agent in overlay.get("agents", {}).get("list", []):
        by_id[overlay_agent["id"]] = deepcopy(overlay_agent)
    agents["list"] = list(by_id.values())

    main_agent = next((a for a in agents["list"] if a.get("id") == "main"), None)
    if main_agent:
        subagents = main_agent.setdefault("subagents", {})
        allow_agents = subagents.setdefault("allowAgents", [])
        if "finance_main" not in allow_agents:
            allow_agents.append("finance_main")

    config_path.write_text(
        json.dumps(current, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"[finance-opc] overlay imported into {domain_root}")
    if backup_path.exists():
        print(f"[finance-opc] backup created: {backup_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
