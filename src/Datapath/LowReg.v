`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/19 09:23:06
// Design Name: 
// Module Name: LowReg
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


module LowReg(

    input  clk,
    
    // LO寄存器写使能
    input  lo_wen,
    
    // 数据输入
    input      [31: 0] lo_in,
    
    // 数据输出
    output reg [31: 0] lo_out
    );
    
    initial
    begin
        lo_out <= 32'b0;
    end
    
    always @(posedge clk)
    begin
        if (lo_wen)
        begin
            lo_out <= lo_in;
        end
    end
endmodule
