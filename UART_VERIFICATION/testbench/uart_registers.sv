//==============================================================================//
// File        : uart_regmap.sv                                         //
// Author(s)   :                                                                //
// Created     : 13-Mar-2014                                                        //
// Last update : 13-Mar-2014                                                        //
// Purpose     : simulation                                                     //
//------------------------------------------------------------------------------//
// Description :                                                                //
// This file has the registermap of uart instantiated                        //
//==============================================================================//
class XMIT_FIFO_Reg extends Generic_RegBase;
       
    // Randomly generated reserved bits
    
    // Default constraints on the reserved bits
    constraint reserved_bits  { 
    }
    
    // Coverage related bits
	static 	int 	xmit_fifo_top=-1;
	fifo			tx_fifo			;

	//bit [PDATA_WIDTH-1:0] tx_fifo [`MAX_FIFO_DEPTH-1:0] ;
    // bit        DLAB;
    // bit        BRKC;
    // bit        S_PAR;
    // bit        PAR_SEL;
    // bit        PAR_EN;
    // bit        STOP;
    // bit [1:0] CHARL;
    
    /////////////////////////////////////////////////////////
    // Function: new
    // -----------------------------------------------------
    // Description: new function of the class 
    ////////////////////////////////////////////////////////
    
    function new();
        reg_name = "XMIT_FIFO";
        reg_addr = XMIT_FIFO_ADDR;
        reg_bit_acc_type = {
            RW, RW, RW , RW, RW, RW, RW, RW
        };

		tx_fifo		=	new(`MAX_FIFO_DEPTH)	;

        vccdet_val   = 32'h0;
        rsth_val     = 32'h0;
        por_val      = 32'h0;
        rbtrst_val   = 32'h0;
        hardrst_val  = 32'h0;
        softrst_val  = 32'h0;
        vccdet_mask  = 32'hFF;
        rsth_mask    = 32'hFF;
        por_mask     = 32'hFF;
        rbtrst_mask  = 32'h0;
        hardrst_mask = 32'h0;
        softrst_mask = 32'h0;
        reg_wr_en    = 32'hFF;
        reg_rd_en    = 32'hFF;
        reg_val      = vccdet_val; 
    
    endfunction: new
    
    /////////////////////////////////////////////////////////
    // Task: update_bit_fields 
    // -----------------------------------------------------
    // Description: Update the coverage bits 
    ////////////////////////////////////////////////////////

	task update_bit_fields ();
		// $display("XMIT update",$time);
		// if(xmit_fifo_top < `MAX_FIFO_DEPTH-1) begin
		// 	xmit_fifo_top++ ;
		// 	$display("PUSH: fifo_top = %d",xmit_fifo_top,$time);
		// 	$display("reg_val = %b",reg_val,$time);
		// 	push(reg_val);
		// end
		// else 
		// begin
		// 	$display("FIFO overflow");
		// //FIX---- Set regmap status
		// end
		tx_fifo.push_fifo(reg_val);
		xmit_fifo_top	=	(tx_fifo.top()	-	1	)	;

	endtask

	//task push (bit[PDATA_WIDTH-1:0] data);

	//	tx_fifo[xmit_fifo_top] = reg_val;

	//endtask

	task pop(output [PDATA_WIDTH-1:0] pop_data);
		// if(xmit_fifo_top > -1) begin
		// 	pop_data = tx_fifo[0]	;
		// 	for(int i=0; i<xmit_fifo_top; i++) begin
		// 		tx_fifo[i]	=	tx_fifo[i+1];
		// 	end
		// 	xmit_fifo_top-- ;
		// 	$display("POP: fifo_top = %d",xmit_fifo_top,$time);
		// 	$display("POP: pop_data = %d",pop_data,$time);
		// end
		// else 
		// begin
		// 	$display("FIFO overflow");
		// //FIX---- Set regmap status
		// end

		pop_data	=	tx_fifo.pop();
		xmit_fifo_top	=	(tx_fifo.top()	-	1	)	;

	endtask


	task reset_por();


		repeat(tx_fifo.top())	begin
			tx_fifo.pop()	;
		end
		xmit_fifo_top	=	(tx_fifo.top()	-	1	)	;
		//for (int i=0; i < `MAX_FIFO_DEPTH; i++) begin
		//	tx_fifo[i]	=	0;
		//end
		//xmit_fifo_top = -1;
	endtask
		
		
