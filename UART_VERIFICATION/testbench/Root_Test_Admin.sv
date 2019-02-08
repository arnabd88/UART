class Root_Test_Admin;

	static Root_Test_Admin 		root_test;
	static int 					test_cnt;

	virtual Apb_Interface 		u_apb_intf;
	virtual Uart_Interface 		u_uart_intf;
	virtual Event_Interface 	u_event_intf;
	mailbox #(Stimulus) 		mbx;
	mailbox #(int)			uart_drv_mbx	;
	`MODULE_REGMAP				regmap	;

	uart_test					test;
	uart_test					reset_test;
	static int 				queue[]			;



	protected function new	(

		virtual Apb_Interface 	u_apb_intf		,
		virtual Uart_Interface 	u_uart_intf		,
		virtual Event_Interface	u_event_intf	,
		ref `MODULE_REGMAP 			regmap	,
		mailbox #(Stimulus)		mbx				,
		mailbox #(int)			uart_drv_mbx

	);

		this.regmap 		= 	regmap;
		this.u_apb_intf 	= 	u_apb_intf;
		this.u_uart_intf 	= 	u_uart_intf;
		this.u_event_intf	=	u_event_intf;
		this.mbx 			= 	mbx;
		this.uart_drv_mbx	=	uart_drv_mbx	;
	
endfunction

	static task start (
		
		virtual Apb_Interface 	u_apb_intf	,
		virtual Uart_Interface 	u_uart_intf	,
		virtual Event_Interface	u_event_intf,
		ref `MODULE_REGMAP		regmap		,
		mailbox #(Stimulus) 	mbx			,
		ref int diff_counter				,
		mailbox #(int)		uart_drv_mbx

	);

		if(root_test == null)	begin
			root_test	=	new(u_apb_intf,	u_uart_intf, u_event_intf,	regmap, mbx, uart_drv_mbx);
			test_cnt++;
			messagef(HIGH,	INFO,	`HIERARCHY,	$sformatf("ROOT_TEST_ADMIN OBJECT ALIVE"))	;
		end
		else	messagef(HIGH,	INFO,	`HIERARCHY,	$sformatf("REDUNDANT TRY to ANOTHER ROOT_TEST_ADMIN.\n\tROOT_TEST_ADMIN ALREADY ACTIVE"))	;
		//else	$display ("TEST-ENVIRONMENT ACTIVE !!");
		
		if(root_test !== null && test_cnt === 1)	
			root_test.trigger(diff_counter);
		//else	$display("Root_Test_Admin: Redundant Trigger Call. INVESTIGATE !!!! -> ",$realtime); 
		else	messagef(LOW, INFO, `HIERARCHY, $sformatf("Root_Test_Admin: Redundant Trigger Call"));

		//wait(u_event_intf.Simulation_End.triggered);
			root_test.test.test_finish();
	endtask : start


	task trigger(ref int diff_counter);

	int source_clock_count;
	int random_object_id	;

	while(source_clock_count < 3)	begin
		set_clock_source(source_clock_count);
		source_clock_count++	;
		unique_randomize(1,MAX_TEST_COUNT,1);
		random_object_id	=	0;
		reset_test	=	new(u_apb_intf, u_uart_intf, u_event_intf,	regmap, mbx,	uart_drv_mbx, random_object_id);
		reset_test.start(diff_counter);

		repeat(MAX_TEST_COUNT) begin
			 @(u_uart_intf.uart_intf_tx_pos);
			 @(u_uart_intf.uart_intf_tx_pos);

			if(diff_counter !== 0)
				wait(diff_counter == 0);
				random_object_id	=	(unique_randomize(1,MAX_TEST_COUNT,0) % (TEST_COUNT+1));
			  test	=	new(u_apb_intf, u_uart_intf, u_event_intf,	regmap, mbx,	uart_drv_mbx, random_object_id);
			    fork
			    	root_test.test.start(diff_counter);
			    join
		end
		root_test.test.clear_queue();
		messagef (LOW, INFO, `HIERARCHY, $sformatf("CLEARING QUEUE"));
		$display("CLEARING QUEUE",$time);
	end
			
		-> u_event_intf.Simulation_End ;

	endtask

	function void set_clock_source (bit[1:0] set_clock);

		if(	set_clock == 0	)	u_event_intf.clock_type	=	CLOCK1	;
		if(	set_clock == 1	)	u_event_intf.clock_type	=	CLOCK2	;
		if(	set_clock == 2	)	u_event_intf.clock_type	=	CLOCK3	;
		if(	set_clock == 3	)	u_event_intf.clock_type	=	CLOCK1	;

		-> u_event_intf.change_source_clock	;

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



		 	
endclass
		

