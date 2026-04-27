## End-to-end smoke test

Assignees: both  
Labels: `integration`, `milestone`

Run a small RISC-V program through Ibex and collect branch prediction logs.

### Tasks
- Run a simple test program
- Confirm Verilog passes PC/GHR to Rust
- Confirm Rust returns prediction/confidence
- Confirm CSV logs are generated

### Acceptance Criteria
- End-to-end Verilator -> DPI-C -> Rust path works
- README has exact reproduction commands
