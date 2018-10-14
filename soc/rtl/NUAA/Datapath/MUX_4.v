`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/19 15:53:07
// Design Name: 
// Module Name: MUX_4
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


module MUX_4(

    input  [31: 0] source_0,
    input  [31: 0] source_1,
    input  [31: 0] source_2,
    input  [31: 0] source_3,
    input  [1 : 0] sel,
    output [31: 0] sel_result
    
    );
    
    assign sel_result = (sel == 2'b00) ? source_0 :
                        (sel == 2'b01) ? source_1 :
                        (sel == 2'b10) ? source_2 :
                        (sel == 2'b11) ? source_3 :
                        0;
endmodule
