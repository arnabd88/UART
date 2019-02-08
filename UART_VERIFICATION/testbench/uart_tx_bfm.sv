
module uart_tx_bfm	(

	Uart_Interface u_uart_intf		,
	Event_Interface	u_event_intf	

	)	;

	`MODULE_REGMAP	regmap	;
	reg BRKC	;
	assign BRKC	=	(regmap!==null) ? LCR_Reg::reg_lcr[6] : 1'b0	;
	assign LOOPBACK	=	(regmap!==null) ? MCR_Reg::reg_mcr[4] : 1'b0	;

	event tx_capture_frame_bits	;
	event compare_tx_frame		;
	event sample_frame_data		;

	reg [PDATA_WIDTH - 1 : 0] data_out_buf	;

	reg		tx_start						;
	reg [PDATA_WIDTH - 1 : 0]	RCVR_SR	;
	int baud_count						;
	int data_count						;
	int data_length						;
	reg par_count_buf					;
	reg parity_error					;
	int break_count						;
	int CHARACTER_FRAME_TIME			;
	real stop							;
	bit frame_st						;

	initial 
		begin
			@(u_event_intf.init_regmap);
			u_uart_intf.regmap_mbx.peek(regmap);
			tx_start		=	1'b0	;
			parity_error=	1'b0	;
			baud_count	=	0		;
			data_count	=	0		;
			data_length	=	6		;	// To be taken from Regmap
		end

	
	always@(negedge u_uart_intf.sTX) begin
		if(tx_start	==	1'b0 && BRKC !==1'b1 && LOOPBACK == 1'b0)	begin
			messagef(LOW, INFO, `HIERARCHY, $sformatf("************ INITIATING FRAME TRANSFER **************"));
			`XMIT_FIFO.pop(data_out_buf);
			//tx_start	=	1'b1	;
			check_tx_start_bit();
			data_count	=	0	;
			baud_count	=	0	;
			if(tx_start	==	1'b1)	begin
				messagef(LOW, INFO, `HIERARCHY, $sformatf("************ Initiate Capturing frame bits **************"));
				-> tx_capture_frame_bits	;
				RCVR_SR = {PDATA_WIDTH{1'b0}}	;
			end
		end
	end

	always@(	negedge u_apb_intf.PRESETn	)	begin

		tx_start	=	1'b0				;
		u_event_intf.tx_start	=	1'b0	;
		RCVR_SR	=	{PDATA_WIDTH{1'b0}}	;
		data_count	=	0;
		disable count_clks;
		disable check_parity;
		disable check_stop_bit;
		disable compare;
		disable check_tx_start_bit;
		disable capture_frame;
		disable compare;
	
	end

	initial begin
	@(	u_event_intf.env_start	);
	fork
		forever@(`CHARL	or tx_start)	begin
			if(tx_start == 0) begin
				case(`CHARL)
					2'b00	:	data_length	=	5	;
					2'b01	:	data_length	=	6	;
					2'b10	:	data_length	=	7	;
					2'b11	:	data_length	=	8	;
					default	:	data_length	=	5	;
				endcase
				CHARACTER_FRAME_TIME	=	(data_length + `PAR_SEL	+	1);
				//CHARACTER_FRAME_TIME	=	`CHAR_LENGTH - (`STOP + 1);

				if(`STOP)	begin
					if(	`CHARL	===	2'b00	)	stop	=	1.5	;
					else						stop	=	2	;
				end
				else						stop	=	1	;

			end
		end
	join

			
	end

	
	
	
	always@(tx_capture_frame_bits) begin

		capture_frame();

	  // while (	data_count < data_length	)	begin

	  //   count_clks(BAUD_SAMPLE_CYCLES);
	  //   -> sample_frame_data	;
	  //   RCVR_SR = {u_uart_intf.sTX	,	RCVR_SR[PDATA_WIDTH-1:1]}	;
//	  //   RCVR_SR	=	{	RCVR_SR[PDATA_WIDTH-2:0], u_uart_intf.sTX	}	;
	  //   data_count++	;

	  // end
	  // if(	`PAR_EN	===	1'b1)	check_parity(`PAR_SEL);
	  // else $display("TRANSMISSION without parity -> ", $time);
	  // check_stop_bit(stop*BAUD_SAMPLE_CYCLES, frame_st);
	  // if(~frame_st)  begin
	  // 	-> compare_tx_frame ;
	  // 	messagef (HIGH, INFO, `HIERARCHY, $sformatf("TX: VALID PARITY CHECK: STOP  DETECTED"));
	  // end
	  // else	messagef (HIGH, INFO, `HIERARCHY, $sformatf("TX: IGNORE PARITY BIT: STOP NOT DETECTED"));
	end

	task capture_frame();
		
		while (	data_count < data_length	)	begin

			count_clks(BAUD_SAMPLE_CYCLES);
			-> sample_frame_data	;
			RCVR_SR = {u_uart_intf.sTX	,	RCVR_SR[PDATA_WIDTH-1:1]}	;
	//		RCVR_SR	=	{	RCVR_SR[PDATA_WIDTH-2:0], u_uart_intf.sTX	}	;
			data_count++	;

		 end
	  	if(	`PAR_EN	===	1'b1)	check_parity(`PAR_SEL);
	  	else $display("TRANSMISSION without parity -> ", $time);
	  	check_stop_bit(stop*BAUD_SAMPLE_CYCLES, frame_st);
	  	if(~frame_st)  begin
	  		-> compare_tx_frame ;
	  		messagef (HIGH, INFO, `HIERARCHY, $sformatf("TX: VALID PARITY CHECK: STOP  DETECTED"));
	  	end
	  	else	messagef (HIGH, INFO, `HIERARCHY, $sformatf("TX: IGNORE PARITY BIT: STOP NOT DETECTED"));

	endtask



	task check_parity (bit parity_mode);

		par_count_buf = ^RCVR_SR ;
		count_clks(BAUD_SAMPLE_CYCLES);
		if ((parity_mode	===	1'b1) && (par_count_buf === 1'b0))
			if(u_uart_intf.sTX === 1'b0) messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:SUCCESS: EVEN PARITY "));
			else	begin
				messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:ERROR: EVEN PARITY ERROR"));
				parity_error	=	1'b1	;
			end
		else if((parity_mode === 1'b1) && (par_count_buf === 1'b1))
			if(u_uart_intf.sTX === 1'b1) messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:SUCCESS: EVEN PARITY "));
			else	begin
				messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:ERROR: EVEN PARITY ERROR"));
				parity_error	=	1'b1	;
			end
		else if ((parity_mode	===	1'b0) && (par_count_buf === 1'b1))
			if(u_uart_intf.sTX === 1'b0) messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:SUCCESS: ODD PARITY "));
			else	begin	
				messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:ERROR: ODD PARITY ERROR"));
				parity_error	=	1'b1	;
			end
		else if((parity_mode === 1'b0) && (par_count_buf === 1'b0))
			if(u_uart_intf.sTX === 1'b1) messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:SUCCESS: ODD PARITY "));
			else	begin	
				messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:ERROR: ODD PARITY ERROR"));
				parity_error	=	1'b1	;
			end

	endtask



//-------- Also check stop-bit duration depending on LCR --------------

	task check_stop_bit(int stop_num, output status);
		count_clks(stop_num);
		if (u_uart_intf.sTX === 1'b1) begin
			messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:SUCCESS: STOP BIT DETECTED"));
			status = 1'b0	;
		end
		else begin
			status	=	1'b1	;
			messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:ERROR: FRAMING ERROR detected"));
		//--	Update regmap for framing error	
			// `FE		=	1'b1	;
			// `ERROR	=	1'b1	;
			// `ID_INT	=	`ID_INT | 2'b10	;
		end
		count_clks(BAUD_SAMPLE_CYCLES/2);
	  tx_start		=		1'b0	;
	  u_event_intf.tx_start		=		1'b0	;

	endtask



	//always@(posedge parity_error) begin
	//	`PE	=	1'b1;
	//	`ID_INT	=	`ID_INT	|	2'b10	;
	//end
		

	always@(u_uart_intf.uart_intf_tx_pos) begin
		if(`XMIT_FIFO_TOP === -1 && regmap != null) begin //indicates last byte of xmit transmission started
			`THRE	=	1'b1;
			//`ID_INT	=	`ID_INT	|	2'b01	; // Sets status flag
	//		`ID_INT	=	set_id_int(`ID_INT	,	2'b01)	; // Sets status flag
		end
	end

	always@(negedge tx_start)	begin
		if(`XMIT_FIFO_TOP === -1)	begin //indicates last byte transmission completed
			`THRE	=	1'b1				;
			`TEMT	=	1'b1				;
			//`ID_INT	=	`ID_INT	|	2'b01	;
	//		`ID_INT	=	set_id_int(`ID_INT	,	2'b01)	;
		end
	end

	// initial begin
	// 		@(u_event_intf.init_regmap);
	// 		fork
	// 			forever@(`XMIT_FIFO_TOP == -1) begin
	// 				`THRE	=	1'b1	;
	// 				`TEMT	=	1'b1	;
	// 			end
	// 			forever@(`RCVR_FIFO_TOP == -1) begin
	// 				`RCV_DR	=	1'b0	;
	// 			end
	// 		join
	// end
		

	always@(compare_tx_frame)	begin
		
		// `XMIT_FIFO.pop(data_out_buf);
		compare(data_out_buf, RCVR_SR, data_length);

	end

	task compare (
		bit [PDATA_WIDTH-1:0] EX_DATA	, 
		bit [PDATA_WIDTH-1:0] AC_DATA	,
		int data_length
		);
			$display("AC_DATA_ACTUAL = %b",AC_DATA);
			//AC_DATA	=	AC_DATA	<< (PDATA_WIDTH-data_length)	;
			EX_DATA	=	EX_DATA	<< (PDATA_WIDTH-data_length)	;
			$display("data_length = %d",data_length);


		// bit [PDATA_WIDTH-1:0] temp_ex_data, temp_ac_data	;
		// for(int i=0; i < data_length; i++) begin
		// 	//temp_ex_data[i]	=	EX_DATA[PDATA_WIDTH-data_length-1+i];
		// 	temp_ex_data[PDATA_WIDTH-data_length+i]	=	EX_DATA[i];
		// 	temp_ac_data[i]	=	AC_DATA[i]	;
		// end

		// if (temp_ex_data === temp_ac_data)
		// 	$display	("SUCCESS: DATA FRAME MATCH",	$time);
		// else 
		// 	$display	("ERROR: DATA FRAME MISMATCH",	$time);
		$display("PARITY_SELECT = %b",`PAR_SEL);
		$display("PARITY_ENABLE = %b",`PAR_EN);
		$display("STOP_ENABLE = %b",`STOP);
		 if (EX_DATA === AC_DATA)
			messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:SUCCESS: DATA FRAME MATCH"));
		 else 
			messagef(HIGH, ERROR, `HIERARCHY, $sformatf("TX:ERROR: DATA FRAME MISMATCH"));
		// $display ("EXPECTED DATA	=	%b",temp_ex_data, $time);
		// $display ("ACTUAL DATA		=	%b",temp_ac_data, $time);
		messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:EX_DATA	=	%b",EX_DATA));
		messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:EX_DATA	=	%d",EX_DATA));
		messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:AC_DATA	=	%b",AC_DATA));
		messagef(HIGH, INFO, `HIERARCHY, $sformatf("TX:AC_DATA	=	%d",AC_DATA));


		//repeat(PDATA_WIDTH-data_length) begin
	endtask




	task count_clks ( int sample_cycles);
		repeat(sample_cycles) begin
			@(u_uart_intf.uart_intf_rx_pos);
		end
	endtask



	task check_tx_start_bit();
		count_clks(8);
		if(u_uart_intf.sTX === 1'b0) begin
			$display("SUCCESS: tx_Start bit detected after 8 cycles",	$realtime);
			tx_start	=	1'b1	;
			u_event_intf.tx_start	=	1'b1	;
		end
		else	$display("ERROR: Faulty tx_start-bit on SD0. **********", $realtime);
	endtask

	//---------- Break Indicator Check(Need to move to rx_bfm) -------------------
	// always@(	posedge tx_start	) begin
	// 	repeat(CHARACTER_FRAME_TIME)	begin 
	// 		count_clks(BAUD_SAMPLE_CYCLES);
	// 		if(		u_uart_intf.sRX	===	1'b0	)	break_count++			;
	// 		else if(	u_uart_intf.sRX	===	1'b1	)	break_count	=	0	;
	// 	end

	// 	if (	break_count >= CHARACTER_FRAME_TIME	)	begin
	// 		$display("SUCCESS:	BREAK CONDITION DETECTED",$time)	;
	// 		`BI		=		1'b1	;
	// 		`ID_INT	=	`ID_INT	|	2'b01	;
	// 	end

	// end

	// always@(	negedge u_uart_intf.sRX		)	begin

	// 	check_break();

	// end

	// task check_break();

	// 	repeat(8)	begin 
	// 		count_clks(BAUD_SAMPLE_CYCLES);
	// 		if(	u_uart_intf.sRX	===	1'b0	)	break_count++	;
	// 		else	begin
	// 			break_count = 0	;
	// 			disable check_break;
	// 		end
	// 	end


	// endtask


	function bit[1:0] set_id_int(bit[1:0] id_int, bit[1:0] new_int);

		if(new_int > id_int)	return new_int	;
		else					return id_int	;

	endfunction




endmodule
