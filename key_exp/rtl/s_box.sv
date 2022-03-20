//===================================================================================
// Project      : aes (advanced encryption standard)
// File name    : s_box.sv 
// Designer     : Albin Gomes
// Device       : 
// Description  :
// Limitations  :
// Version      :
//===================================================================================

module s_box (
  input         clk,
  input         reset_n,
  input         enable,
  input   [7:0] data_in,  // A(x)
  output  [7:0] data_out, 
  output        done
);

//-----------------------------------------------------------------------------------
// Nets, Regs and states
//-----------------------------------------------------------------------------------

logic [2:0] present_state, next_state;
// FSM encoding: hard encoded
localparam s0_load  = 3'b001;
localparam s1  = 3'b010;
localparam s2  = 3'b100;

logic [8:0] rem_prev, rem_present;  // division remainder
localparam P_x = 9'b100011011;      // irreducible polynomial for GF(2^8): x^8 + x^4 + x^3 + x + 1
logic [7:0] t_prev, t_present;      // t(x) = A^-1(x) mod P(x); essentially t(x) is inverse of data_in i.e. A(x)
logic [7:0] quotient;               // division quotient


//-----------------------------------------------------------------------------------
// Instantiations
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
// Assignment
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
// Process
//-----------------------------------------------------------------------------------

//--------------
//State Machine
//--------------

//async next state logic
always_comb begin
  case(present_state) 
     s0_load:
     begin
      next_state = (enable == 1) ? s1:s0_load;
     end 
     default:
     begin
     
     end
  endcase
end 

//sync signal assignment
always_ff(posedge clk, negedge reset_n) begin
  if(reset_n == 0) begin
    rem_prev    <= 9'h000;
    rem_present <= 9'h000;
    t_prev      <= 8'h00;
    t_present   <= 8'h00;
    quotient    <= 8'h00;
  end
  else begin
    present_state <= next_state;
    case(present_state) 
      s0_load:
      begin
        rem_prev    <= P_x;
        rem_present <= {1'b0,data_in};
        t_prev      <= 0; // init value
        t_present   <= 1; // init value
        quotient    <= 8'h00;
      end 
      s1:
      begin
      
      
      end
      
      
      
      default:
      begin
    
    
      end
    endcase
  end
end 


endmodule