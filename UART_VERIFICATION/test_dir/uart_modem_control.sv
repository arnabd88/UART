class uart_modem_control extends generic_test;

	bit [3:0] config_bit;
	bit [7:0] mcr_config_data;
	 		bit [PDATA_WIDTH-1:0] mask	;
	 		bit [PDATA_WIDTH-1:0] msr_read ;
	int flag;
	bit [PDATA_WIDTH-1:0] check_data	;
	// @ (u_uart_intf.uart_intf_tx_pos)
	// 	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit;

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
	
	-> u_event_intf.start_test	;
	//gsec.reset_por()	;
	
	
//	// -Configuring MCR for ---------------------------------------------------------------------//
//	temp_data = (MCR_DTR | MCR_RTS | MCR_OUT1 | MCR_OUT2) & ~MCR_LOOPBACK	;
//	temp_mask = (MCR_LOOPBACK | MCR_DTR | MCR_RTS | MCR_OUT1 | MCR_OUT2)	;
//	gseq.generate_write_packet(MCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
//	// ------------------------------------------------------------------------------------------//

	
	// -Configure IER for -----------------------------------------------------------------------//
	//temp_data = (IER_MODEM_ST)	;
	//temp_mask = (IER_MODEM_ST)	;
	temp_data = (IER_REC_DA | IER_THRE_ST | IER_REC_LS | IER_MODEM_ST)	;
	temp_mask = (IER_REC_DA | IER_THRE_ST | IER_REC_LS | IER_MODEM_ST)	;
	gseq.generate_write_packet(IER_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
	// ------------------------------------------------------------------------------------------//

	
	gseq.generate_read_packet(MSR_ADDR); // clearing any status present on MSR Register

	
	// Configuring MCR -- Checking for default status for Modem control output pins--------------//
	temp_data = (MCR_RESET)	;
	temp_mask = 8'hFF	;
	gseq.generate_write_packet(MCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0)	;
	#10;
	wait (diff_counter == 0);
	if (u_uart_intf.DTRn & u_uart_intf.RTSn & u_uart_intf.OUT1n & u_uart_intf.OUT2n) $display ("SUCCESS : Default values output control pins of Modem Control Logic is identified", $time);
	else $display ("ERROR : Default values output control pins of Modem Control Logic is NOT identified", $time);
	//-------------------------------------------------------------------------------------------//

	///////////////////////////////////////////////////////////////////////////////////////////////
	// Configuring MCR -- Checking for OUTPUT pin functionality ///////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	//bit [3:0] mcr_control_vector = {MCR_DTR, MCR_RTS};
	// temp_mask = 'b11110000	;
	temp_mask = 'b00001111	;
	unique_randomize(0, 15, 1);
	repeat (15) begin
	//while (i <= 15) begin
	//	flag = 0;
	//	bit [7:0] mcr_config_data_temp = $urandom_range('b00001111,'b11111111);
	//	for (int j = 0; j < i; j++) begin
	//		if (mcr_config_data_temp == mcr_config_data_queue[j]) begin
	//				flag = 1;
	//		end
	//	end
	//	if (flag == 0) begin
	//		mcr_config_data_queue[i] = mcr_config_data_temp;
	//		mcr_config_data = mcr_config_data_temp;
	//		i++;
	//	end
		temp_data	=	unique_randomize(0, 15, 0);
		temp_data = temp_data & temp_mask;
		gseq.generate_write_packet(MCR_ADDR, temp_data, 8'h00, 1'b0, 1'b0)	;
	#10;
	wait (diff_counter == 0);
		check_data = {1'b0, 1'b0, 1'b0, 1'b0, ~u_uart_intf.OUT2n, ~u_uart_intf.OUT1n, ~u_uart_intf.RTSn, ~u_uart_intf.DTRn};
		$display("CHECK_DATA = %b\tTEMP_DATA = %b",check_data, temp_data,$time);
		if ( check_data === temp_data) $display ("SUCCESS : MCR configured output control pins to correct values", $time);
		else $display ("ERROR : MCR(%b) NOT driving output control pins to correct values", temp_data, $time);

	end

	
	
	///////////////////////////////////////////////////////////////////////////////////////////////
	// Configuring MCR -- Checking for INPUT pin & corresponding STATUS fields functionality //////
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	
	// bit [3:0] config_bit;
	// queue = new[15];
	//@ (u_uart_intf.uart_intf_tx_pos)
	//	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit;
	// while (i <= 15) begin
	// 	flag = 0;
	// 	bit [3:0] config_bit_rand = $urandom_range(15);
	// 	for (int j = 0; j < i; j++) begin
	// 		if (config_bit_rand == queue[j]) begin
	// 				flag = 1;
	// 		end
	// 	end
	// 	if (flag == 0) begin
	// 		queue[i] = config_bit_rand;
	// 		config_bit = config_bit_rand;
	// 		i++;
	// 	end
	// 	@ (u_uart_intf.uart_intf_tx_pos)
	// 	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit	;
	// 	generate_read_packet (MSR_ADDR)	;
	// 	wait (diff_counter == 0)	;
	// 	@ (u_apb_intf.apb_intf_pos)	begin
	// 		bit [7:0] mask	;
	// 		mask = 'b11110000	;
	// 		bit [7:0] msr_read = u_apb_intf.PRDATA	;
	// 		msr_read = msr_read & mask	;
	// 		if (msr_read[7:4] === ~config_bit) $display ("SUCCESS $d : Model control inputs getting reflected in MSR",i,$time);
	// 		else $display ("ERROR $d : Model control inputs NOT getting reflected in MSR(%b)",i,msr_read[7:4],$time);
	// 	end
	// end
	unique_randomize(15, 0, 1);
	repeat (15) begin
		config_bit	=	unique_randomize(15, 0, 0);
		@ (u_uart_intf.uart_intf_tx_pos)
	 	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit	;
	 	gseq.generate_read_packet (MSR_ADDR)	;
		#10;
	 	wait (diff_counter == 0)	;
		$display("1. PR_DATA = %b\tPSEL = %b",u_apb_intf.PRDATA,u_apb_intf.PSEL,$time);
	 	@ (u_apb_intf.apb_intf_pos)	begin
	 		mask = 'b11110000	; 
			msr_read = u_apb_intf.PRDATA	;
		$display("2. PR_DATA = %b\tPSEL = %b",u_apb_intf.PRDATA,u_apb_intf.PSEL,$time);
	 		msr_read = msr_read & mask	;
			$display("CONFIG_BIT = %b", config_bit, $time);
	 		if (msr_read[7:4] === ~config_bit) $display ("SUCCESS  : Model control inputs getting reflected in MSR",$time);
	 		else $display ("ERROR : Model control inputs NOT getting reflected in MSR(%b)",msr_read[7:4],$time);
	 	end
	end



	///////////////////////////////////////////////////////////////////////////////////////////////
	// Checking the functionality for DELTA STATUS fields in UART MSR /////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////


	// Note : Last read on MSR (should have) cleared its delta status bits. Checking if they have gone low

	gseq.generate_read_packet (MSR_ADDR)	;
	#10;
	wait (diff_counter == 0)	;
	if (u_apb_intf.PRDATA[3:0] === 'b0000) $display ("SUCCESS : Delta fields are getting default values (Low) afret MSR Read", $time)	;
	else $display ("ERROR : Delta fields are NOT getting default values (Low) afret MSR Read", $time)	;

	// Driving inputs to UART Model controls and checking for the Delta status fields when input is CONSTANT

	flag = 0;
	config_bit = 'b0000;
	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit	;
	gseq.generate_read_packet (MSR_ADDR)	;
	#10;
	wait (diff_counter == 0)	;
	config_bit = 'b0000;
	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit	;
	gseq.generate_read_packet (MSR_ADDR)	;
	#10;
	wait (diff_counter == 0)	;
	if (u_apb_intf.PRDATA[3:0] === 'b0000) flag = 1;

	config_bit = 'b1111;
	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit	;
	#10;
	wait (diff_counter == 0)	;
	gseq.generate_read_packet (MSR_ADDR)	;
	wait_on(diff_counter);
	config_bit = 'b1111;
	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit	;
	gseq.generate_read_packet (MSR_ADDR)	;
	#10;
	wait (diff_counter == 0)	;
	if ((u_apb_intf.PRDATA[3:0] === 'b0000) & (flag)) $display ("SUCCESS : MSR Delta fields stays LOW when no change in corresponding Modem Control input lines", $time)	;
	else $display ("ERROR : MSR Delta fields DO NOT stay LOW when no change in corresponding Modem Control input lines", $time);

	
	// Driving inputs to UART Model controls and checking for the Delta status fields when input is CHANGING

	flag = 0;
	config_bit = 'b0000;
	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit	;
	gseq.generate_read_packet (MSR_ADDR)	;
	#10;
	wait (diff_counter == 0)	;
	config_bit = 'b1111;
	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit	;
	gseq.generate_read_packet (MSR_ADDR)	;
	#10;
	wait (diff_counter == 0)	;
	if (u_apb_intf.PRDATA[3:0] === 'b1111) flag = 1;


	config_bit = 'b1111;
	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit	;
	gseq.generate_read_packet (MSR_ADDR)	;
	#10;
	wait (diff_counter == 0)	;
	config_bit = 'b0000;
	{u_uart_intf.DCDn, u_uart_intf.RIn , u_uart_intf.DSRn , u_uart_intf.CTSn} = config_bit	;
	gseq.generate_read_packet (MSR_ADDR)	;
	#10;
	wait (diff_counter == 0)	;
	if ((u_apb_intf.PRDATA[3:0] === 'b1011) & (flag)) $display ("SUCCESS : MSR Delta fields gives correct status when data changes in their corresponding Modem Control input lines", $time)	;
	else $display ("ERROR : MSR Delta fields DO NOT give correct status when data changes in their corresponding Modem Control input lines", $time)	;

	
//--------- This event denotes the testcase scope end. It initiates the creation for the next testcase object.
		-> u_event_intf.test_end ;

endtask

endclass











	 

	
