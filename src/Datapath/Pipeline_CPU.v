`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ZhangJingtang
// 
// Create Date: 2017/06/28 16:00:57
// Design Name: 
// Module Name: Pipeline_CPU
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


module Pipeline_CPU(
    
    input aclk,
    input reset,
    
    output [3 :0] if_ben,
    output [31:0] if_wdata,
//  output if_wr,
    output [31:0] if_addr,
    input         if_addr_ok,
    input         if_data_ok,
    input  [31:0] if_rdata,
    
    output [3 :0] mem_ben,
    output [31:0] mem_wdata,
    output        mem_wr,
    output [31:0] mem_addr,
    input         mem_addr_ok,
    input         mem_data_ok,
    input  [31:0] mem_rdata

    );
    
    // 通路连线
    
    wire IF_over;
    wire ID_over;
    wire EXE_over;
    wire MEM_over;
    wire WB_over;
    
    wire ID_allow_in;
    wire EXE_allow_in;
    wire MEM_allow_in;
    wire WB_allow_in;
    
    wire [63 :0] IF_OUT;
    wire [63 :0] ID_IN;
    wire [159:0] ID_OUT;
    wire [159:0] EXE_IN;
    wire [127:0] EXE_OUT;
    wire [127:0] MEM_IN;
    wire [127:0] MEM_OUT;
    wire [127:0] WB_IN;
    
    wire [31: 0] OUT_ID;
    wire [31: 0] OUT_EXE;
    wire [63: 0] OUT_MEM;
    wire [68: 0] OUT_WB;
   
    wire cancel;
    
    // 数据通路模块实例化
    
    /////////////////////////////////////////////////////        IF        //////////////////////////////////////////////
    
    // IF阶段局部通路连线
    wire        IF_OUT_EXC;
    wire        ID_IN_EXC;
    wire        ID_IN_DELAY;
    wire [17:0] ID_CONTROL;
    wire [3 :0] br_type_D;
    wire        compare_result;
    wire        ID_pc_sel;
    wire        stall;
    
    /*        取指阶段模块        */
    IF ifetch (
        .clk         ( aclk                                        ),
        .reset       ( reset                                       ),
        .cancel      ( cancel                                      ),   // I 1bit Wire
        .ID_allow_in ( ID_allow_in                                 ),   // I 1bit Wire
        .IF_over     ( IF_over                                     ),   // O 1bit Wire : IF_over
        .IF_OUT      ( IF_OUT                                      ),   // O 64bit Wire : IF_OUT
        .IN_IF       ( {OUT_ID, OUT_WB[31:0]}                      ),   // I 64bit
        .PC_EXC_IF   ( IF_OUT_EXC                                  ),   // O 1bit Wire : IF_OUT_EXC
        .ID_pc_sel   ( (ID_CONTROL[17] | ID_CONTROL[16]) & ~stall ),    // I 1bit
        .if_ben      ( if_ben                                      ),   // O 4bit
        .if_wdata    ( if_wdata                                    ),   // O 32bit
//      .if_wr       ( if_wr                                       ),   // O 1bit
        .if_addr     ( if_addr                                     ),   // O 32bit
        .if_addr_ok  ( if_addr_ok                                  ),   // I 1bit
        .if_data_ok  ( if_data_ok                                  ),   // I 1bit
        .if_rdata    ( if_rdata                                    )    // I 32bit
    );
    
    /*        IF/ID流水段寄存器模块        */
    IF_ID_REG if_id_reg (
        .clk         ( aclk           ),
        .reset       ( reset          ),
        .cancel      ( cancel         ),                  // I 1bit Wire
        .IF_over     ( IF_over        ),                  // I 1bit Wire
        .ID_allow_in ( ID_allow_in    ),                  // I 1bit Wire
        .IF_OUT      ( IF_OUT         ),                  // I 64bit Wire
        .ID_IN       ( ID_IN          ),                  // O 64bit Wire : ID_IN
        .PC_EXC_IF   ( IF_OUT_EXC     ),                  // I 1bit Wire
        .PC_EXC_ID   ( ID_IN_EXC      ),                  // O 1bit Wire : ID_IN_EXC
        .DELAY       ( ID_IN_DELAY    ),                  // O 1bit Wire : ID_IN_DELAY
        .jbr         ( ID_CONTROL[10] )                   // I 1bit
    );
    
    /////////////////////////////////////////////////////        ID        //////////////////////////////////////////////

    // ID阶段局部通路连线
    wire [3:0] user_stall_bus_D;
    wire [3:0] ForwardD;
    wire [1:0] user_bus_D;
    wire [3:0] wrback_stall_bus_E;
    wire [1:0] wrback_stall_bus_M;
    wire       forward_bus_E;
    wire [2:0] forward_bus_M;
    wire [2:0] forward_bus_W;
    wire [3:0] EXE_IN_EXC;
    wire       EXE_IN_DELAY;
    wire [1:0] MEM_STALL_BUS;
        
    /*        暂停控制器模块        */
    Stall_Control stall_control (
        .IR_D               ( ID_IN [63 :32 ]    ),     // I 32 bit  Wire
        .IR_E               ( EXE_IN[159:128]    ),     // I 32 bit  Wire
        .IR_M               ( MEM_IN[127:96 ]    ),     // I 32 bit  Wire
        .user_stall_bus_D   ( user_stall_bus_D   ),     // I 4  bit  Wire
        .wrback_stall_bus_E ( wrback_stall_bus_E ),     // I 4  bit  Wire
        .wrback_stall_bus_M ( wrback_stall_bus_M ),     // I 2  bit  Wire
        .datapath_M_bus     ( MEM_STALL_BUS      ),     // I 2  bit  Wire
        .stall_D            ( stall              )      // O 1  bit  Wire : stall
    );
        
    /*        ID阶段控制器模块        */
    ControlUnit_D control_D (
        .inst_D         ( ID_IN     [63:32] ),           // I 32 bit Wire
        .RegWriEn       ( WB_CONTROL[0    ] ),           // I 1  bit Wire
        .comp_result    ( compare_result    ),           // I 1  bit Wire
        .ID_control_bus ( ID_CONTROL        ),           // O 17 bit Wire : ID_CONTROL
        .user_stall_bus ( user_stall_bus_D  ),           // O 4  bit Wire : user_stall_bus_D
        .user_bus_D     ( user_bus_D        ),           // O 2  bit Wire : user_bus_D
        .br_type_D      ( br_type_D         )            // O 4  bit Wire : br_type_D
    );
    
    /*        ID阶段转发控制器模块        */
    Forward_D forward_D (
        .IR_D          ( ID_IN    [63 :32] ),           // I 32 bit Wire
        .IR_M          ( MEM_IN   [127:96] ),           // I 32 bit Wire
        .user_bus_D    ( user_bus_D        ),           // I 2  bit Wire
        .forward_bus_E ( forward_bus_E     ),           // I 1  bit Wire
        .forward_bus_M ( forward_bus_M     ),           // I 3  bit Wire
        .ForwardRSD    ( ForwardD [3 :2 ]  ),           // O 2  bit Wire : ForwardD
        .ForwardRTD    ( ForwardD [1 :0 ]  )            // O 2  bit Wire : ForwardD
    );
    
    /*        译码阶段模块        */
    ID id (
        .clk            ( aclk                                  ),
        .reset          ( reset                                 ),
        .cancel         ( cancel                                ),      // I 1   bit Wire
        .stall          ( stall                                 ),      // I 1   bit Wire
        .IF_over        ( IF_over                               ),      // I 1   bit Wire
        .EXE_allow_in   ( EXE_allow_in                          ),      // I 1   bit Wire
        .ID_over        ( ID_over                               ),      // O 1   bit Wire : ID_over
        .ID_allow_in    ( ID_allow_in                           ),      // O 1   bit Wire : ID_allow_in
        .ID_IN          ( ID_IN                                 ),      // I 64  bit Wire
        .ID_OUT         ( ID_OUT                                ),      // O 160 bit Wire : ID_OUT
        .ID_CONTROL     ( {ID_CONTROL[17:16], ID_CONTROL[12:0]} ),      // I 15  bit Wire
        .compare_result ( compare_result                        ),      // O 1   bit Wire : compare_result
        .Forward_D      ( ForwardD                              ),      // I 4   bit Wire
        .IN_ID          ( {OUT_WB    [68:32], OUT_EXE, OUT_MEM} ),      // I 133 bit Wire
        .OUT_ID         ( OUT_ID                                )       // O 32  bit Wire : OUT_ID
    );
    
    /*        ID/EXE流水段寄存器模块        */
    ID_EXE_REG id_exe_reg (
        .clk          ( aclk                            ),
        .reset        ( reset                           ),
        .cancel       ( cancel                          ),          // I 1   bit Wire
        .ID_over      ( ID_over                         ),          // I 1   bit Wire
        .EXE_allow_in ( EXE_allow_in                    ),          // I 1   bit Wire
        .ID_OUT       ( ID_OUT                          ),          // I 160 bit Wire
        .EXE_IN       ( EXE_IN                          ),          // O 160 bit Wire : EXE_IN
        .ID_OUT_EXC   ( {ID_CONTROL[15:13], ID_IN_EXC}  ),          // I 4   bit Wire
        .EXE_IN_EXC   ( EXE_IN_EXC                      ),          // O 4   bit Wire : EXE_IN_EXC
        .ID_OUT_DELAY ( ID_IN_DELAY                     ),          // I 1   bit Wire
        .EXE_IN_DELAY ( EXE_IN_DELAY                    ),          // O 1   bit Wire : EXE_IN_DELAY
        .IF_over      ( IF_over                         ),          // I 1   bit Wire
        .ID_allow_in  ( ID_allow_in                     )           // I 1   bit Wire
    );
    
    /////////////////////////////////////////////////////        EXE        //////////////////////////////////////////////
    
    // EXE阶段局部通路连线
    wire [1 :0] user_bus_E;
    wire [13:0] EXE_CONTROL;
    wire [3 :0] ForwardE;
    wire        overflow;
    wire [4 :0] MEM_IN_EXC;
    wire        MEM_IN_DELAY;
    
    /*        EXE阶段控制器模块        */
    ControlUnit_E control_E (
        .inst_E           ( EXE_IN[159:128]    ),       // I 32 bit
        .wrback_stall_bus ( wrback_stall_bus_E ),       // O 4  bit Wire : wrback_stall_bus_E
        .user_bus_E       ( user_bus_E         ),       // O 2  bit Wire : user_bus_E
        .forward_bus_E    ( forward_bus_E      ),       // O 1  bit Wire : forward_bus_E
        .Ex_control_bus   ( EXE_CONTROL        )        // O 14 bit Wire : EXE_CONTROL
    );
    
    /*        EXE阶段转发控制器模块        */
    Forward_E forward_E (
        .IR_E          ( EXE_IN [159:128] ),            // I 32bit Wire
        .IR_M          ( MEM_IN [127: 96] ),            // I 32bit Wire
        .IR_W          ( WB_IN  [127: 96] ),            // I 32bit Wire
        .user_bus_E    ( user_bus_E       ),            // I 2bit Wire
        .forward_bus_M ( forward_bus_M    ),            // I 3bit Wire
        .forward_bus_W ( forward_bus_W    ),            // I 3bit Wire
        .ForwardRSE    ( ForwardE[3 : 2 ] ),            // O 2bit Wire : ForwardE
        .ForwardRTE    ( ForwardE[1 : 0 ] )             // O 2bit Wire : ForwardE
    );
    
    /*        执行阶段模块        */
    EXE exe (
        .clk          ( aclk                     ),
        .reset        ( reset                    ),
        .cancel       ( cancel                   ),         // I 1   bit Wire
        .ID_over      ( ID_over                  ),         // I 1   bit Wire
        .MEM_allow_in ( MEM_allow_in             ),         // I 1   bit Wire
        .EXE_over     ( EXE_over                 ),         // O 1   bit Wire : EXE_over
        .EXE_allow_in ( EXE_allow_in             ),         // O 1   bit Wire : EXE_allow_in
        .EXE_IN       ( EXE_IN                   ),         // I 160 bit Wire
        .EXE_OUT      ( EXE_OUT                  ),         // O 128 bit Wire : EXE_OUT
        .EXE_CONTROL  ( EXE_CONTROL              ),         // I 14  bit Wire
        .IN_EXE       ( {OUT_MEM, OUT_WB[63:32]} ),         // I 96  bit
        .OUT_EXE      ( OUT_EXE                  ),         // O 32  bit Wire : OUT_EXE
        .Forward_E    ( ForwardE                 ),         // I 2   bit Wire
        .overflow     ( overflow                 ),         // O 1   bit Wire : overflow
        .ID_allow_in  ( ID_allow_in              ),         // I 1   bit Wire
        .IF_over      ( IF_over                  )          // I 1   bit Wire
    );
    
    /*        EXE/MEM流水段寄存器模块        */
    EXE_MEM_REG exe_mem_reg (
        .clk           ( aclk                   ),
        .reset         ( reset                  ),
        .cancel        ( cancel                 ),          // I 1   bit Wire
        .EXE_over      ( EXE_over               ),          // I 1   bit Wire
        .MEM_allow_in  ( MEM_allow_in           ),          // I 1   bit Wire
        .EXE_OUT       ( EXE_OUT                ),          // I 128 bit Wire
        .MEM_IN        ( MEM_IN                 ),          // O 128 bit Wire : MEM_IN
        .EXE_OUT_EXC   ( {overflow, EXE_IN_EXC} ),          // I 5   bit Wire
        .MEM_IN_EXC    ( MEM_IN_EXC             ),          // O 5   bit Wire : MEM_IN_EXC
        .EXE_OUT_DELAY ( EXE_IN_DELAY           ),          // I 1   bit Wire
        .MEM_IN_DELAY  ( MEM_IN_DELAY           )           // O 1   bit Wire : MEM_IN_DELAY
    );
    
    /////////////////////////////////////////////////////        MEM        //////////////////////////////////////////////
    
    // MEM阶段局部通路连线
    wire [1 :0] user_bus_M;
    wire [1 :0] ForwardM;
    wire [12:0] MEM_CONTROL;
    wire [7 :0] WB_IN_EXC;
    wire [1 :0] MEM_EXC;
    wire [1 :0] STORE_ADDR;
    
    /*        MEM阶段控制器模块        */
    ControlUnit_M control_M (
        .inst_M           ( MEM_IN[127: 96]    ),           // I 32 bit Wire
        .addr_offset      ( STORE_ADDR         ),           // I 2  bit Wire
        .wrback_stall_bus ( wrback_stall_bus_M ),           // O 2  bit Wire : wrback_stall_bus_M
        .user_bus_M       ( user_bus_M         ),           // O 2  bit Wire : user_bus_M
        .forward_bus_M    ( forward_bus_M      ),           // O 3  bit Wire : forward_bus_M
        .Mem_control_bus  ( MEM_CONTROL        )            // O 13 bit Wire : MEM_CONTROL
    );
    
    /*        MEM阶段转发控制器模块        */
    Forward_M forward_M (
        .IR_M          ( MEM_IN[127: 96] ),                 // I 32 bit Wire
        .IR_W          ( WB_IN [127: 96] ),                 // I 32 bit Wire
        .user_bus_M    ( user_bus_M      ),                 // I 2  bit Wire
        .forward_bus_W ( forward_bus_W   ),                 // I 3  bit Wire
        .ForwardRSM    ( ForwardM[1]     ),                 // O 1  bit Wire : ForwardM
        .ForwardRTM    ( ForwardM[0]     )                  // O 1  bit Wire : ForwardM
    );
    
    /*        访存阶段模块        */
    MEM mem (
        .clk          ( aclk          ),
        .reset        ( reset         ),
        .cancel       ( cancel        ),                    // I 1   bit Wire
        .EXE_over     ( EXE_over      ),                    // I 1   bit Wire
        .WB_allow_in  ( WB_allow_in   ),                    // I 1   bit Wire
        .MEM_over     ( MEM_over      ),                    // O 1   bit Wire : MEM_over
        .MEM_allow_in ( MEM_allow_in  ),                    // O 1   bit Wire : MEM_allow_in
        .MEM_IN       ( MEM_IN        ),                    // I 128 bit Wire
        .MEM_OUT      ( MEM_OUT       ),                    // O 128 bit Wire : MEM_OUT
        .MEM_CONTROL  ( MEM_CONTROL   ),                    // I 12  bit Wire
        .IN_MEM       ( OUT_WB[63:32] ),                    // I 32  bit Wire
        .OUT_MEM      ( OUT_MEM       ),                    // O 64  bit Wire : OUT_MEM
        .ForwardM     ( ForwardM      ),                    // I 2   bit Wire
        .MEM_EXC      ( MEM_EXC       ),                    // O 2   bit Wire : MEM_EXC
        .STORE_ADDR   ( STORE_ADDR    ),                    // O 2   bit Wire : STORE_ADDR
        .MEM_STALL    ( MEM_STALL_BUS ),                    // O 2   bit Wire : MEM_STALL_BUS
        .mem_ben      ( mem_ben       ),                    // O 4   bit
        .mem_wdata    ( mem_wdata     ),                    // O 32  bit
        .mem_wr       ( mem_wr        ),                    // O 1   bit
        .mem_addr     ( mem_addr      ),                    // O 32  bit
        .mem_addr_ok  ( mem_addr_ok   ),                    // I 1   bit
        .mem_data_ok  ( mem_data_ok   ),                    // I 1   bit
        .mem_rdata    ( mem_rdata     )                     // I 32  bit
    );
    
    /*        MEM/WB流水段寄存器模块        */
    MEM_WB_REG mem_wb_reg (
        .clk           ( aclk                                          ),
        .reset         ( reset                                         ),
        .cancel        ( cancel                                        ),           // I 1   bit Wire
        .MEM_over      ( MEM_over                                      ),           // I 1   bit Wire
        .WB_allow_in   ( WB_allow_in                                   ),           // I 1   bit Wire
        .MEM_OUT       ( MEM_OUT                                       ),           // I 128 bit Wire
        .WB_IN         ( WB_IN                                         ),           // O 128 bit Wire : WB_IN
        .MEM_OUT_EXC   ( {MEM_IN_EXC[0], MEM_EXC      , MEM_IN_EXC[1],
                          MEM_IN_EXC[2], MEM_IN_EXC[3], MEM_IN_EXC[4]} ),           // I 7   bit Wire
        .WB_IN_EXC     ( WB_IN_EXC                                     ),           // O 8   bit Wire : WB_IN_EXC
        .MEM_OUT_DELAY ( MEM_IN_DELAY                                  ),           // I 1   bit Wire
        .if_addr_ok    ( if_addr_ok                                    )            // I 1   bit Wire
    );
    
    /////////////////////////////////////////////////////        WB        //////////////////////////////////////////////
    
    // WB阶段局部通路连线
    wire [29: 0] WB_CONTROL;
    
    /*        WB阶段控制器模块        */
    ControlUnit_W control_W (
        .inst_W         ( WB_IN[127: 96] ),         // I 32 bit Wire
        .exception_reg  ( WB_IN_EXC      ),         // I 8  bit Wire
        .forward_bus_W  ( forward_bus_W  ),         // O 3  bit Wire : forward_bus_W
        .WB_control_bus ( WB_CONTROL     ),         // O 30 bit Wire : WB_CONTROL
        .cancel         ( cancel         )          // O 1  bit Wire : cancel
    );
    
    /*        写回阶段模块        */
    WB wb (
        .clk         ( aclk        ),
        .reset       ( reset       ),
        .cancel      ( cancel      ),               // I 1   bit Wire
        .MEM_over    ( MEM_over    ),               // I 1   bit Wire
        .WB_allow_in ( WB_allow_in ),               // O 1   bit Wire : WB_allow_in
        .WB_IN       ( WB_IN       ),               // I 128 bit Wire
        .WB_CONTROL  ( WB_CONTROL  ),               // I 30  bit Wire
        .OUT_WB      ( OUT_WB      )                // O 69  bit Wire : OUT_WB
    );
    
    
endmodule
