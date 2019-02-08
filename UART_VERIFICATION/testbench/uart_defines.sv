//==============================================================================//
// Module      : uart                                                  //
//------------------------------------------------------------------------------//
// File        : uart_defines.sv                                       //
// Author(s)   : arnabd
                                                               //
// Created     : 13-Mar-2014                                                  //
// Last update : 13-Mar-2014                                                  //
// Purpose     : simulation                                                     //
//------------------------------------------------------------------------------//
// Description :                                                                //
// This file has the defines for SV env                                         //
//==============================================================================//


////////////////////////////////////////////////////////
// Test timeout parameter
////////////////////////////////////////////////////////

`define MODULE_IF        uart_If
`define MODULE_DRIVER    uart_Driver
`define MODULE_REGMAP    uart_Regmap
`define MODULE_CLOCKSGEN uart_ClocksGen
`define MODULE_IF_INST   uart_if

////////////////////////////////////////////////////////
// Test timeout parameter
////////////////////////////////////////////////////////

parameter TEST_TIMEOUT = 1000000; 

////////////////////////////////////////////////////////
// Reset related parameters
////////////////////////////////////////////////////////

parameter RSTH_DELAY   = 300;
parameter POR_DELAY    = 300;
parameter RBT_NUM_CLK  = 2;
parameter HARD_NUM_CLK = 2;
parameter SOFT_NUM_CLK = 2;

///////////////////////////////////////////////////////
// Required typedefs
///////////////////////////////////////////////////////
//typedef string bit_access_t;
typedef enum {R, RO, W, RW} bit_access_t;
//typedef enum {BYTE=0 , HWRD=1 , WRD=2 } access_size_t ;
typedef enum {WRD,	HWRD1,	HWRD2,	BYTE1,	BYTE2,	BYTE3,	BYTE4, MXD } access_size_t ;
typedef enum {NONE=0,  VCCDET=1, RSTH=2, POR=3, RBTRST=4, HARDRST=5, SOFTRST=6 } reset_t ;
typedef enum {RAND_ACC,	BYTE1_ACC,	BYTE2_ACC,	BYTE3_ACC,	BYTE4_ACC,	HWRD1_ACC,	HWRD2_ACC,	WRD_ACC} rand_acc_size_t	;
typedef enum {RAND_OFFST, OFFST_0, OFFST_1, OFFST_2, OFFST_3 } rand_offst_size_t	;

typedef enum {	CLOCK1,	CLOCK2,		CLOCK3	}	CLOCK_TYPE	;

parameter ADDR_OFFSET_WIDTH = 2 ;
parameter ADDR_WIDTH		= 3	;
parameter DATA_WIDTH		= 8	;
parameter BYTE_LANES		= 4	;
parameter BYTE_EN_VAL		= 4'b0001 ;

parameter START_DELAY		= 20 ;
parameter BAUD_SAMPLE_CYCLES	=	16	;


//--BAUD_DIVISIONS
//========================
//////////////////////////
//	CLOCK1	//////////////
//////////////////////////
parameter CLK1_50_L			=	8'h00	;
parameter CLK1_75_L			=	8'h00	;
parameter CLK1_110_L		=	8'h17	;
parameter CLK1_134_5_L		=	8'h59	;
parameter CLK1_150_L		=	8'h00	;
parameter CLK1_300_L		=	8'h80	;
parameter CLK1_600_L		=	8'hC0	;
parameter CLK1_1200_L		=	8'h60	;
parameter CLK1_1800_L		=	8'h40	;
parameter CLK1_2000_L		=	8'h3A	;
parameter CLK1_2400_L		=	8'h30	;
parameter CLK1_3600_L		=	8'h20	;
parameter CLK1_4800_L		=	8'h18	;
parameter CLK1_7200_L		=	8'h10	;
parameter CLK1_9600_L		=	8'h0C	;
parameter CLK1_19200_L		=	8'h06	;
parameter CLK1_38400_L		=	8'h03	;
parameter CLK1_56000_L		=	8'h02	;
parameter CLK1_128000_L		=	8'h00	;//default

parameter CLK1_50_M			=	8'h09	;
parameter CLK1_75_M			=	8'h06	;
parameter CLK1_110_M		=	8'h04	;
parameter CLK1_134_5_M		=	8'h03	;
parameter CLK1_150_M		=	8'h03	;
parameter CLK1_300_M		=	8'h01	;
parameter CLK1_600_M		=	8'h00	;
parameter CLK1_1200_M		=	8'h00	;
parameter CLK1_1800_M		=	8'h00	;
parameter CLK1_2000_M		=	8'h00	;
parameter CLK1_2400_M		=	8'h00	;
parameter CLK1_3600_M		=	8'h00	;
parameter CLK1_4800_M		=	8'h00	;
parameter CLK1_7200_M		=	8'h00	;
parameter CLK1_9600_M		=	8'h00	;
parameter CLK1_19200_M		=	8'h00	;
parameter CLK1_38400_M		=	8'h00	;
parameter CLK1_56000_M		=	8'h00	;
parameter CLK1_128000_M		=	8'h09	;//default


//////////////////////////
//	CLOCK2	//////////////
//////////////////////////
parameter CLK2_50_L			=	8'h00	;
parameter CLK2_75_L			=	8'h00	;
parameter CLK2_110_L		=	8'hD1	;
parameter CLK2_134_5_L		=	8'h94	;
parameter CLK2_150_L		=	8'h00	;
parameter CLK2_300_L		=	8'h80	;
parameter CLK2_600_L		=	8'h40	;
parameter CLK2_1200_L		=	8'hA0	;
parameter CLK2_1800_L		=	8'h6B	;
parameter CLK2_2000_L		=	8'h60	;
parameter CLK2_2400_L		=	8'h50	;
parameter CLK2_3600_L		=	8'h35	;
parameter CLK2_4800_L		=	8'h28	;
parameter CLK2_7200_L		=	8'h1B	;
parameter CLK2_9600_L		=	8'h14	;
parameter CLK2_19200_L		=	8'h0A	;
parameter CLK2_38400_L		=	8'h05	;
parameter CLK2_56000_L		=	8'h00	;//default
parameter CLK2_128000_L		=	8'h00	;//default

parameter CLK2_50_M			=	8'h0F	;
parameter CLK2_75_M			=	8'h0A	;
parameter CLK2_110_M		=	8'h06	;
parameter CLK2_134_5_M		=	8'h05	;
parameter CLK2_150_M		=	8'h05	;
parameter CLK2_300_M		=	8'h02	;
parameter CLK2_600_M		=	8'h01	;
parameter CLK2_1200_M		=	8'h00	;
parameter CLK2_1800_M		=	8'h00	;
parameter CLK2_2000_M		=	8'h00	;
parameter CLK2_2400_M		=	8'h00	;
parameter CLK2_3600_M		=	8'h00	;
parameter CLK2_4800_M		=	8'h00	;
parameter CLK2_7200_M		=	8'h00	;
parameter CLK2_9600_M		=	8'h00	;
parameter CLK2_19200_M		=	8'h00	;
parameter CLK2_38400_M		=	8'h00	;
parameter CLK2_56000_M		=	8'h0F	;//default
parameter CLK2_128000_M		=	8'h0F	;//default


//////////////////////////
//	CLOCK3	//////////////
//////////////////////////
parameter CLK3_50_L			=	8'h00	;
parameter CLK3_75_L			=	8'h00	;
parameter CLK3_110_L		=	8'hE9	;
parameter CLK3_134_5_L		=	8'h75	;
parameter CLK3_150_L		=	8'h00	;
parameter CLK3_300_L		=	8'h00	;
parameter CLK3_600_L		=	8'h80	;
parameter CLK3_1200_L		=	8'h98	;
parameter CLK3_1800_L		=	8'h80	;
parameter CLK3_2000_L		=	8'h40	;
parameter CLK3_2400_L		=	8'hE0	;
parameter CLK3_3600_L		=	8'h40	;
parameter CLK3_4800_L		=	8'hF0	;
parameter CLK3_7200_L		=	8'hA0	;
parameter CLK3_9600_L		=	8'h78	;
parameter CLK3_19200_L		=	8'h3C	;
parameter CLK3_38400_L		=	8'h1E	;
parameter CLK3_56000_L		=	8'h15	;
parameter CLK3_128000_L		=	8'h09	;

parameter CLK3_50_M			=	8'h5A	;
parameter CLK3_75_M			=	8'h3C	;
parameter CLK3_110_M		=	8'h28	;
parameter CLK3_134_5_M		=	8'h21	;
parameter CLK3_150_M		=	8'h1E	;
parameter CLK3_300_M		=	8'h0F	;
parameter CLK3_600_M		=	8'h07	;
parameter CLK3_1200_M		=	8'h03	;
parameter CLK3_1800_M		=	8'h02	;
parameter CLK3_2000_M		=	8'h02	;
parameter CLK3_2400_M		=	8'h01	;
parameter CLK3_3600_M		=	8'h01	;
parameter CLK3_4800_M		=	8'h00	;
parameter CLK3_7200_M		=	8'h00	;
parameter CLK3_9600_M		=	8'h00	;
parameter CLK3_19200_M		=	8'h00	;
parameter CLK3_38400_M		=	8'h00	;
parameter CLK3_56000_M		=	8'h00	;
parameter CLK3_128000_M		=	8'h00	;

parameter LSR_RD_CLR		=	8'h61	;
parameter MSR_CLEAR			=	8'hF0	;


////////////////////////////////////////////////////////
// Register and Field Defines 
////////////////////////////////////////////////////////


`define LCR_REG     regmap.lcr_reg 
`define LCR     regmap.lcr_reg.reg_val 
`define DLAB     regmap.lcr_reg.reg_val[7:7] 
`define BRKC     regmap.lcr_reg.reg_val[6:6] 
`define S_PAR     regmap.lcr_reg.reg_val[5:5] 
`define PAR_SEL     regmap.lcr_reg.reg_val[4:4] 
`define PAR_EN     regmap.lcr_reg.reg_val[3:3] 
`define STOP     regmap.lcr_reg.reg_val[2:2] 
`define CHARL     regmap.lcr_reg.reg_val[1:0] 

