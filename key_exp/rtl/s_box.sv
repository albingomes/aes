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
localparam s0_load        = 3'b001;
localparam s1_div_start   = 3'b010;
localparam s2  = 3'b100;

logic [8:0] rem_prev, rem_present;  // division remainder
localparam P_x = 9'b100011011;      // irreducible polynomial for GF(2^8): x^8 + x^4 + x^3 + x + 1
logic [7:0] t_prev, t_present;      // t(x) = A^-1(x) mod P(x); essentially t(x) is inverse of data_in i.e. A(x)
logic [7:0] quotient;               // division quotient
logic [8:0] product_reg;            // holds the product of divider and quotient

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
      next_state = (enable == 1) ? s1_div_start:s0_load;
     end 
     s1_div_start:
     begin
      next_state = s2;
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
    product_reg <= 9'h000;
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
        quotient    <= 8'h01;
        product_reg <= 9'h000;
      end 
      s1_div_start:
      begin
        if(rem_present < rem_prev) begin
          if(rem_present[8] == 1) begin
            quotient      <= 8'h01;
            product_reg   <= rem_present;
          end
          else if(rem_present[7] == 1) begin
            quotient      <= quotient << 1;
            product_reg   <= rem_present << 1;
          end
          else if(rem_present[6] == 1) begin
            quotient      <= quotient << 2;
            product_reg   <= rem_present << 2;
          end
          else if(rem_present[5] == 1) begin
            quotient      <= quotient << 3;
            product_reg   <= rem_present << 3;
          end
          else if(rem_present[4] == 1) begin
            quotient      <= quotient << 4;
            product_reg   <= rem_present << 4;
          end
          else if(rem_present[3] == 1) begin
            quotient      <= quotient << 5;
            product_reg   <= rem_present << 5;
          end
          else if(rem_present[2] == 1) begin
            quotient      <= quotient << 6;
            product_reg   <= rem_present << 6;
          end
          else if(rem_present[1] == 1) begin
            quotient      <= quotient << 7;
            product_reg   <= rem_present << 7;
          end
          else if(rem_present[0] == 1) begin
            quotient      <= quotient << 8;
            product_reg   <= rem_present << 8;
          end
        end
        else begin
          quotient        <= 8'h01;
          product_reg     <= rem_present;
        end
      end
     
      default:
      begin
    
    
      end
    endcase
  end
end 


endmodule