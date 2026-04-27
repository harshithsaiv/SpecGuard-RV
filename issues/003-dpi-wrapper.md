## Create DPI branch predictor wrapper

Labels: `rtl`, `dpi-c`, `branch-predictor`

Create `rtl/ibex_branch_predict_dpi.sv` that keeps the same predictor-facing behavior but calls Rust through DPI-C.

### Tasks
- Add DPI-C imports for `bp_init`, `bp_predict`, `bp_update`
- Add placeholder call to `bp_predict`
- Return predicted taken/not-taken and predicted target
- Add debug `$display` for first integration test

### Acceptance Criteria
- Verilator can parse the module
- DPI symbols match the Rust ABI
