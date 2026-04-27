## Link Verilator simulation with Rust staticlib

Assignees: both  
Labels: `integration`, `verilator`, `rust`, `rtl`

Connect Ibex Verilator simulation to the Rust predictor library.

### Tasks
- Build Rust release staticlib
- Pass linker flags to Verilator
- Confirm `bp_predict` is called from simulation
- Print one debug line from Rust per prediction call

### Acceptance Criteria
- Verilator binary links successfully
- Running simulation invokes Rust `bp_predict`