endclass: XMIT_FIFO_Reg

class RCVR_FIFO_Reg extends Generic_RegBase;
       
    // Randomly generated reserved bits
    
    // Default constraints on the reserved bits
    constraint reserved_bits  { 
    }
    
    // Coverage related bits
	static 	int 	rcvr_fifo_top=-1;

	fifo				rx_fifo	;

	//bit [PDATA_WIDTH-1:0] rx_fifo [`MAX_FIFO_DEPTH-1:0] ;
    // bit        DLAB;
    // bit        BRKC;
    // bit        S_PAR;
    // bit        PAR_SEL;
    // bit        PAR_EN;
    // bit        STOP;
    // bit [1:0] CHARL;
    
    /////////////////////////////////////////////////////////
    // Function: new
    // -----------------------------------------------------
    // Description: new function of the class 
    ////////////////////////////////////////////////////////
    
    function new();
        reg_name = "RCVR_FIFO";
        reg_addr = RCVR_FIFO_ADDR;
        reg_bit_acc_type = {
            RW, RW, RW , RW, RW, RW, RW, RW
        };

		rx_fifo		=	new(`MAX_FIFO_DEPTH);


        vccdet_val   = 32'h0;
        rsth_val     = 32'h0;
        por_val      = 32'h0;
        rbtrst_val   = 32'h0;
        hardrst_val  = 32'h0;
        softrst_val  = 32'h0;
        vccdet_mask  = 32'hFF;
        rsth_mask    = 32'hFF;
        por_mask     = 32'hFF;
        rbtrst_mask  = 32'h0;
        hardrst_mask = 32'h0;
        softrst_mask = 32'h0;
        reg_wr_en    = 32'hFF;
        reg_rd_en    = 32'hFF;
        reg_val      = vccdet_val; 
    
    endfunction: new
    
    /////////////////////////////////////////////////////////
    // Task: update_bit_fields 
    // -----------------------------------------------------
    // Description: Update the coverage bits 
    ////////////////////////////////////////////////////////

	task update_bit_fields ();
		// if(rcvr_fifo_top < `MAX_FIFO_DEPTH-1) begin
		// 	rcvr_fifo_top++ ;
		// 	push(reg_val);
		// end
		// else 
		// begin
		// 	$display("FIFO overflow");
		// //FIX---- Set regmap status
		// end

		rx_fifo.push_fifo(reg_val);
		rcvr_fifo_top	=	(rx_fifo.top()	-	1	)	;



	endtask

	//task push (bit[PDATA_WIDTH-1:0] data);

	//	rx_fifo[rcvr_fifo_top] = reg_val;

	//endtask

	task push(input logic [PDATA_WIDTH-1:0] wr_data,
              input access_size_t           access_size);
		bit [PADDR_WIDTH-1:0] reg_offst;
		write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL);
	endtask

	task pop(output [PDATA_WIDTH-1:0] pop_data);
		// if(rcvr_fifo_top > -1) begin
		// 	pop_data = rx_fifo[0]	;
		// 	for(int i=0; i<rcvr_fifo_top; i++) begin
		// 		rx_fifo[i]	=	rx_fifo[i+1];
		// 	end
		// 	rcvr_fifo_top-- ;
		// end
		// else 
		// begin
		// 	$display("FIFO overflow");
		// //FIX---- Set regmap status
		// end

		pop_data	=	rx_fifo.pop();
		rcvr_fifo_top	=	(rx_fifo.top()	-	1	)	;
	endtask


	task reset_por();

		repeat(rx_fifo.top())	begin
			rx_fifo.pop()	;
		end
		rcvr_fifo_top	=	(rx_fifo.top()	-	1	)	;

		// for (int i=0; i < `MAX_FIFO_DEPTH; i++) begin
		// 	rx_fifo[i]	=	0;
		// end
		// rcvr_fifo_top = -1;
	endtask
		
		
endclass: RCVR_FIFO_Reg

