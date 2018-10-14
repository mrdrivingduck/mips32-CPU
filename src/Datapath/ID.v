`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/19 15:28:04
// Design Name: 
// Module Name: ID
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


module ID(
    input clk,
    input reset,
    input cancel,
    input stall,
    
    // ID阶段流水段控制信号
    input  IF_over,
    input  EXE_allow_in,
    output ID_over,
    output ID_allow_in,
    
    // ID阶段输入总线
    input [63: 0] ID_IN,
    /*
        [63:32] IR@D
        [31: 0] PC4@D
    */
    
    // ID阶段输出总线
    output [159:  0] ID_OUT,
    /*
        [159:128] IR@E
        [127: 96] PC4@E
        [95 : 64] RS@E
        [63 : 32] RT@E
        [31 : 0 ] EXT@E
    */
    
    // 控制输入总线
    input [14: 0] ID_CONTROL,
    /*
        [14]  input br_taken
        [13]  input j_taken
        [12]  input store,
        [11]  input load,
        [10]  input jbr,
        [9]   input RFA2Sel,
        [8:6] input [2:0] comp_func_choice,
        [5]   input npc_func_choice,
        [4]   input PCDSel,
        [3:2] input [1:0] ext_func_choice,
        [1]   input PC4ESel,
        [0]   input RegWriEn,            // WB
    */
    
    // 控制输出总线
    output compare_result,
    
    // 转发信号
    input [3:0] Forward_D,
    /*
        [3:2] ForwardRSD,
        [1:0] ForwardRTD,
    */
    
    // 交互输入总线
    input [132: 0 ] IN_ID,
    /*
        input [132:128] RFWriAddr,      // WB
        input [127:96 ] RFWriData,      // WB
        input [95 :64 ] PC4_E,          // EX
        input [63 :32 ] AO_M,           // MEM
        input [31 :0  ] PC4_M,          // MEM
    */
    // 交互输出总线
    output [31: 0] OUT_ID               // PCD
    );

    // ID阶段流水段控制信号
    reg ID_valid;
    
    assign ID_allow_in = ~ID_valid | (ID_over & EXE_allow_in);
    assign ID_over     = ID_valid & ~stall;
    
    initial
    begin
        ID_valid <= 1'b0;
    end
    
    always @(posedge clk)
    begin
        if (reset | cancel)
        begin
            ID_valid <= 1'b0;
        end
        else if (ID_allow_in)
        begin
            ID_valid <= 1'b1;
        end
    end
    
    // 通路连线
    wire [31: 0] RF_RD1;
    wire [31: 0] RF_RD2;
    wire [31: 0] RFA2;
    wire [31: 0] FRSD;
    wire [31: 0] FRTD;
    wire [31: 0] NPC_OUT;
    wire [31: 0] NEXT_PC;
    wire [31: 0] EXT_OUT;
    wire [31: 0] PC4E;
    
    // 输出总线
    assign PC4E   = ID_IN[31:0] + 32'd4;
    assign ID_OUT = {ID_IN[63:32], PC4E, FRSD, FRTD, EXT_OUT};
    
    // 模块实例化
    RegisterFile REGFILE (
        .clk     ( clk                     ),
        .rs      ( ID_IN[57 : 53]          ),           // rs
        .rt      ( RFA2[4  :  0]           ),           // MUX : MRFA2
        .busA    ( RF_RD1                  ),           // Wire
        .busB    ( RF_RD2                  ),           // Wire
        .wen     ( ID_CONTROL[0] & ~cancel ),           // RegWriEn
        .rd      ( IN_ID[132:128]          ),           // RFWriAddr
        .data_in ( IN_ID[127: 96]          )            // RFWriData
    );
    
    MUX_2 MRFA2 (
        .source_0   ( {{27{1'b0}}, ID_IN[52:48]} ),     // rt
        .source_1   ( 32'b0                      ),
        .sel        ( ID_CONTROL[9]              ),     // RFA2Sel
        .sel_result ( RFA2                       )      // Wire : RFA2
    );
    
    MUX_4 MFRSD (
        .source_0   ( RF_RD1           ),               // Wire
        .source_1   ( IN_ID    [95:64] ),               // PC4_E
        .source_2   ( IN_ID    [63:32] ),               // AO_M
        .source_3   ( IN_ID    [31: 0] ),               // PC4_M
        .sel        ( Forward_D[3 : 2] ),               // ForwardRSD
        .sel_result ( FRSD             )                // Wire : FRSD
    );
    
    MUX_4 MFRTD (
        .source_0   ( RF_RD2           ),
        .source_1   ( IN_ID    [95:64] ),               // PC4_E
        .source_2   ( IN_ID    [63:32] ),               // AO_M
        .source_3   ( IN_ID    [31: 0] ),               // PC4_M
        .sel        ( Forward_D[1 : 0] ),               // ForwardRTD
        .sel_result ( FRTD             )                // Wire : FRTD
    );
    
    Compare COMP (
        .busA        ( FRSD            ),               // Wire
        .busB        ( FRTD            ),               // Wire
        .func_choice ( ID_CONTROL[8:6] ),               // comp_func_choice
        .comp_result ( compare_result  )                // Output to Controller
    );
    
    NextProgCounter NPC (
        .add4        ( ID_IN     [31: 0] ),             // PC@D
        .imm26       ( ID_IN     [57:32] ),             // imm26
        .func_choice ( ID_CONTROL[5    ] ),             // npc_func_choice
        .next_pc     ( NPC_OUT           )              // Wire : NPC_OUT
    );
    
    MUX_2 MPCD (
        .source_0   ( NPC_OUT       ),                  // Wire
        .source_1   ( FRSD          ),                  // Wire
        .sel        ( ID_CONTROL[4] ),                  // PCDSel
        .sel_result ( OUT_ID        )                   // Output to IF
    );
    
    Extension EXT (
        .imm16       ( ID_IN     [47:32] ),             // IR@D [15:0]
        .func_choice ( ID_CONTROL[3 : 2] ),             // ext_func_choice
        .ext_result  ( EXT_OUT           )              // Wire : EXT_OUT
    );
    
endmodule
