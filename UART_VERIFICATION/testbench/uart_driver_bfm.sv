


class uart_driver	;

	`MODULE_REGMAP						regmap			;
	mailbox #(int)						uart_drv_mbx	;
	virtual	Uart_Interface				u_uart_intf		;
	virtual Event_Interface				u_event_intf	;
	int 								frame_number	;
	bit [ 0 : `MAX_FRAME_SIZE - 1 ]		frame			;
	bit [ `MAX_FRAME_SIZE - 1 - 4 : 0 ]	new_data		;
	bit									do_err_inject	;
	int									err_position	;
	bit 								par_val			;
	static int 							cyc_err_pos		;
	bit 								temp_sRX=1		;

	function new	(

		virtual Uart_Interface	u_uart_intf		,
		virtual	Event_Interface	u_event_intf	,
		`MODULE_REGMAP			regmap			,
		mailbox	#(int)		uart_drv_mbx	

		);

		this.u_uart_intf	=	u_uart_intf		;
		this.u_event_intf	=	u_event_intf	;
		this.regmap			=	regmap			;
		this.uart_drv_mbx	=	uart_drv_mbx	;

	endfunction


	task start();

		uart_initialize();
	
		fork
		frame_transmit();
		assign_sRX();
		join

	endtask

	task frame_transmit();

		//while (u_event_intf.signal_test_finish !== 1)	
		int i	;
		int frame_cnt	;
		do
			begin

				@(	u_event_intf.start_transmit_frm_BFM	); //wait for event from testcase to start transmission

				uart_drv_mbx.get(frame_number);
					frame_cnt = 0;
				repeat(frame_number) begin
					frame_cnt++	;
					$display("FRAME_COUNT = %d",frame_cnt,$time);

					new_data	=	$random();
					par_val		=	0	;
					frame		=	{`MAX_FRAME_SIZE{1'b1}}	;
					for(int i=0	;	i<(`CHARL+5) ;	i++	)	par_val	=	par_val ^ new_data[i]	;
//					par_val		=	^new_data[(`CHARL+5) -1 : 0]	;
					//----- Create frame
					$display("PAR_VAL = %b",par_val,$time);
					if(	`PAR_EN === 1'b1	)	begin
					//		frame	=	{1'b0,	new_data[(`CHARL+5)	-1:0],	~(`PAR_SEL ^ par_val),	1}	;
							frame[0]		=	1'b0	;	//start-bit
							for(i=0;	i<(`CHARL+5) ; i++ )	begin
								frame[i+1]	=	new_data[i]	;
							end
							frame[i+1]	=	~(`PAR_SEL ^ par_val);
							$display("PAR_FRAME = %b\ni = %d",frame[i+1],i,$time);
//							frame[i+2 : `MAX_FRAME_SIZE]	=	1;
					end
					else	begin
							//frame	=	{1'b0,	new_data[(`CHARL+5)	-1:0],	1}	;
							frame[0]		=	1'b0	;	//start-bit
							for(i=0;	i<(`CHARL+5) ; i++ )	begin
								frame[i+1]	=	new_data[i]	;
							end
//							frame[i+1 : `MAX_FRAME_SIZE]	=	1;
					end

/*deb*/				//do_err_inject	=	$urandom_range(0,4)	>> 2;
/*deb*/				if(u_event_intf.start_data_error_injection == 'b1) begin
/*deb*/				  	//frame [err_position + 1]	=	~frame[err_position + 1];
/*deb*/				  	frame [err_position]	=	~frame[err_position];
/*deb*/				  	err_position++	;
/*deb*/				  	if(err_position >= (`CHARL+5) + `PAR_EN + `STOP + 1)	err_position = 0;
/*deb*/				end

					start_transmit(frame, ~do_err_inject);
				end

			end
		while (u_event_intf.signal_test_finish !== 1)	;

	endtask

	task start_transmit (
		
		bit [ 0 : `MAX_FRAME_SIZE - 1 ]		CHARACTER	,
		bit 							inject_error

		)	;

		//int cyc_err_pos		;
	//	bit inject_error	;

		int stop	;
		int CHARACTER_FRAME_TIME	;

		if(`STOP)	begin
			if(	`CHARL	===	2'b00	)	stop	=	1.5	;
			else						stop	=	2	;
		end
		else						stop	=	1	;

		//CHARACTER_FRAME_TIME	=	1 + (`CHARL + 5) + `PAR_EN + stop	;
		CHARACTER_FRAME_TIME	=	`CHAR_LENGTH	;
		$display ("CHARACTER FRAME TIME = %d",CHARACTER_FRAME_TIME,$time);
		$display ("CHARACTER LENGTH = %b",`CHARL,$time);

		for (int tx_bit_index=0	;	tx_bit_index	<	CHARACTER_FRAME_TIME	;	tx_bit_index++)	begin

				//u_uart_intf.sRX	=	CHARACTER[	tx_bit_index	];
				temp_sRX	=	CHARACTER[	tx_bit_index	];
				//if (u_event_intf.start_cyclic_error_injection == 1) begin

			//	inject_error	=	$random();

				 if((u_event_intf.start_cyclic_error_injection == 'b1) && (tx_bit_index!== 0))	begin
				 	count_clks(	cyc_err_pos+1	);
				 	u_uart_intf.sRX	=	~u_uart_intf.sRX	;
				 	count_clks(BAUD_SAMPLE_CYCLES - cyc_err_pos -1);
				 	cyc_err_pos = cyc_err_pos + 1	;
				 	if(	cyc_err_pos === BAUD_SAMPLE_CYCLES)	cyc_err_pos	=	0;
				 end
				else
					count_clks(BAUD_SAMPLE_CYCLES);
			// end
		end

	endtask

	task assign_sRX();

		forever@(temp_sRX,u_event_intf.set_break)	begin
			u_uart_intf.sRX	=	temp_sRX & ~u_event_intf.set_break	;
		end

	endtask



	
	task count_clks ( int sample_cycles);
		repeat(sample_cycles) begin
			@(u_uart_intf.uart_intf_rx_pos);
		end
	endtask


			
	task uart_initialize();

		u_uart_intf.sRX	<=	1'b1	;
		u_uart_intf.sTX	<=	1'b1	;

	endtask

endclass

