class uart_rcvr_trigger_intr_check extends generic_test;

function new (`MODULE_REGMAP regmap					,
			  mailbox #(Stimulus) mbx				,
			  mailbox #(int) uart_drv_mbx			,
			  virtual Apb_Interface u_apb_intf		,
			  virtual Uart_Interface u_uart_intf	,
			  virtual Event_Interface u_event_intf	
			  );

			  super.new(regmap, mbx, uart_drv_mbx, u_apb_intf, u_uart_intf, u_event_intf);
			  test_id = generic_id;
endfunction


task start (ref int diff_counter);

	int char_len, trigger_bit;

	-> u_event_intf.start_test	;

	set_baud();

	// Configuring LCR with disable parity, disable stick parity, disable break /////////////////
	temp_data = ~LCR_PAR_EN & ~LCR_DLAB & ~LCR_BRKC & LCR_STOP	;
	temp_mask = LCR_PAR_EN | LCR_DLAB | LCR_BRKC | LCR_STOP	;
	gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);
	////////////////////////////////////////////////////////////////////////////////////////////


	// Configuring IER with enble Receive Data available interrupt disable Line Status interrupt
	temp_data = ~IER_REC_LS & IER_REC_DA	;
	temp_mask = IER_REC_LS | IER_REC_DA		;
	gseq.generate_write_packet(IER_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);
	////////////////////////////////////////////////////////////////////////////////////////////

	char_len = (`CHARL + 5) + (`PAR_EN) + (`STOP + 1) + 1;
	unique_randomize(3, 0, 1);

	//repeat(FCR_TRIG_LVL_mask >> 6) begin
	repeat(4) begin
			trigger_bit = unique_randomize(3, 0, 0);
			trigger_bit = trigger_bit << 6;

		// Configure FCR with trigger_bit, disable receive FIFO reset ///////////////////////////////
		temp_data = trigger_bit & ~FCR_RCVR_RST;
		temp_mask = FCR_TRIG_LVL_mask | FCR_RCVR_RST;
		gseq.generate_write_packet(FCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);
		/////////////////////////////////////////////////////////////////////////////////////////////

		uart_drv_mbx.put(get_trigger_level(trigger_bit[7:6]));
		-> u_event_intf.start_transmit_frm_BFM	;

		repeat ((get_trigger_level(trigger_bit[7:6])) * (16 * char_len) +1) begin
			@ (u_uart_intf.uart_intf_rx_pos);
		end

		gseq.generate_read_packet (IIR_ADDR)	;
		wait_on (diff_counter);
		if ((u_apb_intf.PRDATA[3:1] == 'b010) && (u_uart_intf.IRQ == 'b1)) begin
			$display("SUCCESS: RCVR FIFO Trigger Level reached as expected. Interrupt generated", $time);
		end
		else $display("ERROR: RCVR FIFO Trigger Level is expected to be reached. Interrupt NOT generated", $time);
	end

endtask

endclass
