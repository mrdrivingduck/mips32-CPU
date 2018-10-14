`timescale 1ns / 1ps
`define rs 25 : 21
`define rt 20 : 16
`define rd 15 : 11
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 宗华
// 
// Create Date: 2017/06/18 12:44:56
// Design Name: 
// Module Name: Stall_Control
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


module Stall_Control(
    input [31:0]IR_D , [31:0]IR_E , [31:0]IR_M ,
    //输入D ，E，M阶段的指令
    input [3:0] user_stall_bus_D ,
    //D阶段阻塞提供总线
    input [3:0] wrback_stall_bus_E ,
    //E阶段阻塞提供总线
    input [1:0] wrback_stall_bus_M ,
    //M阶段阻塞提供总线
    input [1:0] datapath_M_bus ,
    //M阶段数据通路总线
    /*
        0 valid_2
        1 load
    */
    output stall_D
    //输出阻塞信号
    );
    wire use_rs_rt0_D ;//D阶段需要用到rs ，rt的指令集（br_rs_rt）, Tuse = 0
    wire use_rs_rt1_D ;//D阶段需要用的rs，rt的指令集(cal_r | di/mu) , Tuse = 1
    wire use_rs0_D ;//D阶段需要用到rs的指令集（br_rs | br_rs_al | jr_rs | jalr_rs_al），Tuse = 0
    wire use_rs1_D ;//D阶段需要用到rs的指令集(cal_i | load | store) , Tuse = 1
    
    assign use_rs_rt0_D = user_stall_bus_D[3] ;
    assign use_rs_rt1_D = user_stall_bus_D[2] ;
    assign use_rs0_D = user_stall_bus_D[1] ;
    assign use_rs1_D = user_stall_bus_D[0] ;
    
    wire wrback_rd2_E ;//E阶段最终会写回rd的指令集(mfhi | mflo), Tnew = 2
    wire wrback_rt2_E ;//E阶段最终会写回rt的指令集(load , mfc0) , Tnew = 2  
    wire wrback_rd12_E ;//E阶段需要写回rd的指令集（mfhi | mflo | cal_r），Tnew = 1 , 2
    wire wrback_rt12_E ;//E阶段需要写回rt的指令集（load | mfc0 | cal_i），Tnew = 1 , 2
    
    assign wrback_rd2_E = wrback_stall_bus_E[3] ;
    assign wrback_rt2_E = wrback_stall_bus_E[2] ;
    assign wrback_rd12_E = wrback_stall_bus_E[1] ;
    assign wrback_rt12_E = wrback_stall_bus_E[0] ;
    
    wire wrback_rd1_M ;//M阶段需要写回rd的指令集（mfhi | mflo），Tnew = 1
    wire wrback_rt1_M ;//M阶段需要写回rt的指令集（load | mfc0），Tnew = 1
    
    assign wrback_rd1_M = wrback_stall_bus_M[1] ;
    assign wrback_rt1_M = wrback_stall_bus_M[0] ;
    
    wire stall_use_rs_rt1 ;
    //cal_r , di/mu 类指令在D阶段的阻塞
    assign stall_use_rs_rt1 = use_rs_rt1_D & 
        ((wrback_rd2_E & (IR_D[`rs] == IR_E[`rd] | IR_D[`rt] == IR_E[`rd]) & (IR_E[`rd] != 5'b0))
        | (wrback_rt2_E & (IR_D[`rs] == IR_E[`rt] | IR_D[`rt] == IR_E[`rt])& (IR_E[`rt] != 5'b0))
        | (~datapath_M_bus[0] & datapath_M_bus[1] & (IR_D[`rs] == IR_M[`rt] | IR_D[`rt] == IR_M[`rt])& (IR_M[`rt] != 5'b0)));
    wire stall_use_rs1 ;
    //cal_i | load | store类指令在D阶段的阻塞
    assign stall_use_rs1 = use_rs1_D &
        ((wrback_rd2_E & (IR_D[`rs] == IR_E[`rd])& (IR_E[`rd] != 5'b0))
        |(wrback_rt2_E & (IR_D[`rs] == IR_E[`rt])& (IR_E[`rt] != 5'b0))
        | (~datapath_M_bus[0] & datapath_M_bus[1] & (IR_D[`rs] == IR_M[`rt])& (IR_M[`rt] != 5'b0)));
    wire stall_use_rs_rt0 ;
    // br_rs_rt类指令在D阶段的阻塞
    assign stall_use_rs_rt0 = use_rs_rt0_D &
        ((wrback_rd12_E & (IR_D[`rs] == IR_E[`rd] | IR_D[`rt] == IR_E[`rd])& (IR_E[`rd] != 5'b0))
        | (wrback_rt12_E & (IR_D[`rs] == IR_E[`rt] | IR_D[`rt] == IR_E[`rt])& (IR_E[`rt] != 5'b0))
        | (wrback_rd1_M & (IR_D[`rs] == IR_M[`rd] | IR_D[`rt] == IR_M[`rd])& (IR_M[`rd] != 5'b0))
        | (wrback_rt1_M & (IR_D[`rs] == IR_M[`rt] | IR_D[`rt] == IR_M[`rt])& (IR_M[`rt] != 5'b0)));
    wire stall_use_rs0 ;
    //br_rs | br_rs_al | jr_rs | jalr_rs_al类指令在D阶段的阻塞
    assign stall_use_rs0 = use_rs0_D &
        ((wrback_rd12_E & (IR_D[`rs] == IR_E[`rd])& (IR_E[`rd] != 5'b0))
            | (wrback_rt12_E & (IR_D[`rs] == IR_E[`rt])& (IR_E[`rt] != 5'b0))
            | (wrback_rd1_M & (IR_D[`rs] == IR_M[`rd])& (IR_M[`rd] != 5'b0))
            | (wrback_rt1_M & (IR_D[`rs] == IR_M[`rt])& (IR_M[`rt] != 5'b0)));   
    //总阻塞信号
    assign stall_D = stall_use_rs_rt1 | stall_use_rs1 | stall_use_rs_rt0 | stall_use_rs0 ;
    
endmodule










