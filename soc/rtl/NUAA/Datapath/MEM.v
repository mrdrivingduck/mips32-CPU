`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/19 22:58:48
// Design Name: 
// Module Name: MEM
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


module MEM(

    input  clk,
    input  reset,
    input  cancel,
    
    // MEM流水段控制信号
    input  EXE_over,
    input  WB_allow_in,
    output MEM_over,
    output MEM_allow_in,
    
    // MEM阶段输入总线
    input  [127:  0] MEM_IN,
    // MEM阶段输出总线
    output [127:  0] MEM_OUT,
    
    // 控制信号
    input  [12 :  0] MEM_CONTROL,
    /*
        [12] instr_LHU
        [11] instr_SB
        [10] instr_SW
        [9] instr_SH
        [8] instr_LW
        [7] instr_LH
        [6:3] input Byte_wen
        [2] input LRMSel,
        [1] input inst_load,
        [0] input inst_store,
    */
    
    // 交互输入总线
    input  [31 :  0] IN_MEM,        // WB RFWD
    // 交互输出总线
    output [63 :  0] OUT_MEM,
    /*
        [63:32] output AO_M,
        [31:0] output PC4_M,
    */
    
    // 转发控制总线
    input  [1  :  0] ForwardM,
    /*
        [1] input ForwardRSM,
        [0] input ForwardRTM
    */
    
    // 异常信号
    output [1  :  0] MEM_EXC,
    /*
        [1] load取指错例外
        [0] store取指错例外
    */
    output [1  :  0] STORE_ADDR,
    // 字节地址
    
    output [1  :  0] MEM_STALL,
    
    output [3  :  0] mem_ben,
    output [31 :  0] mem_wdata,
    output           mem_wr,
    output [31 :  0] mem_addr,
    input            mem_addr_ok,
    input            mem_data_ok,
    input  [31 :  0] mem_rdata
    
    );
    
    // MEM流水段控制信号
    reg MEM_valid;
    reg mem_addr_valid;
    
    initial
    begin
        MEM_valid <= 1'b0;
        mem_addr_valid <= 1'b0;
    end
    

    always @(posedge clk)
    begin
        if (reset | cancel | MEM_allow_in)
        begin
            mem_addr_valid <= 1'b0;
        end
        else if ((MEM_CONTROL[1] | MEM_CONTROL[0]) & mem_addr_ok)
        begin
            mem_addr_valid <= 1'b1;
        end
    end
    
    assign mem_ben      = (MEM_CONTROL[1]) ? { 4{ 1'b1 & ~MEM_EXC[1] & ~cancel & ~mem_addr_valid } } :
                          (MEM_CONTROL[0]) ? (MEM_CONTROL[6:3] & { 4{ ~MEM_EXC[0] & ~cancel & ~mem_addr_valid } }) :
                           4'b0000;
    
    assign MEM_allow_in = ~MEM_valid | (MEM_over & WB_allow_in);
    assign MEM_over     = (MEM_CONTROL[1] & ~cancel & ~MEM_EXC[1]) ? (mem_data_ok & mem_addr_valid) :
                          (MEM_CONTROL[0] & ~cancel & ~MEM_EXC[0]) ? mem_addr_valid :
                           MEM_valid; 
    
    always @(posedge clk)
    begin
        if (reset | cancel)
        begin
            MEM_valid <= 1'b0;
        end
        else if (MEM_allow_in)
        begin
            MEM_valid <= EXE_over;
        end
    end
    
    // 通路连线
    wire [31:0] FRSM;
    wire [31:0] FRTM;
    wire [31:0] LRM;
    
    assign mem_wr   = (MEM_CONTROL[0]) ? 1'b1 : 1'b0;
    assign mem_addr = { 3'b0, FRSM[28:0] };
    
    // 输出总线
    assign MEM_OUT  = { MEM_IN[127: 96], MEM_IN[95 : 64], FRSM, LRM };
    
    // 交互输出总线
    assign OUT_MEM[63:32] = MEM_IN[63:32];      // AO@M
    assign OUT_MEM[31: 0] = MEM_IN[95:64];      // PC4@M
    
    // 异常信号输出总线
    assign MEM_EXC = {(MEM_CONTROL[ 8] & (FRSM[1] | FRSM[0])) | (MEM_CONTROL[7] & FRSM[0] | (MEM_CONTROL[12] & FRSM[0])),    // LH or LW or LHU
                      (MEM_CONTROL[10] & (FRSM[1] | FRSM[0])) | (MEM_CONTROL[9] & FRSM[0])};                                // SH or SW
                      
    // store字节地址
    assign STORE_ADDR = FRSM[1:0];
    
    assign MEM_STALL  = { MEM_CONTROL[1], mem_data_ok };
    
    // 模块实例化
    MUX_2 MFRSM (
        .source_0   ( MEM_IN  [63:32] ),        // AO@M
        .source_1   ( IN_MEM          ),        // from WB
        .sel        ( ForwardM[1]     ),        // ForwardRSM
        .sel_result ( FRSM            )         // Wire : FRSM
    );
    
    MUX_2 MFRTM (
        .source_0   ( MEM_IN  [31:0] ),         // RT@M
        .source_1   ( IN_MEM         ),         // from WB
        .sel        ( ForwardM[0]    ),         // ForwardRTM
        .sel_result ( FRTM           )          // Wire : FRTM
    );
    
    StoreShifter STORESHIFTER (
        .store_data ( FRTM             ),       // I 32bit Wire
        .shift_data ( mem_wdata        ),       // O 32bit
        .byte_addr  ( FRSM       [1:0] ),       // I 2bit Wire
        .Instr_SB   ( MEM_CONTROL[11]  ),       // I 1bit Instr_SB
        .Instr_SH   ( MEM_CONTROL[9]   )        // I 1bit Instr_SH
    );
    
    MUX_2 MLRM (
        .source_0   ( FRTM           ),         // Wire
        .source_1   ( mem_rdata      ),         // Wire
        .sel        ( MEM_CONTROL[2] ),         // LRMSel
        .sel_result ( LRM            )          // Wire : LRM
    );
    
endmodule