class LCR_Reg extends Generic_RegBase;
       
    // Randomly generated reserved bits
    
    // Default constraints on the reserved bits
    constraint reserved_bits  { 
    }
    
    // Coverage related bits
    bit        DLAB;
    bit        BRKC;
    bit        S_PAR;
    bit        PAR_SEL;
    bit        PAR_EN;
    bit        STOP;
    bit [1:0] CHARL;
	static bit[PDATA_WIDTH-1:0] reg_lcr	;
    
    /////////////////////////////////////////////////////////
    // Function: new
    // -----------------------------------------------------
    // Description: new function of the class 
    ////////////////////////////////////////////////////////
    
    function new();
        reg_name = "LCR";
        reg_addr = LCR_ADDR;
        reg_bit_acc_type = {
            RW, RW, R , RW, RW, RW, RW, RW
        };

        vccdet_val   = 32'h0;
        rsth_val     = 32'h0;
        por_val      = 32'h0;
        rbtrst_val   = 32'h0;
        hardrst_val  = 32'h0;
        softrst_val  = 32'h0;
        vccdet_mask  = 32'hFF;
        rsth_mask    = 32'hFF;
        por_mask     = 32'hFF;
        rbtrst_mask  = 32'h0;
        hardrst_mask = 32'h0;
        softrst_mask = 32'h0;
        reg_wr_en    = 32'hFF;
        reg_rd_en    = 32'hFF;
        reg_val      = vccdet_val; 
    
    endfunction: new
    
    /////////////////////////////////////////////////////////
    // Task: update_bit_fields 
    // -----------------------------------------------------
    // Description: Update the coverage bits 
    ////////////////////////////////////////////////////////
    
    task update_bit_fields ();
        DLAB = reg_val[7:7];
        BRKC = reg_val[6:6];
        S_PAR = reg_val[5:5];
        PAR_SEL = reg_val[4:4];
        PAR_EN = reg_val[3:3];
        STOP = reg_val[2:2];
        CHARL = reg_val[1:0];
    endtask: update_bit_fields

	task start();
		
		forever@(reg_val) begin
			reg_lcr	=	reg_val	;
			$display("LCR_REG_VAL = %b",reg_val,$time);
			$display("LCR_REG_TEMP = %b",reg_lcr,$time);
		end

	endtask
    
endclass: LCR_Reg

class LSR_Reg extends Generic_RegBase;
       
    // Randomly generated reserved bits
    
    // Default constraints on the reserved bits
    constraint reserved_bits  { 
    }
    
    // Coverage related bits
    bit        ERROR;
    bit        TEMT;
    bit        THRE;
    bit        BI;
    bit        FE;
    bit        PE;
    bit        OVRE;
    bit        RCV_DR;

	static bit[PDATA_WIDTH-1:0] reg_lsr	;
    
    /////////////////////////////////////////////////////////
    // Function: new
    // -----------------------------------------------------
    // Description: new function of the class 
    ////////////////////////////////////////////////////////
    
    function new();
        reg_name = "LSR";
        reg_addr = LSR_ADDR;
        reg_bit_acc_type = {
            RO, RO, RO, RO, RO, RO, RO, RO
        };

        vccdet_val   = 32'h60;
        rsth_val     = 32'h60;
        por_val      = 32'h60;
        rbtrst_val   = 32'h60;
        hardrst_val  = 32'h60;
        softrst_val  = 32'h60;
        vccdet_mask  = 32'hFF;
        rsth_mask    = 32'hFF;
        por_mask     = 32'hFF;
        rbtrst_mask  = 32'h0;
        hardrst_mask = 32'h0;
        softrst_mask = 32'h0;
        reg_wr_en    = 32'hFF;
        reg_rd_en    = 32'hFF;
        reg_val      = vccdet_val; 
    
    endfunction: new
    
    /////////////////////////////////////////////////////////
    // Task: update_bit_fields 
    // -----------------------------------------------------
    // Description: Update the coverage bits 
    ////////////////////////////////////////////////////////
    
    task update_bit_fields ();
        ERROR = reg_val[7:7];
        TEMT = reg_val[6:6];
        THRE = reg_val[5:5];
        BI = reg_val[4:4];
        FE = reg_val[3:3];
        PE = reg_val[2:2];
        OVRE = reg_val[1:1];
        RCV_DR = reg_val[0:0];
    endtask: update_bit_fields
 
	task start();
		
		forever@(reg_val) begin
			reg_lsr	=	reg_val	;
			$display("LSR_REG_VAL = %b",reg_val,$time);
			$display("LSR_REG_TEMP = %b",reg_lsr,$time);
		end

	endtask
    
   
