`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/19 09:52:47
// Design Name: 
// Module Name: CoProcessor0
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


module CoProcessor0(

    input clk,
    input reset,
    
    // 输入信号
    input [31: 0] CP0_DATA_IN,       // 写入数据
    input [31: 0] CP0_PC_IN,         // PC+8
    
    // CP0控制总线
    input [13: 0] CP0_CONTROL,
    /*
        [13] EPC_IN_Sel
        [12] BadAddr_wen
        [11] BadAddr_IN_Sel
        [10] Status_wen
        [9] Status_EXL_Sel
        [8] Status_EXL_wen
        [7] Cause_BD_wen
        [6] Cause_BD_Sel
        [5] Cause_wen
        [4] Cause_ExcCode_wen
        [3:1] Cause_ExcCode_Sel
        [0] EPC_wen
    */
    
    // 数据输出
    output [31: 0] Status_OUT,
    output [31: 0] Cause_OUT,
    output [31: 0] BadAddr_OUT,
    output [31: 0] EPC_OUT
    );
    
    // EPC寄存器 32bit
    reg [31: 0] EPC;
    // BadVAddr寄存器 32bit
    reg [31: 0] BadVAddr;
    // Cause寄存器 14bit 其余全为0
    reg         Cause_BD;
    reg [5 : 0] Cause_IP_7_2;
    reg [1 : 0] Cause_IP_1_0;
    reg [4 : 0] Cause_ExcCode;
    // Status寄存器 10bit 其余全为0
    reg [7 : 0] Status_IM_7_0;
    reg         Status_EXL;
    reg         Status_IE;
    
    initial
    begin
        EPC           <= 32'b0;
        BadVAddr      <= 32'b0;
        Cause_BD      <= 1'b0;
        Cause_IP_7_2  <= 6'b0;
        Cause_IP_1_0  <= 2'b0;
        Cause_ExcCode <= 5'b0;
        Status_IM_7_0 <= 8'b0;
        Status_EXL    <= 1'b0;
        Status_IE     <= 1'b0;
    end
    
    // 读CP0
    assign Status_OUT  = { 16'b0, Status_IM_7_0, 6'b0, Status_EXL, Status_IE };
    assign Cause_OUT   = { Cause_BD, 15'b0, Cause_IP_7_2, Cause_IP_1_0, 1'b0, Cause_ExcCode, 2'b0 };
    assign BadAddr_OUT =   BadVAddr;
    assign EPC_OUT     =   EPC;
    
    // 写CP0
    /*
        EPCINSel == 0   pc_in - 8
        EPCINSel == 1   data_in
    */
    wire [31: 0] CP0_IN;
    wire [31: 0] BadAddr_IN;
    wire [31: 0] BDPC;
    
    MUX_2 MBDPC (
        .source_0   ( CP0_PC_IN - 32'd8  ),     // 当前指令的PC值
        .source_1   ( CP0_PC_IN - 32'd12 ),     // 当前指令的前一PC值（延迟槽异常）
        .sel        ( CP0_CONTROL[6]     ),     // BD
        .sel_result ( BDPC               )      // Wire : BDPC
    );
    
    MUX_2 MEPCIN (
        .source_0   ( CP0_DATA_IN     ),        // Data
        .source_1   ( BDPC            ),        // PC
        .sel        ( CP0_CONTROL[13] ),        // EPCINSel
        .sel_result ( CP0_IN          )         // Wire : CP0_IN
    );
    
    MUX_2 MBADADDR (
        .source_0   ( CP0_IN          ),
        .source_1   ( CP0_DATA_IN     ),
        .sel        ( CP0_CONTROL[11] ),        // BADADDRINSel
        .sel_result ( BadAddr_IN      )         // Wire : BadAddr_IN
    );
    
    always @(posedge clk)
    begin
            if (CP0_CONTROL[0])                 //  EPC_wen
        begin
            EPC <= CP0_IN;
        end
        if (CP0_CONTROL[12])                    //  BadAddr_wen
        begin
            BadVAddr <= BadAddr_IN;
        end
        if (CP0_CONTROL[10])                    // Status_wen
        begin
            Status_IM_7_0 <= CP0_IN[15: 8];
            Status_EXL    <= CP0_IN[1];
            Status_IE     <= CP0_IN[0];
        end
        if (CP0_CONTROL[8])                     // Status_EXL_wen
        begin
            Status_EXL    <= CP0_CONTROL[9];    // EXL_choice_Sel
        end
        if (CP0_CONTROL[5])                 // Cause_wen
        begin
            Cause_IP_1_0  <= CP0_IN[9 : 8];
        end
        if (CP0_CONTROL[7])                 // Cause_BD_wen
        begin
            Cause_BD      <= CP0_CONTROL[6];     // cause_BD_Sel
        end
        if (CP0_CONTROL[4])                 // Cause_ExcCode_wen
        begin
            Cause_ExcCode <= ( CP0_CONTROL[3:1] == 3'b001) ? 5'b00100 :      // AdEL 0x04
                             ( CP0_CONTROL[3:1] == 3'b010) ? 5'b00101 :      // AdES 0x05
                             ( CP0_CONTROL[3:1] == 3'b011) ? 5'b01000 :      // Sys 0x08
                             ( CP0_CONTROL[3:1] == 3'b100) ? 5'b01001 :      // Bp 0x09
                             ( CP0_CONTROL[3:1] == 3'b101) ? 5'b01010 :      // RI 0x0a
                             ( CP0_CONTROL[3:1] == 3'b110) ? 5'b01100 :      // Ov 0x0c
                             5'b0;
        end
    end
    
endmodule
