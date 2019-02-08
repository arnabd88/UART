
class Stimulus ;

	rand bit [PDATA_WIDTH - 1 : 0] pdata;
	rand bit [PADDR_WIDTH - 1 : 0] paddr;
	rand bit pwrite;
	rand bit presetn;
	rand bit duplex_mode; // Half/Full Duplex
	rand bit dir_mode; // Tx/Rx
	rand bit past_pack_event;

endclass
	