endclass: LSR_Reg

class FCR_Reg extends Generic_RegBase;
       
    // Randomly generated reserved bits
    
    // Default constraints on the reserved bits
    constraint reserved_bits  { 
    }
    
    // Coverage related bits
    bit [1:0] TRIG_LVL;
    bit [1:0] FCR_RS;
    bit        MODE;
    bit        XMIT_RST;
    bit        RCVR_RST;
    bit        FIFO_EN;
	static bit[PDATA_WIDTH-1:0] reg_fcr	;
    
    /////////////////////////////////////////////////////////
    // Function: new
    // -----------------------------------------------------
    // Description: new function of the class 
    ////////////////////////////////////////////////////////
    
    function new();
        reg_name = "FCR";
        reg_addr = FCR_ADDR;
        reg_bit_acc_type = {
            W , W , R , R , W , W , W , RO
        };

        vccdet_val   = 32'h1;
        rsth_val     = 32'h1;
        por_val      = 8'h01;
        rbtrst_val   = 32'h1;
        hardrst_val  = 32'h1;
        softrst_val  = 32'h1;
        vccdet_mask  = 32'hFF;
        rsth_mask    = 32'hFF;
        por_mask     = 32'hFF;
        rbtrst_mask  = 32'h0;
        hardrst_mask = 32'h0;
        softrst_mask = 32'h0;
        reg_wr_en    = 32'hFF;
        reg_rd_en    = 32'hFF;
        reg_val      = vccdet_val; 
    
    endfunction: new
    
    /////////////////////////////////////////////////////////
    // Task: update_bit_fields 
    // -----------------------------------------------------
    // Description: Update the coverage bits 
    ////////////////////////////////////////////////////////
    
    task update_bit_fields ();
        TRIG_LVL = reg_val[7:6];
        FCR_RS = reg_val[5:4];
        MODE = reg_val[3:3];
        XMIT_RST = reg_val[2:2];
        RCVR_RST = reg_val[1:1];
        FIFO_EN = reg_val[0:0];
    endtask: update_bit_fields
  
	task start();
		
		forever@(reg_val) begin
			reg_fcr	=	reg_val	;
			$display("FCR_REG_VAL = %b",reg_val,$time);
			$display("FCR_REG_TEMP = %b",reg_fcr,$time);
		end

	endtask
    
   
endclass: FCR_Reg

class IIR_Reg extends Generic_RegBase;
       
    // Randomly generated reserved bits
    
    // Default constraints on the reserved bits
    constraint reserved_bits  { 
    }
    
    // Coverage related bits
    bit [1:0] IIR_RS1;
    bit [1:0] IIR_RS2;
    bit        TIMEOUT;
    bit [1:0] ID_INT;
    bit        PEND_INT;

	static bit[PDATA_WIDTH-1:0]	reg_iir	;
    
    /////////////////////////////////////////////////////////
    // Function: new
    // -----------------------------------------------------
    // Description: new function of the class 
    ////////////////////////////////////////////////////////
    
    function new();
        reg_name = "IIR";
        reg_addr = IIR_ADDR;
        reg_bit_acc_type = {
            RO , RO , R , R , RO, RO, RO, RO
        };

        vccdet_val   = 32'h1;
        rsth_val     = 32'h1;
        //por_val      = 32'h1;
        por_val      = 8'hC1;
        rbtrst_val   = 32'h1;
        hardrst_val  = 32'h1;
        softrst_val  = 32'h1;
        vccdet_mask  = 32'hFF;
        rsth_mask    = 32'hFF;
        por_mask     = 32'hFF;
        rbtrst_mask  = 32'h0;
        hardrst_mask = 32'h0;
        softrst_mask = 32'h0;
        reg_wr_en    = 32'hFF;
        reg_rd_en    = 32'hFF;
        reg_val      = vccdet_val; 
    
    endfunction: new
    
    /////////////////////////////////////////////////////////
    // Task: update_bit_fields 
    // -----------------------------------------------------
    // Description: Update the coverage bits 
    ////////////////////////////////////////////////////////
    
    task update_bit_fields ();
        IIR_RS1 = reg_val[7:6];
        IIR_RS2 = reg_val[5:4];
        TIMEOUT = reg_val[3:3];
        ID_INT = reg_val[2:1];
        PEND_INT = reg_val[0:0];
    endtask: update_bit_fields
 
	task start();
		
		forever@(reg_val) begin
			reg_iir	=	reg_val	;
			$display("IIR_REG_VAL = %b",reg_val,$time);
			$display("IIR_REG_TEMP = %b",reg_iir,$time);
		end

	endtask
    
    
