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
  input             key_ack,       //'1' when key is accepted by aes top and indicates key expansion should proceed to next round
  input   [127:0]   key,
  // Output
  output            key_ready,     //'1' when key is ready 
  output  [3:0]     key_transform, //key transform 0 -> 10
  output  [127:0]   key_out
);

//-----------------------------------------------------------------------------------
// Nets, Regs and states
//-----------------------------------------------------------------------------------

logic       [3:0][31:0] key_reg; // 4 array elements of 32 bits each, holds key of each round
logic                   g_enable;
logic                   g_done;
logic       [31:0]      g_data;
logic       [3:0]       present_state, next_state;
// FSM state encoding: hard encoded
localparam   s_idle  = 4'b00000;
localparam   s0      = 4'b00011;
localparam   s1      = 4'b00101;
localparam   s2      = 4'b00110;
localparam   s3      = 4'b01001;
localparam   s4      = 4'b01010;
localparam   s5      = 4'b01100;
localparam   s6      = 4'b01111;
localparam   s7      = 4'b10001;

//-----------------------------------------------------------------------------------
// Instantiations
//-----------------------------------------------------------------------------------

g_function g_function_0(
  .clk      (clk),
  .reset_n  (reset_n),
  .enable   (g_enable),
  .data_in  (key_reg[3]),
  .data_out (g_data)
);

//-----------------------------------------------------------------------------------
// Assignment
//-----------------------------------------------------------------------------------

assign key_out = {key_reg[3],key_reg[2],key_reg[1],key_reg[0]};

//-----------------------------------------------------------------------------------
// Processes
//-----------------------------------------------------------------------------------

//--------------
//State Machine
//--------------

// Async next state logic
always_comb@() begin
  case(present_state)
    s0: 
    begin
      if(enable == 1) begin
        if(key_ack == 1) begin
          next_state = s1;
        end  
        else begin
          next_state = s0;
        end
      end
      else begin
        next_state = s0;
      end
    end
    s1:
    begin
      next_state  = s2;
    end
    s2:
    begin
      if (g_done == 1) begin
        next_state = s3;
      end
      else begin
        next_state = s2;
      end
    end
    s3:
    begin
      next_state  = s4;
    end
    s4:
    begin
     next_state = s5;
    end
    s5:
    begin
      next_state = s6;
    end
    s6:
    begin
      next_state = s7;
    end
    s7:
    begin
      if(key_ack == 1) begin
        if(transform >= 10) begin
          next_state = s_idle;
        end
        else
          next_state = s1;
        end
      end
      else begin
        next_state = s7;
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
  present_state <= next_state;
  case(present_state)
    s_idle:
    begin
      key_reg[0]    <= 0;
      key_reg[1]    <= 0;
      key_reg[2]    <= 0;
      key_reg[3]    <= 0;
      g_enable      <= 0;
      key_transform <= 0;
      key_ready     <= 0;
    end
    s0: 
    begin
      key_reg[0]    <= key(31:0);
      key_reg[1]    <= key(63:32);
      key_reg[2]    <= key(95:64);
      key_reg[3]    <= key(127:96);
      key_transform <= 0;
      key_ready     <= 1;
      g_enable      <= 0;
    end
    s1:
    begin
      g_enable      <= 1;
      key_ready     <= 0;
      key_transform <= key_transform + 1;
    end 
    s2:
    begin
      g_enable      <= 0;
    end
    s3:
    begin
      key_reg[0]    <= key_reg[0] ^ g_data;
    end
    s4:
    begin
      key_reg[1]    <= key_reg[0] ^ key_reg[1];
    end
    s5:
    begin
      key_reg[2]    <= key_reg[2] ^ key_reg[1];
    end
    s6:
    begin
      key_reg[3]    <= key_reg[3] ^ key_reg[2];
      key_ready     <= 1;
    end
    s7:
    begin
      key_ready     <= 1;
      g_enable      <= 0;
    end
    default:
    begin
      key_reg[0]    <= 0;
      key_reg[1]    <= 0;
      key_reg[2]    <= 0;
      key_reg[3]    <= 0;
      g_enable      <= 0;
      key_transform <= 0;
      key_ready     <= 0;
    end 
  endcase 
 end
end 

endmodule