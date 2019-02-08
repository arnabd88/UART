
class uart_THRE_interrupt_test extends generic_test;

	
	function new( `MODULE_REGMAP regmap					, 
				mailbox #(Stimulus) mbx					, 
				mailbox #(int) uart_drv_mbx				, 
				virtual Apb_Interface u_apb_intf		, 
				virtual Uart_Interface u_uart_intf		,
				virtual Event_Interface u_event_intf	
			);
		super.new(regmap, mbx, uart_drv_mbx,	u_apb_intf, u_uart_intf, u_event_intf)	;
		test_id				=	generic_id		;

	endfunction


	task start(ref int diff_counter);
		int char_len;
		-> u_event_intf.start_test;
		gseq.reset_por();
		set_baud();
		@(u_apb_intf.apb_intf_pos);
		//if(`THRE_ST == 1'b1 && `ID_INT == 2'b01 && u_uart_intf.INTR == 1'b1 && u_uart_intf.TXRDYn == 1'b0) 
		//		$display("uart_THRE_interrupt_test: XMIT_FIFO EMPTY after POR.\n THRE interrupt generated -> ", $realtime);
		//else 
		//		$display("ERROR: uart_THRE_interrupt_test: THRE interrupt test Failed!!! -> ", $realtime);


		gseq.generate_read_packet(IIR_ADDR);
		wait_on(diff_counter);
		$display ("I am here");
		if (u_apb_intf.PRDATA[3:1] != 'b01) begin
			
			//--------------- LCR configure --------------------------------------------------
			temp_data = ~LCR_S_PAR & ~LCR_DLAB & ~LCR_BRKC;
			temp_mask = (LCR_S_PAR | LCR_DLAB | LCR_BRKC);
			gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);
			//--------------------------------------------------------------------------------
			
			
			//----------------IER configure --------------------------------------------------
			temp_data = IER_THRE_ST & ~IER_REC_LS & ~IER_REC_DA;
			temp_mask = (IER_THRE_ST | IER_REC_LS | IER_REC_DA);
			gseq.generate_write_packet(IER_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);
			//--------------------------------------------------------------------------------


			//----------------FCR configure --------------------------------------------------
			temp_data = ~FCR_XMIT_RST;
			temp_mask = FCR_XMIT_RST;
			gseq.generate_write_packet(FCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);
			//--------------------------------------------------------------------------------


			//----------------XMIT data send -------------------------------------------------
			temp_data = $urandom_range(0,512);
			temp_mask = temp_data;
			gseq.generate_write_packet(XMIT_FIFO_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);
			//--------------------------------------------------------------------------------
			char_len = ((`CHARL + 5) + (`PAR_EN) + (`STOP + 1) + 1)	;
			repeat (16 * char_len) begin
				@ (u_uart_intf.uart_intf_rx_pos);
			end
			wait_on(diff_counter);
		
			gseq.generate_read_packet(IIR_ADDR);
			wait_on(diff_counter);

			if (u_apb_intf.PRDATA[3:1] == 'b001) $display("SUCCESS: THRE successfully detected in IIR",$time);
			if (u_uart_intf.IRQ == 'b1) $display("SUCCESS: THRE interrupt observed at the IRQ pin", $time);
			gseq.generate_read_packet(IIR_ADDR);
			wait_on(diff_counter);
			if (u_apb_intf.PRDATA[3:1] != 'b001) $display("SUCCESS: THRE successfully cleared in IIR due to IIR read",$time);

			//----------------XMIT data send -------------------------------------------------
			temp_data = $urandom_range(0,512);
			temp_mask = temp_data;
			gseq.generate_write_packet(XMIT_FIFO_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);
			//--------------------------------------------------------------------------------

			gseq.generate_read_packet(IIR_ADDR);
			wait_on(diff_counter);
			if (u_apb_intf.PRDATA[3:1] != 'b001) $display("SUCCESS: THRE successfully cleared in IIR after writing in XMIT FIFO",$time);
		end
		else begin
			$display ("ERROR: THRE interrupt not cleared after Master Reset", $time);
		end
		
	//debanjan//	//--------------- LCR configure ----------------------
	//debanjan//	temp_data	=	(LCR_PAR_EN | LCR_PAR_SEL | LCR_STOP) & ~LCR_DLAB ;
	//debanjan//	temp_mask	=	(LCR_PAR_EN | LCR_PAR_SEL | LCR_STOP | LCR_DLAB);
	//debanjan//	gseq.generate_write_packet(LCR_ADDR, temp_data, temp_mask, 1'b0, 1'b0);

	//debanjan//	//------------------------------------------------------------------\\

	//debanjan//	temp_buf_reset();


	//debanjan//	//-------- generate packet for filling XMIT_FIFO ----------------\\
	//debanjan//	@(u_uart_intf.uart_intf_tx_pos);
	//debanjan//	gseq.generate_write_packet(	XMIT_FIFO_ADDR, temp_data, temp_mask , 1'b0, 1'b0);
	//debanjan//	gseq.generate_write_packet(	XMIT_FIFO_ADDR, temp_data, temp_mask , 1'b0, 1'b0);
	//debanjan//	//wait(`THRE_ST == 1'b0 && u_apb_intf.PRESETn == 1'b1); // event trigger from BFM fifo
	//debanjan//	$display("THRE cleared with data input to FIFO");
	//debanjan//	//wait(`THRE_ST == 1'b1 && u_apb_intf.PRESETn == 1'b1); // event trigger from BFM fifo


	//debanjan//	
//--//debanjan//-----------------------------------------------------------------------------------
//--//debanjan//------- This event denotes the testcase scope end. It initiates the creation for the next testcase object.
	//debanjan//	-> u_event_intf.test_end ;


	endtask : start

endclass


