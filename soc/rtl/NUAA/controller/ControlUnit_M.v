`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 宗华
// 
// Create Date: 2017/06/19 15:33:24
// Design Name: 
// Module Name: ControlUnit_M
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


module ControlUnit_M(
        input [31:0] inst_M ,
        //输入M阶段指令
        input [1:0] addr_offset ,
/*冒险控制总线*/ 
        output [1:0] wrback_stall_bus ,
/*转发控制总线*/
        output [1:0] user_bus_M ,
        output [2:0] forward_bus_M ,
/*Mem阶段通路控制总线*/
        output [12:0] Mem_control_bus 
/*例外控制*/
        //output 
    );
    
    //取指令操作码
        wire [5:0] op ;
        wire [4:0] sa ;
        wire [5:0] funct ;
        wire [4:0] rs ;
        wire [4:0] rt ;
        wire [4:0] rd ;
        assign op = inst_M[31:26] ;
        assign sa = inst_M[10:6] ;
        assign funct = inst_M[5:0] ;
        assign rs = inst_M[25:21] ;
        assign rt = inst_M[20:16] ;
        assign rd = inst_M[15:11] ;
        //实现指令列表
        wire inst_ADD , inst_ADDI , inst_ADDU , inst_ADDIU , inst_SUB , inst_SUBU ;
        wire inst_SLT , inst_SLTI , inst_SLTU , inst_SLTIU ;
        wire inst_DIV , inst_DIVU , inst_MULT , inst_MULTU ;
        wire inst_AND , inst_ANDI , inst_LUI , inst_NOR , inst_OR , inst_ORI , inst_XOR , inst_XORI ;
        wire inst_SLLV ,inst_SLL , inst_SRAV , inst_SRA , inst_SRLV , inst_SRL ;
        wire inst_BEQ , inst_BNE , inst_BGEZ , inst_BGTZ , inst_BLEZ , inst_BLTZ , inst_BGEZAL , inst_BLTZAL ;
        wire inst_J , inst_JAL , inst_JR , inst_JALR ;
        wire inst_MFHI , inst_MFLO , inst_MTHI , inst_MTLO ;
        wire inst_BREAK , inst_SYSCALL ;
        wire inst_LB , inst_LBU , inst_LH , inst_LHU , inst_LW , inst_SB , inst_SH ,inst_SW ;
        wire inst_ERET , inst_MFC0 , inst_MTC0 ;
        wire op_zero; // 操作码全 0
        wire sa_zero; // sa 域全 0
        assign op_zero = ~(|op);
        assign sa_zero = ~(|sa); 
        assign inst_ADD = op_zero & sa_zero & (funct == 6'b100000);//有符号加法（整形溢出例外）
        assign inst_ADDI = (op == 6'b001000);//有符号立即数加法（整形溢出例外）
        assign inst_ADDU = op_zero & sa_zero & (funct == 6'b100001);//无符号加法
        assign inst_ADDIU = (op == 6'b001001);//无符号立即数加法
        assign inst_SUB = op_zero & sa_zero & (funct == 6'b100010);//有符号减法（整形溢出例外）
        assign inst_SUBU = op_zero & sa_zero & (funct == 6'b100011);//无符号减法
        assign inst_SLT = op_zero & sa_zero & (funct == 6'b101010);//小于则置位
        assign inst_SLTI = (op == 6'b001010);//立即数小于置位
        assign inst_SLTU = op_zero & sa_zero & (funct == 6'b101011);//无符号小则置
        assign inst_SLTIU = (op == 6'b001011);//立即数无符号小于置位
        assign inst_DIV = op_zero & sa_zero & (funct == 6'b011010) & (rd == 5'b0);//有符号除法
        assign inst_DIVU = op_zero & sa_zero & (funct == 6'b011011) & (rd == 5'b0);//无符号除法
        assign inst_MULT = op_zero & sa_zero & (funct == 6'b011000) & (rd == 5'b0);//有符号乘法
        assign inst_MULTU = op_zero & sa_zero & (funct == 6'b011001) & (rd == 5'b0);//无符号乘法
        assign inst_AND = op_zero & sa_zero & (funct == 6'b100100);//与运算
        assign inst_ANDI = (op == 6'b001100);//立即数逻辑与
        assign inst_LUI = (op == 6'b001111) & (rs==5'd0);//立即数装载高半字节 
        assign inst_NOR = op_zero & sa_zero & (funct == 6'b100111);//或非运算
        assign inst_OR = op_zero & sa_zero & (funct == 6'b100101);//或运算
        assign inst_ORI = (op == 6'b001101);//立即数逻辑或
        assign inst_XOR = op_zero & sa_zero & (funct == 6'b100110);//异或运算
        assign inst_XORI = (op == 6'b001110);//立即数的逻辑异或
        assign inst_SLL = op_zero & (rs==5'd0) & (funct == 6'b000000);//逻辑左移
        assign inst_SLLV = op_zero & sa_zero & (funct == 6'b000100);//变量逻辑左移
        assign inst_SRA = op_zero & (rs==5'd0) & (funct == 6'b000011);//算术右移
        assign inst_SRAV = op_zero & sa_zero & (funct == 6'b000111);//变量算术右移
        assign inst_SRL = op_zero & (rs==5'd0) & (funct == 6'b000010);//逻辑右移
        assign inst_SRLV = op_zero & sa_zero & (funct == 6'b000110);//变量逻辑右移
        assign inst_BEQ = (op == 6'b000100); //判断相等跳转
        assign inst_BNE = (op == 6'b000101); //判断不等跳转
        assign inst_BGEZ = (op == 6'b000001) & (rt==5'd1);//大于等于 0 跳转
        assign inst_BGTZ = (op == 6'b000111) & (rt==5'd0);//大于 0 跳转
        assign inst_BLEZ = (op == 6'b000110) & (rt==5'd0);//小于等于 0 跳转
        assign inst_BLTZ = (op == 6'b000001) & (rt==5'd0);//小于 0 跳转
        assign inst_BGEZAL = (op == 6'b000001) & (rt == 5'b10001);//大于等于0跳转，并且保留PC+8
        assign inst_BLTZAL = (op == 6'b000001) & (rt == 5'b10000);//小于0跳转，并且保留PC+8
        assign inst_J = (op == 6'b000010);//无条件跳转
        assign inst_JAL = (op == 6'b000011);//无条件跳转，并保留PC+8
        assign inst_JALR = op_zero & (rt==5'd0) & (rd==5'd31)
         & sa_zero & (funct == 6'b001001); //跳转寄存器并链接
        assign inst_JR = op_zero & (rt==5'd0) & (rd==5'd0 )
         & sa_zero & (funct == 6'b001000); //跳转寄存器
        assign inst_MFLO = op_zero & (rs==5'd0) & (rt==5'd0)
         & sa_zero & (funct == 6'b010010); //从 LO 读取
        assign inst_MFHI = op_zero & (rs==5'd0) & (rt==5'd0)
         & sa_zero & (funct == 6'b010000); //从 HI 读取
        assign inst_MTLO = op_zero & (rt==5'd0) & (rd==5'd0)
         & sa_zero & (funct == 6'b010011); //向 LO 写数据
        assign inst_MTHI = op_zero & (rt==5'd0) & (rd==5'd0)
         & sa_zero & (funct == 6'b010001); //向 HI 写数据
        assign inst_BREAK = (op == 6'b000000) & (funct == 6'b001101);//系统自陷（断点例外）
        assign inst_SYSCALL = (op == 6'b000000) & (funct == 6'b001100);//SYSCALL（系统调用例外）
        assign inst_LB = (op == 6'b100000); //load 字节（符号扩展）
        assign inst_LBU = (op == 6'b100100); //load 字节（无符号扩展）
        assign inst_LH = (op == 6'b100001);//load半字（地址错例外）
        assign inst_LHU = (op == 6'b100101);//load半字（0拓展）（地址错例外）
        assign inst_LW = (op == 6'b100011); //从内存装载字（地址错例外）
        assign inst_SB = (op == 6'b101000); //向内存存储字节
        assign inst_SH = (op == 6'b101001);//向内存存储半字（地址错例外）
        assign inst_SW = (op == 6'b101011); //向内存存储字（地址错例外）
        assign inst_ERET = (op == 6'b010000) & (rs == 5'b10000) & (rt == 5'b0) & (rd == 5'b0) & sa_zero & (funct == 6'b011000);//ERET
        assign inst_MFC0 = (op == 6'b010000) & (rs == 5'b0) & sa_zero & (funct[5:3] == 3'b0);//向CP0取值
        assign inst_MTC0 = (op == 6'b010000) & (rs == 5'b00100) & sa_zero & (funct[5:3] == 3'b0);//向CP0存值
/*指令归类*/
        wire cal_r ;//R型运算类指令
        wire di_mu ;//乘除运算指令
        wire cal_i ;//I型运算类指令
        wire br_rs_rt ;//跳转指令（rs rt）
        wire br_rs ;//跳转指令（rs）
        wire br_rs_al ;//跳转并链接（rs 31）
        wire jr_rs ;//无条件跳转并链接(rs)
        wire jal_al ;//无条件跳转并链接(31)
        wire jalr_rs_al ;//无条件跳转并链接(rs 31)
        wire mfhi , mflo , mfc0 , mthi , mtlo , mtc0 ;//数据转移指令
        wire load , store ;  //访存指令
        assign cal_r = inst_ADD | inst_ADDU | inst_SUB | inst_SUBU | inst_SLT | inst_SLTU | inst_AND | inst_NOR | inst_OR | inst_XOR | inst_SLLV
                     | inst_SLL | inst_SRAV | inst_SRA | inst_SRLV | inst_SRL ;
        assign di_mu = inst_DIV | inst_DIVU | inst_MULT | inst_MULTU ;
        assign cal_i = inst_ADDI | inst_ADDIU | inst_SLTI | inst_SLTIU | inst_ANDI | inst_ANDI | inst_LUI | inst_ORI | inst_XORI ;
        assign br_rs_rt = inst_BEQ | inst_BNE ;
        assign br_rs = inst_BGEZ | inst_BGTZ | inst_BLEZ | inst_BLTZ ;
        assign br_rs_al = inst_BGEZAL | inst_BLTZAL ;
        assign jr_rs = inst_JR ;
        assign jal_al = inst_JAL ;
        assign jalr_rs_al = inst_JALR ;
        assign mfhi = inst_MFHI ;
        assign mflo = inst_MFLO ;
        assign mfc0 = inst_MFC0 ;
        assign mthi = inst_MTHI ;
        assign mtlo = inst_MTLO ;
        assign mtc0 = inst_MTC0 ;
        assign load = inst_LB | inst_LBU | inst_LH | inst_LHU | inst_LW ;
        assign store = inst_SB | inst_SH | inst_SW ;
/*阻塞控制*/
        wire wrback_rd1_M , wrback_rt1_M ;
        assign wrback_rd1_M = mfhi | mflo ;
        assign wrback_rt1_M = load | mfc0 ;
        assign wrback_stall_bus = { wrback_rd1_M ,wrback_rt1_M };
/*转发控制*/  
        wire use_rs_M , use_rt_M , forward_rd_M , forward_rt_M , forward_31_M ;
        assign use_rs_M = mthi | mtlo ;
        assign use_rt_M = store | mtc0 ;
        assign forward_rd_M = cal_r ;
        assign forward_rt_M = cal_i ;
        assign forward_31_M = br_rs_al | jal_al | jalr_rs_al  ;
        assign user_bus_M = {use_rs_M , use_rt_M };
        assign forward_bus_M = {forward_rd_M , forward_rt_M , forward_31_M};
/*数据选择器控制信号*/
        wire LRMSel ;
        assign LRMSel =   inst_LB | inst_LBU | inst_LH | inst_LHU | inst_LW ? 1'b1 : 1'b0 ;
/*内存字节写使能*/
        wire [3:0] Byte_wen ;
        assign Byte_wen = inst_SB & ( addr_offset[1:0] == 2'b00 )? 4'b0001 :
                          inst_SB & ( addr_offset[1:0] == 2'b01 )? 4'b0010 :
                          inst_SB & ( addr_offset[1:0] == 2'b10 )? 4'b0100 :
                          inst_SB & ( addr_offset[1:0] == 2'b11 )? 4'b1000 :
                          inst_SH & ( addr_offset[1] == 1'b0 ) ? 4'b0011 :
                          inst_SH & ( addr_offset[1] == 1'b1 ) ? 4'b1100 :
                          inst_SW ? 4'b1111 : 4'b0000 ;
/*Mem阶段通路总线*/        
        assign Mem_control_bus = {inst_LHU, inst_SB , inst_SW, inst_SH, inst_LW, inst_LH, Byte_wen[3:0] , LRMSel ,load , store };

endmodule
