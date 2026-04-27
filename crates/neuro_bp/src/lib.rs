//! neuro_bp
//!
//! Minimal Rust static library that exposes a stable C ABI for SystemVerilog DPI-C.
//! This milestone intentionally uses deterministic placeholder behavior to validate
//! end-to-end connectivity before implementing real predictor logic.

use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};

/// Tracks whether bp_init has already run.
static INIT_DONE: AtomicBool = AtomicBool::new(false);
/// Simple call counter for debug visibility during integration.
static PREDICT_CALLS: AtomicU64 = AtomicU64::new(0);
/// Simple call counter for update path.
static UPDATE_CALLS: AtomicU64 = AtomicU64::new(0);

/// Initialize predictor state.
///
/// C ABI export required by DPI-C:
/// `void bp_init(void);`
#[no_mangle]
pub extern "C" fn bp_init() {
    if !INIT_DONE.swap(true, Ordering::SeqCst) {
        eprintln!("[neuro_bp] bp_init: initialized");
    } else {
        eprintln!("[neuro_bp] bp_init: already initialized");
    }
}

/// Predict branch behavior for a given PC/GHR snapshot.
///
/// Placeholder policy:
/// - Always predict not-taken (`out_taken = 0`)
/// - Predicted target defaults to sequential `pc + 4`
/// - Constant confidence (`out_conf = 128`)
///
/// C ABI export required by DPI-C:
/// `void bp_predict(uint64_t, uint64_t, uint8_t*, uint64_t*, uint8_t*);`
#[no_mangle]
pub extern "C" fn bp_predict(
    pc: u64,
    ghr: u64,
    out_taken: *mut u8,
    out_target: *mut u64,
    out_conf: *mut u8,
) {
    let call_id = PREDICT_CALLS.fetch_add(1, Ordering::SeqCst) + 1;

    // Defensive null checks: avoid UB if caller wiring is incomplete during bring-up.
    if !out_taken.is_null() {
        // SAFETY: pointer checked for null; caller guarantees valid writable storage.
        unsafe { *out_taken = 0 };
    }

    if !out_target.is_null() {
        let seq_target = pc.wrapping_add(4);
        // SAFETY: pointer checked for null; caller guarantees valid writable storage.
        unsafe { *out_target = seq_target };
    }

    if !out_conf.is_null() {
        // Mid-range confidence placeholder.
        // SAFETY: pointer checked for null; caller guarantees valid writable storage.
        unsafe { *out_conf = 128 };
    }

    eprintln!(
        "[neuro_bp] bp_predict #{call_id}: pc=0x{pc:016x} ghr=0x{ghr:016x}"
    );
}

/// Update predictor state with resolved branch outcome.
///
/// C ABI export required by DPI-C:
/// `void bp_update(uint64_t, uint64_t, uint8_t, uint64_t);`
#[no_mangle]
pub extern "C" fn bp_update(pc: u64, ghr: u64, actual_taken: u8, actual_target: u64) {
    let call_id = UPDATE_CALLS.fetch_add(1, Ordering::SeqCst) + 1;
    eprintln!(
        "[neuro_bp] bp_update #{call_id}: pc=0x{pc:016x} ghr=0x{ghr:016x} actual_taken={} actual_target=0x{actual_target:016x}",
        actual_taken
    );
}
