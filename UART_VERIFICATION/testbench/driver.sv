
class Driver;

	virtual Apb_Interface  	u_apb_intf		;
	virtual Uart_Interface 	u_uart_intf		;
	virtual Event_Interface u_event_intf	;
	Apb_Driver				u_apb_driver	;
	`MODULE_REGMAP			regmap			;
	mailbox #(Stimulus)		mbx				;
	Stimulus				sti				;
	static int						drv_counter		;
 	semaphore 				apb_pass		;
	mailbox #(int)			uart_drv_mbx	;
	uart_driver				u_uart_driver	;
	//int read_status_count = 1				;
	int dummy_read;
//	bit sema_flag;


	function new (

		virtual Apb_Interface u_apb_intf		,
		virtual Uart_Interface	u_uart_intf		,
		virtual Event_Interface	u_event_intf	,
		`MODULE_REGMAP	regmap					,
		mailbox #(Stimulus)		mbx				,
		mailbox #(int)		uart_drv_mbx

		);

		this.u_apb_intf		=		u_apb_intf							;
		this.u_uart_intf	=		u_uart_intf							;
		this.u_event_intf	=		u_event_intf						;
		this.regmap			=		regmap								;
		this.mbx			=		mbx									;
		this.uart_drv_mbx	=		uart_drv_mbx						;
		u_apb_driver		=		new(u_apb_intf.apb_driver)			;
		u_uart_driver		=		new(u_uart_intf,	u_event_intf,	regmap,	uart_drv_mbx);
		apb_pass	 		= 		new(1);


	endfunction


	task start(ref int diff_counter);
	
	fork
		u_apb_driver.start();
		u_uart_driver.start();
		event_request_read();
	join_any
		
		do
			begin
				@(u_apb_intf.apb_intf_pos);
				sequencer(diff_counter);
			end
		while(u_event_intf.signal_test_finish !== 1); //TBD: create from test_end event
		#100 $finish;

	endtask

	task event_request_read();
	bit [PDATA_WIDTH-1:0] status_addr	;
		fork
			forever@(u_event_intf.read_status_event) begin
			u_event_intf.dummy_cnt++;
				status_addr	=	u_apb_intf.PADDR;
				if(u_event_intf.read_status_count == 0) begin
					u_event_intf.read_status_count++;
					reg_read(status_addr);
				end
				else #1 u_event_intf.read_status_count=0;
			end
			forever@(u_event_intf.lsr_read_stat_reg) begin
					reg_read(LSR_ADDR);
			end
			forever@(u_event_intf.iir_read_stat_reg) begin
					reg_read(IIR_ADDR);
			end
		join
			
	endtask



	task automatic reg_read (	bit [PADDR_WIDTH - 1 : 0] addr );
		
		apb_pass.get(1);
		u_event_intf.sema_flag	=	1'b1;	

		u_apb_driver.apb_read(addr);

		apb_pass.put(1);
		u_event_intf.sema_flag	=	1'b0;	
		#1;

	endtask



	task automatic reg_write (
				bit [PADDR_WIDTH - 1 : 0] addr,
				bit [PDATA_WIDTH - 1 : 0] data
		);

		apb_pass.get(1);

		u_apb_driver.apb_write(addr,	data);

		apb_pass.put(1);

	endtask



	task sequencer (ref int diff_counter);
	
	 if(diff_counter !== 0) begin
		for(int i=0; i<diff_counter; i++)
			begin
				$display("\n\n\n\n~~~~~~~~~~~~~~ DIFF COUNTER = %d~~~~~~~~~~~~~~~~\n",diff_counter);
				i = 0;
				@(u_apb_intf.apb_intf_neg);
				//u_event_intf.read_status_count = 0;
				mbx.get(sti);
				$display("Driver counter = %d",drv_counter,$time);
				//read_write( 1, data_packet.addr, data_packet.data, data_packet.we_i, intf.ACK_o, data_packet.stb_i, data_packet.cyc_i);
				if (sti.presetn === 1'b0)
					u_apb_driver.reset();
				else if (sti.pwrite === 1'b1)
					reg_write(sti.paddr,	sti.pdata);
				else if(sti.pwrite === 1'b0)
					reg_read(sti.paddr);
				drv_counter = drv_counter+1;

			end
		end

	endtask : sequencer



endclass 
