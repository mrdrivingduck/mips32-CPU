`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/18 19:19:28
// Design Name: 
// Module Name: LoadExtension
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


module LoadExtension(

    // 读取所得的数据
    input  [31: 0] load_data,
    input  [1 : 0] byte_address,
    
    // 功能选择
    input  [2 : 0] func_choice,
    
    // 扩展结果
    output [31: 0] ext_result
    
    );
    
    /*
        功能选择：
            func_choice == 000 : LB
            func_choice == 001 : LBU
            func_choice == 010 : LH
            func_choice == 011 : LHU
            func_choice == 100 : LW
    */
    
    assign ext_result = ( func_choice == 3'b000 && byte_address    == 2'b00 ) ? { { 24{load_data[7]}  }, load_data[7 : 0] } :    // LB
                        ( func_choice == 3'b000 && byte_address    == 2'b01 ) ? { { 24{load_data[15]} }, load_data[15: 8] } :    // LB
                        ( func_choice == 3'b000 && byte_address    == 2'b10 ) ? { { 24{load_data[23]} }, load_data[23:16] } :    // LB
                        ( func_choice == 3'b000 && byte_address    == 2'b11 ) ? { { 24{load_data[31]} }, load_data[31:24] } :    // LB
                        ( func_choice == 3'b001 && byte_address    == 2'b00 ) ? {   24'b0              , load_data[7 : 0] } :    // LBU
                        ( func_choice == 3'b001 && byte_address    == 2'b01 ) ? {   24'b0              , load_data[15: 8] } :    // LBU
                        ( func_choice == 3'b001 && byte_address    == 2'b10 ) ? {   24'b0              , load_data[23:16] } :    // LBU
                        ( func_choice == 3'b001 && byte_address    == 2'b11 ) ? {   24'b0              , load_data[31:24] } :    // LBU
                        ( func_choice == 3'b010 && byte_address[1] == 1'b0 )  ? { { 16{load_data[15]} }, load_data[15: 0] } :    // LH
                        ( func_choice == 3'b010 && byte_address[1] == 1'b1 )  ? { { 16{load_data[31]} }, load_data[31:16] } :    // LH
                        ( func_choice == 3'b011 && byte_address[1] == 1'b0 )  ? {   16'b0              , load_data[15: 0] } :    // LHU
                        ( func_choice == 3'b011 && byte_address[1] == 1'b1 )  ? {   16'b0              , load_data[31:16] } :    // LHU
                        ( func_choice == 3'b100) ? load_data :                                                                   // LW
                        0;
    
endmodule
