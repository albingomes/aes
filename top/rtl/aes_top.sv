//===================================================================================
// Project      : aes (advanced encryption standard)
// File name    : aes_top.sv 
// Designer     : Albin Gomes
// Device       : 
// Description  :
// Limitations  :
// Version      :
//===================================================================================

module aes_top #(
  parameter int key_size = 128 // default = 128, choices: 128, 192, 256
)(
  // Input
  input         clk,
  input         reset_n,
  input         enable,
  input [255:0] key,        // shared for all key size use, for example bits [127:0] used for key size 128 bits
  input [127:0] plaintext,
  // Output
  output [127:0] ciphertext
);

//-----------------------------------------------------------------------------------
// Nets and Regs
//-----------------------------------------------------------------------------------

logic [255:0] key_out; // shared for all key sizes
logic [4:0]   round;


//-----------------------------------------------------------------------------------
// Instantiations
//-----------------------------------------------------------------------------------

generate
  case (key_size)
    128: begin
        key_exp_128_0 (
          .clk        (clk), 
          .reset_n    (reset_n),
          .enable     (enable),
          .round      (round),
          .key        (key[127:0]),
          .key_out    (key_out[127:0])
        );
      end 
    192:

    256: 

  endcase 
endgenerate 


endmodule