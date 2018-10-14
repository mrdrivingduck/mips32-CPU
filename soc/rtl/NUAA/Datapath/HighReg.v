`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/19 09:18:45
// Design Name: 
// Module Name: HighReg
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


module HighReg(

    input  clk,
    
    // HI寄存器写使能
    input  hi_wen,
    
    // 数据送入
    input      [31: 0] hi_in,
    
    // 数据输出
    output reg [31: 0] hi_out
    );
    
    initial
    begin
        hi_out <= 32'b0;
    end
    
    always @(posedge clk)
    begin
        if (hi_wen)
        begin
            hi_out <= hi_in;
        end
    end
    
endmodule
