class uart_loopback extends generic_test;

	static bit dtr_dsr = 0;
	static bit cts_rts = 0;
	static bit out1_ri = 0;
	static bit out2_dcd = 0;

function new(`MODULE_REGMAP regmap					,
			mailbox #(Stimulus) mbx					,
			mailbox #(int) uart_drv_mbx				,
			virtual Apb_Interface u_apb_intf		,
			virtual Uart_Interface u_uart_intf		,
			virtual Event_Interface	u_event_intf	
		);
		super.new(regmap, mbx, uart_drv_mbx, u_apb_intf, u_uart_intf, u_event_intf)	;
		test_id = generic_id	;
endfunction


task start(ref int diff_counter);

	bit [7:0] read_data;
	bit [7:0] check_data;
	bit flag = 0;

	bit DTR_REG		;
	bit RTS_REG		;
	bit OUT1_REG	;
	bit OUT2_REG	;
	-> u_event_intf.start_test	;
	gseq.reset_por();
	//gseq.reset_por()	; //testting TXRDY
	@(u_apb_intf.apb_intf_pos)	;
	if (`RCV_DR) $display("UART_FIFO is Empty after Reset -> ",$realtime)	;
	else $display ("LSR[0] is not Set after Reset -> ",$realtime)	;
	
			
		// //-------- configure LCR and IER before filling FIFO ---------------\\
		// //1. Setting DLAB before writing to DLM
		// temp_data	=	LCR_DLAB 	;
		// temp_mask	=	LCR_DLAB	;
		// gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);

		// temp_buf_reset();

		// //2. Writing DLL = 12
		// temp_data	=	8'h0C	;
		// temp_mask	=	8'hFF	;
		// gseq.generate_write_packet(DLL_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);
		// $display("PDATA = %d\nPADDR = %d", gseq.sti.pdata, gseq.sti.paddr, $time);

		// temp_buf_reset();


		// temp_data	=	~LCR_DLAB 	;
		// temp_mask	=	LCR_DLAB	;
		// gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);
		set_baud();

		temp_buf_reset();

	#10	;
		wait(diff_counter==0);
		$display("1. CHECK LOOPBACK TIME",$time);


	// -Configuring MSR for loopback mode -------------------------------------------------------//
	temp_data = (MCR_LOOPBACK | MCR_DTR | MCR_RTS | MCR_OUT1 | MCR_OUT2)	;
	temp_mask = (MCR_LOOPBACK | MCR_DTR | MCR_RTS | MCR_OUT1 | MCR_OUT2)	;
	gseq.generate_write_packet(MCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
	DTR_REG		=	temp_data[0]		;
	RTS_REG		=	temp_data[1]		;
	OUT1_REG	=	temp_data[2]		;
	OUT2_REG	=	temp_data[3]		;
		temp_buf_reset();
	// ------------------------------------------------------------------------------------------//


	// -Configure LCR for loopback mode ---------------------------------------------------------//
		//* configuring LCR for no parity
		//* configuring LCR for 8 bit data size
		//* configuring LCR for singular stop bit
		//*
	// temp_data = LCR_CHARL_8 & (~LCR_PAR_EN | ~LCR_DLAB | ~LCR_STOP)	;
	temp_data = LCR_CHARL_8 & ~LCR_PAR_EN & ~LCR_DLAB & ~LCR_STOP & ~LCR_BRKC & ~LCR_S_PAR	;
	temp_mask = (LCR_CHARL_8 | LCR_PAR_EN | LCR_DLAB | LCR_STOP | LCR_BRKC | LCR_S_PAR)	;
	gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
		temp_buf_reset();
	// ------------------------------------------------------------------------------------------//


	// -Configure FCR for loopback mode ---------------------------------------------------------//
		//* enabling receiver and transmitter fifo
		//* setting trigger level to 1
	temp_data = (FCR_FIFO_EN | FCR_TRIG_LVL_1)  & ~FCR_XMIT_RST & ~FCR_RCVR_RST;
	temp_mask = (FCR_FIFO_EN | FCR_TRIG_LVL_mask | FCR_XMIT_RST | FCR_RCVR_RST);
	gseq.generate_write_packet(FCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
		temp_buf_reset();
	// ------------------------------------------------------------------------------------------//



	// -Configure IER for loopback mode ---------------------------------------------------------//
	//temp_data = (IER_MODEM_ST)	;
	//temp_mask = (IER_MODEM_ST)	;
	temp_data = (IER_REC_DA | IER_THRE_ST | IER_REC_LS | IER_MODEM_ST)	;
	temp_mask = (IER_REC_DA | IER_THRE_ST | IER_REC_LS | IER_MODEM_ST)	;
	gseq.generate_write_packet(IER_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
		temp_buf_reset();
	// ------------------------------------------------------------------------------------------//
	
		// temp_data	=	~LCR_DLAB 	;
		// temp_mask	=	LCR_DLAB	;
		// gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);

		temp_buf_reset();


	gseq.generate_read_packet(MSR_ADDR); // clearing any status present on MSR Register

	// Sending one data from host to UART
	// temp_data = 'b10100101;
	temp_data = $random()%512;
	temp_mask = 'b11111111;
	gseq.generate_write_packet(XMIT_FIFO_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
		//temp_buf_reset();
	#10	;
	wait (diff_counter==0);
		$display("2. CHECK LOOPBACK TIME",$time);
	repeat (16*(8+1+1)) /*(bit_length+start_bit+stop_bit+1)*/ begin
		@ (u_uart_intf.uart_intf_rx_pos);
	end

	// Reading back the transmitted data
	#10;
	wait (diff_counter==0);
	gseq.generate_read_packet(RCVR_FIFO_ADDR);
	#10 ;
	wait (diff_counter==0);
	read_data = u_apb_intf.PRDATA;
	if(read_data === temp_data)	$display("SUCCESS : data transmitted and received are same in loop-back mode", $time);
	else $display("ERROR : data transmitted and received are NOT same in loop-back mode", $time);
	$display("read_data = %b\ttemp_data = %b",read_data, temp_data,$time);

	// Reading the IIR
	gseq.generate_read_packet(IIR_ADDR);
	#10	;
	wait (diff_counter==0);
	read_data = u_apb_intf.PRDATA;
	// read_data = read_data + 'b11111101;
	// read_data = read_data | 'b11111101;
	if (read_data[2:1] == 'b10) $display ("SUCCESS : RCVR_FIFO trigger level reached flag generated in loop-back mode", $time);
	else $display ("ERROR : RCVR_FIFO trigger level reached flag NOT generated in loop-back mode", $time);


	// Checking Loop-backs internally between Modem Control logis Input and Outputs
	//--Initializing status flags to 0 --------------------------------------------------//
	// static int dtr_dsr = 0;
	// static int cts_rts = 0;
	// static int out1_ri = 0;
	// static int out2_dcd = 0;
	//-----------------------------------------------------------------------------------//
	
	flag = 0;
	gseq.generate_read_packet(MSR_ADDR);
	#10	;
	wait (diff_counter==0);
	check_loopback_connectivity();
	$display("1. dtr_dsr = %b",dtr_dsr,$time);
	$display("1. cts_rts = %b",cts_rts,$time);
	$display("1. out1_ri = %b",out1_ri,$time);
	$display("1. out2_dcd = %b",out2_dcd,$time);
	check_data = {	OUT2_REG, OUT1_REG, RTS_REG, DTR_REG };
	if(check_data	===	u_apb_intf.PRDATA[7:4])
		$display("SUCCESS: LOOPBACK FOR CONTROL SIGNALS");
	else
		$display("ERROR: LOOPBACK FOR CONTROL SIGNALS");
		$display("LOOPBACK: CHECK_DATA = %b\tMSR_DATA = %b",check_data, u_apb_intf.PRDATA[7:4],$time);
	// Not clear if (dtr_dsr & cts_rts & out1_ri & out2_dcd) flag = 1;
	// Not clear // -Configuring MSR for loopback mode -------------------------------------------------------//
	// Not clear // temp_data = (MCR_LOOPBACK) & ( ~MCR_DTR | ~MCR_RTS | ~MCR_OUT1 | ~MCR_OUT2)	;
	// Not clear // temp_data = (MCR_LOOPBACK) &  ~MCR_DTR & ~MCR_RTS & ~MCR_OUT1 & ~MCR_OUT2	;
	// Not clear temp_data = (MCR_LOOPBACK) |  MCR_DTR | MCR_RTS | MCR_OUT1 | MCR_OUT2	;
	// Not clear temp_mask = (MCR_LOOPBACK | MCR_DTR | MCR_RTS | MCR_OUT1 | MCR_OUT2)	;
	// Not clear gseq.generate_write_packet(MCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
	// Not clear 	temp_buf_reset();
	// Not clear // ------------------------------------------------------------------------------------------//
	// Not clear gseq.generate_read_packet(MSR_ADDR);
	// Not clear #10	;
	// Not clear wait (diff_counter==0);
	// Not clear check_loopback_connectivity();
	// Not clear $display("2. FLAG = %b",flag,$time);
	// Not clear $display("2. dtr_dsr = %b",dtr_dsr,$time);
	// Not clear $display("2. cts_rts = %b",cts_rts,$time);
	// Not clear $display("2. out1_ri = %b",out1_ri,$time);
	// Not clear $display("2. out2_dcd = %b",out2_dcd,$time);
	// Not clear if (flag & dtr_dsr & cts_rts & out1_ri & out2_dcd) $display ("SUCCESS : Loopback connections between MCR signals are correct", $time);
	// Not clear else $display ("ERROR : MCR control pins are not looped-back in Loop_back mode", $time);

	pclk_wait_states(20);

	gseq.reset_por();

//--------- This event denotes the testcase scope end. It initiates the creation for the next testcase object.
		-> u_event_intf.test_end ;

endtask : start


task check_loopback_connectivity();

	if (u_uart_intf.DSRn == 'b0) 	dtr_dsr			=	1;
	else	dtr_dsr	=	0;

	if (u_uart_intf.CTSn == 'b0)	cts_rts			=	1;
	else	cts_rts			=	0;

	if (u_uart_intf.RIn == 'b0)		out1_ri			=	1;
	else	out1_ri			=	0;

	if (u_uart_intf.DCDn == 'b0)	out2_dcd		=	1;
	else	out2_dcd		=	0;

endtask

endclass
