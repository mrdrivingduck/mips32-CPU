`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/18 12:41:38
// Design Name: 
// Module Name: Extension
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


module Extension(

    // 16 bit 立即数输入
    input  [15: 0] imm16,
    
    // 功能选择
    input  [1 : 0] func_choice,
    
    // 扩展结果
    output [31: 0] ext_result
    );
    
    /*
        func_choice == 00 : 带符号[15:0]16bit立即数扩展
        func_choice == 01 : 无符号[15:0]16bit立即数扩展
     // func_choice == 10 : 带符号[10:6]5bit立即数扩展
        func_choice == 11 : 无符号[10:6]5bit立即数扩展
    */
    assign ext_result = ( func_choice == 2'b00 ) ? { { 16{imm16[15]} }, imm16[15: 0] } :        // 带符号[15:0]16bit立即数扩展
                        ( func_choice == 2'b01 ) ? { { 16{1'b0} }     , imm16[15: 0] } :        // 无符号[15:0]16bit立即数扩展
                     // ( func_choice == 2'b10 ) ? { { 27{imm16[10]} }, imm16[10: 6] } :        // 带符号[10:6]5bit立即数扩展
                        ( func_choice == 2'b11 ) ? { { 27{1'b0}      }, imm16[10: 6] } :        // 无符号[10:6]5bit立即数扩展
                        32'b0;      // 控制信号非法
    
endmodule
