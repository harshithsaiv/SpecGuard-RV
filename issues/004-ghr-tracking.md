## Add GHR feature tracking in SystemVerilog

Labels: `rtl`, `features`

Implement a simple Global History Register (GHR) for branch prediction features.

### Tasks
- Add parameterized GHR width (default 32)
- Shift GHR on branch resolution
- Pass GHR to `bp_predict`
- Log PC and GHR for debug

### Acceptance Criteria
- GHR updates once per resolved branch
- Feature values are stable and readable in logs
