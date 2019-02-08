
interface Event_Interface();

	event start_test				;
	event Simulation_End			;
	event test_end					;
	event finish_test				;
	event init_regmap				;
	event env_start					;


	event change_source_clock		;
	event BR_TRIGGER				;

	event start_timeout				; // transmit 4 more packets
	event start_transmit_frm_BFM	; //tells the BFM to start transmitting depending on trigger-level

	event	read_status_event		;

	event lsr_read_stat_reg			;
	event stop_detect				;
	event iir_read_stat_reg			;

	bit signal_test_finish;

	int read_status_count=1;

	bit sema_flag;

	int dummy_cnt;
	bit start_data_error_injection;
	
	bit start_cyclic_error_injection;

	// int BAUD_VALUE = 50	;

	CLOCK_TYPE	clock_type = CLOCK1	;	
	int test_num	;

	bit [PDATA_WIDTH-1:0]	lcr_intf	;
	bit [PDATA_WIDTH-1:0]	lsr_intf	;

	bit set_break						;
	bit tx_start						;
	bit rx_start						;
	//modport regmap_mirror (input lcr_intf, lsr_intf);



	always@(finish_test)	signal_test_finish <= 1'b1;

endinterface