endclass: IIR_Reg

class IER_Reg extends Generic_RegBase;
       
    // Randomly generated reserved bits
    
    // Default constraints on the reserved bits
    constraint reserved_bits  { 
    }
    
    // Coverage related bits
    bit [3:0] IER_RS;
    bit        MODEM_ST;
    bit        REC_LS;
    bit        THRE_ST;
    bit        REC_DA;

	static bit[PDATA_WIDTH-1:0] reg_ier	;
    
    /////////////////////////////////////////////////////////
    // Function: new
    // -----------------------------------------------------
    // Description: new function of the class 
    ////////////////////////////////////////////////////////
    
    function new();
        reg_name = "IER";
        reg_addr = IER_ADDR;
        reg_bit_acc_type = {
            R , R , R , R , RW, RW, RW, RW
        };

        vccdet_val   = 32'h0;
        rsth_val     = 32'h0;
        por_val      = 32'h0;
        rbtrst_val   = 32'h0;
        hardrst_val  = 32'h0;
        softrst_val  = 32'h0;
        vccdet_mask  = 32'hFF;
        rsth_mask    = 32'hFF;
        por_mask     = 32'hFF;
        rbtrst_mask  = 32'h0;
        hardrst_mask = 32'h0;
        softrst_mask = 32'h0;
        reg_wr_en    = 32'hFF;
        reg_rd_en    = 32'hFF;
        reg_val      = vccdet_val; 
    
    endfunction: new
    
    /////////////////////////////////////////////////////////
    // Task: update_bit_fields 
    // -----------------------------------------------------
    // Description: Update the coverage bits 
    ////////////////////////////////////////////////////////
    
    task update_bit_fields ();
        IER_RS = reg_val[7:4];
        MODEM_ST = reg_val[3:3];
        REC_LS = reg_val[2:2];
        THRE_ST = reg_val[1:1];
        REC_DA = reg_val[0:0];
    endtask: update_bit_fields
 
	task start();
		
		forever@(reg_val) begin
			reg_ier	=	reg_val	;
			$display("IER_REG_VAL = %b",reg_val,$time);
			$display("IER_REG_TEMP = %b",reg_ier,$time);
		end

	endtask
    
    
endclass: IER_Reg

class MCR_Reg extends Generic_RegBase;
       
    // Randomly generated reserved bits
    
    // Default constraints on the reserved bits
    constraint reserved_bits  { 
    }
    
    // Coverage related bits
    bit [2:0] MCR_RS;
    bit        LOOPBACK;
    bit        OUT2;
    bit        OUT1;
    bit        RTS;
    bit        DTR;

	static bit[PDATA_WIDTH-1:0]	reg_mcr	;
    
    /////////////////////////////////////////////////////////
    // Function: new
    // -----------------------------------------------------
    // Description: new function of the class 
    ////////////////////////////////////////////////////////
    
    function new();
        reg_name = "MCR";
        reg_addr = MCR_ADDR;
        reg_bit_acc_type = {
            R , R , R , RW, RW, RW, RW, RW
        };

        vccdet_val   = 32'h0;
        rsth_val     = 32'h0;
        por_val      = 32'h0;
        rbtrst_val   = 32'h0;
        hardrst_val  = 32'h0;
        softrst_val  = 32'h0;
        vccdet_mask  = 32'hFF;
        rsth_mask    = 32'hFF;
        por_mask     = 32'hFF;
        rbtrst_mask  = 32'h0;
        hardrst_mask = 32'h0;
        softrst_mask = 32'h0;
        reg_wr_en    = 32'hFF;
        reg_rd_en    = 32'hFF;
        reg_val      = vccdet_val; 
    
    endfunction: new
    
    /////////////////////////////////////////////////////////
    // Task: update_bit_fields 
    // -----------------------------------------------------
    // Description: Update the coverage bits 
    ////////////////////////////////////////////////////////
    
    task update_bit_fields ();
        MCR_RS = reg_val[7:5];
        LOOPBACK = reg_val[4:4];
        OUT2 = reg_val[3:3];
        OUT1 = reg_val[2:2];
        RTS = reg_val[1:1];
        DTR = reg_val[0:0];
    endtask: update_bit_fields
  
	task start();
		
		forever@(reg_val) begin
			reg_mcr	=	reg_val	;
			$display("MCR_REG_VAL = %b",reg_val,$time);
			$display("MCR_REG_TEMP = %b",reg_mcr,$time);
		end

	endtask
    
   
