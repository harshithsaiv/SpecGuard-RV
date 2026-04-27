## Implement hashed perceptron predictor v0

Labels: `rust`, `ai`, `predictor`

Replace constant predictor with simple hashed perceptron logic.

### Tasks
- Implement feature hashing from PC, GHR, PHR, LHR
- Add INT8 weight arrays
- Implement dot product
- Return taken/not-taken and confidence
- Keep implementation dependency-free

### Acceptance Criteria
- `bp_predict` returns deterministic predictions
- Unit tests cover hash and dot product behavior
