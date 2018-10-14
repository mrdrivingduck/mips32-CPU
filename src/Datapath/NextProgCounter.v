`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/18 13:24:04
// Design Name: 
// Module Name: NextProgCounter
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


module NextProgCounter(

    // 延迟槽PC输入
    input  [31: 0] add4,
    
    // 指令低26bit输入
    input  [25: 0] imm26,
    
    // 功能选择
    input  func_choice,
    
    // 下一PC输出
    output [31:0] next_pc
    
    );
    
    /*
        功能选择
            func_choice == 0 : Branch类指令
            func_choice == 1 : Jump类指令
    */
    
    assign next_pc = (func_choice == 0) ? ( add4 + { {14{imm26[15]} }, imm26[15:0], 2'b00} ) :      // Branch类npc计算
                     (func_choice == 1) ? { add4[31:28]              , imm26[25:0], 2'b00}   :      // Jump类npc计算
                     0;
    
endmodule
