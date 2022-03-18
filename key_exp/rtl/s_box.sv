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
  input   [7:0] data_in,
  output  [7:0] data_out,
  output        done
);

//-----------------------------------------------------------------------------------
// Nets, Regs and states
//-----------------------------------------------------------------------------------

logic      [2:0] present_state, next_state;
// FSM encoding: hard encoded
localparam s0  = 3'b001;
localparam s1  = 3'b010;
localparam s2  = 3'b100;


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
     s0:
     begin
     
     
     end 
     default:
     begin
     
     end
  endcase
end 

//sync signal assignment
always_ff(posedge clk, negedge reset_n) begin
  if(reset_n == 0) begin
  
  
  end
  else begin
    present_state <= next_state;
    case(present_state) 
      s0:
      begin
    
      end 
      default:
      begin
    
    
      end
    endcase
  end
end 


endmodule