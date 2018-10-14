`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/19 15:33:25
// Design Name: 
// Module Name: ProgramCounter
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


`define INIT_ADDRESS 32'hbfc00000;

module ProgramCounter(

    input              clk,
    input              reset,
    input              pc_wen,
    input      [31: 0] npc,
    output reg [31:0 ] pc
    
    );
    
    initial
    begin
        pc <= `INIT_ADDRESS;
    end
    
    always @(posedge clk)
    begin
        // 复位
        if (reset)
        begin
            pc <= `INIT_ADDRESS;
        end
        // 更新下一PC
        else if (pc_wen)
        begin
            pc <= npc;
        end
        // 除此之外，不变
    end
    
endmodule
