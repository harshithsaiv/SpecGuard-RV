# Architecture: Ibex Branch Predictor DPI Bridge

## 1) Objective

Introduce a low-risk, incremental integration point where Ibex branch prediction can query a Rust library through DPI-C without changing ISA-visible behavior during initial bring-up.

Milestone 0 prioritizes:

- deterministic interoperability,
- traceability/debuggability,
- clear ownership boundaries.

## 2) High-level Data Flow

```text
Ibex IF stage (branch candidate PC, next PC context)
        |
        v
rtl/ibex_branch_predict_dpi.sv
  - optional GHR bookkeeping
  - bp_predict(...) DPI call
  - bp_update(...) on resolution
        |
        v
DPI-C symbol boundary (C ABI)
        |
        v
Rust staticlib (crates/neuro_bp)
  - bp_init()
  - bp_predict(...)
  - bp_update(...)
        |
        v
Prediction output + optional logs
```

## 3) Ibex IF-stage Hook Strategy

Planned hook points:

1. **Fetch/predict time**
   - Provide current fetch PC and basic history feature(s).
   - Ask predictor for:
     - taken/not-taken bit,
     - predicted target (or placeholder),
     - optional confidence byte.

2. **Resolve/update time**
   - When branch outcome is known, call `bp_update`.
   - Pass actual outcome and actual target so the Rust side can train/adapt later.

For Milestone 0, minimal integration can run with synthetic/placeholder values if full Ibex plumbing is not complete yet.

## 4) DPI-C Bridge Module Responsibilities

`rtl/ibex_branch_predict_dpi.sv` should:

- import stable DPI symbols exactly matching contract,
- call `bp_init()` once at startup/reset release,
- call `bp_predict(...)` in combinational/sequential safe context,
- call `bp_update(...)` upon branch resolution,
- provide simple debug instrumentation (`$display`) for early bring-up.

Design note: keep this wrapper thin so ABI or predictor changes do not force large IF-stage refactors.

## 5) Rust Predictor Responsibilities

`crates/neuro_bp` currently provides stubs:

- `bp_init`: initialize global state and emit a startup debug line.
- `bp_predict`: return deterministic placeholder prediction and confidence.
- `bp_update`: consume resolved outcome and optionally log event.

Near-term progression:

- constant predictor -> hashed perceptron v0,
- enable feature expansion (PC, GHR, local history, path history),
- CSV logging for evaluation pipelines.

## 6) Future Path: Anomaly Score CSR

A future extension is to surface a predictor health/anomaly metric to software via CSR:

- Rust computes confidence/anomaly score (e.g., low confidence or unstable behavior).
- DPI bridge forwards score to RTL register.
- Ibex exposes that register through custom CSR space.
- Firmware/runtime can sample this value for adaptive policies or telemetry.

This is **not** part of Milestone 0 implementation, but the ABI and module boundaries are designed to make it straightforward later.

## 7) Integration Sequence (Recommended)

1. Build Rust staticlib and verify symbols.
2. Compile RTL wrapper in isolation under Verilator parse checks.
3. Connect wrapper to a minimal test harness calling one `bp_predict`.
4. Integrate with Ibex fetch/resolve path.
5. Add logging and compare expected call counts.

## 8) Non-goals for Milestone 0

- predictor accuracy optimization,
- ML training loop integration,
- speculative rollback correctness tuning,
- performance tuning of DPI overhead.
