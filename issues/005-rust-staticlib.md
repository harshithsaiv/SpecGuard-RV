## Create Rust staticlib with DPI ABI

Labels: `rust`, `dpi-c`, `ffi`

Create `crates/neuro_bp` as a Rust staticlib exposing C ABI functions.

### Tasks
- Configure `Cargo.toml` with `crate-type = ["staticlib"]`
- Implement `#[no_mangle] extern "C"` functions:
  - `bp_init()`
  - `bp_predict(...)`
  - `bp_update(...)`
- Return constant prediction initially
- Add simple internal logger

### Acceptance Criteria
- `cargo build --release` produces `libneuro_bp.a`
- `nm` shows unmangled `bp_predict`/`bp_update` symbols
