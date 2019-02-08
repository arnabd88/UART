class uart_overrun_check extends generic_test;

event start_transmit_frm_BFM;

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

task start (ref int diff_counter)	;

	int char_depth;

	-> u_event_intf.start_test	;
	set_baud();


	// Configuring LCR
	temp_data = ~LCR_DLAB & ~LCR_S_PAR	;
	temp_mask = LCR_DLAB | LCR_S_PAR	;
	gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;

	// Configuring FCR
	temp_data = ~FCR_RCVR_RST	;
	temp_mask = FCR_RCVR_RST	;
	gseq.generate_write_packet(FCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;

	// Configuring MCR
	temp_data = ~MCR_LOOPBACK	;
	temp_mask = MCR_LOOPBACK	;
	gseq.generate_write_packet(MCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);

	char_depth = $urandom_range(17,25);
	uart_drv_mbx.put(char_depth)			;
	-> u_event_intf.start_transmit_frm_BFM	;

	repeat ((char_depth * (16 * `CHAR_LENGTH)) + 1) @ (u_uart_intf.uart_intf_rx_pos);

	//reading LSR
	gseq.generate_read_packet(IIR_ADDR);
	wait_on (diff_counter);

	if ((u_apb_intf.PRDATA[3:1] == 'b011) & (u_uart_intf.IRQ == 'b1)) begin
		$display("SUCCESS: RECEIVER LINE INTERRUPT IS DETECTED IN IIR",$time);
		gseq.generate_read_packet(LSR_ADDR);
		wait_on (diff_counter);
		if (u_apb_intf.PRDATA[1] == 'b1) begin
			$display("SUCCESS: OVER-RUN ERROR IS DETECTED IN LSR",$time);
		end
	end
	else begin
		$display("ERROR: RECEIVER LINE INTERRUPT IS NOT DETECTED IN IIR even after OVER-RUN error scenerio",$time);
	end
endtask

endclass

