`timescale 1ns / 1ps
`define Queue_length 4'b0111
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: zonghua
// 
// Create Date: 2017/07/20 16:20:35
// Design Name: 
// Module Name: ifech_handshake
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


module Ifetch_handshake(
    input                  clk ,
    input                reset ,
    input               cancel ,
    input           if_addr_ok ,
    input           if_data_ok ,
    input          ID_allow_in ,
    input       [31:0]   if_pc ,
    input       [31:0] if_data ,
    input              refetch ,
    output     pc_overflow_out ,
    output           inst_flag ,
    output      [31:0] if_pc_4 ,
    output      [31:0] if_inst
    );
    
    reg [31:0] INST_Queue [`Queue_length:0];
    reg [31:0]   PC_Queue [`Queue_length:0];
    reg         Flag_inst [`Queue_length:0];
    reg        INST_arrive[`Queue_length:0];
    reg [3:0]                     pc_count ; 
    reg [3:0]                   inst_count ;
    reg                        pc_overflow ;
    wire                          pc_below ;
    wire                     pc_q_overflow ;

    /*
        PC队列已满，必须暂停PC刷新，并且读使能拉低
    */
    
assign pc_q_overflow   = (pc_count > `Queue_length) ? 1'b1 : 1'b0 ;
assign pc_below        = (pc_count <=      4'd2   ) ? 1'b1 : 1'b0 ;
assign pc_overflow_out =              pc_overflow | pc_q_overflow ;
assign inst_flag       =            Flag_inst[0] && INST_arrive[0];
assign if_pc_4         =                               PC_Queue[0];
assign if_inst         =                             INST_Queue[0];
//每周期刷新队列
always@ (posedge clk)
begin
if(reset || cancel)
        begin
        /*有效位清零*/
            Flag_inst[0]   <= 1'b0 ;
            Flag_inst[1]   <= 1'b0 ;
            Flag_inst[2]   <= 1'b0 ;
            Flag_inst[3]   <= 1'b0 ;
            Flag_inst[4]   <= 1'b0 ;
            Flag_inst[5]   <= 1'b0 ;
            Flag_inst[6]   <= 1'b0 ;
            Flag_inst[7]   <= 1'b0 ;          
        /*指令标记位清零*/
            INST_arrive[0]   <= 1'b0 ;
            INST_arrive[1]   <= 1'b0 ;
            INST_arrive[2]   <= 1'b0 ;
            INST_arrive[3]   <= 1'b0 ;
            INST_arrive[4]   <= 1'b0 ;
            INST_arrive[5]   <= 1'b0 ;
            INST_arrive[6]   <= 1'b0 ;
            INST_arrive[7]   <= 1'b0 ;      
        /*计数器归位*/
            pc_count       <= 4'b0 ;
            inst_count     <= 4'b0 ;
            pc_overflow    <= 1'b0 ;
        end
else if(ID_allow_in && INST_arrive[0])
        begin
        if (refetch)
            begin
                    pc_count    <= 4'b0 ;
                    inst_count  <= 4'b0 ;
                    pc_overflow <= 1'b0 ;
        /*有效位清零*/
                    Flag_inst[0]   <= 1'b0 ;
                    Flag_inst[1]   <= 1'b0 ;
                    Flag_inst[2]   <= 1'b0 ;
                    Flag_inst[3]   <= 1'b0 ;
                    Flag_inst[4]   <= 1'b0 ;
                    Flag_inst[5]   <= 1'b0 ;
                    Flag_inst[6]   <= 1'b0 ;
                    Flag_inst[7]   <= 1'b0 ;           
                /*指令标记位清零*/
                    INST_arrive[0]   <= 1'b0 ;
                    INST_arrive[1]   <= 1'b0 ;
                    INST_arrive[2]   <= 1'b0 ;
                    INST_arrive[3]   <= 1'b0 ;
                    INST_arrive[4]   <= 1'b0 ;
                    INST_arrive[5]   <= 1'b0 ;
                    INST_arrive[6]   <= 1'b0 ;
                    INST_arrive[7]   <= 1'b0 ;               
            end
        else
            begin
                INST_Queue[0]   =  INST_Queue[1] ;
                INST_Queue[1]   =  INST_Queue[2] ;
                INST_Queue[2]   =  INST_Queue[3] ;
                INST_Queue[3]   =  INST_Queue[4] ;
                INST_Queue[4]   =  INST_Queue[5] ;
                INST_Queue[5]   =  INST_Queue[6] ;
                INST_Queue[6]   =  INST_Queue[7] ;
                INST_Queue[7]   =          32'b0 ;
                inst_count      =inst_count-4'b1 ;
                
                PC_Queue[0]     =    PC_Queue[1] ;
                PC_Queue[1]     =    PC_Queue[2] ;
                PC_Queue[2]     =    PC_Queue[3] ;
                PC_Queue[3]     =    PC_Queue[4] ;
                PC_Queue[4]     =    PC_Queue[5] ;
                PC_Queue[5]     =    PC_Queue[6] ;
                PC_Queue[6]     =    PC_Queue[7] ;
                PC_Queue[7]     =          32'b0 ;
                pc_count        =pc_count - 4'b1 ;
                
                Flag_inst[0]    =   Flag_inst[1] ;
                Flag_inst[1]    =   Flag_inst[2] ;
                Flag_inst[2]    =   Flag_inst[3] ;
                Flag_inst[3]    =   Flag_inst[4] ;
                Flag_inst[4]    =   Flag_inst[5] ;
                Flag_inst[5]    =   Flag_inst[6] ;
                Flag_inst[6]    =   Flag_inst[7] ;
                Flag_inst[7]    =           1'b0 ;
                
                INST_arrive[0]  = INST_arrive[1] ;
                INST_arrive[1]  = INST_arrive[2] ;
                INST_arrive[2]  = INST_arrive[3] ;
                INST_arrive[3]  = INST_arrive[4] ;
                INST_arrive[4]  = INST_arrive[5] ;
                INST_arrive[5]  = INST_arrive[6] ;
                INST_arrive[6]  = INST_arrive[7] ;
                INST_arrive[7]  =           1'b0 ;
                
                
            end
        end
if((inst_count <= `Queue_length) && if_data_ok && (~refetch | (refetch && ~inst_flag)) && !cancel && !reset)
        begin
                      INST_Queue[inst_count]  = if_data ;
                      INST_arrive[inst_count] =    1'b1 ;
                      inst_count    = inst_count + 4'b1 ;
        end