`define LSR_REG     regmap.lsr_reg 
`define LSR     regmap.lsr_reg.reg_val 
`define ERROR     regmap.lsr_reg.reg_val[7:7] 
`define TEMT     regmap.lsr_reg.reg_val[6:6] 
`define THRE     regmap.lsr_reg.reg_val[5:5] 
`define BI     regmap.lsr_reg.reg_val[4:4] 
`define FE     regmap.lsr_reg.reg_val[3:3] 
`define PE     regmap.lsr_reg.reg_val[2:2] 
`define OVRE     regmap.lsr_reg.reg_val[1:1] 
`define RCV_DR     regmap.lsr_reg.reg_val[0:0] 
`define TRIGGER_VALUE	 get_trigger_level(`TRIG_LVL)

`define CHAR_LENGTH	((`CHARL + 5) + (`PAR_EN) + (`STOP + 1) + 1)

`define FCR_REG     regmap.fcr_reg 
`define FCR     regmap.fcr_reg.reg_val 
`define TRIG_LVL     regmap.fcr_reg.reg_val[7:6] 
`define FCR_RS     regmap.fcr_reg.reg_val[5:4] 
`define MODE     regmap.fcr_reg.reg_val[3:3] 
`define XMIT_RST     regmap.fcr_reg.reg_val[2:2] 
`define RCVR_RST     regmap.fcr_reg.reg_val[1:1] 
`define FIFO_EN     regmap.fcr_reg.reg_val[0:0] 

