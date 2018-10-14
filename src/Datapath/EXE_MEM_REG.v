`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/18 18:33:28
// Design Name: 
// Module Name: EXE_MEM_REG
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


module EXE_MEM_REG(
    input  clk,
    input  reset,
    input  cancel,
    
    input  EXE_over,
    input  MEM_allow_in,
    
    input      [127:  0] EXE_OUT,
    output reg [127:  0] MEM_IN,
    
    input      [4  :  0] EXE_OUT_EXC,
    output reg [4  :  0] MEM_IN_EXC,
    /*
        [4] overflow
        [3] 保留指令
        [2] break
        [1] syscall
        [0] PC取指错
    */
    input      EXE_OUT_DELAY,
    output reg MEM_IN_DELAY
    );
    
    /*
        [31:0] IR@M     本级指令
        [31:0] PC4@M    延迟槽指令
        [31:0] AO@M     ALU运算结果或乘除法高32bit
        [31:0] RT@M     写入DM的数据或乘除法低32bit
        共128bit
    */
    
    initial
    begin
        MEM_IN       <= 128'b0;
        MEM_IN_EXC   <= 5'b0;
        MEM_IN_DELAY <= 1'b0;
    end
    
    always @(posedge clk)
    begin
        if ( cancel | reset | (~EXE_over & MEM_allow_in) )
        begin
            /*
                寄存器清零：
                    1、复位 reset
                    2、异常 cancel
                    3、EXE阶段未结束，MEM阶段已经允许进入
            */
            MEM_IN       <= 128'b0;
            MEM_IN_EXC   <= 5'b0;
            MEM_IN_DELAY <= 1'b0;
        end
        else if ( EXE_over & MEM_allow_in )
        begin
            /*
                更新寄存器：
                    EXE阶段已经完成，MEM阶段允许进入
                    更新阶段总线以及所有异常标识位
            */
            MEM_IN       <= EXE_OUT;
            MEM_IN_EXC   <= EXE_OUT_EXC;
            MEM_IN_DELAY <= EXE_OUT_DELAY;
        end
            /*
                其余情况，寄存器中的值保持不变
            */
    end
    
endmodule
