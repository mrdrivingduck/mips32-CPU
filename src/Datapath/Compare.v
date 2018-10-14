`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/18 13:00:22
// Design Name: 
// Module Name: Compare
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


module Compare(

    // 数据输入
    input  [31: 0] busA,
    input  [31: 0] busB,
    
    // 功能选择
    input  [2 : 0] func_choice,
    
    // 结果输出
    output comp_result
    );
    
    /*
        功能选择：
            func_choice == 000 : 判断 busA 是否 == busB
            func_choice == 001 : 判断 busA 是否 != busB
            func_choice == 010 : 判断 busA 是否 < busB
            func_choice == 011 : 判断 busA 是否 > busB
            func_choice == 100 : 判断 busA 是否 <= busB
            func_choice == 101 : 判断 busA 是否 >= busB
            其余控制信号为非法
            只可能有一个输出
    */
    /*
        结果输出：
            满足条件 ：   输出1
            不满足条件 ： 输出0
    */
    
    assign comp_result = ( (func_choice == 3'b000) & (busA == busB) )                          ? 1 :
                         ( (func_choice == 3'b001) & (busA != busB) )                          ? 1 :
                         ( (func_choice == 3'b010) & (busA[31] == 1'b1) )                      ? 1 :
                         ( (func_choice == 3'b011) & ( (busA > busB) & (busA[31] != 1'b1) ) )  ? 1 :
                         ( (func_choice == 3'b100) & ( (busA[31] == 1'b1) | (busA == busB) ) ) ? 1 :
                         ( (func_choice == 3'b101) & (busA[31] != 1'b1) )                      ? 1 :
                         0;
endmodule
