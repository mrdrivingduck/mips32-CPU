`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/07/05 12:56:58
// Design Name: 
// Module Name: StoreShifter
// Project Name: 
// Target Devices: 
// Tool Versions: 4.0
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module StoreShifter(

    input  [31: 0] store_data,
    output [31: 0] shift_data,
    
    input  [1 : 0] byte_addr,
    
    input  Instr_SB,
    input  Instr_SH

    );
    
    assign shift_data = ( Instr_SB & (byte_addr == 2'b11) )   ? store_data << 24 :
                        ( Instr_SB & (byte_addr == 2'b10) )   ? store_data << 16 :
                        ( Instr_SB & (byte_addr == 2'b01) )   ? store_data << 8  :
                        ( Instr_SH & (byte_addr[1] == 1'b1) ) ? store_data << 16 :
                        store_data;
    
endmodule