`define IIR_REG     regmap.iir_reg 
`define IIR     regmap.iir_reg.reg_val 
`define IIR_RS1     regmap.iir_reg.reg_val[7:6] 
`define IIR_RS2     regmap.iir_reg.reg_val[5:4] 
`define TIMEOUT     regmap.iir_reg.reg_val[3:3] 
`define ID_INT     regmap.iir_reg.reg_val[2:1] 
`define PEND_INT     regmap.iir_reg.reg_val[0:0] 

`define IER_REG     regmap.ier_reg 
`define IER     regmap.ier_reg.reg_val 
`define IER_RS     regmap.ier_reg.reg_val[7:4] 
`define MODEM_ST     regmap.ier_reg.reg_val[3:3] 
`define REC_LS     regmap.ier_reg.reg_val[2:2] 
`define THRE_ST     regmap.ier_reg.reg_val[1:1] 
`define REC_DA     regmap.ier_reg.reg_val[0:0] 

`define MCR_REG     regmap.mcr_reg 
`define MCR     regmap.mcr_reg.reg_val 
`define MCR_RS     regmap.mcr_reg.reg_val[7:5] 
`define LOOPBACK     regmap.mcr_reg.reg_val[4:4] 
`define OUT2     regmap.mcr_reg.reg_val[3:3] 
`define OUT1     regmap.mcr_reg.reg_val[2:2] 
`define RTS     regmap.mcr_reg.reg_val[1:1] 
`define DTR     regmap.mcr_reg.reg_val[0:0] 

