`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJiantang
// 
// Create Date: 2017/06/19 10:13:23
// Design Name: 
// Module Name: MUX_2
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


module MUX_2(

    input  [31: 0] source_0,
    input  [31: 0] source_1,
    input          sel,
    output [31: 0] sel_result
    );
    
    assign sel_result = sel ? source_1 : source_0;
    
endmodule
