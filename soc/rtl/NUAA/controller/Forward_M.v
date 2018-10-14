`timescale 1ns / 1ps
`define rs 25 : 21
`define rt 20 : 16
`define rd 15 : 11
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 宗华
// 
// Create Date: 2017/06/19 22:44:44
// Design Name: 
// Module Name: Forward_M
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


module Forward_M(
    /*输入监测指令*/
    input [31:0] IR_M ,
    input [31:0] IR_W ,
    /*转发输入信号*/
    input [1:0] user_bus_M ,
    //M阶段的指令需要得到转发数据
    input [2:0] forward_bus_W ,
    //W阶段提供数据
    /*转发输出信号*/
    output ForwardRSM ,
    output ForwardRTM 
    );
    wire use_rs_M ;
    wire use_rt_M ;
    assign use_rs_M = user_bus_M[1] ;
    assign use_rt_M = user_bus_M[0] ;

    wire forward_rd_W ;
    wire forward_rt_W ;
    wire forward_31_W ;  
    assign forward_rd_W = forward_bus_W[2] ;
    assign forward_rt_W = forward_bus_W[1] ;
    assign forward_31_W = forward_bus_W[0] ;    
    
    assign ForwardRSM = use_rs_M & forward_rd_W & (IR_M[`rs] == IR_W[`rd]) & (IR_M[`rs] != 5'b0)? 1'b1 :
                        use_rs_M & forward_rt_W & (IR_M[`rs] == IR_W[`rt]) & (IR_M[`rs] != 5'b0)? 1'b1 :
                        use_rs_M & forward_31_W & (IR_M[`rs] == 5'b11111) ? 1'b1 : 1'b0 ;
                        
    assign ForwardRTM = use_rt_M & forward_rd_W & (IR_M[`rt] == IR_W[`rd]) & (IR_M[`rt] != 5'b0)? 1'b1 :
                        use_rt_M & forward_rt_W & (IR_M[`rt] == IR_W[`rt]) & (IR_M[`rt] != 5'b0)? 1'b1 :
                        use_rt_M & forward_31_W & (IR_M[`rt] == 5'b11111) ? 1'b1 : 1'b0 ;    
    
    
endmodule