`define MSR_REG     regmap.msr_reg 
`define MSR     regmap.msr_reg.reg_val 
`define DCD     regmap.msr_reg.reg_val[7:7] 
`define RI     regmap.msr_reg.reg_val[6:6] 
`define DSR     regmap.msr_reg.reg_val[5:5] 
`define CTS     regmap.msr_reg.reg_val[4:4] 
`define DDCD     regmap.msr_reg.reg_val[3:3] 
`define TERI     regmap.msr_reg.reg_val[2:2] 
`define DDSR     regmap.msr_reg.reg_val[1:1] 
`define DCTS     regmap.msr_reg.reg_val[0:0] 
`define MSR_INT     regmap.msr_reg.reg_val[3:0] 

`define SCRATCH_PAD_REG     regmap.scratch_pad_reg 
`define SCRATCH_PAD     regmap.scratch_pad_reg.reg_val 
`define SCRATCH     regmap.scratch_pad_reg.reg_val[7:0] 

`define DLL_REG     regmap.dll_reg 
//`define DLL     regmap.dll_reg.reg_val 
`define DLL     regmap.dll_reg.reg_val[7:0] 

`define DLM_REG     regmap.dlm_reg 
//`define DLM     regmap.dlm_reg.reg_val 
`define DLM     regmap.dlm_reg.reg_val[7:0] 

`define XMIT_FIFO	regmap.xmit_fifo_reg
`define XMIT_FIFO_TOP	regmap.xmit_fifo_reg.xmit_fifo_top

`define RCVR_FIFO	regmap.rcvr_fifo_reg
`define RCVR_FIFO_TOP	regmap.rcvr_fifo_reg.rcvr_fifo_top

`define UART_FRAME_TEST
`define UART_TIMEOUT
`define UART_MODEM_CONTROL
`define UART_LOOPBACK
`define UART_MODE0
`define UART_MODE1
`define UART_BRAKE_INTR_CHECK
`define UART_ERROR_INJECTION_TC
`define UART_OVERRUN_CHECK
`define UART_THRE_INTERRUPT_TEST
`define UART_IIR_TRANS_COV


`define MAX_FIFO_DEPTH 16

`define MAX_FRAME_SIZE 12
////////////////////////////////////////////////////////
// Register Addresses
////////////////////////////////////////////////////////
//baud = 134.5 not possible for randomization -> set exclusive test
// `define baud_dist 50:=1, 75:=1, 110:=1, 150:=1, 300:=1, 600:=1, 1200:=1, 1800:=1, 2000:=1, 2400:= 1, 3600:=1, 4800:= 1, 7200:=1, 9600:=1, 19200:=1, 38400:=1, 56000:=1, 128000:=1

