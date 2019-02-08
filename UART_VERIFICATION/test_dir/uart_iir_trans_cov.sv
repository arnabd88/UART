
class uart_iir_trans_cov extends generic_test;

	bit [3:0] config_bit;

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
	int char_len, trigger_bit;
	
	-> u_event_intf.start_test	;
	//gsec.reset_por()	;
	
	
		set_baud();

		temp_buf_reset();

//===================== SCENARIO-1 =============================================================\\

			
	// -Configure IER for -----------------------------------------------------------------------//
	//temp_data = (IER_MODEM_ST)	;
	//temp_mask = (IER_MODEM_ST)	;
	temp_data = (IER_REC_DA | IER_THRE_ST | IER_REC_LS | IER_MODEM_ST)	;
	temp_mask = (IER_REC_DA | IER_THRE_ST | IER_REC_LS | IER_MODEM_ST)	;
	gseq.generate_write_packet(IER_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
	// ------------------------------------------------------------------------------------------//


	gseq.generate_read_packet(MSR_ADDR); // clearing any status present on MSR Register

	config_bit	=	unique_randomize(15, 0, 0);
	@ (u_uart_intf.uart_intf_tx_pos);
	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit	;
	gseq.generate_read_packet (IIR_ADDR)	;
	wait_on(diff_counter);
	gseq.generate_read_packet (MSR_ADDR)	;
	wait_on(diff_counter);

	//-------------------------------------------------------------------------------------------------------
//===================== END SCENARIO1 =============================================================\\


//===================== SCENARIO-2 =============================================================\\

	gseq.generate_read_packet(MSR_ADDR); // clearing any status present on MSR Register

	config_bit	=	unique_randomize(15, 0, 0);
	@ (u_uart_intf.uart_intf_tx_pos);
	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit	;
	gseq.generate_read_packet (IIR_ADDR)	;
	wait_on(diff_counter);


	char_len = (`CHARL + 5) + (`PAR_EN) + (`STOP + 1) + 1;
	unique_randomize(3, 0, 1);

	trigger_bit	=	unique_randomize(3, 0, 0);
	trigger_bit	=	trigger_bit << 6;

	temp_data	=	trigger_bit & ~FCR_RCVR_RST			;
	temp_mask	=	FCR_TRIG_LVL_mask | FCR_RCVR_RST	;
	gseq.generate_write_packet(FCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);

	uart_drv_mbx.put(get_trigger_level(trigger_bit[7:6]))	;
	-> u_event_intf.start_transmit_frm_BFM	;

	repeat((get_trigger_level(trigger_bit[7:6])) * (16 * char_len) + 1) begin
		@ (u_uart_intf.uart_intf_rx_pos);
	end

	gseq.generate_read_packet(IIR_ADDR);
	wait_on(diff_counter);

	 while(`RCVR_FIFO_TOP > -1) begin
	 	gseq.generate_read_packet (XMIT_DLL_RCVR_00)	;
	 	wait_on(diff_counter);
	 end
	 gseq.generate_read_packet(IIR_ADDR);
	 wait_on(diff_counter);

	 -> u_event_intf.test_end ;

endtask

endclass

		
	
