`timescale 1ns / 1ps
`define rs 25 : 21
`define rt 20 : 16
`define rd 15 : 11
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 宗华
// 
// Create Date: 2017/06/19 22:05:58
// Design Name: 
// Module Name: Forward_E
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


module Forward_E(
    /*输入监测指令*/
    input [31:0] IR_E ,
    input [31:0] IR_M ,
    input [31:0] IR_W ,
    /*转发输入信号*/
    input [1:0] user_bus_E ,
    //E阶段的指令需要得到转发数据
    input [2:0] forward_bus_M , 
    input [2:0] forward_bus_W ,
    //M,W阶段提供数据
    /*转发输出信号*/
    output [1:0]ForwardRSE ,
    output [1:0]ForwardRTE 
    );
    wire use_rs_E ;
    wire use_rt_E ;
    assign use_rs_E = user_bus_E[1] ;
    assign use_rt_E = user_bus_E[0] ;
    
    wire  forward_rd_M ;
    wire  forward_rt_M ;
    wire  forward_31_M ;
    assign forward_rd_M = forward_bus_M[2];
    assign forward_rt_M = forward_bus_M[1];
    assign forward_31_M = forward_bus_M[0];   
    
    wire forward_rd_W ;
    wire forward_rt_W ;
    wire forward_31_W ;  
    assign forward_rd_W = forward_bus_W[2] ;
    assign forward_rt_W = forward_bus_W[1] ;
    assign forward_31_W = forward_bus_W[0] ;
        
    assign ForwardRSE = use_rs_E & forward_rd_M & (IR_E[`rs] == IR_M[`rd]) & (IR_E[`rs] != 5'b0)? 2'b01 :
                        use_rs_E & forward_rt_M & (IR_E[`rs] == IR_M[`rt]) & (IR_E[`rs] != 5'b0)? 2'b01 :
                        use_rs_E & forward_31_M & (IR_E[`rs] == 5'b11111) ? 2'b10 :
                        use_rs_E & forward_rd_W & (IR_E[`rs] == IR_W[`rd]) & (IR_E[`rs] != 5'b0)? 2'b11 :
                        use_rs_E & forward_rt_W & (IR_E[`rs] == IR_W[`rt]) & (IR_E[`rs] != 5'b0)? 2'b11 :
                        use_rs_E & forward_31_W & (IR_E[`rs] == 5'b11111) ? 2'b11 : 2'b00 ;
                        
    assign ForwardRTE = use_rt_E & forward_rd_M & (IR_E[`rt] == IR_M[`rd]) & (IR_E[`rt] != 5'b0)? 2'b01 :
                        use_rt_E & forward_rt_M & (IR_E[`rt] == IR_M[`rt]) & (IR_E[`rt] != 5'b0)? 2'b01 :
                        use_rt_E & forward_31_M & (IR_E[`rt] == 5'b11111) ? 2'b10 :
                        use_rt_E & forward_rd_W & (IR_E[`rt] == IR_W[`rd]) & (IR_E[`rt] != 5'b0)? 2'b11 :
                        use_rt_E & forward_rt_W & (IR_E[`rt] == IR_W[`rt]) & (IR_E[`rt] != 5'b0)? 2'b11 :
                        use_rt_E & forward_31_W & (IR_E[`rt] == 5'b11111) ? 2'b11 : 2'b00 ;    
    
endmodule
