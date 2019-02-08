//==============================================================================//
// File        : uart_regmap.sv                                        //
// Author(s)   :                                                                //
// Created     : 13-Mar-2014                                                  //
// Last update : 13-Mar-2014                                                  //
// Purpose     : simulation                                                     //
//------------------------------------------------------------------------------//
// Description :                                                                //
// This file has the registermap of uart instantiated                  //
//==============================================================================//

class uart_Regmap extends Generic_Regmap;

        /////////////////////////////////////////////////////////
        // Instantiate all registers in the regmap
        /////////////////////////////////////////////////////////
        LCR_Reg lcr_reg;
        LSR_Reg lsr_reg;
        FCR_Reg fcr_reg;
        IIR_Reg iir_reg;
        IER_Reg ier_reg;
        MCR_Reg mcr_reg;
        MSR_Reg msr_reg;
        SCRATCH_PAD_Reg scratch_pad_reg;
        DLL_Reg dll_reg;
        DLM_Reg dlm_reg;
		XMIT_FIFO_Reg	xmit_fifo_reg;
		RCVR_FIFO_Reg	rcvr_fifo_reg;


        /////////////////////////////////////////////////////////
        // Random variables for all the fields in the regmap
        /////////////////////////////////////////////////////////

        //  LCR 
        rand bit        rand_DLAB;
        rand bit        rand_BRKC;
        rand bit        rand_S_PAR;
        rand bit        rand_PAR_SEL;
        rand bit        rand_PAR_EN;
        rand bit        rand_STOP;
        rand bit [1:0] rand_CHARL;

        //  LSR 
        rand bit        rand_ERROR;
        rand bit        rand_TEMT;
        rand bit        rand_THRE;
        rand bit        rand_BI;
        rand bit        rand_FE;
        rand bit        rand_PE;
        rand bit        rand_OVRE;
        rand bit        rand_RCV_DR;

        //  FCR 
        rand bit [1:0] rand_TRIG_LVL;
        rand bit [1:0] rand_FCR_RS;
        rand bit        rand_MODE;
        rand bit        rand_XMIT_RST;
        rand bit        rand_RCVR_RST;
        rand bit        rand_FIFO_EN;

        //  IIR 
        rand bit [1:0] rand_IIR_RS1;
        rand bit [1:0] rand_IIR_RS2;
        rand bit        rand_TIMEOUT;
        rand bit [1:0] rand_ID_INT;
        rand bit        rand_PEND_INT;

        //  IER 
        rand bit [3:0] rand_IER_RS;
        rand bit        rand_MODEM_ST;
        rand bit        rand_REC_LS;
        rand bit        rand_THRE_ST;
        rand bit        rand_REC_DA;

        //  MCR 
        rand bit [2:0] rand_MCR_RS;
        rand bit        rand_LOOPBACK;
        rand bit        rand_OUT2;
        rand bit        rand_OUT1;
        rand bit        rand_RTS;
        rand bit        rand_DTR;

        //  MSR 
        rand bit        rand_DCD;
        rand bit        rand_RI;
        rand bit        rand_DSR;
        rand bit        rand_CTS;
        rand bit        rand_DDCD;
        rand bit        rand_TERI;
        rand bit        rand_DDSR;
        rand bit        rand_DCTS;

        //  SCRATCH_PAD 
        rand bit [7:0] rand_SCRATCH;

        //  DLL 
        rand bit [7:0] rand_DLL;

        //  DLM 
        rand bit [7:0] rand_DLM;
		bit tot_intr = 1'b1	;

		bit thre	;
		bit msr_int	;
		bit trig_int	;
		bit get_trg	;
		bit lsr_error	;

        /////////////////////////////////////////////////////////
        // Function: new
        // -----------------------------------------------------
        // Description: new function of the class 
        ////////////////////////////////////////////////////////

        function new();
            // create objects for registers
            lcr_reg = new();
            lsr_reg = new();
            fcr_reg = new();
            iir_reg = new();
            ier_reg = new();
            mcr_reg = new();
            msr_reg = new();
            scratch_pad_reg = new();
            dll_reg = new();
            dlm_reg = new();
			xmit_fifo_reg = new();
			rcvr_fifo_reg = new();

            // add register addresses to regmap_addr queue
            regmap_addr.push_back(lcr_reg.reg_addr);
            regmap_addr.push_back(lsr_reg.reg_addr);
            regmap_addr.push_back(fcr_reg.reg_addr);
            regmap_addr.push_back(iir_reg.reg_addr);
            regmap_addr.push_back(ier_reg.reg_addr);
            regmap_addr.push_back(mcr_reg.reg_addr);
            regmap_addr.push_back(msr_reg.reg_addr);
            regmap_addr.push_back(scratch_pad_reg.reg_addr);
            regmap_addr.push_back(dll_reg.reg_addr);
            regmap_addr.push_back(dlm_reg.reg_addr);
            regmap_addr.push_back(rcvr_fifo_reg.reg_addr);

        endfunction: new


		task start();
			fork
				lcr_reg.start();
				lsr_reg.start();
				fcr_reg.start();
				mcr_reg.start();
				msr_reg.start();
				iir_reg.start();
				ier_reg.start();
				dll_reg.start();
				dlm_reg.start();
				forever@(lsr_reg.reg_val,msr_reg.reg_val,fcr_reg.reg_val,ier_reg.reg_val,rcvr_fifo_reg.rcvr_fifo_top, xmit_fifo_reg.xmit_fifo_top)	begin
					iir_reg.reg_val[7]	=	fcr_reg.reg_val[0];
					iir_reg.reg_val[6]	=	fcr_reg.reg_val[0];
					thre	=	(lsr_reg.reg_val[5]	&& ier_reg.reg_val[1]);
					lsr_error	=	((lsr_reg.reg_val[7] || lsr_reg.reg_val[1])&& ier_reg.reg_val[2])	;
					msr_int		=	((|msr_reg.reg_val[3:0]) && ier_reg.reg_val[3])	;
					get_trg		=	(rcvr_fifo_reg.rcvr_fifo_top >= get_trigger_level(fcr_reg.reg_val[7:6]));
					trig_int	=	(get_trg && ier_reg.reg_val[0]) ;
					tot_intr	=	thre || lsr_error || msr_int || trig_int	;
					iir_reg.reg_val[0] = ~tot_intr	;	
					set_interrupt()	;

				end
				forever@(fcr_reg.reg_val)	begin

					fork
						if(fcr_reg.reg_val[2])	xmit_fifo_reg.reset_por();
						if(fcr_reg.reg_val[1])	rcvr_fifo_reg.reset_por();
					join

				end
			join_none
		endtask

		function void set_interrupt();

			if(lsr_error ) iir_reg.reg_val[2:1] 		= 'b11	;
			else if(trig_int ) iir_reg.reg_val[2:1] 	= 'b10	;
			else if(thre ) iir_reg.reg_val[2:1] 		= 'b01	;
			else if(msr_int ) iir_reg.reg_val[2:1] 	= 'b00	;

		endfunction
        
        /////////////////////////////////////////////////////////
        // Task: write_regmap()
        // -----------------------------------------------------
        // Description: Write to a register in the regmap
        ////////////////////////////////////////////////////////

        task write_regmap (input logic [PADDR_WIDTH-1:0] wr_addr,
                           input logic [PDATA_WIDTH-1:0] wr_data,
                           input access_size_t           access_size);

           bit [PADDR_WIDTH-1:0] reg_offst;
           bit [PADDR_WIDTH-1:0] reg_addr;

           //reg_offst = wr_addr % 4;
           //reg_addr  = wr_addr - reg_offst;
		   reg_addr	=	wr_addr;
		   $display("actual_addr = %b",wr_addr);
		   $display("reg_addr = %b",reg_addr);
		   $display("from regmap: wr_data = %b",wr_data);
		   $display("DLAB = %b",lcr_reg.reg_val[7:7]);

           // messagef(DEBUG,INFO,`HIERARCHY,$sformatf("Updating register addr: %h offst:%h accss: %h", reg_addr, reg_offst, access_size));
           case (reg_addr)
                LCR_ADDR: lcr_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL); 
                LSR_ADDR: lsr_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL); 
                FCR_ADDR: fcr_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL); 
                //IIR_ADDR: iir_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size); 
                //IER_ADDR: begin
				//			if(lcr_reg.reg_val[7:7] === 1'b0) ier_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL); 
				//		  end
                MCR_ADDR: mcr_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL); 
                MSR_ADDR: msr_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL); 
                SCRATCH_PAD_ADDR: scratch_pad_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL); 
                //DLL_ADDR: begin
				//			if(lcr_reg.reg_val[7:7] === 1'b1) dll_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL); 
				//		  end
                //DLM_ADDR: begin
				//			if(lcr_reg.reg_val[7:7] === 1'b1) dlm_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL); 
				//		  end
				DLM_IER_01: begin
							if(lcr_reg.reg_val[7:7] === 1'b0) ier_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL); 
							else if(lcr_reg.reg_val[7:7] === 1'b1) dlm_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL);
						  end

		//  XMIT_FIFO_ADDR: begin
		//  					if(lcr_reg.reg_val[7:7] === 1'b0) xmit_fifo_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL);
		//				  end
		XMIT_DLL_RCVR_00: begin
							if(lcr_reg.reg_val[7:7] === 1'b1) dll_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL); 
							else if(lcr_reg.reg_val[7:7] === 1'b0) xmit_fifo_reg.write_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], wr_data, access_size, BYTE_EN_VAL);
						  end
           endcase
        endtask: write_regmap



        /////////////////////////////////////////////////////////
        // Task: read_regmap()
        // -----------------------------------------------------
        // Description: Read from a register in the regmap
        ////////////////////////////////////////////////////////

        task read_regmap ( input  logic [PADDR_WIDTH-1:0] rd_addr,
                           output logic [PDATA_WIDTH-1:0] rd_data,
                           input  access_size_t           access_size);

           bit [PADDR_WIDTH-1:0] reg_offst;
           bit [PADDR_WIDTH-1:0] reg_addr;

        //   reg_offst = rd_addr % 4;
        //   reg_addr = rd_addr - reg_offst;
	   	//	reg_offst = 0;
			reg_addr	=	rd_addr	;

           case (reg_addr)
                LCR_ADDR: lcr_reg.read_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], rd_data, access_size); 
                LSR_ADDR: lsr_reg.read_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], rd_data, access_size); 
                //FCR_ADDR: fcr_reg.read_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], rd_data, access_size); 
                IIR_ADDR: iir_reg.read_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], rd_data, access_size); 
                IER_ADDR: ier_reg.read_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], rd_data, access_size); 
                MCR_ADDR: mcr_reg.read_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], rd_data, access_size); 
                MSR_ADDR: msr_reg.read_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], rd_data, access_size); 
                SCRATCH_PAD_ADDR: scratch_pad_reg.read_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], rd_data, access_size); 
               // DLL_ADDR: dll_reg.read_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], rd_data, access_size); 
                DLM_ADDR: dlm_reg.read_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], rd_data, access_size); 
		//  RCVR_FIFO_ADDR: begin
		//  					if(lcr_reg.reg_val[7:7] === 1'b0) rcvr_fifo_reg.pop(rd_data);
		//				  end
		XMIT_DLL_RCVR_00: begin
							if(lcr_reg.reg_val[7:7] === 1'b0) rcvr_fifo_reg.pop(rd_data);
							else if(lcr_reg.reg_val[7:7] === 1'b1) dll_reg.read_reg(reg_offst[PADDR_OFFSET_WIDTH-1:0], rd_data, access_size);
						  end
			default: rd_data = 0;
           endcase
           // messagef(DEBUG,INFO,`HIERARCHY,$sformatf("read from register addr: %h offst %h accss: %h data: %h \n", reg_addr, reg_offst, access_size, rd_data));
        endtask: read_regmap

        /////////////////////////////////////////////////////////
        // Task: reset_regmap_vccdet
        // -----------------------------------------------------
        // Description: Assigns the reset valus to all the 
        //              registers upon vccdet
        // 
        ////////////////////////////////////////////////////////
        
        //NA task reset_regmap_vccdet;

        //NA      lcr_reg.reset_vccdet(); 
        //NA      lsr_reg.reset_vccdet(); 
        //NA      fcr_reg.reset_vccdet(); 
        //NA      iir_reg.reset_vccdet(); 
        //NA      ier_reg.reset_vccdet(); 
        //NA      mcr_reg.reset_vccdet(); 
        //NA      msr_reg.reset_vccdet(); 
        //NA      scratch_pad_reg.reset_vccdet(); 
        //NA      dll_reg.reset_vccdet(); 
        //NA      dlm_reg.reset_vccdet(); 

        //NA endtask: reset_regmap_vccdet

        /////////////////////////////////////////////////////////
        // Task: reset_regmap_rsth
        // -----------------------------------------------------
        // Description: Assigns the reset valus to all the 
        //              registers upon rsth
        // 
        ////////////////////////////////////////////////////////
        
        //NA task reset_regmap_rsth;

        //NA      lcr_reg.reset_rsth(); 
        //NA      lsr_reg.reset_rsth(); 
        //NA      fcr_reg.reset_rsth(); 
        //NA      iir_reg.reset_rsth(); 
        //NA      ier_reg.reset_rsth(); 
        //NA      mcr_reg.reset_rsth(); 
        //NA      msr_reg.reset_rsth(); 
        //NA      scratch_pad_reg.reset_rsth(); 
        //NA      dll_reg.reset_rsth(); 
        //NA      dlm_reg.reset_rsth(); 

        //NA endtask: reset_regmap_rsth

 
        /////////////////////////////////////////////////////////
        // Task: reset_regmap_por
        // -----------------------------------------------------
        // Description: Assigns the reset valus to all the 
        //              registers upon por
        //
        ////////////////////////////////////////////////////////
        
        task reset_regmap_por;

             lcr_reg.reset_por(); 
             lsr_reg.reset_por(); 
             fcr_reg.reset_por(); 
             iir_reg.reset_por(); 
             ier_reg.reset_por(); 
             mcr_reg.reset_por(); 
             msr_reg.reset_por(); 
             scratch_pad_reg.reset_por(); 
             dll_reg.reset_por(); 
             dlm_reg.reset_por(); 
			 xmit_fifo_reg.reset_por();
			 rcvr_fifo_reg.reset_por();

        endtask: reset_regmap_por

        /////////////////////////////////////////////////////////
        // Task: reset_regmap_rbtrst
        // -----------------------------------------------------
        // Description: Assigns the reset values to all the 
        //              registers upon rbtrst
        //
        ////////////////////////////////////////////////////////
        
        //NA task reset_regmap_rbtrst;

        //NA      lcr_reg.reset_rbtrst(); 
        //NA      lsr_reg.reset_rbtrst(); 
        //NA      fcr_reg.reset_rbtrst(); 
        //NA      iir_reg.reset_rbtrst(); 
        //NA      ier_reg.reset_rbtrst(); 
        //NA      mcr_reg.reset_rbtrst(); 
        //NA      msr_reg.reset_rbtrst(); 
        //NA      scratch_pad_reg.reset_rbtrst(); 
        //NA      dll_reg.reset_rbtrst(); 
        //NA      dlm_reg.reset_rbtrst(); 

        //NA endtask: reset_regmap_rbtrst


        /////////////////////////////////////////////////////////
        // Task: reset_regmap_hardrst
        // -----------------------------------------------------
        // Description: Assigns the reset values to all the 
        //              registers upon hardrst
        //
        ////////////////////////////////////////////////////////
        
        //NA task reset_regmap_hardrst;

        //NA      lcr_reg.reset_hardrst(); 
        //NA      lsr_reg.reset_hardrst(); 
        //NA      fcr_reg.reset_hardrst(); 
        //NA      iir_reg.reset_hardrst(); 
        //NA      ier_reg.reset_hardrst(); 
        //NA      mcr_reg.reset_hardrst(); 
        //NA      msr_reg.reset_hardrst(); 
        //NA      scratch_pad_reg.reset_hardrst(); 
        //NA      dll_reg.reset_hardrst(); 
        //NA      dlm_reg.reset_hardrst(); 

        //NA endtask: reset_regmap_hardrst

        /////////////////////////////////////////////////////////
        // Task: reset_regmap_softrst
        // -----------------------------------------------------
        // Description: Assigns the reset valus to all the 
        //              registers upon softrst
        ////////////////////////////////////////////////////////
        
        //NA task reset_regmap_softrst;

        //NA      lcr_reg.reset_softrst(); 
        //NA      lsr_reg.reset_softrst(); 
        //NA      fcr_reg.reset_softrst(); 
        //NA      iir_reg.reset_softrst(); 
        //NA      ier_reg.reset_softrst(); 
        //NA      mcr_reg.reset_softrst(); 
        //NA      msr_reg.reset_softrst(); 
        //NA      scratch_pad_reg.reset_softrst(); 
        //NA      dll_reg.reset_softrst(); 
        //NA      dlm_reg.reset_softrst(); 

        //NA endtask: reset_regmap_softrst
        

        /////////////////////////////////////////////////////////
        // Function: get_rand_gen_data
        // -----------------------------------------------------
        // Description: Gets the random-generated data for a 
        //              given address
        ////////////////////////////////////////////////////////

	function bit [PDATA_WIDTH-1:0]  get_rand_gen_data(input  logic [       PADDR_WIDTH-1:0] reg_addr,
                                                          input  logic [PADDR_OFFSET_WIDTH-1:0] offset,
                                                          input  access_size_t                  access_size,
                                                          input  reset_t                        write_type = NONE);

	   bit  [PDATA_WIDTH-1:0] rand_data_val;

           case (reg_addr)
                LCR_ADDR: begin 
                    lcr_reg.bits_7_0_rand_tmp = {rand_DLAB,rand_BRKC,rand_S_PAR,rand_PAR_SEL,rand_PAR_EN,rand_STOP,rand_CHARL };
                    rand_data_val     =  lcr_reg.collate_bit_fields(offset, access_size, write_type); 
                end 
                LSR_ADDR: begin 
                    lsr_reg.bits_7_0_rand_tmp = {rand_ERROR,rand_TEMT,rand_THRE,rand_BI,rand_FE,rand_PE,rand_OVRE,rand_RCV_DR };
                    rand_data_val     =  lsr_reg.collate_bit_fields(offset, access_size, write_type); 
                end 
                FCR_ADDR: begin 
                    fcr_reg.bits_7_0_rand_tmp = {rand_TRIG_LVL,rand_FCR_RS,rand_MODE,rand_XMIT_RST,rand_RCVR_RST,rand_FIFO_EN };
                    rand_data_val     =  fcr_reg.collate_bit_fields(offset, access_size, write_type); 
                end 
                IIR_ADDR: begin 
                    iir_reg.bits_7_0_rand_tmp = {rand_IIR_RS1,rand_IIR_RS2,rand_TIMEOUT,rand_ID_INT,rand_PEND_INT };
                    rand_data_val     =  iir_reg.collate_bit_fields(offset, access_size, write_type); 
                end 
                IER_ADDR: begin 
                    ier_reg.bits_7_0_rand_tmp = {rand_IER_RS,rand_MODEM_ST,rand_REC_LS,rand_THRE_ST,rand_REC_DA };
                    rand_data_val     =  ier_reg.collate_bit_fields(offset, access_size, write_type); 
                end 
                MCR_ADDR: begin 
                    mcr_reg.bits_7_0_rand_tmp = {rand_MCR_RS,rand_LOOPBACK,rand_OUT2,rand_OUT1,rand_RTS,rand_DTR };
                    rand_data_val     =  mcr_reg.collate_bit_fields(offset, access_size, write_type); 
                end 
                MSR_ADDR: begin 
                    msr_reg.bits_7_0_rand_tmp = {rand_DCD,rand_RI,rand_DSR,rand_CTS,rand_DDCD,rand_TERI,rand_DDSR,rand_DCTS };
                    rand_data_val     =  msr_reg.collate_bit_fields(offset, access_size, write_type); 
                end 
                SCRATCH_PAD_ADDR: begin 
                    scratch_pad_reg.bits_7_0_rand_tmp = {rand_SCRATCH };
                    rand_data_val     =  scratch_pad_reg.collate_bit_fields(offset, access_size, write_type); 
                end 
                DLL_ADDR: begin 
                    dll_reg.bits_7_0_rand_tmp = {rand_DLL };
                    rand_data_val     =  dll_reg.collate_bit_fields(offset, access_size, write_type); 
                end 
                DLM_ADDR: begin 
                    dlm_reg.bits_7_0_rand_tmp = {rand_DLM };
                    rand_data_val     =  dlm_reg.collate_bit_fields(offset, access_size, write_type); 
                end 
           endcase

           return rand_data_val;

        endfunction: get_rand_gen_data


        /////////////////////////////////////////////////////////
        // Task: start
        // -----------------------------------------------------
        // Description: starts any forever running tasks
        //              
        ////////////////////////////////////////////////////////

        // task start();

        // endtask: start


        
endclass: uart_Regmap


