
class generator ;

	Stimulus sti;
	mailbox #(Stimulus) mbx;
	static int gen_counter;
	virtual Apb_Interface u_apb_intf;

	function new	(	
			mailbox #(Stimulus) mbx				,
			virtual Apb_Interface u_apb_intf	
		);

		this.mbx 			=		mbx;
		this.u_apb_intf		=		u_apb_intf	;

	endfunction
		

	
	function void put_packet();
		sti = new();
		mbx.put(sti);
		gen_counter = gen_counter + 1;
		$display("GEN_COUNTER = %d",gen_counter,$time);
	endfunction : put_packet



	task reset_por();
		@(u_apb_intf.apb_intf_pos);
		u_apb_intf.PRESETn <= 1'b0;
		u_apb_intf.PSEL <= 1'b0;
		u_apb_intf.PENABLE <= 1'b0;
		@(u_apb_intf.apb_intf_pos);
		u_apb_intf.PRESETn <= 1'b1;
	endtask : reset_por



	function void generate_write_packet (bit[PADDR_WIDTH-1:0] reg_addr, bit[PDATA_WIDTH-1:0] pass_data, bit[PDATA_WIDTH-1:0] mask, bit dir_mode_sel, bit dir_mode_val);
		put_packet();
		$display("Data = %b",pass_data, $time);
		$display("Mask = %b",mask, $time);
		sti.randomize() with
			{
				presetn == 1'b1;
				paddr	==	reg_addr;
				pwrite == 1'b1;
			};
		$display("config Data = %b",sti.pdata,$time);
		sti.pdata = ((sti.pdata | ~mask) & (pass_data | mask));
		if(dir_mode_sel) sti.dir_mode = dir_mode_val;
		$display("config Data = %b",sti.pdata,$time);
	endfunction	: generate_write_packet



	//task generate_read_packet (bit[PADDR_WIDTH-1:0] reg_addr, bit[PDATA_WIDTH-1:0] pass_data);
	function void generate_read_packet (bit[PADDR_WIDTH-1:0] reg_addr);
		put_packet();
		sti.randomize() with
			{
				presetn == 1'b1;
				paddr == reg_addr;
				pwrite == 1'b0;
			};
	endfunction	: generate_read_packet



	function void generate_reset_packet();
		put_packet();
		sti.randomize() with
			{
				presetn	==	1'b0;
			};
	endfunction	: generate_reset_packet



endclass
		
