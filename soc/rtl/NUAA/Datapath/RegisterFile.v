`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/14 22:54:00
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile(

    input  clk,
    
    // READ
    input  [4 : 0] rs, rt,
    output [31: 0] busA, busB,
    
    // WRITE
    input          wen,
    input  [4 : 0] rd,
    input  [31: 0] data_in
    );
    
    reg [31: 0] regfile [31: 0];
   
    // READ 
    assign busA = (rs != 0) ? regfile[rs] : 0;
    assign busB = (rt != 0) ? regfile[rt] : 0;
    
    // WRITE
    always @(negedge clk)
    begin
        if (wen)
            regfile[rd] <= data_in;
    end
    
endmodule
