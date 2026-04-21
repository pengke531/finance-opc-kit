#!/usr/bin/env python3

from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    repo_root = Path(__file__).resolve().parents[2]
    package_file = repo_root / "openclaw.json"
    deploy_script = repo_root / "workspace" / "scripts" / "deploy_profile.py"
    host_config = Path.home() / ".openclaw" / "openclaw.json"

    if not package_file.exists():
        print("ERROR: missing openclaw.json")
        return 1
    if not deploy_script.exists():
        print("ERROR: missing deploy_profile.py")
        return 1

    package = json.loads(package_file.read_text(encoding="utf-8"))
    if package.get("_package", {}).get("mode") != "incremental-import":
        print("ERROR: package is not configured for incremental import")
        return 1

    before_hash = sha256(host_config) if host_config.exists() else None

    with tempfile.TemporaryDirectory(prefix="finance-opc-safety-") as tmp:
        tmp_root = Path(tmp)
        subprocess.run(
            [sys.executable, str(deploy_script), "--target-root", str(tmp_root), "--package-root", str(repo_root)],
            check=True,
        )

        merged_config = tmp_root / "openclaw.json"
        if not merged_config.exists():
            print("ERROR: temp deployment did not produce openclaw.json")
            return 1

        if shutil.which("openclaw"):
            env = dict(os.environ)
            env["OPENCLAW_STATE_DIR"] = str(tmp_root)
            env["OPENCLAW_CONFIG_PATH"] = str(merged_config)
            subprocess.run("openclaw config validate", check=True, env=env, shell=True)
            print("OK: temp config validates")
        else:
            print("WARN: openclaw not found; skipped config validation")

    after_hash = sha256(host_config) if host_config.exists() else None
    if before_hash != after_hash:
        print("ERROR: host config changed during safety verification")
        return 1

    print("OK: host config unchanged")
    print("OK: package safety verification passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