// `define baud_dist 50:=1, 75:=1, 110:=1, 150:=1, 300:=1, 600:=1
 `define baud_dist 4800:= 1, 7200:=1, 9600:=1, 19200:=1, 38400:=1


parameter MAX_TEST_COUNT	=	20;
parameter TEST_COUNT	=	13;
parameter PADDR_WIDTH		=	3;
parameter PDATA_WIDTH		=	8;
parameter PADDR_OFFSET_WIDTH = 2;

parameter WAIT_DELAY	=	10	;


parameter ADDR_BASE_UART  =  32'h00;

parameter LCR_ADDR = ADDR_BASE_UART + 8'h03;
parameter LSR_ADDR = ADDR_BASE_UART + 8'h05;
parameter FCR_ADDR = ADDR_BASE_UART + 8'h02;
parameter IIR_ADDR = ADDR_BASE_UART + 8'h02;
parameter IER_ADDR = ADDR_BASE_UART + 8'h01;
parameter MCR_ADDR = ADDR_BASE_UART + 8'h04;
parameter MSR_ADDR = ADDR_BASE_UART + 8'h06;
parameter SCRATCH_PAD_ADDR = ADDR_BASE_UART + 8'h07;
parameter DLL_ADDR = ADDR_BASE_UART + 8'h00;
parameter DLM_ADDR = ADDR_BASE_UART + 8'h01;
parameter XMIT_FIFO_ADDR = ADDR_BASE_UART + 8'h00;
parameter RCVR_FIFO_ADDR = ADDR_BASE_UART + 8'h00;

//-------- Common address list ------------------------
parameter XMIT_DLL_RCVR_00		=		ADDR_BASE_UART	+	8'h00	;
parameter DLM_IER_01			=		ADDR_BASE_UART	+	8'h01	;
parameter FCR_IIR_02			=		ADDR_BASE_UART	+	8'h02	;

parameter MODULE_START_ADDR        =  ADDR_BASE_UART;
parameter MODULE_END_ADDR          =  ADDR_BASE_UART + 32'h00003FF;
parameter NUM_REG                  =  10;

//----------- Register bit defines ------------------------
//===================== LCR ===========================
parameter LCR_RESET			= 		8'h00;
parameter LCR_DLAB   		=		8'h80;
parameter LCR_BRKC  		=		8'h40;
parameter LCR_S_PAR			=		8'h20;
parameter LCR_PAR_SEL		=		8'h10;
parameter LCR_PAR_EN		=		8'h08;
parameter LCR_STOP 			=		8'h04;
parameter LCR_CHARL_5		=		8'h00;
parameter LCR_CHARL_6		=		8'h01;
parameter LCR_CHARL_7		=		8'h02;
parameter LCR_CHARL_8		=		8'h03;

//===================== FCR ===========================
parameter FCR_RESET			=		8'h01;
parameter FCR_TRIG_LVL_1	=		8'h00;
parameter FCR_TRIG_LVL_4	=		8'h80;
parameter FCR_TRIG_LVL_8	=		8'h40;
parameter FCR_TRIG_LVL_14	=		8'hC0;
parameter FCR_TRIG_LVL_mask =		8'hC0;
parameter FCR_RS	  		=		8'h00;
parameter FCR_MODE   		=		8'h08;
// parameter FCR_MODE_0   		=		8'h00;
// parameter FCR_MODE_1   		=		8'h08;
parameter FCR_XMIT_RST 		=		8'h04;
parameter FCR_RCVR_RST		=		8'h02;
parameter FCR_FIFO_EN		=		8'h01;

//==================== IER ===========================
parameter IER_RESET			=		8'h00;   	 
parameter IER_MODEM_ST		=		8'h08;
parameter IER_REC_LS 		=		8'h04;
parameter IER_THRE_ST		=		8'h02;
parameter IER_REC_DA		=		8'h01;

//==================== MCR ===========================
parameter MCR_RESET			=		8'h00;
parameter MCR_LOOPBACK		=		8'h10;
parameter MCR_OUT2   		=		8'h08;
parameter MCR_OUT1  		=		8'h04;
parameter MCR_RTS  			=		8'h02;
parameter MCR_DTR 			=		8'h01;


