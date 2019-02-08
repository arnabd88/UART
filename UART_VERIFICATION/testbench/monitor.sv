
module monitor (

	Apb_Interface 	 	u_apb_intf			,
	Uart_Interface 		u_uart_intf			,
	Event_Interface 	u_event_intf
	
	);

	reg [PADDR_WIDTH-1:0]	PADDR_reg	;
	reg [PDATA_WIDTH-1:0]	PWDATA_reg	;
	reg [PDATA_WIDTH-1:0]	PRDATA_reg	;
	reg [PDATA_WIDTH-1:0]	data_buffer	;
	reg PWRITE_reg	;
	reg PENABLE_reg	;
	reg prev_DCDn;
	reg prev_RIn;
	reg prev_CTSn;
	reg prev_DSRn;

	reg reg_DCD, reg_CTS, reg_RI, reg_DSR	;

	int hold_fifo_count	;

	int div_value		;

	`MODULE_REGMAP regmap;
	reg	RDL_ST	;

	wire [PDATA_WIDTH-1:0] DLL	;
	wire [PDATA_WIDTH-1:0] DLM	;


	`include "uart_coverage.sv"

	assign DLL		=		(regmap!==null)?DLL_Reg::reg_dll : 0;
	assign DLM		=		(regmap!==null)?DLM_Reg::reg_dlm : 0;

	always@(DLL,DLM) begin
		$display("DLL, DLM has changed",$time);
		case({DLM,DLL}) 
			16'h0900	:	div_value	=	2304	;
			16'h0600	:	div_value	=	1536	;
			16'h0417	:	div_value	=	1047	;
			16'h0359	:	div_value	=	857		;
			16'h0300	:	div_value	=	768		;
			16'h0180	:	div_value	=	384		;
			16'h00C0	:	div_value	=	192		;
			16'h0060	:	div_value	=	96 		;
			16'h0040	:	div_value	=	64		;
			16'h003A	:	div_value	=	58		;
			16'h0030	:	div_value	=	48		;
			16'h0020	:	div_value	=	32		;
			16'h0018	:	div_value	=	24		;
			16'h0010	:	div_value	=	16		;
			16'h000C	:	div_value	=	12		;
			16'h0006	:	div_value	=	6 		;
			16'h0003	:	div_value	=	3       ;
			16'h0002	:	div_value	=	2		;

			16'h0F00	:	div_value	=	3840	;
			16'h0A00	:	div_value	=	2560	;
			16'h06D1	:	div_value	=	1745	;
			16'h0594	:	div_value	=	1428	;
			16'h0500	:	div_value	=	1280	;
			16'h0280	:	div_value	=	640		;
			16'h0140	:	div_value	=	320		;
			16'h00A0	:	div_value	=	160		;
			16'h006B	:	div_value	=	107		;
	//		16'h0060	:	div_value	=			;
			16'h0050	:	div_value	=	80		;
			16'h0035	:	div_value	=	53		;
			16'h0028	:	div_value	=	40		;
			16'h001B	:	div_value	=	27		;
			16'h0014	:	div_value	=	20		;
			16'h000A	:	div_value	=	10		;
			16'h0005	:	div_value	=	5		;


			16'h5A00	:	div_value	=	23040	;
			16'h3C00	:	div_value	=	15360	;
			16'h28E9	:	div_value	=	10473	;
			16'h2175	:	div_value	=	8565	;
			16'h1E00	:	div_value	=	7680	;
			16'h0F00	:	div_value	=	3840	;
			16'h0780	:	div_value	=	1920	;
			16'h0398	:	div_value	=	920		;
			16'h0280	:	div_value	=	640		;
			16'h0240	:	div_value	=	576		;
			16'h01E0	:	div_value	=	480		;
			16'h0140	:	div_value	=	320		;
			16'h00F0	:	div_value	=	240		;
			16'h00A0	:	div_value	=	160		;
			16'h0078	:	div_value	=	120		;
			16'h003C	:	div_value	=	60		;
			16'h001E	:	div_value	=	30		;
			16'h0015	:	div_value	=	21		;
			16'h0009	:	div_value	=	9		;

		endcase
	end

	initial 
		begin
			regmap 				= 	new();
			fork
				regmap.start()	;
				sample_coverage();
			join_none
			u_uart_intf.regmap_mbx.put(regmap);
			# (START_DELAY) ;
			-> u_event_intf.init_regmap	;
		end

	always@(posedge u_apb_intf.apb_intf_pos.PSEL)
	begin
	
	if(u_apb_intf.PRESETn == 1'b1)
		monitor_interface();
		
	end



	task monitor_interface();

		if(u_apb_intf.PENABLE === 1'b0)		$display("SUCCESS APB: APB first cycle ", $time);
		else	$display("ERROR APB: APB first cycle ", $time);

		@(u_apb_intf.apb_intf_pos);
			PADDR_reg	<=	u_apb_intf.PADDR	;
			PWDATA_reg	<=	u_apb_intf.PWDATA	;
			PWRITE_reg	<=	u_apb_intf.PWRITE	;

		@(u_apb_intf.apb_intf_pos.PENABLE);
		u_cg_adr_lcr.sample();// collecting coverage
		//u_cg_adr_lsr.sample();// collecting coverage
		u_cg_adr_mcr.sample();// collecting coverage
		u_cg_adr_msr.sample();// collecting coverage
		u_cg_adr_ier.sample();// collecting coverage
		u_cg_adr_iir.sample();// collecting coverage
		u_cg_adr_fcr.sample();// collecting coverage
		u_cg_adr_xmit_fifo.sample();// collecting coverage
		u_cg_MODE0.sample();
		u_LSR_INTR_seq.sample();
		u_cg_intr.sample();
		u_THRE_detect_seq.sample();
		u_THRESHOLD_detect_seq.sample();
		u_MCR_drive_seq.sample();
		u_MSR_LOOPBK_seq.sample();
		u_MSR_detect_seq.sample();
		//u_cg_iir_trans_cov.sample();
		u_cg_msr_trans_cov.sample();
		u_cg_lcr_5_ot_3_trans_cov.sample();
		u_cg_lcr_2_to_0_trans_cov.sample();
		u_cg_mcr_4_to_0_trans_cov.sample();
		u_cg_adr_lcr_reg.sample();
		u_cg_adr_mcr_reg.sample();
		u_cg_adr_fcr_reg.sample();
		u_cg_adr_ier_reg.sample();
		//u_cg_adr_lsr_reg.sample();
		u_cg_adr_iir_reg.sample();

		// u_cg_adr.sample();// collecting coverage
		// u_cg_MODE0.sample();
		// u_LSR_INTR_seq.sample();
		// u_cg_intr.sample();

		if(u_apb_intf.PENABLE === 1'b1 && u_apb_intf.PSEL === 1'b1)		$display("SUCCESS APB: APB second cycle ", $time);
		else	$display("ERROR APB: APB second cycle ", $time);

		@(u_apb_intf.apb_intf_pos);
			PENABLE_reg	=	u_apb_intf.PENABLE	;

		if(PWRITE_reg === 1'b1) begin
			$display("Updating Regmap at ", $time);
			Update_Regmap();
		end
		else if(PWRITE_reg	===	1'b0)	begin
			PRDATA_reg	=	u_apb_intf.PRDATA	;
			if(`LOOPBACK !== 1'b1) begin
				if((PADDR_reg == LSR_ADDR)) -> u_event_intf.read_status_event	;
				if((PADDR_reg	===	XMIT_DLL_RCVR_00) && (`DLAB === 1'b0))
					`RCVR_FIFO.pop(data_buffer);
				else
					regmap.read_regmap (	PADDR_reg,	data_buffer,BYTE1	)	;

					compare_reg_data(PRDATA_reg,	data_buffer,	PADDR_reg);
					clear_regmap(PADDR_reg);
			end
		end
	endtask


	task clear_regmap	(	bit [PDATA_WIDTH-1:0] addr_reg	);

		case(addr_reg)

			//LSR_ADDR	:	regmap.write_regmap (addr_reg,(data_buffer && LSR_RD_CLR) , BYTE1)	;
			LSR_ADDR	:	`LSR	=	(data_buffer & LSR_RD_CLR)	;

		XMIT_DLL_RCVR_00:	if(`DLAB==1'b0) begin
								`TIMEOUT	=	1'b0;
								RDL_ST	=	1'b0	;
								if(`RCVR_FIFO_TOP < `TRIGGER_VALUE)	`ID_INT	=	`ID_INT && 2'b01	;
							end

			// MSR_ADDR	:	regmap.write_regmap (addr_reg,	(data_buffer && MSR_CLEAR) , BYTE1);
			MSR_ADDR	:	`MSR	=	(data_buffer & MSR_CLEAR)	;

		endcase

	endtask

	task compare_reg_data	(

		bit [PDATA_WIDTH-1:0]	AC_DATA		,
		bit	[PDATA_WIDTH-1:0]	EX_DATA		,
		bit	[PADDR_WIDTH-1:0]	REG_ADDR

	);

	reg PASS;

	if	(	EX_DATA		===		AC_DATA		)	PASS	=	1'b1	;
	else										PASS	=	1'b0	;
		
		case(REG_ADDR)
			LCR_ADDR:	begin
							if(PASS) $display("SUCCESS FROM MONITOR	:	LCR REGISTER MATCH");
							else	 $display("ERROR FROM MONITOR	:	LCR REGISTER MATCH");
						end
        	LSR_ADDR:	begin
							if(PASS) $display("SUCCESS FROM MONITOR	:	LSR REGISTER MATCH");
							else	 $display("ERROR FROM MONITOR	:	LSR REGISTER MATCH");
						end
        	IIR_ADDR:	begin
							if(PASS) $display("SUCCESS FROM MONITOR	:	IIR REGISTER MATCH");
							else	 $display("ERROR FROM MONITOR	:	IIR REGISTER MATCH");
						end
        	IER_ADDR:	begin
							if(PASS) $display("SUCCESS FROM MONITOR	:	IER REGISTER MATCH");
							else	 $display("ERROR FROM MONITOR	:	IER REGISTER MATCH");
						end
        	MCR_ADDR:	begin
							if(PASS) $display("SUCCESS FROM MONITOR	:	MCR REGISTER MATCH");
							else	 $display("ERROR FROM MONITOR	:	MCR REGISTER MATCH");
						end
        	MSR_ADDR:	begin
							if(PASS) $display("SUCCESS FROM MONITOR	:	MSR REGISTER MATCH");
							else	 $display("ERROR FROM MONITOR	:	MSR REGISTER MATCH");
						end
    SCRATCH_PAD_ADDR:	begin
							if(PASS) $display("SUCCESS FROM MONITOR	:	PAD REGISTER MATCH");
							else	 $display("ERROR FROM MONITOR	:	PAD REGISTER MATCH");
						end
    	    DLM_ADDR:	begin
							if(PASS) $display("SUCCESS FROM MONITOR	:	DLM REGISTER MATCH");
							else	 $display("ERROR FROM MONITOR	:	DLM REGISTER MATCH");
						end
	XMIT_DLL_RCVR_00:	begin
							if(PASS) begin
								if(`DLAB === 1'b0)	$display("SUCCESS FROM MONITOR	:	RCVR REGISTER MATCH");
								else if(`DLAB === 1'b1)	$display("SUCCESS FROM MONITOR	:	DLL REGISTER MATCH");
							end
							else	 begin
								if(`DLAB === 1'b0)	$display("ERROR FROM MONITOR	:	RCVR REGISTER MATCH");
								else if(`DLAB === 1'b1)	$display("ERROR FROM MONITOR	:	DLL REGISTER MATCH");
							end
						end

			endcase
			$display("EXPECTED DATA = %b",EX_DATA,$time);
			$display("ACTUAL DATA = %b",AC_DATA,$time);

endtask




	always@(negedge u_apb_intf.PRESETn) 
		begin
			regmap.reset_regmap_por();
			disable monitor_interface;
			RDL_ST	=	1'b0	;

		end

	task Update_Regmap();

	  if(`LOOPBACK !== 1'b1) begin
		regmap.write_regmap ( PADDR_reg, PWDATA_reg, BYTE1 );
		if((PADDR_reg === XMIT_DLL_RCVR_00) && (`DLAB === 1'b0)) {`TEMT, `THRE}	=	'b00 ;
	  end

	endtask


	always@(u_uart_intf.uart_intf_tx_pos)	begin
		
		if(	`RCVR_FIFO_TOP !== -1	)	`RCV_DR	=	1'b1	;
		else							`RCV_DR	=	1'b0	;

		if(	`XMIT_FIFO_TOP == -1	)	begin
			`THRE	=	1'b1	;
		end

		// if(	`XMIT_FIFO_TOP !== -1	)	begin
		// 		{`TEMT, `THRE}	=	'b00	;
		// 		//`ID_INT = `ID_INT && 2'b10	;
		// end

		if( `RCVR_FIFO_TOP >= `TRIGGER_VALUE) begin
				//`ID_INT	=	`ID_INT | 2'b10	;
				RDL_ST	=	1'b1	;
		end

	// 	if( `RCVR_FIFO_TOP < `TRIGGER_VALUE) begin
	// 			`ID_INT	=	`ID_INT && 2'b01	;
	// 			RDL_ST	=	1'b0	;
	// 	end


	end

	always@(posedge RDL_ST)	begin
		
			hold_fifo_count = `RCVR_FIFO_TOP	;
			check_timeout();
	end
	


	task check_timeout();

		repeat((4*`CHAR_LENGTH) * 16 ) begin
			@(u_uart_intf.uart_intf_rx_pos)	;
			if(`RCVR_FIFO_TOP	>=	hold_fifo_count) ;
			else disable check_timeout;
		end

		`TIMEOUT	=	1'b1	;

	endtask

	 // always@(u_uart_intf.DCDn, u_uart_intf.RIn, u_uart_intf.CTSn, u_uart_intf.DSRn) begin

	 // 	`DCD		=	~u_uart_intf.DCDn	;	
     //     `RI 		=	~u_uart_intf.RIn 	;	
     //     `DSR		=	~u_uart_intf.DSRn	;	
     //     `CTS		=	~u_uart_intf.CTSn	;	
	 // 
	 // end

	always@(u_uart_intf.DCDn) begin

		`DDCD		=	(`DCD ^ ~u_uart_intf.DCDn);
		`DCD		=	~u_uart_intf.DCDn	;	

	end
	
	always@(u_uart_intf.CTSn) begin


		`DCTS		=	(`CTS ^ ~u_uart_intf.CTSn);
		`CTS		=	~u_uart_intf.CTSn;	
//		`DCTS		=	1'b1				;

	end
		
	always@(u_uart_intf.DSRn) begin

		`DDSR		=	(`DSR ^ ~u_uart_intf.DSRn);
		`DSR		=	~u_uart_intf.DSRn;	

	end
			
		
	//always@(posedge u_uart_intf.RIn) begin
	always@( u_uart_intf.RIn) begin

		`TERI		=	`RI & u_uart_intf.RIn;
		`RI			=	~u_uart_intf.RIn;	
//		`TERI		=	1'b1				;

	end

	always@(	posedge u_apb_intf.PRESETn		)	begin

		@(	u_apb_intf.apb_intf_pos		)	;
		$display("DCDn = %b",u_uart_intf.DCDn);
		$display("CTSn = %b",u_uart_intf.DCDn);
		$display("DSRn = %b",u_uart_intf.DCDn);
		$display("RIn = %b",u_uart_intf.DCDn);
		`DCD		=	~u_uart_intf.DCDn	;	
		reg_DCD		=	~u_uart_intf.DCDn	;	
		`DDCD		=	(u_uart_intf.DCDn !== 1'bX) & 1'b1				;
		`CTS		=	~u_uart_intf.CTSn;	
		reg_CTS		=	~u_uart_intf.CTSn;	
		`DCTS		=	(u_uart_intf.CTSn !== 1'bX) & 1'b1				;
		`DSR		=	~u_uart_intf.DSRn;	
		reg_DSR		=	~u_uart_intf.DSRn;	
		`DDSR		=	(u_uart_intf.DSRn !== 1'bX) & 1'b1				;
		`RI			=	~u_uart_intf.RIn;	
		reg_RI			=	~u_uart_intf.RIn;	
		`TERI		=	(u_uart_intf.RIn !== 1'bX) & u_uart_intf.RIn	;
		$display("R:DCDn = %b",`DDCD);
		$display("R:CTSn = %b",`DCTS);
		$display("R:DSRn = %b",`DDSR);
		$display("R:RIn = %b",`TERI);
		$display("REG:DCDn = %b",reg_DCD);
		$display("REG:CTSn = %b",reg_CTS);
		$display("REG:DSRn = %b",reg_DSR);
		$display("REG:RIn = %b",reg_RI);

	end


///-------------- COVERAGE TASK --------------------


	task sample_coverage();
		wait(u_event_intf.init_regmap.triggered);
		fork
			forever@(`XMIT_FIFO_TOP, `RCVR_FIFO_TOP) begin
				u_cg_xmit.sample();
				u_cg_rcvr.sample();
			end

			forever@(`ID_INT,`TIMEOUT) begin
				u_cg_intr_seq.sample();
				u_cg_timeout_seq.sample();
				$display("COLLECTING IIR COVERAGE",$time);
				$display("IIR[3:1] = %b",`IIR[3:1],$time);
			end

			forever@(`LSR) begin
				// -> u_event_intf.lsr_read_stat_reg	;
				// @(u_apb_intf.apb_intf_pos);
				u_cg_adr_lsr.sample();// collecting coverage
				u_cg_adr_lsr_reg.sample();
			end

			forever@(`IIR) begin
				// -> u_event_intf.iir_read_stat_reg	;
				// @(u_apb_intf.apb_intf_pos);
				u_cg_adr_iir.sample();
				u_cg_adr_iir_reg.sample();
				u_cg_iir_trans_cov.sample();
			end


		join_none
	endtask

///-------------------------------------------------
		
		
endmodule



		
