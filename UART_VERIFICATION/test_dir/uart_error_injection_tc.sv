class uart_error_injection_tc extends generic_test;

function new(`MODULE_REGMAP regmap					,
			mailbox #(Stimulus) mbx					,
			mailbox #(int) uart_drv_mbx				,
			virtual Apb_Interface u_apb_intf		,
			virtual Uart_Interface u_uart_intf		,
			virtual Event_Interface	u_event_intf	
		);
		super.new(regmap, mbx, uart_drv_mbx,	u_apb_intf, u_uart_intf, u_event_intf)	;
		test_id = generic_id	;
endfunction

task start (ref int diff_counter);
	
	int char_len, trigger_depth, packet_lim;
	int set_1 =1;
	bit flag;
	reg [PDATA_WIDTH-1:0] temp_rx_bfx_fifo_data;
	gseq.reset_por()	;
	set_baud();
	
	// Configure LCR to enable parity and stop bits ///////////////////////////////////////////////////
	temp_data = ~LCR_DLAB & ~LCR_S_PAR & ~LCR_BRKC							;
	temp_mask = LCR_DLAB | LCR_S_PAR | LCR_BRKC							;
	gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
	///////////////////////////////////////////////////////////////////////////////////////////////////

		
	// Configuring FCR for setting up RX FIFO /////////////////////////////////////////////////////////
	temp_data = ~FCR_RCVR_RST	;
	temp_mask = FCR_RCVR_RST	;
	gseq.generate_write_packet(FCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
	//////////////////////////////////////////////////////////////////////////////////////////////////


	// -Configuring IER before putting data inside RX FIFO ------------------------------------//
	temp_data = (IER_REC_LS)	;
	temp_mask = (IER_REC_LS)	;
	gseq.generate_write_packet(IER_ADDR, temp_data, 8'h00, 1'b0, 1'b0)	;
	// ---------------------------------------------------------------------------------------//


	wait (diff_counter == 0);

	char_len = (`CHARL + 5) + (`PAR_EN) + (`STOP + 1) + 1;
	
	trigger_depth	=	get_trigger_level(`TRIG_LVL);
	
	//packet_lim = $urandom_range (18,1);
	packet_lim = `MAX_FIFO_DEPTH + $urandom_range (5,1);
	uart_drv_mbx.put(packet_lim);
	u_event_intf.start_data_error_injection	= 1;
	-> u_event_intf.start_transmit_frm_BFM		;

	repeat (packet_lim * (16*char_len) +1) @ (u_uart_intf.uart_intf_rx_pos);

	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////// CONFIRMING SAMPLING AT 8th B_CLK /////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Configuring (read modifying) LCR to disable parity, put stop bit to 1 /////////////////////////
	temp_data = ~LCR_DLAB & ~LCR_S_PAR	& ~LCR_BRKC		;
	temp_mask = LCR_DLAB | LCR_S_PAR	| LCR_BRKC		;
	gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)				;
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	u_event_intf.start_data_error_injection	= 0;	
	wait (diff_counter == 0);
	char_len = (`CHARL + 5) + (`PAR_EN) + (`STOP + 1) + 1;
	repeat (2) begin
	uart_drv_mbx.put(set_1);
	u_event_intf.start_cyclic_error_injection = 1	;
	-> u_event_intf.start_transmit_frm_BFM			;

		repeat ((16*char_len) +1) @ (u_uart_intf.uart_intf_rx_pos);
		$display("fifo top :",`RCVR_FIFO_TOP);
		`RCVR_FIFO.pop(temp_rx_bfx_fifo_data);
		`RCVR_FIFO.push(temp_rx_bfx_fifo_data, BYTE1);
		gseq.generate_read_packet(RCVR_FIFO_ADDR);
		wait_on(diff_counter);
		$display ("uart_data : %b  vs BFM_data: %b",u_apb_intf.PRDATA,temp_rx_bfx_fifo_data, $time);
		if ((u_apb_intf.PRDATA == temp_rx_bfx_fifo_data))
			flag = flag ^ 0;
		else flag = 1;
	end

	if (flag == 0) messagef (LOW,INFO,`HIERARCHY,$sformatf("SUCCESS: UART is sampling data at the 8th B_CLK"));
	else messagef (LOW,ERROR,`HIERARCHY,$sformatf("ERROR: UART is NOT sampling data at the 8th B_CLK"));
	u_event_intf.start_cyclic_error_injection = 0	;
endtask

endclass
	


