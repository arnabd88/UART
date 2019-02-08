

class generic_seqlib ;

	Stimulus sti;
	mailbox #(Stimulus) mbx;

	function new(mailbox #(Stimulus) mbx));
		this.mbx = mbx;
	endfunction
		

	
	virtual task put_packet();
		sti = new();
		mbx.put(sti);
		gen_counter = gen_counter + 1;
	endtask


		