if(( INST_arrive[inst_count - 1'b1] == 1'b1 ) && ( Flag_inst[inst_count - 1'b1] == 1'b0 ))
        begin
                    inst_count = inst_count - 4'b1 ;
                    INST_arrive[inst_count] = 1'b0 ;
        end
if((pc_count   <= `Queue_length) && if_addr_ok && (~refetch | (refetch && ~inst_flag)) && !cancel && !reset && !pc_q_overflow && !pc_overflow)
        begin
              PC_Queue[pc_count]   = if_pc ;
              Flag_inst[pc_count]   = 1'b1 ;
              pc_count   = pc_count + 4'b1 ;
        end

if(pc_q_overflow | pc_below)
        begin
            if (pc_q_overflow)
            begin
                pc_overflow <= 1'b1 ;
            end
            else
            begin
                pc_overflow <= 1'b0 ;
            end
        end
end
    
    initial 
    begin
        INST_Queue[0] <= 32'b0 ;
        INST_Queue[1] <= 32'b0 ;
        INST_Queue[2] <= 32'b0 ;
        INST_Queue[3] <= 32'b0 ;
        INST_Queue[4] <= 32'b0 ;
        INST_Queue[5] <= 32'b0 ;
        INST_Queue[6] <= 32'b0 ;
        INST_Queue[7] <= 32'b0 ;
        PC_Queue[0]   <= 32'b0 ;
        PC_Queue[1]   <= 32'b0 ;
        PC_Queue[2]   <= 32'b0 ;
        PC_Queue[3]   <= 32'b0 ;
        PC_Queue[4]   <= 32'b0 ;
        PC_Queue[5]   <= 32'b0 ;
        PC_Queue[6]   <= 32'b0 ;
        PC_Queue[7]   <= 32'b0 ;
        Flag_inst[0]   <= 1'b0 ;
        Flag_inst[1]   <= 1'b0 ;
        Flag_inst[2]   <= 1'b0 ;
        Flag_inst[3]   <= 1'b0 ;
        Flag_inst[4]   <= 1'b0 ;
        Flag_inst[5]   <= 1'b0 ;
        Flag_inst[6]   <= 1'b0 ;
        Flag_inst[7]   <= 1'b0 ;
        INST_arrive[0]   <= 1'b0 ;
        INST_arrive[1]   <= 1'b0 ;
        INST_arrive[2]   <= 1'b0 ;
        INST_arrive[3]   <= 1'b0 ;
        INST_arrive[4]   <= 1'b0 ;
        INST_arrive[5]   <= 1'b0 ;
        INST_arrive[6]   <= 1'b0 ;
        INST_arrive[7]   <= 1'b0 ;    
    end
    
endmodule
