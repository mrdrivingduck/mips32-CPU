`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/19 17:19:51
// Design Name: 
// Module Name: EXE
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


module EXE(
    input clk,
    input reset,
    input cancel,
    
    // EXE阶段流水段控制信号
    input  ID_over,
    input  MEM_allow_in,
    output EXE_over,
    output EXE_allow_in,
    
    // EXE阶段输入总线
    input  [159:  0] EXE_IN,
    // EXE阶段输出总线
    output [127:  0] EXE_OUT,
    
    // EXE控制信号总线
    input  [13 :  0] EXE_CONTROL,
    /*
        [13] input instr_divu
        [12] input instr_div
        [11] input instr_multu
        [10] input instr_mult
        [9] input ALUASel,
        [8] input ALUBSel,
        [7:4] input [3:0] alu_func_choice,
        [3:2] input [1:0] AOMSel,
        [1:0] input [1:0] RTMSel,
    */
    
    // 交互总线输入
    input   [95 :  0] IN_EXE,
    /*
        [95:64] input [31:0] AO_M,      // MEM
        [63:32] input [31:0] PC4_M,     // MEM
        [31:0] input [31:0] RFWD,       // WB
    */
    // 交互总线输出
    output  [31 :  0] OUT_EXE,              // PC4_E
    
    // 转发信号总线
    input   [3  :  0] Forward_E,
    /*
        [3:2] ForwardRSE,
        [1:0] ForwardRTE,
    */
    
    // 异常信号
    output overflow,
    
    input  ID_allow_in,
    input  IF_over
    );
    
    // EXE阶段流水段控制信号
    reg  EXE_valid;
    reg  EXE_valid_div;
    wire DIV_OVER;
    
    initial
    begin
        EXE_valid     <= 1'b0;
        EXE_valid_div <= 1'b0;
    end
    
    assign EXE_over     = EXE_valid & (~(EXE_CONTROL[12] | EXE_CONTROL[13]) | DIV_OVER);
    assign EXE_allow_in = ~EXE_valid | (EXE_over & MEM_allow_in);
    
    always @(posedge clk)
    begin
        if (reset | cancel)
        begin
            EXE_valid <= 1'b0;
        end
        else if (EXE_allow_in & ID_over & IF_over & ID_allow_in)
        begin
            EXE_valid <= ID_over;
        end
        else if (EXE_allow_in)
        begin
            EXE_valid <= 1'b0;
        end
    end
    
    always @(posedge clk)
    begin
        EXE_valid_div <= EXE_allow_in;
    end
    
    // 通路连线
    wire [31: 0] FRSE;
    wire [31: 0] FRTE;
    wire [31: 0] ALUA;
    wire [31: 0] ALUB;
    wire [31: 0] ALU_OUT;
    wire [31: 0] AOM;
    wire [31: 0] RTM;
    
    wire [63: 0] MULTU;
    wire [63: 0] MULT;
    wire [63: 0] MULT_OUT;
    wire [63: 0] DIVU;
    wire [63: 0] DIV;
    wire [63: 0] DIV_OUT;
    
    wire         Div_OVER;
    wire         Divu_OVER;
    
    // 输出总线
    assign EXE_OUT = { EXE_IN[159:128], EXE_IN[127: 96], AOM, RTM };
    // 交互总线
    assign OUT_EXE =   EXE_IN[127:96]; 
    
    // 模块实例化
    MUX_4 MFRSE (
        .source_0   ( EXE_IN   [95:64] ),       // RS@E
        .source_1   ( IN_EXE   [95:64] ),       // AO_M
        .source_2   ( IN_EXE   [63:32] ),       // PC4_M
        .source_3   ( IN_EXE   [31: 0] ),       // RFWD
        .sel        ( Forward_E[3 : 2] ),       // ForwardRSE
        .sel_result ( FRSE             )        // Wire : FRSE
    );
    
    MUX_4 MFRTE (
        .source_0   ( EXE_IN   [63:32] ),       // RT@E
        .source_1   ( IN_EXE   [95:64] ),       // AO_M
        .source_2   ( IN_EXE   [63:32] ),       // PC4_M
        .source_3   ( IN_EXE   [31: 0] ),       // RFWD
        .sel        ( Forward_E[1 : 0] ),       // ForwardRTE
        .sel_result ( FRTE             )        // Wire : FRTE
    );
    
    MUX_2 MALUA (
        .source_0   ( FRSE              ),      // MFRSE
        .source_1   ( EXE_IN     [31:0] ),      // EXT@E
        .sel        ( EXE_CONTROL[9]    ),      // ALUASel
        .sel_result ( ALUA              )       // Wire : ALUA
    );
    
    MUX_2 MALUB (
        .source_0   ( FRTE               ),     // Wire
        .source_1   ( EXE_IN     [31: 0] ),     // EXT@E
        .sel        ( EXE_CONTROL[8]     ),     // ALUBSel
        .sel_result ( ALUB               )      // Wire : ALUB
    );
    
    ArithLogicUnit ALU (
        .sourceA     ( ALUA             ),      // Wire
        .sourceB     ( ALUB             ),      // Wire
        .func_choice ( EXE_CONTROL[7:4] ),      // alu_func_choice
        .alu_out     ( ALU_OUT          ),      // Wire : ALU_OUT
        .overflow    ( overflow         )       // Exception OUT
    );
    
    SignedMultiplier SIGNEDMULTIPLIER (
        .A ( FRSE ),                            // Wire
        .B ( FRTE ),                            // Wire
        .P ( MULT )                             // Wire : MULT
    );
    
    UnsignedMultiplier UNSIGNEDMULTIPLIER (
        .A ( FRSE  ),                           // Wire
        .B ( FRTE  ),                           // Wire
        .P ( MULTU )                            // Wire : MULTU
    );
    
    SignedDivider SIGNEDDIVIDER (
        .aclk                   ( clk                             ),
        .aresetn                ( ~(cancel | reset)               ),            // cancel
        .s_axis_divisor_tdata   ( FRTE                            ),            // Wire
        .s_axis_divisor_tvalid  ( EXE_CONTROL[12] & EXE_valid_div ),            // instr_div & EXE_valid_div
        .s_axis_dividend_tdata  ( FRSE                            ),            // Wire
        .s_axis_dividend_tvalid ( EXE_CONTROL[12] & EXE_valid_div ),            // instr_div & EXE_valid_div
        .m_axis_dout_tdata      ( DIV                             ),            // Wire : DIV
        .m_axis_dout_tvalid     ( Div_OVER                        )             // Wire : Div_OVER
    );
    
    UnsignedDivider UNSIGNEDDIVIDER (
        .aclk                   ( clk                             ),
        .aresetn                ( ~(cancel | reset)               ),            // cancel
        .s_axis_divisor_tdata   ( FRTE                            ),            // Wire
        .s_axis_divisor_tvalid  ( EXE_CONTROL[13] & EXE_valid_div ),            // instr_divu & EXE_valid_div
        .s_axis_dividend_tdata  ( FRSE                            ),            // Wire
        .s_axis_dividend_tvalid ( EXE_CONTROL[13] & EXE_valid_div ),            // instr_divu & EXE_valid_div
        .m_axis_dout_tdata      ( DIVU                            ),            // Wire : DIVU
        .m_axis_dout_tvalid     ( Divu_OVER                       )             // Wire : Divu_OVER
    );
    
    assign MULT_OUT = (EXE_CONTROL[11]) ? MULTU : MULT;     // instr_multu
    assign DIV_OUT  = (EXE_CONTROL[13]) ? DIVU  : DIV;      // instr_divu
    assign DIV_OVER = Div_OVER | Divu_OVER;                 // Wire : DIV_OVER
    
    MUX_3 MAOM (
        .source_0   ( ALU_OUT            ),                 // Wire
        .source_1   ( DIV_OUT    [31: 0] ),                 // DIV_OUT[31: 0]
        .source_2   ( MULT_OUT   [63:32] ),                 // MULT_OUT[63:32]
        .sel        ( EXE_CONTROL[3 : 2] ),                 // AOMSel
        .sel_result ( AOM                )                  // Wire : AOM
    );
    
    MUX_3 MRTM (
        .source_0   ( FRTE               ),                 // Wire
        .source_1   ( DIV_OUT    [63:32] ),                 // DIV_OUT[63:32]
        .source_2   ( MULT_OUT   [31: 0] ),                 // MULT_OUT[31:0]
        .sel        ( EXE_CONTROL[1 : 0] ),                 // RTMSel
        .sel_result ( RTM                )                  // Wire : RTM
    );
    
endmodule
