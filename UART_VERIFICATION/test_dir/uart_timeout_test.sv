class uart_timeout_test extends generic_test;

event start_timeout,start_transmit_frm_BFM; 

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


task start(ref int diff_counter);

	int char_len;
	bit[7:0] trigger_level	;
	int rep_cnt;
	int trigger_depth	;
	-> u_event_intf.start_test	;
	gseq.reset_por()	;
	if(diff_counter !== 0)
	wait (diff_counter == 0);
	@(u_apb_intf.apb_intf_pos)	;

		// //1. Setting DLAB before writing to DLL
		// temp_data	=	LCR_DLAB 	;
		// temp_mask	=	LCR_DLAB	;
		// gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);

		// temp_buf_reset();

		// //2. Writing DLL = 12
		// temp_data	=	8'h0C	;
		// temp_mask	=	8'hFF	;
		// gseq.generate_write_packet(DLL_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);
		// $display("PDATA = %d\nPADDR = %d", gseq.sti.pdata, gseq.sti.paddr, $time);

		set_baud();

		temp_buf_reset();

	if(regmap == null ) $display("REGMAP NULL POINTER -> ", $time);
	if (`RCV_DR) $display("UART_FIFO is Empty after Reset -> ",$realtime)	;
	else $display ("LSR[0] is not Set after Reset -> ",$realtime)	;

	// -Configuring LCR before putting data inside RX FIFO ------------------------------------//
	 temp_data = ( ~LCR_DLAB & ~LCR_S_PAR);
	// temp_data = ( (~LCR_DLAB | ~LCR_BRKC ) & LCR_PAR_EN );
	// temp_mask	=	(LCR_PAR_EN | LCR_DLAB | LCR_BRKC)	;
	 temp_mask	=	(LCR_S_PAR | LCR_DLAB)	;
	gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
	// ---------------------------------------------------------------------------------------//
	
	// -Configuring IER before putting data inside RX FIFO ------------------------------------//
	temp_data = (IER_REC_LS | IER_REC_DA) ;
	temp_mask	=	(IER_REC_LS | IER_REC_DA)	;
	gseq.generate_write_packet(IER_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
	// ---------------------------------------------------------------------------------------//

	// -Configuring FCR before putting data inside RX FIFO ------------------------------------//

	//trigger_level = $urandom_range(FCR_TRIG_LVL_1,FCR_TRIG_LVL_4,FCR_TRIG_LVL_8,FCR_TRIG_LVL_14)	;
	trigger_level = $urandom_range(3,0) << 6	;
	$display("Trigger-level = %b",trigger_level,$time);
	temp_data = (FCR_FIFO_EN | trigger_level) & ~FCR_RCVR_RST ;
	temp_mask	=	(FCR_FIFO_EN | FCR_TRIG_LVL_mask | FCR_RCVR_RST)	;
	gseq.generate_write_packet(FCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
	// ---------------------------------------------------------------------------------------//
	@(u_apb_intf.apb_intf_pos);
	$display("TESTCASE: DIFF_COUNTER = %d",diff_counter,$time);

	//if(diff_counter !== 0)
	wait_on(diff_counter);
	//trigger_level = trigger_level >> 6;
	char_len = (`CHARL + 5) + (`PAR_EN) + (`STOP + 1) + 1;
	$display("REGMAP: CHAR_LENGTH = %d", char_len,$time);
	trigger_depth	=	(get_trigger_level(trigger_level[7:6])+$urandom_range(0,1));
	$display("TESTCASE TRIGGER_DEPTH = %d", trigger_depth, $time);
//	uart_drv_mbx.put(int'(trigger_level));
	uart_drv_mbx.put(trigger_depth);
	-> u_event_intf.start_transmit_frm_BFM	;
	
	repeat (trigger_depth * (16 * char_len) +1) begin
	rep_cnt++;
	$display("TIMEOUT WAIT, %d -> ",rep_cnt, $time);
		@ (u_uart_intf.uart_intf_rx_pos);
	end
	gseq.generate_read_packet (LSR_ADDR)	;
	if (`ID_INT == 2) $display ("Trigger Level interrupt detected successfully", $time)	;
	else begin
	$display ("Warning : Trigger level flag (LCR2) is not set in DUT : UART", $time)	;
	end

	//-> u_event_intf.start_timeout	;
	
	repeat (5 * (16 * char_len) +1) begin
		@ (u_uart_intf.uart_intf_rx_pos);
	end
	gseq.generate_read_packet (LSR_ADDR)	;
	if (~ `TIMEOUT & (`ID_INT != 2)) $display ("Timeout interrupt detected successfully", $time)	;
	else begin
	$display ("Warning : Timeout flag (LCR3,LCR2) is not set in DUT : UART", $time)	;
	end
	gseq.generate_read_packet (XMIT_DLL_RCVR_00)	;
	wait_on(diff_counter);
	@ (u_uart_intf.uart_intf_rx_pos);

	-> u_event_intf.test_end ;

endtask : start

endclass