endclass: MCR_Reg

class MSR_Reg extends Generic_RegBase;
       
    // Randomly generated reserved bits
    
    // Default constraints on the reserved bits
    constraint reserved_bits  { 
    }
    
    // Coverage related bits
    bit        DCD;
    bit        RI;
    bit        DSR;
    bit        CTS;
    bit        DDCD;
    bit        TERI;
    bit        DDSR;
    bit        DCTS;

	static bit [PDATA_WIDTH-1:0]	reg_msr	;
    
    /////////////////////////////////////////////////////////
    // Function: new
    // -----------------------------------------------------
    // Description: new function of the class 
    ////////////////////////////////////////////////////////
    
    function new();
        reg_name = "MSR";
        reg_addr = MSR_ADDR;
        reg_bit_acc_type = {
            RO, RO, RO, RO, RO, RO, RO, RO
        };

        vccdet_val   = 32'h0;
        rsth_val     = 32'h0;
        por_val      = 32'h0;
        rbtrst_val   = 32'h0;
        hardrst_val  = 32'h0;
        softrst_val  = 32'h0;
        vccdet_mask  = 32'hFF;
        rsth_mask    = 32'hFF;
        por_mask     = 32'hFF;
        rbtrst_mask  = 32'h0;
        hardrst_mask = 32'h0;
        softrst_mask = 32'h0;
        reg_wr_en    = 32'hFF;
        reg_rd_en    = 32'hFF;
        reg_val      = vccdet_val; 
    
    endfunction: new
    
    /////////////////////////////////////////////////////////
    // Task: update_bit_fields 
    // -----------------------------------------------------
    // Description: Update the coverage bits 
    ////////////////////////////////////////////////////////
    
    task update_bit_fields ();
        DCD = reg_val[7:7];
        RI = reg_val[6:6];
        DSR = reg_val[5:5];
        CTS = reg_val[4:4];
        DDCD = reg_val[3:3];
        TERI = reg_val[2:2];
        DDSR = reg_val[1:1];
        DCTS = reg_val[0:0];
    endtask: update_bit_fields
 
	task start();
		
		forever@(reg_val) begin
			reg_msr	=	reg_val	;
			$display("MSR_REG_VAL = %b",reg_val,$time);
			$display("MSR_REG_TEMP = %b",reg_msr,$time);
		end

	endtask
    
    
endclass: MSR_Reg

class SCRATCH_PAD_Reg extends Generic_RegBase;
       
    // Randomly generated reserved bits
    
    // Default constraints on the reserved bits
    constraint reserved_bits  { 
    }
    
    // Coverage related bits
    bit [7:0] SCRATCH;
    
    /////////////////////////////////////////////////////////
    // Function: new
    // -----------------------------------------------------
    // Description: new function of the class 
    ////////////////////////////////////////////////////////
    
    function new();
        reg_name = "SCRATCH_PAD";
        reg_addr = SCRATCH_PAD_ADDR;
        reg_bit_acc_type = {
            RW, RW, RW, RW, RW, RW, RW, RW
        };

        vccdet_val   = 32'h0;
        rsth_val     = 32'h0;
        por_val      = 32'h0;
        rbtrst_val   = 32'h0;
        hardrst_val  = 32'h0;
        softrst_val  = 32'h0;
        vccdet_mask  = 32'hFF;
        rsth_mask    = 32'hFF;
        por_mask     = 32'hFF;
        rbtrst_mask  = 32'h0;
        hardrst_mask = 32'h0;
        softrst_mask = 32'h0;
        reg_wr_en    = 32'hFF;
        reg_rd_en    = 32'hFF;
        reg_val      = vccdet_val; 
    
    endfunction: new
    
    /////////////////////////////////////////////////////////
    // Task: update_bit_fields 
    // -----------------------------------------------------
    // Description: Update the coverage bits 
    ////////////////////////////////////////////////////////
    
    task update_bit_fields ();
        SCRATCH = reg_val[7:0];
    endtask: update_bit_fields
    
