//===================================================================================
// Project      : aes (advanced encryption standard)
// File name    : g_function.sv 
// Designer     : Albin Gomes
// Device       : 
// Description  :
// Limitations  :
// Version      :
//===================================================================================

module g_function (
  input           clk,
  input           reset_n,
  input           enable,
  input   [31:0]  data_in,
  input   [3:0]   key_transform,    
  output  [31:0]  data_out,
  output  logic   done,
  output          o_state_error
);

//-----------------------------------------------------------------------------------
// Nets, Regs and states
//-----------------------------------------------------------------------------------
logic [3:0][7:0] data_reg; // 4 array elements of  bits each
logic      [2:0] present_state, next_state;
logic            state_error;
// FSM encoding: hard encoded
localparam s0_data_load     = 3'b001;
localparam s1_sbox          = 3'b010;
localparam s2_round_cooeff  = 3'b100;

// Round coefficient values RC[i] where i is the round/transform number
// RC[i] = x * RC[i-1] (multiplying by x => multiplying by 2  => left shifft by 1)
// Needs to be reduced by irreducible polynomial if the highest exponent for x > 7 for a particular RC[i]
// Property of Galois Field requires all resultant element to be within the field
// Irreducible polynomial: x^8 + x^4 + x^3 + x + 1
// Ex: GF(2^3) = {000,001,010,011,100,101,110,111} = {0,1,x,x+1,x^2,x^2+1,x^2+x,x^2+x+1}
/*
localparam R_1  = 8'b00000001;
localparam R_2  = 8'b00000010;
localparam R_3  = 8'b00000100;
localparam R_4  = 8'b00001000;
localparam R_5  = 8'b00010000;
localparam R_6  = 8'b00100000;
localparam R_7  = 8'b01000000;
localparam R_8  = 8'b10000000;
localparam R_9  = 8'b00011011;
localparam R_10 = 8'b00110110;
*/

localparam [0:9][7:0] RC = {{8'b00000001},
                            {8'b00000010},
                            {8'b00000100},
                            {8'b00001000},
                            {8'b00010000},
                            {8'b00100000},
                            {8'b01000000},
                            {8'b10000000},
                            {8'b00011011},
                            {8'b00110110}};
                            
logic sbox_done;
logic sbox0_done;
logic sbox1_done;
logic sbox2_done;
logic sbox3_done; 
logic s_box_enable;     

//-----------------------------------------------------------------------------------
// Instantiations
//-----------------------------------------------------------------------------------

s_box s_box_0 (
  .clk        (clk),
  .reset_n    (reset_n),
  .enable     (s_box_enable),
  .data_in    (data_reg[0]),
  .data_out   (data_reg[0]),
  .done       (sbox0_done)
);

s_box s_box_1 (
  .clk        (clk),
  .reset_n    (reset_n),
  .enable     (s_box_enable),
  .data_in    (data_reg[1]),
  .data_out   (data_reg[1]),
  .done       (sbox1_done)
);

s_box s_box_2 (
  .clk        (clk),
  .reset_n    (reset_n),
  .enable     (s_box_enable),
  .data_in    (data_reg[2]),
  .data_out   (data_reg[2]),
  .done       (sbox2_done)
);

s_box s_box_3 (
  .clk        (clk),
  .reset_n    (reset_n),
  .enable     (s_box_enable),
  .data_in    (data_reg[3]),
  .data_out   (data_reg[3]),
  .done       (sbox3_done)
);

//-----------------------------------------------------------------------------------
// Assignment
//-----------------------------------------------------------------------------------

assign data_out     = {data_reg[3],data_reg[2],data_reg[1],data_reg[0]};
assign sbox_done    = sbox0_done && sbox1_done && sbox2_done && sbox3_done;
assign state_error  = (present_state == s0_data_load    || 
                       present_state == s1_sbox         ||
                       present_state == s2_round_cooeff 
                       )? 0:1;
assign o_state_error = state_error;

//-----------------------------------------------------------------------------------
// Process
//-----------------------------------------------------------------------------------

//--------------
//State Machine
//--------------

//Async next state logic
always_comb begin
  case(present_state)
    s0_data_load:
    begin
      next_state = (enable == 1) ? s1_sbox:s0_data_load;
    end
    s1_sbox:
    begin
      next_state = (sbox_done == 1) ? s2_round_cooeff:s1_sbox;
    end
    s2_round_cooeff:
    begin
      next_state = (enable == 1) ? s2_round_cooeff:s0_data_load;
    end
    default:
    begin
      next_state = s0_data_load;
    end
  endcase
end

//Sync signal assignment
always_ff(posedge clk, negedge reset_n) begin
  if(reset_n == 0) begin
    data_reg[0]   <= 0;
    data_reg[1]   <= 0;
    data_reg[2]   <= 0;
    data_reg[3]   <= 0;
    s_box_enable  <= 0;
    done          <= 0;
  end
  else begin
    present_state <= (state_error == 1) ? s0_data_load:next_state;
    case(present_state) 
      s0_data_load:
      begin
        data_reg[0]   <= data_in[15:8];
        data_reg[1]   <= data_in[23:16];
        data_reg[2]   <= data_in[31:24];
        data_reg[3]   <= data_in[7:0];
        s_box_enable  <= 0;
        done          <= 0;
      end 
      s1_sbox:
      begin
        s_box_enable  <= 1;
        done          <= 0;
      end
      s2_round_cooeff:
      begin
        s_box_enable  <= 0;
        data_reg[0]   <= data_reg[0] ^ RC[key_transform];
        done          <= 1;
      end
      default:
      begin
        data_reg[0]   <= data_in[15:8];
        data_reg[1]   <= data_in[23:16];
        data_reg[2]   <= data_in[31:24];
        data_reg[3]   <= data_in[7:0];
        s_box_enable  <= 0;
        done          <= 0;
      end
    endcase
  end 
end

endmodule