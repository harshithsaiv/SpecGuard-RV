#!/usr/bin/env bash
set -euo pipefail

# Build the Rust DPI static library used by the Verilator simulation.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${REPO_ROOT}/crates/neuro_bp"
echo "[build_rust] Building crates/neuro_bp (release staticlib)..."
cargo build --release

echo "[build_rust] Done. Artifact: ${REPO_ROOT}/crates/neuro_bp/target/release/libneuro_bp.a"
