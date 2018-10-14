`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/18 19:01:00
// Design Name: 
// Module Name: MEM_WB_REG
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


module MEM_WB_REG(
    input  clk,
    input  reset,
    input  cancel,
    
    input  MEM_over,
    input  WB_allow_in,
    
    input      [127:  0] MEM_OUT,
    output reg [127:  0] WB_IN,
    
    input      [6  :  0] MEM_OUT_EXC,
    /*
        [6] PC取指错
        [5] Load地址错
        [4] Store地址错
        [3] syscall
        [2] break
        [1] 保留指令例外
        [0] overflow
    */
    output reg [7  :  0] WB_IN_EXC,
    /*
        [7] BD default : 0
        [6] PC取指错
        [5] Load地址错
        [4] Store地址错
        [3] syscall
        [2] break
        [1] 保留指令例外
        [0] overflow
    */
    input MEM_OUT_DELAY,
    
    input if_addr_ok
    );
    
    /*
        [31:0] IR@W
        [31:0] PC4@W
        [31:0] AO@W
        [31:0] lo_result@W
        共128bit
    */
    
    initial
    begin
        WB_IN     <= 128'b0;
        WB_IN_EXC <= 8'b0;
    end
    
    always @(posedge clk)
    begin
        if ( (cancel & if_addr_ok) | reset )
        begin
            /*
                寄存器清零：
                    1、复位 reset
                    2、异常 cancel
            */
            WB_IN     <= 128'b0;
            WB_IN_EXC <= 8'b0;
        end
        else if ( MEM_over & WB_allow_in )
        begin
            /*
                更新寄存器：
                    MEM阶段已完成，WB阶段允许进入
                    由于WB阶段一直允许进入，因此只要MEM阶段完成即可更新
            */
            WB_IN     <=   MEM_OUT;
            WB_IN_EXC <= { MEM_OUT_DELAY, MEM_OUT_EXC };
        end
            /*
                由于WB阶段一个周期内一定能完成
                若MEM阶段还未完成，则寄存器不清零（保持不变）
                可以为之前阶段提供必要的转发
                （如果清零，则之前阶段的指令将无法拿到更新后的值）
                
                其余情况，寄存器中的值保持不变
            */
    end
    
endmodule
