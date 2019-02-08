class uart_brake_intr_check extends generic_test;

int char_len,char_depth,break_time,count;
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
	
	int char_len,char_depth,break_time,count,char_depth_cycle;

	-> u_event_intf.start_test	;
	set_baud();
	
	// Configuring LCR before putting data inside RX FIFO ////////////////////////////////////////////////////////////////////////////////////////////////////////////
	temp_data = ~LCR_DLAB & ~LCR_S_PAR & ~LCR_PAR_EN & ~LCR_STOP & (LCR_CHARL_8 | LCR_BRKC); // Enable Break, char_len = 8, stop_bit = 0, parity disabled, stick_parity disabled
	temp_mask = LCR_DLAB | LCR_S_PAR | LCR_PAR_EN | LCR_CHARL_8 | LCR_BRKC | LCR_STOP	;
	gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	// Configuring IER for setting up correct interrupts //////////////////////////////////
	temp_data = ~IER_MODEM_ST & ~IER_THRE_ST & ~IER_REC_DA & IER_REC_LS	;
	temp_mask = IER_MODEM_ST | IER_THRE_ST | IER_REC_DA | IER_REC_LS	;
	gseq.generate_write_packet(IER_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
	//////////////////////////////////////////////////////////////////////////////////////

	
	// Configuring FCR for setting up RX FIFO ////////////////////////////////////////////
	temp_data = ~FCR_RCVR_RST	;
	temp_mask = FCR_RCVR_RST	;
	gseq.generate_write_packet(FCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
	//////////////////////////////////////////////////////////////////////////////////////

		
	repeat (3) begin
		wait_on (diff_counter);
		
		char_len = (`CHARL + 5) + (`STOP + 1) + 1;
		char_depth = $urandom_range(16,2)		;
		char_depth_cycle = (char_depth * (16 * char_len));
		break_time = $urandom_range(char_depth-1,1);

		//uart_drv_mbx.put(trigger_depth)			;
		uart_drv_mbx.put(char_depth)			;
		-> u_event_intf.start_transmit_frm_BFM	;
		
		if (count == 0) begin
			repeat (break_time * (16 * char_len)) begin
				@ (u_uart_intf.uart_intf_rx_pos);
				char_depth_cycle--;
			end
		end
		else if (count == 1) begin
			repeat ((break_time * (16*char_len)) - $urandom_range(char_len-1,1)) begin
				@ (u_uart_intf.uart_intf_rx_pos);
				char_depth_cycle--;
			end
		end

		repeat ((16 * char_len) + $urandom_range(char_len-1,0)) begin
			 u_event_intf.set_break = 'b1;
			@ (u_uart_intf.uart_intf_rx_pos);
			char_depth_cycle--;
		end
			 u_event_intf.set_break = 'b0;
		//release u_uart_intf.sRX;

		wait_on(diff_counter);
		if (u_uart_intf.IRQ == 'b1) begin
			$display("Info: INTERRUPT identidied at ",$time);
			@(u_apb_intf.apb_intf_pos);
			@(u_apb_intf.apb_intf_pos);
			gseq.generate_read_packet(IIR_ADDR);
			wait_on(diff_counter);
			if (u_apb_intf.PRDATA[3:1] == 'b011) begin
				$display ("Info: IIR Break interrupt has supposedly got generated", $time);
				gseq.generate_read_packet(LSR_ADDR);
				wait_on(diff_counter);
				if (u_apb_intf.PRDATA[4] == 'b1) $display("SUCCESS: BREAK INDICATOR (BI) got triggered along with relevant interrupts at ",$time);
				else $display("ERROR: BREAK INDICATOR (BI) not detected even after relevant stimulus", $time);
			end
		end
		repeat (char_depth_cycle) @ (u_uart_intf.uart_intf_rx_pos);
		count ++;
	end

endtask

endclass





