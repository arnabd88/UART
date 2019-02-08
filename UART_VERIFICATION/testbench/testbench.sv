//`include "MODULE_REGMAP_DUMMY.sv"
// `include "uart_defines.sv"
// `include "fifo.sv"
// `include "generic_rand_addr_gen.sv"
// `include "generic_regbase.sv"
// `include "generic_regmap.sv"
// `include "uart_registers.sv"
// `include "uart_regmap.sv"
// `include "stimulus.sv"
// `include "messagef_pkg.sv"
// `include "apb_interface.sv"
// `include "uart_interface.sv"
// `include "event_interface.sv"
// `include "uart_clock_module.sv"
// `include "monitor.sv"
// `include "uart_tx_bfm.sv"
// `include "uart_rx_bfm.sv"
// `include "generator.sv"
// `include "generic_test.sv"
// `include "apb_driver.sv"
// `include "uart_driver_bfm.sv"
// `include "driver.sv"
// `include "Uart_Env.sv"
// `include "uart_frame_transmit.sv"
// `include "uart_THRE_interrupt_test.sv"
// `include "uart_modem_control.sv"
// `include "uart_loopback.sv"
// `include "uart_timeout_test.sv"
// `include "uart_mode0.sv"
// `include "uart_test.sv"
// `include "Root_Test_Admin.sv"
// `include "uart_checker.sv"


module testbench();


logic PCLK, BR_CLK;
int diff_counter;
mailbox #(Stimulus) mbx;
mailbox #(int)	uart_drv_mbx	;
always@(PCLK) #50 PCLK <= ~PCLK;
// always #5 BR_CLK = ~BR_CLK;
wire [31:0] fifo_top;
event get_counter	;




	Apb_Interface 					u_apb_intf(.PCLK(PCLK));

	Uart_Interface 					u_uart_intf(.BR_CLK(BR_CLK));

	Event_Interface					u_event_intf();

	gh_uart_16550_AMBA_APB_wrapper 	u_duv (
						
									.PCLK(PCLK)  							,  
                                    .PRESETn(u_apb_intf.PRESETn)			,
                                    .PSEL(u_apb_intf.PSEL)					,
                                    .PENABLE(u_apb_intf.PENABLE)			,
                                    .PWRITE(u_apb_intf.PWRITE) 				,
                                    .PADDR(u_apb_intf.PADDR)   				,
                                    .PWDATA(u_apb_intf.PWDATA)  			,
                                    .PRDATA(u_apb_intf.PRDATA)  			,
									.BR_clk(BR_CLK)				,
                                    .sRX(u_uart_intf.sRX)	  				,
                                    .CTSn(u_uart_intf.CTSn)  				,
                                    .DSRn(u_uart_intf.DSRn)  				,
                                    .RIn(u_uart_intf.RIn)   				,
                                    .DCDn(u_uart_intf.DCDn)  				,
                                    .sTX(u_uart_intf.sTX)   				,
                                    .DTRn(u_uart_intf.DTRn)  				,
                                    .RTSn(u_uart_intf.RTSn)  				,
                                    .OUT1n(u_uart_intf.OUT1n) 				,
                                    .OUT2n(u_uart_intf.OUT2n) 				,
                                    .TXRDYn(u_uart_intf.TXRDYn)				,
                                    .RXRDYn(u_uart_intf.RXRDYn)				,
                                    .IRQ(u_uart_intf.IRQ)   				,
                                    .B_CLK(u_uart_intf.B_CLK)

						);

	monitor							u_monitor	(

									.u_apb_intf(u_apb_intf)					,
									.u_uart_intf(u_uart_intf)				,
									.u_event_intf(u_event_intf)

						);


	Uart_Clock_Module				u_ucm		(

									
									.u_apb_intf(u_apb_intf)					,								
									.u_event_intf(u_event_intf)				,
									.BR_CLK(BR_CLK)

						);

	uart_tx_bfm						u_uart_tx_bfm	(						
		
									.u_uart_intf(u_uart_intf)					,
									.u_event_intf(u_event_intf)

						);


	uart_rx_bfm						u_uart_rx_bfm	(

									.u_uart_intf(u_uart_intf)					,
									.u_event_intf(u_event_intf)

						);


	Uart_Checker					u_uart_checker	(
									
									.u_uart_intf(u_uart_intf)					,
									.u_event_intf(u_event_intf)					
						);

	`MODULE_REGMAP regmap;

	msg_verbosity_t	SIM_MODE	;

	initial 
		begin
			@(u_event_intf.init_regmap);
			PCLK = 1'b1;
		    -> u_event_intf.change_source_clock	;
			mbx				=		new();
			uart_drv_mbx	=		new();
			u_uart_intf.regmap_mbx.peek(regmap);
			-> u_event_intf.env_start	;

			set_message_verbosity(DEBUG);
			messagef(HIGH,INFO,`HIERARCHY,$sformatf("TEST-ENVIRONMENT STARTING"));
			fork
				Uart_Env::start(u_apb_intf, u_uart_intf, u_event_intf, diff_counter, mbx, regmap, uart_drv_mbx); // Singleton Env 
				Root_Test_Admin::start(u_apb_intf, u_uart_intf, u_event_intf, regmap, mbx, diff_counter, uart_drv_mbx); // Singleton Root
			join
		end

		initial begin
			@(u_event_intf.env_start);
			forever@(generator::gen_counter-Uart_Env::single_uart_env.u_drvr.drv_counter)
				begin
					//-> get_counter	;
					// diff_counter	=	(generator::gen_counter	-	Uart_Env::single_uart_env.u_drvr.drv_counter);
					// $display("TESTBENCH: DIFF_COUNTER = %d",diff_counter,$time);
				end
		end

		always@(generator::gen_counter, Uart_Env::single_uart_env.u_drvr.drv_counter) begin
			diff_counter	=	(generator::gen_counter	-	Driver::drv_counter);
					$display("TESTBENCH: DIFF_COUNTER = %d",diff_counter,$time);
		end

		//always@(posedge PCLK) 
		//$display("TESTBENCH: GEN_COUNTER = %d",generator::gen_counter,$time);
			

endmodule


