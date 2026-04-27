## Add prediction/update CSV logging

Labels: `rust`, `evaluation`

Log branch prediction events for evaluation.

### Tasks
- Log `pc`, `ghr`, `prediction`, `confidence`
- Log updates with actual outcome and target
- Write CSV under `sim/logs/`
- Add environment variable to enable/disable logging

### Acceptance Criteria
- Simulation creates a readable CSV trace
- Logs can be used for MPKI calculation later
