`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/19 10:17:57
// Design Name: 
// Module Name: MUX_3
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


module MUX_3(

    input  [31: 0] source_0,
    input  [31: 0] source_1,
    input  [31: 0] source_2,
    input  [1 : 0] sel,
    output [31: 0] sel_result
    
    );
    
    assign sel_result = (sel == 2'b00) ? source_0 :
                        (sel == 2'b01) ? source_1 :
                        (sel == 2'b10) ? source_2 :
                        0;
    
endmodule
