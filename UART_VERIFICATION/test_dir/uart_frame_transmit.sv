
class uart_frame_transmit extends generic_test;

	//generator			 	gseq			;
	//mailbox #(stimulus) 	mbx				;
	//Stimulus 				sti				;
	//MODULE_REGMAP 			regmap			;
	//virtual Apb_Interface 	u_apb_intf		;
	//virtual Uart_Interface 	u_uart_intf		;
	//int 					xmit_fifo_count ;
	//bit	[PDATA_WIDTH-1:0]	temp_data		;
	//bit	[PDATA_WIDTH-1:0]	temp_mask		;
	int fifo_count		;
	// rand int baud_value;

	function new(`MODULE_REGMAP regmap					, 
				mailbox #(Stimulus) mbx					, 
				mailbox #(int) uart_drv_mbx				, 
				virtual Apb_Interface u_apb_intf		, 
				virtual Uart_Interface u_uart_intf		,
				virtual Event_Interface	u_event_intf	
			);
		super.new(regmap, mbx, uart_drv_mbx,	u_apb_intf, u_uart_intf, u_event_intf)	;
		test_id				=	generic_id		;
//
//		this.u_apb_intf		= 	u_apb_intf		;
//		this.u_uart_intf	= 	u_uart_intf		;
//		this.mbx 			= 	mbx				;
//		this.regmap 		= 	regmap			;
//		gseq 				= 	new(mbx)		;

	endfunction



	task start(ref int diff_counter);

		-> u_event_intf.start_test;
		gseq.reset_por();
		@(u_apb_intf.apb_intf_pos);
		if(!u_uart_intf.TXRDYn)
			$display("UART_FRAME_TRANSMIT: XMIT_FIFO is Empty after Reset -> ",$realtime);
		else 
			$display("ERROR: UART_FRAME_TRANSMIT: TXRDYn InACTIVE after Reset -> ",$realtime);
		
		set_baud();

		temp_buf_reset();

		temp_data	=	(LCR_PAR_EN | LCR_PAR_SEL | LCR_STOP) & ~LCR_DLAB & ~LCR_BRKC & ~LCR_S_PAR;
		temp_mask	=	(LCR_PAR_EN | LCR_PAR_SEL | LCR_STOP | LCR_DLAB | LCR_BRKC | LCR_S_PAR);
		gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);

		//------------------------------------------------------------------\\

		temp_buf_reset();


		//-------- generate packet for filling-up XMIT_FIFO ----------------\\
		do
			begin
				gseq.generate_write_packet(	XMIT_FIFO_ADDR, temp_data, ~temp_mask , 1'b0, 1'b0);
				//# (START_DELAY * 500);
				fifo_count++;
			end
		while(fifo_count < `MAX_FIFO_DEPTH);
		//------------------------------------------------------------------\\

		wait(regmap.xmit_fifo_reg.xmit_fifo_top == -1);

//-------------------------------------------------------------------------------------
//--------- This event denotes the testcase scope end. It initiates the creation for the next testcase object.
		-> u_event_intf.test_end ;


	endtask

endclass

		
		
