

module uart_rx_bfm	(

	Uart_Interface 		u_uart_intf			,
	Event_Interface		u_event_intf		

	);

	`MODULE_REGMAP	regmap	;
	event rx_capture_frame_bits	;

	reg rx_start				;
	reg	[PDATA_WIDTH - 1 : 0]	RCVR_SR	;
	int data_count				;
	int data_length				;
	reg parity_error			;
	int break_count				;
	real CHARACTER_FRAME_TIME	;
	reg par_count_buf			;
	int trigger_value=1			;
	reg [PDATA_WIDTH-1:0] data_temp	;
	real stop							;


	initial
		begin

			@(u_event_intf.init_regmap);
			u_uart_intf.regmap_mbx.peek(regmap);
			par_count_buf	=		1'b0		;
			rx_start		=		1'b0		;
			parity_error	=		1'b0		;
			data_count		=		0			;
			data_length		=		6			;

		end


	initial begin
		@(	u_event_intf.env_start	);
		fork
			forever@(`CHARL	or rx_start)	begin
				if(rx_start	==	0)	begin
					case(`CHARL)
						2'b00	:	data_length	=	5	;
						2'b01	:	data_length	=	6	;
						2'b10	:	data_length	=	7	;
						2'b11	:	data_length	=	8	;
						default	:	data_length	=	5	;
					endcase
					//CHARACTER_FRAME_TIME	=	(data_length	+	`PAR_EN	+	1	+ 1);
					//							char_length         par_on			stop  start

					if(`STOP)	begin
						if(	`CHARL	===	2'b00	)	stop	=	1.5	;
						else						stop	=	2	;
					end
					else						stop	=	1	;
					CHARACTER_FRAME_TIME	=	(data_length	+	`PAR_EN	+	stop	+ 1);

				end
			end

			forever@(u_uart_intf.uart_intf_rx_pos)	begin
				if(	`RCVR_FIFO_TOP	!==	-1)	begin
					`RCV_DR	=	1'b1	;
				end
			end
		join

	end

               	
	always@(   	 negedge u_uart_intf.sRX		)	begin
		       	
		if(	rx_start	==	1'b0)	begin
			$display(	"***** Starting detection on Receiver side *****",	$realtime	);
			check_rx_start_bit();
			data_count	=	0;
			if(	rx_start	==	1'b1)	begin
			   	 $display("**** Initiate capturing frame bits ***********",	$realtime);
			   	 -> rx_capture_frame_bits	;
			   	 RCVR_SR	=	{PDATA_WIDTH{1'b0}}	;
			end
		end    	
	end



		always@(rx_capture_frame_bits)	begin
			
			while (	data_count	<	data_length	)	begin
				
				count_clks(BAUD_SAMPLE_CYCLES);
				RCVR_SR	=	{u_uart_intf.sRX	,	RCVR_SR[PDATA_WIDTH-1:1]}	;
				data_count++	;

			end

			if(	`PAR_EN	===	1'b1	)	check_parity(`PAR_SEL);
			else	$display("Receiving frame without parity	->	",	$realtime);
			check_stop_bit(stop*BAUD_SAMPLE_CYCLES);
			if(	`RCVR_FIFO_TOP < (`MAX_FIFO_DEPTH-1) ) begin
