`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/18 13:59:10
// Design Name: 
// Module Name: ID_EXE_REG
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


module ID_EXE_REG(
    input  clk,
    input  reset,
    input  cancel,
    
    input  ID_over,
    input  EXE_allow_in,
    
    // ID阶段输出总线
    input      [159:  0] ID_OUT,
    // EXE阶段输入总线
    output reg [159:  0] EXE_IN,
    
    input      [3  :  0] ID_OUT_EXC,
    output reg [3  :  0] EXE_IN_EXC,
    /*
        [3] 保留指令
        [2] break
        [1] syscall
        [0] PC取指错
    */
    input      ID_OUT_DELAY,
    output reg EXE_IN_DELAY,
    
    input IF_over,
    input ID_allow_in
    );
    
    /*
        [31:0] IR@E     本级指令
        [31:0] PC4@E    延迟槽指令
        [31:0] RS@E     操作数1
        [31:0] RT@E     操作数2
        [31:0] EXT@E    立即数扩展
        共160bit
    */
    
    initial
    begin
        EXE_IN       <= 160'b0;
        EXE_IN_EXC   <= 4'b0;
        EXE_IN_DELAY <= 1'b0;
    end
    
    always @(posedge clk)
    begin
        if ( cancel | reset | (~ID_over & EXE_allow_in) )
        begin
            /*
                寄存器清零：
                    1、复位 reset
                    2、异常 cancel
                    3、ID阶段未结束，EXE阶段已经允许进入
            */
            EXE_IN       <= 160'b0;
            EXE_IN_EXC   <= 4'b0;
            EXE_IN_DELAY <= 1'b0;
        end
        else if ( ID_over & EXE_allow_in & ID_allow_in & IF_over )
        begin
            /*
                更新寄存器：
                    ID阶段完成，EXE阶段允许进入
                    更新阶段总线以及异常标识位
            */
            EXE_IN       <= ID_OUT;
            EXE_IN_EXC   <= ID_OUT_EXC;
            EXE_IN_DELAY <= ID_OUT_DELAY;
        end
        else if ( ID_over & EXE_allow_in )
        begin
            EXE_IN       <= 160'b0;
            EXE_IN_EXC   <= 4'b0;
            EXE_IN_DELAY <= 1'b0;
        end
            /*
                其余情况，寄存器中的值保持不变
            */
    end
    
endmodule
