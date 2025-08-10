// File: ffa_engine.v
// Description: Synthesizable FFA Engine with correct memory initialization.
`timescale 1ns / 1ps

module ffa_engine (
 input wire clk,
 input wire rst,
 input wire [7:0] adc_data,
 output reg tx_start,
 output reg [31:0] tx_data,
 input wire tx_busy
);
 // ## FFA Parameters ##
 parameter DATA_BUFFER_SIZE = 16384;
 parameter PROFILE_BINS = 256;
 parameter NUM_TRIAL_PERIODS = 2048;
 parameter PROFILE_MEM_SIZE = NUM_TRIAL_PERIODS * PROFILE_BINS;

 // ## Data Storage ##
 reg [7:0] data_buffer [0:DATA_BUFFER_SIZE-1];
 reg [31:0] profile_memory [0:PROFILE_MEM_SIZE-1];

 // ## State Machine ##
 localparam [2:0]
 S_IDLE = 3'b000,
 S_ACQUIRE_DATA = 3'b001,
 S_FOLD_DATA = 3'b010,
 S_DETECT_PEAK = 3'b011,
 S_SEND_RESULT = 3'b100;
 reg [2:0] current_state;

 // ## Internal Signals and Counters ##
 reg [$clog2(DATA_BUFFER_SIZE):0] buffer_write_addr;
 reg [31:0] detected_period;
 integer i; // for loops

 always @(posedge clk) begin
 if (rst) begin
 current_state <= S_IDLE;
 buffer_write_addr <= 0;
 tx_start <= 1'b0;
 tx_data <= 32'd0;
 // Use the reset signal to clear memory for synthesis.
 for (i = 0; i < PROFILE_MEM_SIZE; i = i + 1) begin
 profile_memory[i] <= 32'd0;
 end
 end else begin
 tx_start <= 1'b0; // Default assignment
 case (current_state)
 S_IDLE: current_state <= S_ACQUIRE_DATA;
 S_ACQUIRE_DATA: begin
 data_buffer[buffer_write_addr] <= adc_data;
 if (buffer_write_addr == DATA_BUFFER_SIZE - 1) begin
 buffer_write_addr <= 0;
 current_state <= S_FOLD_DATA;
 end else begin
 buffer_write_addr <= buffer_write_addr + 1;
 end
 end
 S_FOLD_DATA: begin
 // Placeholder for your complex folding logic.
 current_state <= S_DETECT_PEAK;
 end
 S_DETECT_PEAK: begin
 // Placeholder for your peak detection logic
 detected_period <= 32'd1590; // Placeholder MSP period in microseconds
 current_state <= S_SEND_RESULT;
 end
 S_SEND_RESULT: begin
 if (!tx_busy) begin
 tx_data <= detected_period;
 tx_start <= 1'b1;
 current_state <= S_IDLE;
 end
 end
 default: current_state <= S_IDLE;
 endcase
 end
 end
endmodule
