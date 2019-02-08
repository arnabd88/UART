

class Uart_Env;

	static Uart_Env single_uart_env;
	static int obj_cnt;
	`MODULE_REGMAP regmap;
	//Apb_Driver u_apb_driver;
	Driver	u_drvr;
	virtual Apb_Interface u_apb_intf;
	virtual Uart_Interface u_uart_intf;
	virtual Event_Interface u_event_intf;
	//int diff_counter;
	mailbox #(Stimulus) mbx;
	mailbox #(int)	uart_drv_mbx	;

	protected function new(
		virtual Apb_Interface u_apb_intf		, 
		virtual Uart_Interface u_uart_intf		,
		virtual Event_Interface u_event_intf	,
		mailbox #(Stimulus) mbx					,
		`MODULE_REGMAP regmap					,
		mailbox #(int)	uart_drv_mbx
	);
		this.regmap 		= 	regmap			;
		this.u_apb_intf 	= 	u_apb_intf		;
		this.u_uart_intf 	= 	u_uart_intf		;
		this.u_event_intf	=	u_event_intf	;
		//this.diff_counter	=	diff_counter	;
		this.mbx			=	mbx				;
		this.uart_drv_mbx	=	uart_drv_mbx	;
		u_drvr				=	new(u_apb_intf, u_uart_intf, u_event_intf, regmap, mbx,	uart_drv_mbx);
		//u_apb_driver		=	new(u_apb_intf.apb_driver);

	endfunction
		

	static function void print();
		$display("OBJECT COUNT = %d",obj_cnt,$time);
	endfunction


	static function void end_env();
		single_uart_env = null;
	endfunction
		

	static task start(
				virtual Apb_Interface u_apb_intf		,
				virtual Uart_Interface u_uart_intf		, 
				virtual Event_Interface u_event_intf	,
				ref int diff_counter					,
				mailbox #(Stimulus) mbx					,
				ref `MODULE_REGMAP regmap				,
				mailbox #(int)		uart_drv_mbx
	);
		if(single_uart_env == null) begin
			single_uart_env = new(u_apb_intf, u_uart_intf, u_event_intf, mbx, regmap, uart_drv_mbx);
			obj_cnt++;
		end
		else	$display("UART Environment Already Alive !!");
		
		if(single_uart_env !== null && obj_cnt === 1)	
		//	u_drvr.start();
			//single_uart_env.trigger();
			single_uart_env.u_drvr.start(diff_counter);
		else	$display("Root_Test_Admin: Redundant Trigger Call. INVESTIGATE !!!! -> ",$realtime); 


	endtask : start

	//local task trigger;
	//	u_drvr.start();
	//endtask

endclass
		
		
