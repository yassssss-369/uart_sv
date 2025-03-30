`timescale 1ns / 1ns
// Code your design here

module uart #(parameter DATA = 8, parameter CLK_RATE =153600, parameter BAUD_RATE = 9600 ) 
  (input logic clk, rst,
   input logic [DATA:0]data,
   output logic tx,
   input logic x,
   input logic rx
  );
  
  logic parity;
  logic [0:DATA+2]frame;
  logic [4:0]bit_count;
  logic [4:0] baud_count;
  
  typedef enum logic [1:0] {idle, start, stop} states;
  
  states current_state, next_state;
  states current_state_rx, next_state_rx;  
  
 
  always_comb begin 
    
    parity = ^data;
    frame = {1'b0,data,parity};
  
  end
  
  
  always_ff @(posedge clk or posedge rst) begin 
    
    
    if(rst)begin
      current_state <= idle;
      bit_count <= 0;
      tx <= 1;
      baud_count <= 4'b0;
    end
    
    
    else begin 
      current_state <= next_state;
    
      
      if (current_state == start) begin
         tx <= frame[bit_count];
         baud_count <= baud_count + 1;
        end
        
        if(baud_count == 15)begin
          bit_count <= bit_count + 1;
          baud_count <= 4'b0;
        end
      
  
      
      else if (current_state == stop) begin
        tx <= 1; // Stop bit is high
        baud_count <= baud_count + 1;
      
      end
      else if (current_state == idle) begin
        tx <= 1;
        bit_count <= 0;
        baud_count <= 0;
      end
    end
  end
  
  
  
   always_comb begin
        case (current_state)
            idle: 
                if (x)
                    next_state = start;
                else
                    next_state = idle;

            start: 
              if (bit_count < DATA + 2)
                    next_state = start;
                else
                    next_state = stop;

            stop: 
                if (baud_count == 15)
                    next_state = idle;
                else
                    next_state = stop;

            default: 
                next_state = idle;
        endcase
    end

      
  
   always_ff @(posedge clk) begin
   
     current_state_rx <= next_state_rx;
     rx <= tx;
  end
  
  
  always_comb begin 
    
    case(current_state_rx)
    
      idle: if(tx == 0) next_state_rx = start;
            else next_state_rx = idle;
    
      start :if(bit_count < DATA+2) next_state_rx = start;
             else if (bit_count > DATA + 2 && tx == 1'b1) next_state_rx = stop;
      
      stop: if(tx == 1'b1) next_state_rx = idle;
      default: next_state_rx = idle;
    endcase
  
  end
    
endmodule
