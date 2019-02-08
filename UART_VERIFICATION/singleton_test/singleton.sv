class MODULE_REGMAP;
endclass


class Uart_Env;

	static Uart_Env single_uart_env;
	static int obj_cnt;
	MODULE_REGMAP regmap;

	protected function new(MODULE_REGMAP regmap);
		this.regmap = regmap;
	endfunction

	static function void print();
		$display("OBJECT COUNT = %d",obj_cnt,$time);
	endfunction

	static function void end_env();
		single_uart_env = null;
	endfunction
		

	static task start(
				MODULE_REGMAP regmap
	);
		if(single_uart_env == null) begin
			single_uart_env = new(regmap);
			obj_cnt++;
		end
		else	$display("UART Environment Already Alive !!");

	endtask : start

endclass
		


module test();
	MODULE_REGMAP regmap;
	UART_ENV uart_env;

	initial begin
		regmap = new();
		Uart_Env::start(regmap);
		Uart_Env::print();
		#10;
		Uart_Env::start(regmap);
		Uart_Env::print();
		#10;
		Uart_Env::end_env();
		Uart_Env::print();
		#10;
		Uart_Env::start(regmap);
		Uart_Env::print();


	end

endmodule


