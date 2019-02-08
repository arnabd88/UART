
class uart_mode1 extends generic_test;

	int fifo_count		;


	function new(`MODULE_REGMAP regmap					, 
				mailbox #(Stimulus) mbx					, 
				mailbox #(int) uart_drv_mbx				, 
				virtual Apb_Interface u_apb_intf		, 
				virtual Uart_Interface u_uart_intf		,
				virtual Event_Interface	u_event_intf	
			);
		super.new(regmap, mbx, uart_drv_mbx,	u_apb_intf, u_uart_intf, u_event_intf)	;
		test_id				=	generic_id		;
	endfunction



	task start(ref int diff_counter);

		-> u_event_intf.start_test;
		gseq.reset_por();
		@(u_uart_intf.uart_intf_tx_pos);
		if(!u_uart_intf.TXRDYn)
			$display("UART_FRAME_TRANSMIT: XMIT_FIFO is Empty after Reset -> ",$realtime);
		else 
			$display("ERROR: UART_FRAME_TRANSMIT: TXRDYn InACTIVE after Reset -> ",$realtime);

		set_baud();

	//---------------- Set LCR Control --------------------------------------
		temp_data	=	(LCR_STOP) & ~LCR_DLAB & ~LCR_BRKC & ~LCR_S_PAR;
		temp_mask	=	(LCR_STOP | LCR_DLAB | LCR_BRKC | LCR_S_PAR);
		gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);

		temp_buf_reset();		


	//---------------- Set FCR Control:MODE0 --------------------------------
		temp_data	=	(FCR_FIFO_EN | FCR_XMIT_RST | FCR_MODE)  ;
		temp_mask	=	( FCR_FIFO_EN | FCR_MODE | FCR_XMIT_RST );
		gseq.generate_write_packet(FCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);
		wait_on(diff_counter);
		@(u_uart_intf.uart_intf_tx_pos);
		if(`XMIT_FIFO_TOP == -1) begin
			messagef(LOW,INFO,`HIERARCHY,$sformatf("SUCCESS: XMIT FIFO CLEARED on XMIT FIFO RESET"));
			if(`THRE	==	1'b1)	messagef(LOW,INFO,`HIERARCHY,$sformatf("SUCCESS: THRE SET due to XMIT FIFO CLEAR"));
			else	messagef(LOW,ERROR,`HIERARCHY,$sformatf("ERROR: THRE NOT SET due to XMIT FIFO CLEAR"));
		end
		else 
			messagef(LOW,ERROR,`HIERARCHY,$sformatf("ERROR: XMIT FIFO NOT CLEARED on XMIT FIFO RESET"));

		if(u_uart_intf.TXRDYn == 1'b0)
			messagef(LOW, INFO, `HIERARCHY,$sformatf("SUCCESS: TXRDY goes Active on clearing XMIT FIFO"));
		else
			messagef(LOW, ERROR, `HIERARCHY,$sformatf("ERROR: TXRDY not Active on clearing XMIT FIFO"));


	//----- XMIT-FIFO RESET RELEASE -----\\
		temp_data	=	(FCR_FIFO_EN | FCR_MODE) & ~FCR_XMIT_RST  ;
		temp_mask	=	( FCR_FIFO_EN | FCR_MODE | FCR_XMIT_RST );
		gseq.generate_write_packet(FCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);
		wait_on(diff_counter);
		@(u_uart_intf.uart_intf_tx_pos);
		
	
		//--- FILL XMIT_FIFO with FULL DEPTH BYTE ----
		do
		begin
			
			temp_buf_reset();
			gseq.generate_write_packet(	XMIT_FIFO_ADDR, temp_data, ~temp_mask , 1'b0, 1'b0);
//			fifo_count++;
			if(u_uart_intf.TXRDYn == 1'b0)	
				messagef(LOW, INFO, `HIERARCHY, $sformatf("SUCCESS:MODE1: TXRDYn Active for XMIT_FIFO count = %d",`XMIT_FIFO_TOP));
			else	
				messagef(LOW, ERROR, `HIERARCHY, $sformatf("ERROR:MODE1: TXRDYn InActive at XMIT_FIFO count = %d",`XMIT_FIFO_TOP));
			wait_on(diff_counter);
			@(u_uart_intf.uart_intf_tx_pos);
			$display("MODE1 FILL: XMIT_FIFO_COUNT	=	%d", `XMIT_FIFO_TOP);
		end
		while(`XMIT_FIFO_TOP != (`MAX_FIFO_DEPTH-1));

		@(u_uart_intf.uart_intf_tx_pos);
		@(u_uart_intf.uart_intf_tx_pos);

		if(u_uart_intf.TXRDYn == 1'b1)	
				messagef(LOW, INFO, `HIERARCHY, $sformatf("SUCCESS:MODE1: TXRDYn InActive for XMIT_FIFO count = %d, indicating FIFO FULL",`XMIT_FIFO_TOP));
			else	
				messagef(LOW, ERROR, `HIERARCHY, $sformatf("ERROR:MODE1: TXRDYn Active at XMIT_FIFO count = %d, indicating FIFO FULL",`XMIT_FIFO_TOP));

		do
		begin
			$display("Wait for character transmission",$time);
			wait_for_charater_trasnmission();
			$display("Release for character transmission",$time);
			$display("MODE1: XMIT_FIFO_COUNT	=	%d", `XMIT_FIFO_TOP);
		end
		while(`XMIT_FIFO_TOP > -1);
		@(u_uart_intf.uart_intf_tx_pos);
		@(u_uart_intf.uart_intf_tx_pos);

		if(u_uart_intf.TXRDYn == 0)
			messagef(LOW, INFO, `HIERARCHY, $sformatf("SUCCESS: MODE1: TXRDYn Active since TXFIFO CLEARED by TRANSMISSION"));
		else 
			messagef(LOW, ERROR, `HIERARCHY, $sformatf("ERROR: MODE1: TXRDYn InActive at TXFIFO CLEARED by TRANSMISSION"));

		
//-------------------------------------------------------------------------------------
//--------- This event denotes the testcase scope end. It initiates the creation for the next testcase object.
		-> u_event_intf.test_end ;


	endtask

endclass

		
		
