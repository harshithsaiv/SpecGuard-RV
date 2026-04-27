//------------------------------------------------------------------------------
// ibex_branch_predict_dpi.sv
//------------------------------------------------------------------------------
// Purpose:
//   Thin wrapper module demonstrating how branch prediction can be forwarded
//   from RTL into a Rust static library through DPI-C.
//
// Notes:
//   - This is a scaffold module for bring-up and is not wired into Ibex yet.
//   - Signal names are generic on purpose to help beginners adapt it.
//   - Placeholder prediction path is sufficient for Milestone 0 integration.
//------------------------------------------------------------------------------

module ibex_branch_predict_dpi #(
  parameter int unsigned GHR_WIDTH = 32
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,

  // Predict interface (typically IF-stage context)
  input  logic                 predict_valid_i,
  input  logic [31:0]          predict_pc_i,
  output logic                 predict_taken_o,
  output logic [31:0]          predict_target_o,
  output logic [7:0]           predict_conf_o,

  // Update interface (typically branch resolution context)
  input  logic                 update_valid_i,
  input  logic [31:0]          update_pc_i,
  input  logic                 update_taken_i,
  input  logic [31:0]          update_target_i
);

  // DPI-C imports: must exactly match the ABI names/signatures used by Rust.
  import "DPI-C" function void bp_init();
  import "DPI-C" function void bp_predict(
    input  longint unsigned pc,
    input  longint unsigned ghr,
    output byte unsigned    out_taken,
    output longint unsigned out_target,
    output byte unsigned    out_conf
  );
  import "DPI-C" function void bp_update(
    input longint unsigned pc,
    input longint unsigned ghr,
    input byte unsigned    actual_taken,
    input longint unsigned actual_target
  );

  logic [GHR_WIDTH-1:0] ghr_q, ghr_d;
  byte unsigned         dpi_taken;
  longint unsigned      dpi_target;
  byte unsigned         dpi_conf;

  // Initialize Rust-side predictor once at time 0.
  initial begin
    bp_init();
    $display("[ibex_branch_predict_dpi] bp_init called");
  end

  // Very simple GHR update (placeholder): shift in resolved branch outcome.
  always_comb begin
    ghr_d = ghr_q;
    if (update_valid_i) begin
      ghr_d = {ghr_q[GHR_WIDTH-2:0], update_taken_i};
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      ghr_q <= '0;
    end else begin
      ghr_q <= ghr_d;
    end
  end

  // Prediction path: call Rust predictor when request is valid.
  always_comb begin
    // Safe defaults
    predict_taken_o  = 1'b0;
    predict_target_o = predict_pc_i + 32'd4;
    predict_conf_o   = 8'd0;

    dpi_taken  = 8'd0;
    dpi_target = longint'(predict_pc_i) + 64'd4;
    dpi_conf   = 8'd0;

    if (predict_valid_i) begin
      bp_predict(longint'(predict_pc_i), longint'(ghr_q), dpi_taken, dpi_target, dpi_conf);
      predict_taken_o  = (dpi_taken != 8'd0);
      predict_target_o = dpi_target[31:0];
      predict_conf_o   = dpi_conf;
    end
  end

  // Update/training path: forward actual resolution into Rust.
  always_ff @(posedge clk_i) begin
    if (rst_ni && update_valid_i) begin
      bp_update(longint'(update_pc_i), longint'(ghr_q), byte'(update_taken_i), longint'(update_target_i));
      $display("[ibex_branch_predict_dpi] update pc=0x%08h ghr=0x%08h taken=%0d target=0x%08h",
               update_pc_i, ghr_q, update_taken_i, update_target_i);
    end
  end

endmodule
