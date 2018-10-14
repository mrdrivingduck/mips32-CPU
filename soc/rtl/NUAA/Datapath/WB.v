`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/20 08:56:46
// Design Name: 
// Module Name: WB
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


module WB(
    input  clk,
    input  reset,
    input  cancel,
    
    // WB阶段流水段控制信号
    input  MEM_over,
    output WB_allow_in,
    
    // WB阶段输入总线
    input  [127:  0] WB_IN,
    
    // WB控制信号总线
    input  [29 :  0] WB_CONTROL,
    /*
        [29] PCWSel
        [28:15] CP0_CONTROL
        [14] lo_wen
        [13] hi_wen
        [12:10] RFWDSel
        [9:8] CP0OSel
        [7] CP0DSel
        [6:5] RFA3Sel
        [4] LOSel
        [3:1] EXT_W_func_choice
        [0] WriRegWen
    */
    
    // 交互输出总线
    output [68 :  0] OUT_WB
    /*
        [68:64] output RFWriAddr,
        [63:32] output RFWriData,
        [31:0] output PCW
    */
    
    );
    
    // WB流水段控制
    reg  WB_valid;
    wire WB_over;
    
    initial
    begin
        WB_valid <= 1'b0;
    end
    
    assign WB_over     =  WB_valid;
    assign WB_allow_in = ~WB_valid | WB_over;
    
    always @(posedge clk)
    begin
        if (reset | cancel)
        begin
            WB_valid <= 1'b0;
        end
        else if (WB_allow_in)
        begin
            WB_valid <= MEM_over;
        end
    end
    
    // 通路连线
    wire [31: 0] EXT_W_OUT;
    wire [31: 0] HI_OUT;
    wire [31: 0] LO_IN;
    wire [31: 0] LO_OUT;
    wire [31: 0] RFA3;
    wire [31: 0] RFWD;
    wire [31: 0] CP0D;
    wire [31: 0] CAUSE_OUT;
    wire [31: 0] BADADDR_OUT;
    wire [31: 0] STATUS_OUT;
    wire [31: 0] EPC_OUT;
    wire [31:0] CP0_OUT;
    
    // 交互总线
    assign OUT_WB[68:64] = RFA3[4:0] & { 5{ WB_valid } };               // RFWriAddr
    assign OUT_WB[63:32] = RFWD;                                        // RFWriData
    assign OUT_WB[31: 0] = (WB_CONTROL[29]) ? CP0_OUT : 32'hbfc00380;   // PCW PCWSel
    
    // 模块实例化
    LoadExtension EXT_W (
        .load_data    ( WB_IN     [31: 0] ),        // lo_result@W
        .byte_address ( WB_IN     [33:32] ),        // AO@W[1:0]
        .func_choice  ( WB_CONTROL[3 : 1] ),        // EXT_W_func_choice
        .ext_result   ( EXT_W_OUT         )         // Wire : EXT_W_OUT
    );
    
    HighReg HI (
        .clk    ( clk               ),
        .hi_wen ( WB_CONTROL[13]    ),              // hi_wen
        .hi_in  ( WB_IN     [63:32] ),              // AO@W
        .hi_out ( HI_OUT            )               // Wire : HI_OUT
    );
    
    MUX_2 MLO (
        .source_0   ( WB_IN     [63:32] ),          // AO@W
        .source_1   ( WB_IN     [31: 0] ),          // lo_result@W
        .sel        ( WB_CONTROL[4]     ),          // LOSel
        .sel_result ( LO_IN             )           // Wire : LO_IN
    );
    
    LowReg LO (
        .clk    ( clk            ),
        .lo_wen ( WB_CONTROL[14] ),                 // lo_wen
        .lo_in  ( LO_IN          ),                 // MLO
        .lo_out ( LO_OUT         )                  // Wire : LO_OUT
    );
    
    MUX_3 MRFA3 (
        .source_0   ( {27'b0, WB_IN[111:107]} ),    // IR@W[rd]
        .source_1   ( {27'b0, WB_IN[116:112]} ),    // IR@W[rt]
        .source_2   ( 32'd31                  ),    // 31
        .sel        ( WB_CONTROL[6  :  5]     ),    // RFA3Sel
        .sel_result ( RFA3                    )     // Wire : RFA3
    );
    
    MUX_2 MCP0D (
        .source_0   ( WB_IN     [63:32] ),          // AO@W
        .source_1   ( WB_IN     [31: 0] ),          // lo_result@W
        .sel        ( WB_CONTROL[7]     ),          // CP0DSel
        .sel_result ( CP0D              )           // Wire : CP0D
    );
    
    CoProcessor0 CP0 (
        .clk         ( clk               ),
        .reset       ( reset             ),
        .CP0_DATA_IN ( CP0D              ),
        .CP0_PC_IN   ( WB_IN     [95:64] ),         // PC4@W
        .CP0_CONTROL ( WB_CONTROL[28:15] ),         // CP0_CONTROL
        .Status_OUT  ( STATUS_OUT        ),         // Wire : STATUS_OUT
        .Cause_OUT   ( CAUSE_OUT         ),         // Wire : CAUSE_OUT
        .BadAddr_OUT ( BADADDR_OUT       ),         // Wire : BADADDR_OUT
        .EPC_OUT     ( EPC_OUT           )          // Wire : EPC_OUT
    );
    
    MUX_4 MCP0O (
        .source_0   ( EPC_OUT         ),            // Wire
        .source_1   ( STATUS_OUT      ),            // Wire
        .source_2   ( CAUSE_OUT       ),            // Wire
        .source_3   ( BADADDR_OUT     ),            // Wire
        .sel        ( WB_CONTROL[9:8] ),            // CP0OSel
        .sel_result ( CP0_OUT         )             // Wire : CP0_OUT
    );
    
    MUX_6 MRFWD (
        .source_0   ( WB_IN     [63:32] ),          // AO@W
        .source_1   ( WB_IN     [95:64] ),          // PC4@W
        .source_2   ( HI_OUT            ),          // Wire
        .source_3   ( LO_OUT            ),          // Wire
        .source_4   ( EXT_W_OUT         ),          // Wire
        .source_5   ( CP0_OUT           ),          // Wire
        .sel        ( WB_CONTROL[12:10] ),          // RFWDSel
        .sel_result ( RFWD              )           // Wire : RFWD
    );
    
endmodule
