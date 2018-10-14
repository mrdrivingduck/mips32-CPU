`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZongHua
// 
// Create Date: 2017/06/19 14:52:36
// Design Name: 
// Module Name: IF
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


module IF(

    input  clk,
    input  reset,
    
    // choose PC from WB
    input  cancel,
    
    // IF阶段流水段控制信号
    input  ID_allow_in,
    output IF_over,
    
    // IF阶段输出总线
    output [63: 0] IF_OUT,
    /*
        [63:32] IR@D
        [31:0] PC4@D
    */
    
    // 交互总线
    input  [63: 0] IN_IF,
    /*
        [63:32] PCD     // ID
        [31:0] PCW      // WB
    */
    
    // 异常信号
    output PC_EXC_IF,
    
    input  ID_pc_sel,
    
    output [3 :0] if_ben,
    output [31:0] if_wdata,
 //   output if_wr,
    output [31:0] if_addr,
    input  if_addr_ok,
    input  if_data_ok,
    input  [31:0] if_rdata
    );
    
    // 通路连线
    wire [31: 0] pc;
    wire [31: 0] instruction;
    wire [31: 0] pc_in;
    wire [31: 0] if_pc_out ;
    wire [31: 0] if_inst_out ;
    wire         pc_q_overflow ;
    wire         inst_flag ;
    wire         refetch ;
    wire         if_ben_change ;
    reg          reset_reg ;
    
    initial
    begin
        reset_reg <= 1'b0 ;
    end
    
    assign refetch = ID_pc_sel ;
    
    Ifetch_handshake ifetch_store(
        .clk             ( clk           ),
        .reset           ( reset         ),
        .cancel          ( cancel        ),
        .if_addr_ok      ( if_addr_ok    ),
        .if_data_ok      ( if_data_ok    ),
        .ID_allow_in     ( ID_allow_in   ),
        .if_pc           ( pc            ),
        .if_data         ( if_rdata      ),
        .refetch         ( refetch       ),
        .pc_overflow_out ( pc_q_overflow ),
        .inst_flag       ( inst_flag     ),
        .if_pc_4         ( if_pc_out     ),
        .if_inst         ( if_inst_out   )
    );    
    
    
    // IF阶段流水段控制
    assign IF_over  = inst_flag;
    
//  assign if_wr    = 1'b0;
    assign if_wdata = 32'b0;
    assign if_addr  = { 3'b000, pc[28:0] };
    
    always @(posedge clk)
    begin
        reset_reg <= reset ;
    end
    
    assign if_ben_change = reset_reg || cancel || pc_q_overflow ; 
    assign if_ben        = if_ben_change ? 4'b0000 : 4'b1111 ;
    
    // IF阶段输出总线
    assign IF_OUT[63:32] = if_inst_out;             // IR@D
    assign IF_OUT[31: 0] = if_pc_out + 32'd4;       // PC4@D
    
    assign pc_in = cancel    ? IN_IF[31: 0] :       // from WB
                   ID_pc_sel ? IN_IF[63:32] :       // from ID
                   pc + 32'd4;
                   
    // PC取指错例外信号输出
    assign PC_EXC_IF = pc[0] | pc[1];
    
    // 模块实例化
    
    ProgramCounter PC (
        .clk    ( clk                                     ),
        .reset  ( reset                                   ),
        .pc_wen (( (~pc_q_overflow | refetch) & if_addr_ok) | (refetch & if_data_ok) ),
        .npc    ( pc_in                                   ),
        .pc     ( pc                                      )
    );
    
endmodule
