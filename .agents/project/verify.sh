#!/usr/bin/env bash
# Project-owned verification: README.md и .overgate/install-state.json (source_sha, mode, beads).
set -u
cd "$(dirname "$0")/../.." || exit 1
py -3 -I - <<'PY'
import json, sys
from pathlib import Path
EXPECTED_SHA = "2343df83a3a26ae83bc66d4009dd67a913eeea4e"
readme = Path("README.md")
if not readme.is_file():
    print("FAIL: README.md missing", file=sys.stderr); sys.exit(1)
if not readme.read_text(encoding="utf-8").strip():
    print("FAIL: README.md empty", file=sys.stderr); sys.exit(1)
state_path = Path(".overgate/install-state.json")
if not state_path.is_file():
    print("FAIL: .overgate/install-state.json missing", file=sys.stderr); sys.exit(1)
try:
    state = json.loads(state_path.read_text(encoding="utf-8"))
except ValueError as exc:
    print("FAIL: install-state.json invalid JSON: %s" % exc, file=sys.stderr); sys.exit(1)
sha = state.get("source_sha")
if sha != EXPECTED_SHA:
    print("FAIL: source_sha %r != %s" % (sha, EXPECTED_SHA), file=sys.stderr); sys.exit(1)
mode = state.get("mode")
if mode != "auto":
    print("FAIL: mode %r != auto" % (mode,), file=sys.stderr); sys.exit(1)
# Строгая проверка типа: допустим только bool True, не 1 и не строка.
beads = state.get("beads")
if beads is not True:
    print("FAIL: beads %r is not bool True" % (beads,), file=sys.stderr); sys.exit(1)
print("PASS: README.md ok; install-state source_sha/mode=auto/beads=True ok")
PY
