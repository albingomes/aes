//===================================================================================
// Project      : aes (advanced encryption standard)
// File name    : aes_top.sv 
// Designer     : Albin Gomes
// Device       : 
// Description  :
// Limitations  :
// Version      :
//===================================================================================

module aes_top (
  // Input
  input         clk,
  input         reset_n,
  input [127:0] key_128,
  input [127:0] plaintext,
  // Output
  output [127:0] ciphertext
);

//-----------------------------------------------------------------------------------
// Nets and Regs
//-----------------------------------------------------------------------------------

logic [127:0] key_out;
logic [4:0]   round;


//-----------------------------------------------------------------------------------
// Instantations
//-----------------------------------------------------------------------------------

key_exp_top key_exp_top_0 (
  .clk        (clk),
  .reset_n    (reset_n),
  .round      (round),
  .key        (key_128),
  .key_out    (key_out)
);
