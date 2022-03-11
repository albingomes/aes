//===================================================================================
// Project      : aes (advanced encryption standard)
// File name    : key_exp_128.sv 
// Designer     : Albin Gomes
// Device       : 
// Description  :
// Limitations  :
// Version      :
//===================================================================================

module key_exp_top (
  // Input
  input             clk,
  input             reset_n,
  input             enable,
  input             key_ack,       // '1' when key is accepted by aes top and indicates key expansion should proceed to next round
  input   [127:0]   key,            
  // Output
  output            key_ready,     // '1' when key is ready 
  output  [3:0]     key_transform, // indicating round #
  output  [127:0]   key_out,
  output            o_state_error,  // FSM error detection
  output            g_state_error   // g_function state machine error detection
);

//-----------------------------------------------------------------------------------
// Nets, Regs and states
//-----------------------------------------------------------------------------------

logic                   enable_reg;
logic       [3:0][31:0] key_reg; // 4 array elements of 32 bits each, holds key of each round
logic                   g_enable;
logic                   g_done;
logic       [31:0]      g_data;
logic       [6:0]       present_state, next_state;
logic                   state_error;
logic                   g_state_error;
// FSM encoding: hard encoded
localparam   s0_key_load        = 7'b0000001;
localparam   s1_g_function      = 7'b0000010;
localparam   s2_word0_complete  = 7'b0000100;
localparam   s3_word1_complete  = 7'b0001000;
localparam   s4_word2_complete  = 7'b0010000;
localparam   s5_word3_complete  = 7'b0100000;
localparam   s6_wait_for_ack    = 7'b1000000;

//-----------------------------------------------------------------------------------
// Instantiations
//-----------------------------------------------------------------------------------

g_function g_function_0(
  .clk            (clk),
  .reset_n        (reset_n),
  .enable         (g_enable),
  .key_transform  (key_transform),
  .data_in        (key_reg[3]),
  .data_out       (g_data),
  .done           (g_done),
  .o_state_error  (g_state_error)
);

//-----------------------------------------------------------------------------------
// Assignment
//-----------------------------------------------------------------------------------

assign key_out = {key_reg[3],key_reg[2],key_reg[1],key_reg[0]};
assign state_error = (  present_state == s0_key_load        || 
                        present_state == s1_g_function      || 
                        present_state == s2_word0_complete  || 
                        present_state == s3_word1_complete  ||
                        present_state == s4_word2_complete  ||
                        present_state == s5_word3_complete  ||
                        present_state == s6_wait_for_ack    || ) ? 0:1;
assign o_state_error = state_error;
//-----------------------------------------------------------------------------------
// Processes
//-----------------------------------------------------------------------------------

//--------------
// Enable edge detect
//--------------

always_ff@(posedge clk, negedge reset_n) begin
  enable_reg <= (reset_n == 0) ? 0:enable;
end

//--------------
//State Machine
//--------------

// Async next state logic
always_comb begin
  case(present_state)
    s0_key_load:
    begin
      next_state = (enable == 1 && enable_reg == 0) ? s1_g_function:s0_key_load;
    end 
    s1_g_function:
    begin 
      next_state = (g_done == 1) ? s2_word0_complete:s1_g_function;
    end
    s2_word0_complete:
    begin
      next_state = s3_word1_complete;
    end:
    s3_word1_complete
    begin
      next_state = s4_word2_complete;
    end
    s4_word2_complete:
    begin
      next_state = s5_word3_complete;
    end
    s5_word3_complete:
    begin
      next_state = s6_wait_for_ack;
    end
    s6_wait_for_ack:
    begin
      if (key_ack == 1) begin
        next_state = (key_transform == 10) ? s0_key_load:s1_g_function;
      end
      else begin
        next_state = s6_wait_for_ack;
      end
    end
    default:
    begin
      next_state = s_idle;
    end
  endcase
end

// Sync signal assignment 
always_ff@(posedge clk, negedge reset_n) begin
 if(reset_n == 0) begin
  key_reg[0]    <= 0;
  key_reg[1]    <= 0;
  key_reg[2]    <= 0;
  key_reg[3]    <= 0;
  g_enable      <= 0;
  key_transform <= 0;
  key_ready     <= 0;
 end
 else begin
  present_state <= (state_error == 1) ? s0_key_load:next_state;
  case(present_state)
    s0_key_load:
    begin
      key_reg[0]    <= key[31:0];
      key_reg[1]    <= key[63:32];
      key_reg[2]    <= key[95:64];
      key_reg[3]    <= key[127:96];
      g_enable      <= 0;
      key_transform <= 0;
      key_ready     <= 0;
    end
    s1_g_function:
    begin
      g_enable      <= 1;
      key_ready     <= 0;
    end
    s2_word0_complete:
    begin
      key_reg[0]    <= key_reg[0] ^ g_data;
      g_enable      <= 0;
      key_transform <= key_transform + 1;
    end
    s3_word1_complete:
    begin
      key_reg[1]    <= key_reg[1] ^ key_reg[0];
    end
    s4_word2_complete:
    begin
     key_reg[2]     <= key_reg[2] ^ key_reg[1];
    end
    s5_word3_complete:
    begin
      key_reg[3]    <= key_reg[3] ^ key_reg[2];
      key_ready     <= 1;
    end
    s6_wait_for_ack:
    begin
      key_ready     <= 1;
    end
    default:
    begin
      key_reg[0]    <= key[31:0];
      key_reg[1]    <= key[63:32];
      key_reg[2]    <= key[95:64];
      key_reg[3]    <= key[127:96];
      g_enable      <= 0;
      key_transform <= 0;
      key_ready     <= 0;
    end 
  endcase 
 end
end 

endmodule