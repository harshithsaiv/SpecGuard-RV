# DPI Contract: `bp_init`, `bp_predict`, `bp_update`

This document defines the C ABI used between SystemVerilog DPI-C and the Rust static library.

## 1) ABI Stability Rules

- All exported Rust functions must be `#[no_mangle] extern "C"`.
- Integer widths must be explicit and consistent across SV/C/Rust.
- Avoid ABI-breaking signature changes without updating this document and RTL imports.

## 2) Function Prototypes

Reference C header style:

```c
// Initialize predictor state. Safe to call once at startup/reset.
void bp_init(void);

// Predict for a candidate branch fetch.
// Inputs:
//   pc            : current branch/fetch PC
//   ghr           : global history register snapshot
// Outputs:
//   out_taken     : 0/1 prediction (written by callee)
//   out_target    : predicted branch target (written by callee)
//   out_conf      : confidence score 0..255 (written by callee)
void bp_predict(
    uint64_t pc,
    uint64_t ghr,
    uint8_t *out_taken,
    uint64_t *out_target,
    uint8_t *out_conf
);

// Update predictor with resolved branch outcome.
// Inputs:
//   pc            : branch PC
//   ghr           : history used (or post-resolve, by convention)
//   actual_taken  : resolved outcome (0/1)
//   actual_target : resolved target
void bp_update(
    uint64_t pc,
    uint64_t ghr,
    uint8_t actual_taken,
    uint64_t actual_target
);
```

## 3) SystemVerilog DPI Import Shape

Equivalent SystemVerilog declaration pattern:

```systemverilog
import "DPI-C" function void bp_init();
import "DPI-C" function void bp_predict(
  input longint unsigned pc,
  input longint unsigned ghr,
  output byte unsigned out_taken,
  output longint unsigned out_target,
  output byte unsigned out_conf
);
import "DPI-C" function void bp_update(
  input longint unsigned pc,
  input longint unsigned ghr,
  input byte unsigned actual_taken,
  input longint unsigned actual_target
);
```

## 4) Rust Signature Mapping

Rust should use:

- `u64` for `uint64_t`
- `u8` for `uint8_t`
- raw pointers for out-params in `bp_predict`

Example shape:

```rust
#[no_mangle]
pub extern "C" fn bp_predict(
    pc: u64,
    ghr: u64,
    out_taken: *mut u8,
    out_target: *mut u64,
    out_conf: *mut u8,
)
```

## 5) Conventions (Milestone 0)

- `out_taken`: `0` not-taken, `1` taken.
- `out_target`: if not-taken policy is used, may be set to `pc + 4` as placeholder.
- `out_conf`: free-form confidence; use fixed constant initially.
- Null out-pointers are tolerated by Rust implementation (defensive checks).

## 6) Versioning Guidance

When changing ABI:

1. update this document,
2. update RTL DPI imports,
3. update Rust exports,
4. rerun smoke test and symbol checks.
