

class uart_test;

	
	virtual Apb_Interface 		u_apb_intf;
	virtual Uart_Interface 		u_uart_intf;
	virtual Event_Interface		u_event_intf;
	mailbox #(Stimulus) 		mbx;
	mailbox #(int)		uart_drv_mbx	;
	`MODULE_REGMAP				regmap	;
	static int 					obj_queue[$];
	bit[2:0]					obj_cnt;

	int random_object_id					;

//-------------------  TEST LIST ---------------------------
		generic_test			test_generic	;
	`ifdef UART_FRAME_TEST
		uart_frame_transmit 			test_uart_frame_transmit;
	`endif

	`ifdef UART_THRE_INTERRUPT_TEST
		uart_THRE_interrupt_test		test_uart_THRE_interrupt_test;
	`endif

	`ifdef UART_TIMEOUT
		uart_timeout_test			test_uart_timeout_test	;
	`endif

	`ifdef UART_MODEM_CONTROL
		uart_modem_control		test_uart_modem_control	;
	`endif

	`ifdef UART_LOOPBACK
		uart_loopback			test_uart_loopback	;
	`endif

	`ifdef UART_MODE0
		uart_mode0				test_uart_mode0		;
	`endif

	`ifdef UART_MODE1
		uart_mode1				test_uart_mode1		;
	`endif
	`ifdef UART_BRAKE_INTR_CHECK
		uart_brake_intr_check	test_uart_brake_intr_check	;
	`endif
	`ifdef UART_ERROR_INJECTION_TC
		uart_error_injection_tc	test_uart_error_injection_tc	;
	`endif
	`ifdef UART_RCVR_TRIGGER_INTR_CHECK
		uart_rcvr_trigger_intr_check	test_uart_rcvr_trigger_intr_check	;
	`endif
	`ifdef UART_OVERRUN_CHECK
		uart_overrun_check		test_uart_overrun_check		;
	`endif

	`ifdef UART_IIR_TRANS_COV
		uart_iir_trans_cov		test_uart_iir_trans_cov		;
	`endif
//----------------------------------------------------------


	function new	(

		virtual Apb_Interface 	u_apb_intf		,
		virtual Uart_Interface 	u_uart_intf		,
		virtual Event_Interface	u_event_intf	,
		ref `MODULE_REGMAP 		regmap	,
		mailbox #(Stimulus)		mbx				,
		mailbox #(int)		uart_drv_mbx		,
		int random_object_id
	);

		this.regmap 		= 	regmap;
		this.u_apb_intf 	= 	u_apb_intf;
		this.u_uart_intf 	= 	u_uart_intf;
		this.u_event_intf	=	u_event_intf;
		this.mbx 			= 	mbx;
		this.uart_drv_mbx	=	uart_drv_mbx	;
		obj_cnt				=	$random();
		this.random_object_id	=	random_object_id	;
		$display("random_object_id=%d",random_object_id, $time);
		obj_queue.push_back(random_object_id);
		if(obj_queue.size() <= MAX_TEST_COUNT)
			create_test_object(random_object_id);
		else begin
			messagef(LOW, INFO, `HIERARCHY, $sformatf("TEST COUNT EXCEEDED MAX TEST SIZE"));
			messagef(LOW, INFO, `HIERARCHY, $sformatf("MAX_TEST_COUNT = %d ",MAX_TEST_COUNT));
		end			

	endfunction

	static task clear_queue();

		do
			begin
				obj_queue.pop_front();
			end
		while( obj_queue.size() !== 0);

	endtask



	function create_test_object	(	int test_index);
		
		if(test_index == 0) begin
				test_generic					=	new(regmap, mbx, uart_drv_mbx,	u_apb_intf, u_uart_intf, u_event_intf);
		end
		else if(test_index == 1) begin
			`ifdef UART_FRAME_TEST
				test_uart_frame_transmit		=	new(regmap, mbx, uart_drv_mbx,	u_apb_intf, u_uart_intf, u_event_intf);
			`endif
		end
		else if(test_index == 2) begin
			`ifdef UART_THRE_INTERRUPT_TEST
				test_uart_THRE_interrupt_test	=	new(regmap, mbx, uart_drv_mbx, u_apb_intf, 	u_uart_intf, u_event_intf);
			`endif
		end
		else if(test_index == 3) begin
				messagef(LOW, INFO, `HIERARCHY, $sformatf("Generating Timeout Testcase Object"));
			`ifdef UART_TIMEOUT
				test_uart_timeout_test			=	new(regmap, mbx, uart_drv_mbx, u_apb_intf,	u_uart_intf, u_event_intf);
				messagef(LOW, INFO, `HIERARCHY, $sformatf("Created Timeout Testcase Object"));
			`endif
		end
		else if(test_index == 4) begin
			`ifdef UART_MODEM_CONTROL
				test_uart_modem_control			=	new(regmap, mbx, uart_drv_mbx, u_apb_intf,	u_uart_intf, u_event_intf);
			`endif
		end
		else if(test_index == 5) begin
			`ifdef UART_LOOPBACK
				test_uart_loopback				=	new(regmap, mbx, uart_drv_mbx, u_apb_intf,	u_uart_intf, u_event_intf);
			`endif
		end
		else if(test_index == 6) begin
			`ifdef UART_MODE0
				test_uart_mode0					=	new(regmap, mbx, uart_drv_mbx, u_apb_intf, u_uart_intf, u_event_intf);
			`endif
		end
		else if(test_index == 7) begin
			`ifdef UART_MODE1
				test_uart_mode1					=	new(regmap, mbx, uart_drv_mbx, u_apb_intf, u_uart_intf, u_event_intf);
			`endif
		end
		else if(test_index == 8) begin
			`ifdef UART_BRAKE_INTR_CHECK
				test_uart_brake_intr_check		=	new(regmap, mbx, uart_drv_mbx, u_apb_intf, u_uart_intf, u_event_intf);
			`endif
		end
		else if(test_index == 9) begin
			`ifdef UART_ERROR_INJECTION_TC
				test_uart_error_injection_tc	=	new(regmap, mbx, uart_drv_mbx, u_apb_intf, u_uart_intf, u_event_intf);
			`endif
		end
		else if(test_index == 10) begin
			`ifdef UART_RCVR_TRIGGER_INTR_CHECK
				test_uart_rcvr_trigger_intr_check	=	new(regmap, mbx, uart_drv_mbx, u_apb_intf, u_uart_intf, u_event_intf);
			`endif
		end
		else if(test_index == 11) begin
			`ifdef UART_OVERRUN_CHECK
				test_uart_overrun_check				=	new(regmap, mbx, uart_drv_mbx, u_apb_intf, u_uart_intf, u_event_intf);
			`endif
		end
		else if(test_index == 12) begin
			`ifdef UART_IIR_TRANS_COV
				test_uart_iir_trans_cov				=	new(regmap, mbx, uart_drv_mbx, u_apb_intf, u_uart_intf, u_event_intf);
			`endif
		end
		else begin
		//	-> u_event_intf.test_end ;
		end

	endfunction

	task start(ref int diff_counter);
		messagef(LOW, INFO, `HIERARCHY, $sformatf("START: Inside UART_TEST\t random_object_id=%d",random_object_id));
		$display("QUEUE_SIZE = %d", obj_queue.size(), $time);
		if(obj_queue.size() <= MAX_TEST_COUNT) begin
		u_event_intf.test_num	=	random_object_id	;
			if(random_object_id == 0) begin
				test_generic.start(diff_counter);
			end
			else if(random_object_id == 1) begin
				`ifdef UART_FRAME_TEST
				$display("UART_FRAME_TRANSMIT -> ", $time);
					test_uart_frame_transmit.start(diff_counter);
				`endif
			end
			else if(random_object_id == 2) begin
				`ifdef UART_THRE_INTERRUPT_TEST
					test_uart_THRE_interrupt_test.start(diff_counter);
				`endif
			end
			else if(random_object_id == 3) begin
				`ifdef UART_TIMEOUT
					test_uart_timeout_test.start(diff_counter);
				`endif
			end
			else if(random_object_id == 4) begin
				`ifdef UART_MODEM_CONTROL
						test_uart_modem_control.start(diff_counter);
				`endif
			end
			else if(random_object_id == 5) begin
				`ifdef UART_LOOPBACK
						test_uart_loopback.start(diff_counter);
				`endif
			end
			else if(random_object_id == 6) begin
				`ifdef UART_MODE0
						test_uart_mode0.start(diff_counter);
				`endif
			end
			else if(random_object_id == 7) begin
				`ifdef UART_MODE1
						test_uart_mode1.start(diff_counter);
				`endif
			end
			else if(random_object_id == 8) begin
				`ifdef UART_BRAKE_INTR_CHECK
						test_uart_brake_intr_check.start(diff_counter);
				`endif
			end
			else if(random_object_id == 9) begin
				`ifdef UART_ERROR_INJECTION_TC
						test_uart_error_injection_tc.start(diff_counter);
				`endif
			end
			else if(random_object_id == 10) begin
				`ifdef UART_RCVR_TRIGGER_INTR_CHECK
					test_uart_rcvr_trigger_intr_check.start(diff_counter);
				`endif
			end
			else if(random_object_id == 11) begin
				`ifdef UART_OVERRUN_CHECK
					test_uart_overrun_check.start(diff_counter);
				`endif
			end
			else if(random_object_id == 12) begin
				`ifdef UART_IIR_TRANS_COV
					test_uart_iir_trans_cov.start(diff_counter);
				`endif
			end
			else begin
			$display("1. APB_CLOCK", $time);
				@(u_apb_intf.apb_intf_pos);
				
			$display("2. APB_CLOCK", $time);
				-> u_event_intf.test_end ;
			$display("3: Inside UART_TEST", $time);
			end
		end


	endtask


	task test_finish();
		$display("4: Inside UART_TEST", $time);
		-> u_event_intf.finish_test ;
		// Sequence ending packet
	endtask


endclass

	