endclass: SCRATCH_PAD_Reg

class DLL_Reg extends Generic_RegBase;
       
    // Randomly generated reserved bits
    
    // Default constraints on the reserved bits
    constraint reserved_bits  { 
    }
    
    // Coverage related bits
    bit [7:0] DLL;

	static bit[PDATA_WIDTH-1:0]	reg_dll	;
    
    /////////////////////////////////////////////////////////
    // Function: new
    // -----------------------------------------------------
    // Description: new function of the class 
    ////////////////////////////////////////////////////////
    
    function new();
        reg_name = "DLL";
        reg_addr = DLL_ADDR;
        reg_bit_acc_type = {
            RW, RW, RW, RW, RW, RW, RW, RW
        };

        vccdet_val   = 32'h0;
        rsth_val     = 32'h0;
        por_val      = 32'h0;
        rbtrst_val   = 32'h0;
        hardrst_val  = 32'h0;
        softrst_val  = 32'h0;
        vccdet_mask  = 32'hFF;
        rsth_mask    = 32'hFF;
        por_mask     = 32'hFF;
        rbtrst_mask  = 32'h0;
        hardrst_mask = 32'h0;
        softrst_mask = 32'h0;
        reg_wr_en    = 32'hFF;
        reg_rd_en    = 32'hFF;
        reg_val      = vccdet_val; 
    
    endfunction: new
    
    /////////////////////////////////////////////////////////
    // Task: update_bit_fields 
    // -----------------------------------------------------
    // Description: Update the coverage bits 
    ////////////////////////////////////////////////////////
    
    task update_bit_fields ();
        DLL = reg_val[7:0];
    endtask: update_bit_fields
  
	task start();
		
		forever@(reg_val) begin
			reg_dll	=	reg_val	;
			$display("DLL_REG_VAL = %b",reg_val,$time);
			$display("DLL_REG_TEMP = %b",reg_dll,$time);
		end

	endtask
    
   
endclass: DLL_Reg

class DLM_Reg extends Generic_RegBase;
       
    // Randomly generated reserved bits
    
    // Default constraints on the reserved bits
    constraint reserved_bits  { 
    }
    
    // Coverage related bits
    bit [7:0] DLM;
	static bit[PDATA_WIDTH-1:0]	reg_dlm	;
    
    /////////////////////////////////////////////////////////
    // Function: new
    // -----------------------------------------------------
    // Description: new function of the class 
    ////////////////////////////////////////////////////////
    
    function new();
        reg_name = "DLM";
        reg_addr = DLM_ADDR;
        reg_bit_acc_type = {
            RW, RW, RW, RW, RW, RW, RW, RW
        };

        vccdet_val   = 32'h0;
        rsth_val     = 32'h0;
        por_val      = 32'h0;
        rbtrst_val   = 32'h0;
        hardrst_val  = 32'h0;
        softrst_val  = 32'h0;
        vccdet_mask  = 32'hFF;
        rsth_mask    = 32'hFF;
        por_mask     = 32'hFF;
        rbtrst_mask  = 32'h0;
        hardrst_mask = 32'h0;
        softrst_mask = 32'h0;
        reg_wr_en    = 32'hFF;
        reg_rd_en    = 32'hFF;
        reg_val      = vccdet_val; 
    
    endfunction: new
    
    /////////////////////////////////////////////////////////
    // Task: update_bit_fields 
    // -----------------------------------------------------
    // Description: Update the coverage bits 
    ////////////////////////////////////////////////////////
    
    task update_bit_fields ();
        DLM = reg_val[7:0];
    endtask: update_bit_fields
 
	task start();
		
		forever@(reg_val) begin
			reg_dlm	=	reg_val	;
			$display("DLM_REG_VAL = %b",reg_val,$time);
			$display("DLM_REG_TEMP = %b",reg_dlm,$time);
		end

	endtask
    
    
endclass: DLM_Reg

