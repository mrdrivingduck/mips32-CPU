`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/14 23:03:13
// Design Name: 
// Module Name: IF_ID_REG
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

module IF_ID_REG(

    input               clk,
    input               reset,
    input               cancel,
    
    input               IF_over,
    input               ID_allow_in,
    
    input       [63: 0] IF_OUT,
    output reg [63: 0]  ID_IN,
    
    input               PC_EXC_IF,
    output reg         PC_EXC_ID,
    output reg         DELAY,
    input              jbr
    
    );
    
    /*
        [31:0] IR@D     本级指令
        [31:0] PC4@D    延迟槽指令
        共64bit
    */
    
    // 初始化
    initial
    begin
        ID_IN     <= 64'b0;
        PC_EXC_ID <= 1'b0;
        DELAY     <= 1'b0;
    end

    always @(posedge clk)
    begin
        if (cancel | reset)
        begin
            /*
                寄存器清零：
                    1、异常 cancel
                    2、复位 reset
            */
            ID_IN     <= 64'b0;
            PC_EXC_ID <= 1'b0;
            DELAY     <= 1'b0;
        end
        else if (ID_allow_in & IF_over & ~PC_EXC_IF & jbr)
        begin
            /*
                更新寄存器：
                    ID阶段允许进入，寄存器中当前指令为J类指令或Branch类指令
                    且当前指令满足跳转条件,则打上延迟槽标记
                    且下条指令PC有效
            */
            ID_IN     <= IF_OUT;
            PC_EXC_ID <= PC_EXC_IF;
            DELAY     <= 1'b1;
        end
        else if (ID_allow_in & IF_over & ~PC_EXC_IF)
        begin
            /*
                更新寄存器：
                    ID阶段允许进入，且下一条指令不是延迟槽指令
                    且下条指令PC有效
            */
            ID_IN     <= IF_OUT;
            PC_EXC_ID <= PC_EXC_IF;
            DELAY     <= 1'b0;
        end
        else if (IF_over & ID_allow_in & PC_EXC_IF)
        begin
            /*
                更新寄存器中的PC，指令置0，PC异常位置1：
                    IF阶段取指结束，ID阶段允许进入
                    PC地址不对齐于字边界
            */
            ID_IN     <= {32'b0, IF_OUT[31:0]};
            PC_EXC_ID <= PC_EXC_IF;
            DELAY     <= 1'b0;
        end
            /*
                其余情况，寄存器中的值保持不变
            */
    end
    
endmodule
