`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/19 10:21:28
// Design Name: 
// Module Name: MUX_6
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


module MUX_6(
    input  [31: 0] source_0,
    input  [31: 0] source_1,
    input  [31: 0] source_2,
    input  [31: 0] source_3,
    input  [31: 0] source_4,
    input  [31: 0] source_5,
    input  [2 : 0] sel,
    output [31: 0] sel_result
    );
    
    assign sel_result = (sel == 3'b000) ? source_0 :
                        (sel == 3'b001) ? source_1 :
                        (sel == 3'b010) ? source_2 :
                        (sel == 3'b011) ? source_3 :
                        (sel == 3'b100) ? source_4 :
                        (sel == 3'b101) ? source_5 :
                        0;
endmodule
