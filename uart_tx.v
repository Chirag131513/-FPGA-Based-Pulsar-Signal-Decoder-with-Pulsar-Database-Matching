// File: uart_tx.v
// Description: UART Transmitter module.
`timescale 1ns / 1ps

module uart_tx #(
 parameter CLKS_PER_BIT = 5208 // For 9600 baud @ 50 MHz clock
)(
 input wire clk,
 input wire rst,
 input wire tx_start,
 input wire [31:0] data_in,
 output reg tx_out = 1'b1,
 output reg tx_busy
);
 localparam [1:0]
 S_IDLE = 2'b00,
 S_START_BIT = 2'b01,
 S_DATA_BITS = 2'b10,
 S_STOP_BIT = 2'b11;
 reg [1:0] current_state;
 reg [$clog2(CLKS_PER_BIT)-1:0] clk_counter;
 reg [4:0] bit_index;
 reg [31:0] data_reg;

 always @(posedge clk) begin
 if (rst) begin
 current_state <= S_IDLE;
 tx_out <= 1'b1;
 tx_busy <= 1'b0;
 clk_counter <= 0;
 bit_index <= 0;
 end else begin
 case (current_state)
 S_IDLE: begin
 tx_busy <= 1'b0;
 tx_out <= 1'b1;
 if (tx_start) begin
 data_reg <= data_in;
 tx_busy <= 1'b1;
 clk_counter <= 0;
 current_state <= S_START_BIT;
 end
 end
 S_START_BIT: begin
 tx_out <= 1'b0;
 if (clk_counter == CLKS_PER_BIT - 1) begin
 clk_counter <= 0;
 bit_index <= 0;
 current_state <= S_DATA_BITS;
 end else begin
 clk_counter <= clk_counter + 1;
 end
 end
 S_DATA_BITS: begin
 tx_out <= data_reg[bit_index];
 if (clk_counter == CLKS_PER_BIT - 1) begin
 clk_counter <= 0;
 if (bit_index == 31) begin
 current_state <= S_STOP_BIT;
 end else begin
 bit_index <= bit_index + 1;
 end
 end else begin
 clk_counter <= clk_counter + 1;
 end
 end
 S_STOP_BIT: begin
 tx_out <= 1'b1;
 if (clk_counter == CLKS_PER_BIT - 1) begin
 clk_counter <= 0;
 current_state <= S_IDLE;
 end else begin
 clk_counter <= clk_counter + 1;
 end
 end
 default: current_state <= S_IDLE;
 endcase
 end
 end
endmodule
