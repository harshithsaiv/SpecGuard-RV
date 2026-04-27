#!/usr/bin/env bash
set -euo pipefail

# Smoke test for Milestone 0:
# 1) Build Rust staticlib
# 2) Verify expected exported symbols are present

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LIB_PATH="${REPO_ROOT}/crates/neuro_bp/target/release/libneuro_bp.a"

"${SCRIPT_DIR}/build_rust.sh"

if [[ ! -f "${LIB_PATH}" ]]; then
  echo "[smoke] ERROR: expected library not found at ${LIB_PATH}" >&2
  exit 1
fi

if ! command -v nm >/dev/null 2>&1; then
  echo "[smoke] WARNING: 'nm' not available; skipping symbol check"
  exit 0
fi

echo "[smoke] Checking exported symbols in libneuro_bp.a..."
SYMS="$(nm -g "${LIB_PATH}" || true)"

for sym in bp_init bp_predict bp_update; do
  if ! grep -Eq "[[:space:]]${sym}$" <<<"${SYMS}"; then
    echo "[smoke] ERROR: missing symbol '${sym}'" >&2
    exit 1
  fi
  echo "[smoke] Found symbol: ${sym}"
done

echo "[smoke] PASS: Rust staticlib exports expected DPI ABI symbols."
