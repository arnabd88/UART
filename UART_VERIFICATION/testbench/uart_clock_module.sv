//------------------------------------------------------------------------
//----------------------- CLOCK GENERATION MODULE ------------------------
//------------------------------------------------------------------------
//------------------------- F1	=	1.8432 MHZ ---------------------------
//------------------------- F2	=	3.072  MHZ ---------------------------
//------------------------- F3	=	18.432 MHZ ---------------------------
//------------------------------------------------------------------------
//------------------------------------------------------------------------



module Uart_Clock_Module(
		Apb_Interface	u_apb_intf		,
		Event_Interface u_event_intf	,
		output BR_CLK
	);

	parameter 	freq_1_8432_M	 	= 	(1000/1.8432)	;

	parameter	freq_3_072_M		=	(1000/3.072)	;

	parameter	freq_18_432_M		=	(1000/18.432)	;

	CLOCK_TYPE prev_clock_type	= CLOCK1				;



	reg  BR_CLK	;

//	int rand_freq_sel = 0	;
//	int prev_rand_freq_sel = 1	;
	time base_freq	= freq_1_8432_M;
	reg stop_clk	=	1'b1;

	initial begin
		BR_CLK = 1'b1;
//		-> u_event_intf.change_source_clock	;
	end

	 always@(u_event_intf.change_source_clock) begin



	 		if(	 u_event_intf.clock_type	==	CLOCK1	) begin
	 			if(~stop_clk)	@(posedge BR_CLK) ;
	 			stop_past_clk(prev_clock_type);
	 			#(base_freq/2) ; // wait for clock synchronization
	 			base_freq	=	freq_1_8432_M	;
	 			stop_clk	=	1'b0	;
	 			fork
	 				gen_freq_1_8432_M();
	 			join_none
	 				@(u_apb_intf.apb_intf_pos);
	 				-> u_event_intf.BR_TRIGGER;
	 		end
	 		else if(	u_event_intf.clock_type == CLOCK2 ) begin
	 			if(~stop_clk)	@(posedge BR_CLK) ;
	 			stop_past_clk(prev_clock_type);
	 			#(base_freq/2)	;	//	wait for clock synchronization
	 			base_freq	=	freq_3_072_M	;
	 			stop_clk	=	1'b0	;
	 			fork
	 				gen_freq_3_072_M();
	 			join_none
	 				@(u_apb_intf.apb_intf_pos);
	 				-> u_event_intf.BR_TRIGGER;
	 		end
	 		else if(	u_event_intf.clock_type == CLOCK3 ) begin
	 			if(~stop_clk)	@(posedge BR_CLK) ;
	 			stop_past_clk(prev_clock_type);
	 			#(base_freq/2)	;	//	wait for clock synchronization
	 			base_freq	=	freq_18_432_M	;
	 			stop_clk	=	1'b0	;
	 			fork
	 				gen_freq_18_432_M();
	 			join_none
	 				@(u_apb_intf.apb_intf_pos);
	 				-> u_event_intf.BR_TRIGGER;
	 		end

	 		prev_clock_type = u_event_intf.clock_type;

	 end


		
		
		


	task stop_past_clk(CLOCK_TYPE prev_freq);
	  if(~stop_clk) begin
		if(prev_freq == CLOCK1) disable gen_freq_1_8432_M;
		else if(prev_freq == CLOCK2) disable gen_freq_3_072_M;
		else if(prev_freq == CLOCK3) disable gen_freq_18_432_M;
		stop_clk	=	1'b1	;
	  end
	endtask
	

	task gen_freq_1_8432_M ();
	fork
		forever@(u_event_intf.BR_TRIGGER) begin
			#	((freq_1_8432_M)/2)	BR_CLK	=	~BR_CLK	;
		end
		forever@(BR_CLK)	-> u_event_intf.BR_TRIGGER	;
	join
	endtask
	

	task gen_freq_3_072_M ();
	fork
		forever@(u_event_intf.BR_TRIGGER) begin
			#	((freq_3_072_M)/2)	BR_CLK	=	~BR_CLK	;
		end
		forever@(BR_CLK)	-> u_event_intf.BR_TRIGGER	;
	join
	endtask
	

	task gen_freq_18_432_M ();
	fork
		forever@(u_event_intf.BR_TRIGGER) begin
			#	((freq_18_432_M)/2)	BR_CLK	=	~BR_CLK	;
		end
		forever@(BR_CLK)	-> u_event_intf.BR_TRIGGER	;
	join
	endtask


	// always@(u_event_intf.change_source_clock) begin
	// $display(" I am here ", $time);

	// 		while (rand_freq_sel == prev_rand_freq_sel) begin
	// 			rand_freq_sel	=	$urandom_range(2);
	// 		end


	// 		if(	 rand_freq_sel == 0	) begin
	// 			if(~stop_clk)	@(posedge BR_CLK) ;
	// 			stop_past_clk(prev_rand_freq_sel);
	// 			#(base_freq/2) ; // wait for clock synchronization
	// 			base_freq	=	freq_1_8432_M	;
	// 			stop_clk	=	1'b0	;
	// 			fork
	// 				gen_freq_1_8432_M();
	// 			join_none
	// 				@(u_apb_intf.apb_intf_pos);
	// 				-> u_event_intf.BR_TRIGGER;
	// 		end
	// 		else if(	rand_freq_sel == 1 ) begin
	// 			if(~stop_clk)	@(posedge BR_CLK) ;
	// 			stop_past_clk(prev_rand_freq_sel);
	// 			#(base_freq/2)	;	//	wait for clock synchronization
	// 			base_freq	=	freq_3_072_M	;
	// 			stop_clk	=	1'b0	;
	// 			fork
	// 				gen_freq_3_072_M();
	// 			join_none
	// 				@(u_apb_intf.apb_intf_pos);
	// 				-> u_event_intf.BR_TRIGGER;
	// 		end
	// 		else if(	rand_freq_sel == 2 ) begin
	// 			if(~stop_clk)	@(posedge BR_CLK) ;
	// 			stop_past_clk(prev_rand_freq_sel);
	// 			#(base_freq/2)	;	//	wait for clock synchronization
	// 			base_freq	=	freq_18_432_M	;
	// 			stop_clk	=	1'b0	;
	// 			fork
	// 				gen_freq_18_432_M();
	// 			join_none
	// 				@(u_apb_intf.apb_intf_pos);
	// 				-> u_event_intf.BR_TRIGGER;
	// 		end

	// 		prev_rand_freq_sel = rand_freq_sel	;

	// end


		
		

endmodule
