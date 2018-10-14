`timescale 1ns / 1ps
`define rs 25 : 21
`define rt 20 : 16
`define rd 15 : 11
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 宗华
// 
// Create Date: 2017/06/19 22:05:30
// Design Name: 
// Module Name: Forward_D
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


module Forward_D(
    /*输入监测指令*/
    input [31:0] IR_D ,
    //input [31:0] IR_E ,
    input [31:0] IR_M ,
    /*转发输入信号*/
    input [1:0] user_bus_D ,
    //D阶段的指令需要得到转发数据
    input forward_bus_E ,    
    input [2:0] forward_bus_M ,    
    //E,M阶段提供数据
    /*转发输出信号*/
    output [1:0]ForwardRSD ,
    output [1:0]ForwardRTD 
    );
    wire use_rs_D ;
    wire use_rt_D ;
    assign use_rs_D = user_bus_D[1] ;
    assign use_rt_D = user_bus_D[0] ;
    
    wire forward_31_E ;
    assign forward_31_E = forward_bus_E ;
    
    wire  forward_rd_M ;
    wire  forward_rt_M ;
    wire  forward_31_M ;
    assign forward_rd_M = forward_bus_M[2];
    assign forward_rt_M = forward_bus_M[1];
    assign forward_31_M = forward_bus_M[0]; 
    
    assign ForwardRSD = use_rs_D & forward_31_E & (IR_D[`rs] == 5'b11111) ? 2'b01 :
                        use_rs_D & forward_rd_M & (IR_D[`rs] == IR_M[`rd]) & (IR_D[`rs] != 5'b0)? 2'b10 :
                        use_rs_D & forward_rt_M & (IR_D[`rs] == IR_M[`rt]) & (IR_D[`rs] != 5'b0)? 2'b10 :
                        use_rs_D & forward_31_M & (IR_D[`rs] == 5'b11111) ? 2'b11 : 2'b00 ;
                        
    assign ForwardRTD = use_rt_D & forward_31_E & (IR_D[`rt] == 5'b11111) ? 2'b01 :
                        use_rt_D & forward_rd_M & (IR_D[`rt] == IR_M[`rd]) & (IR_D[`rt] != 5'b0)? 2'b10 :
                        use_rt_D & forward_rt_M & (IR_D[`rt] == IR_M[`rt]) & (IR_D[`rt] != 5'b0)? 2'b10 :
                        use_rt_D & forward_31_M & (IR_D[`rt] == 5'b11111) ? 2'b11 : 2'b00 ;                    
    
    
endmodule
