# Neuro-Adaptive Branch Prediction for RISC-V on Ibex

This repository scaffolds a **hardware/software co-design experiment** that replaces Ibex's static branch predictor path with a **DPI-C bridge** into a **Rust static library**.

## Project Goal (Milestone 0)

The first milestone optimizes for **integration**, not prediction quality:

1. Verilator simulation reaches branch prediction hook points.
2. SystemVerilog calls DPI-C symbols.
3. DPI symbols resolve into Rust `staticlib` exports.
4. Rust returns deterministic prediction outputs and logs calls.

Target path:

`Ibex IF-stage logic -> rtl/ibex_branch_predict_dpi.sv -> DPI-C ABI -> crates/neuro_bp (Rust) -> optional CSV/debug logs`

## Repository Layout

```text
.
├── crates/
│   └── neuro_bp/          # Rust static library for branch prediction ABI
├── docs/
│   ├── architecture.md    # End-to-end architecture and data flow
│   └── dpi-contract.md    # ABI contract for bp_init/predict/update
├── issues/                # GitHub issue bodies for milestone tracking
├── rtl/
│   └── ibex_branch_predict_dpi.sv
├── scripts/
│   ├── build_rust.sh      # Build Rust static library
│   └── run_smoke_test.sh  # Minimal end-to-end ABI sanity checks
├── sim/
│   └── logs/              # Future prediction/update CSV outputs
└── trainer/               # Reserved for future AI/offline training code
```

## Architecture at a Glance

- **RTL side (SystemVerilog)**: gathers branch context (`pc`, `ghr`, resolved outcome), invokes `bp_predict` and `bp_update` through DPI.
- **DPI-C ABI**: stable function signatures shared between Verilator C++ and Rust.
- **Rust side (`neuro_bp`)**: provides `bp_init`, `bp_predict`, `bp_update` with C ABI and no mangling.
- **Future**: expose anomaly/confidence metadata to a custom CSR for firmware observability.

See `docs/architecture.md` for full details.

## Build/Execution Phases

### Phase A — Static library compile

```bash
./scripts/build_rust.sh
```

Expected artifact:

- `crates/neuro_bp/target/release/libneuro_bp.a`

### Phase B — ABI smoke test (symbol-level)

```bash
./scripts/run_smoke_test.sh
```

This verifies the staticlib exists and exported symbols include:

- `bp_init`
- `bp_predict`
- `bp_update`

### Phase C — Ibex integration (future milestone)

- Build baseline Ibex Verilator target.
- Include `rtl/ibex_branch_predict_dpi.sv` in simulation build.
- Link Verilator binary against `libneuro_bp.a`.
- Confirm prediction calls and logging during program execution.

## Ownership Split

### Verilog / RTL Owner

- Ibex IF-stage integration and predictor wrapper wiring.
- GHR/feature extraction in RTL.
- Verilator build/link updates for DPI object and Rust staticlib.

### Rust / AI Owner

- Maintain `crates/neuro_bp` ABI stability.
- Implement and evolve predictor policy (constant -> hashed perceptron -> adaptive).
- Add logging/evaluation hooks and offline analysis interfaces.

## Beginner Notes

- Keep DPI signatures synchronized with `docs/dpi-contract.md`.
- Start with deterministic constant outputs before any learning logic.
- Prefer small, observable steps (e.g., one debug line per call during bring-up).
