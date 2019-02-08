class generic_test;

	generator			 	gseq			;
	Stimulus 				sti				;
	mailbox #(Stimulus) 	mbx				;
	mailbox #(int) 	uart_drv_mbx			;
	`MODULE_REGMAP 			regmap			;
	virtual Apb_Interface 	u_apb_intf		;
	virtual Uart_Interface 	u_uart_intf		;
	virtual Event_Interface	u_event_intf	;
	int 					xmit_fifo_count ;
	static int				generic_id		;
	int						test_id			;
	bit	[PDATA_WIDTH-1:0]	temp_data		;
	bit	[PDATA_WIDTH-1:0]	temp_mask		;
	static int 				queue[]			;

	static rand int baud_value;


	 function new(`MODULE_REGMAP regmap					, 
	 			mailbox #(Stimulus) mbx					, 
				mailbox #(int) 	uart_drv_mbx			,
	 			virtual Apb_Interface u_apb_intf		,	 
	 			virtual Uart_Interface u_uart_intf		,
				virtual Event_Interface	u_event_intf	
	 		);

	 	this.u_apb_intf		= 	u_apb_intf		;
	 	this.u_uart_intf	= 	u_uart_intf		;
		this.u_event_intf	=	u_event_intf	;
	 	this.mbx 			= 	mbx				;
	 	this.uart_drv_mbx	= 	uart_drv_mbx				;
	 	this.regmap 		= 	regmap			;
	 	gseq 				= 	new(mbx, u_apb_intf)		;
		generic_id			=	generic_id++	;

	 endfunction


	function temp_buf_reset();

		temp_data = 8'h00;
		temp_mask = 8'h00;

	endfunction



	virtual task start(ref int diff_counter);

		gseq.reset_por();
		temp_buf_reset();

	endtask


	function int	get_trigger_level	(bit[1:0] TRIG_LEVEL);

		case(TRIG_LEVEL)

			2'b00	:	return	1	;
			2'b01	:	return	4	;
			2'b10	:	return	8	;
			2'b11	:	return	14	;
			default	:	return	1	;

		endcase

	endfunction


	function bit[PDATA_WIDTH-1:0] get_DLM(int BAUD_VALUE);

		case(BAUD_VALUE)
			
			50		:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_50_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_50_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_50_M		;
						end
			75		:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_75_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_75_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_75_M		;
						end
			110		:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_110_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_110_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_110_M		;
						end
			134.5	:	begin
				 	   		if(u_event_intf.clock_type == CLOCK1)	return	CLK1_134_5_M	;
				 	   		if(u_event_intf.clock_type == CLOCK2)	return	CLK2_134_5_M	;
				 	   		if(u_event_intf.clock_type == CLOCK3)	return	CLK3_134_5_M	;
				 	   end
			150		:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_150_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_150_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_150_M		;
						end
			300		:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_300_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_300_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_300_M		;
						end
			600		:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_600_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_600_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_600_M		;
						end
			1200	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_1200_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_1200_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_1200_M		;
						end
			1800	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_1800_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_1800_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_1800_M		;
						end
			2000	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_2000_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_2000_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_2000_M		;
						end
			2400	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_2400_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_2400_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_2400_M		;
						end
			3600	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_3600_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_3600_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_3600_M		;
						end
			4800	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_4800_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_4800_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_4800_M		;
						end
			7200	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_7200_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_7200_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_7200_M		;
						end
			9600	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_9600_M		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_9600_M		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_9600_M		;
						end
			19200	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_19200_M	;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_19200_M	;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_19200_M	;
						end
			38400	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_38400_M	;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_38400_M	;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_38400_M	;
						end
			56000	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_56000_M	;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_56000_M	;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_56000_M	;
						end
			128000	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_128000_M	;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_128000_M	;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_128000_M	;
						end
		endcase

	endfunction








	function bit[PDATA_WIDTH-1:0] get_DLL(int BAUD_VALUE);

		case(BAUD_VALUE)
			
			50		:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_50_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_50_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_50_L		;
						end
			75		:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_75_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_75_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_75_L		;
						end
			110		:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_110_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_110_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_110_L		;
						end
			134.5	:	begin
				 	   		if(u_event_intf.clock_type == CLOCK1)	return	CLK1_134_5_L	;
				 	   		if(u_event_intf.clock_type == CLOCK2)	return	CLK2_134_5_L	;
				 	   		if(u_event_intf.clock_type == CLOCK3)	return	CLK3_134_5_L	;
				 	   end
			150		:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_150_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_150_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_150_L		;
						end
			300		:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_300_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_300_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_300_L		;
						end
			600		:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_600_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_600_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_600_L		;
						end
			1200	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_1200_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_1200_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_1200_L		;
						end
			1800	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_1800_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_1800_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_1800_L		;
						end
			2000	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_2000_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_2000_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_2000_L		;
						end
			2400	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_2400_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_2400_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_2400_L		;
						end
			3600	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_3600_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_3600_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_3600_L		;
						end
			4800	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_4800_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_4800_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_4800_L		;
						end
			7200	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_7200_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_7200_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_7200_L		;
						end
			9600	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_9600_L		;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_9600_L		;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_9600_L		;
						end
			19200	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_19200_L	;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_19200_L	;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_19200_L	;
						end
			38400	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_38400_L	;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_38400_L	;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_38400_L	;
						end
			56000	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_56000_L	;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_56000_L	;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_56000_L	;
						end
			128000	:	begin
							if(u_event_intf.clock_type == CLOCK1)	return	CLK1_128000_L	;
							if(u_event_intf.clock_type == CLOCK2)	return	CLK2_128000_L	;
							if(u_event_intf.clock_type == CLOCK3)	return	CLK3_128000_L	;
						end
		endcase

	endfunction



	function void set_baud	();
		
		//----- Set DLAB for enabling access to DLL, DLM -----\\
		temp_data	=	(LCR_DLAB & ~LCR_BRKC & ~LCR_S_PAR)	;
		temp_mask	=	(LCR_DLAB | LCR_BRKC | LCR_S_PAR)	;
		gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);

		temp_mask	=	8'hFF	;
		assert( randomize(baud_value) with { baud_value dist { `baud_dist}; } );
		$display("BAUD_VALUE = %d",baud_value);

		gseq.generate_write_packet(DLL_ADDR, get_DLL(baud_value), ~temp_mask, 1'b0, 1'b0);
		gseq.generate_write_packet(DLM_ADDR, get_DLM(baud_value), ~temp_mask, 1'b0, 1'b0);

		temp_data	=	(~LCR_DLAB & ~LCR_BRKC & ~LCR_S_PAR)	;
		temp_mask	=	(LCR_DLAB | LCR_BRKC | LCR_S_PAR)	;
		gseq.generate_write_packet(LCR_ADDR, temp_data, ~temp_mask, 1'b0, 1'b0);

		temp_buf_reset();

	endfunction

	
	function int unique_randomize (int start_range, int stop_range, int set_size);

		//static int queue[]	;
		int i = 0			;
		int flag	= 0		;
		int data			;
		int size			;
		int rand_data		;
		static int check_size		;

		if (start_range < stop_range) begin
			int temp;
			temp = start_range;
			start_range = stop_range;
			stop_range = temp;
		end
		size = start_range - stop_range;
		if(set_size) begin
		queue = new[size];
		//static int queue[]	;
		end
		else begin
		

			rand_data = $urandom_range(start_range,stop_range);
			for (int j = 0; j < i; j++) begin
				if (rand_data == queue[j]) begin
						flag = 1;
				end
			end
			if (flag == 0) begin
				queue[i] = rand_data;
				data = rand_data;
				i++;
			end
		end
		return (data);

	endfunction




	task wait_on (ref int diff_counter);

		#(WAIT_DELAY);

		wait(diff_counter == 0);

	endtask

	task wait_for_charater_trasnmission();

		repeat(	`CHAR_LENGTH		*		BAUD_SAMPLE_CYCLES	)	begin

			@(u_uart_intf.uart_intf_rx_pos);

		end

	endtask

	task pclk_wait_states(int cycles);
		
		repeat(cycles) begin
			@(u_apb_intf.apb_intf_pos);
		end

	endtask

















endclass

		
		