//					regmap.write_regmap ( RCVR_FIFO_ADDR, RCVR_SR, BYTE1 );
					`RCVR_FIFO.push (RCVR_SR, BYTE1 );
					if(`RCVR_FIFO_TOP < (`MAX_FIFO_DEPTH-1))	$display("");
					else `OVRE	=	1'b1	;
			end
			else	`OVRE	=	1'b1	;
			rx_start		=		1'b0	;
			u_event_intf.rx_start	=	1'b0	;

		end



	task count_clks ( int sample_cycles);
		repeat(sample_cycles) begin
			@(u_uart_intf.uart_intf_rx_pos);
		end
	endtask



	task check_rx_start_bit();
		count_clks(8);
		if(u_uart_intf.sRX === 1'b0) begin
			$display("SUCCESS: rx_Start bit detected after 8 cycles",	$realtime);
			rx_start	=	1'b1	;
			u_event_intf.rx_start	=	1'b1	;
		end
		else	$display("ERROR: Faulty rx_start-bit on SD0. **********", $realtime);
	endtask


	task check_stop_bit(int stop_num);
		count_clks(stop_num);
		if (u_uart_intf.sRX === 1'b1)
			$display("SUCCESS: STOP bit detected",$time);
		else begin
			$display("ERROR: FRAMING ERROR detected",$time);
		//--	Update regmap for framing error	
			`FE		=	1'b1	;
			`ERROR	=	1'b1	;
			//`ID_INT	=	`ID_INT | 2'b10	;
	//		`ID_INT	=	set_id_int(`ID_INT , 2'b10)	;
		end
		-> u_event_intf.stop_detect;

	endtask

	task check_parity (bit parity_mode);

		par_count_buf = ^RCVR_SR ;
		count_clks(BAUD_SAMPLE_CYCLES);
		if ((parity_mode	===	1'b1) && (par_count_buf === 1'b0))
			if(u_uart_intf.sRX === 1'b0) $display("RX:SUCCESS: EVEN PARITY ",	$time);
			else	begin
				$display("RX:ERROR: EVEN PARITY ERROR",	$time);
				parity_error	=	1'b1	;
			end
		else if((parity_mode === 1'b1) && (par_count_buf === 1'b1))
			if(u_uart_intf.sRX === 1'b1) $display("RX:SUCCESS: EVEN PARITY", $time);
			else	begin
				$display("RX:ERROR: EVEN PARITY ERROR",	$time);
				parity_error	=	1'b1	;
			end
		else if ((parity_mode	===	1'b0) && (par_count_buf === 1'b1))
			if(u_uart_intf.sRX === 1'b0) $display("RX:SUCCESS: ODD PARITY ",	$time);
			else	begin	
				$display("RX:ERROR: ODD PARITY ERROR",	$time);
				parity_error	=	1'b1	;
			end
		else if((parity_mode === 1'b0) && (par_count_buf === 1'b0))
			if(u_uart_intf.sRX === 1'b1) $display("RX:SUCCESS: ODD PARITY", $time);
			else	begin	
				$display("RX:ERROR: ODD PARITY ERROR",	$time);
				parity_error	=	1'b1	;
			end

	endtask


	always@(posedge parity_error) begin
		`PE	=	1'b1;
		`ERROR	=	1'b1	;
		//`ID_INT	=	`ID_INT	|	2'b10	;
	//	`ID_INT	=	set_id_int(`ID_INT	,	2'b10)	;
		#10;
		parity_error = 1'b0	;
		//regmap.read_regmap (	LSR_ADDR,	data_temp,BYTE1	)	;
		$display ("LSR_DATA = %b",regmap.lsr_reg.reg_val, $time);
		$display ("LSR_DATA_INTF = %b",LSR_Reg::reg_lsr, $time);
	end
		



	always@(	negedge u_uart_intf.sRX		)	begin

		check_break();

	end

	task check_break();

		repeat(CHARACTER_FRAME_TIME)	begin 
			count_clks(BAUD_SAMPLE_CYCLES);
			if(	u_uart_intf.sRX	===	1'b0	)	break_count++	;
			else	begin
				break_count = 0	;
				disable check_break;
			end
		end


	endtask

	always@(break_count) begin
		if(break_count >= CHARACTER_FRAME_TIME)	begin
			`BI	=	1'b1	;
		`ERROR	=	1'b1	;
			break_count = 0	;
		//`ID_INT	=	`ID_INT	|	2'b10	;
	//	`ID_INT	=	set_id_int(`ID_INT	,	2'b10)	;
		end
	end


	// initial begin
	// 		@(u_event_intf.init_regmap);
	// 		fork
	// 			forever@(`TRIG_LVL)	begin
	// 				trigger_value = get_trigger_level(`TRIG_LVL);
	// 				$display("ABC: Trigger-level = %d",`TRIGGER_VALUE,$time);
	// 			end
	// 		join

	// end

	function bit[1:0] set_id_int(bit[1:0] id_int, bit[1:0] new_int);

		if(new_int > id_int)	return new_int	;
		else					return id_int	;

	endfunction



endmodule
