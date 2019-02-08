//========================================================================================================\\
//
//---------------- APB DRIVER FILE -----------------------------------------------------------------------\\
//-------- Defines standard functionalities of the APB interface ( read/write/reset/.. ) -----------------\\
//
//=========================================================================================================\\


class Apb_Driver;

	virtual Apb_Interface.apb_driver apb_intf;

	typedef enum {BYTE=0 , HWRD=1 , WRD=2 } access_size_t;
	//parameter PADDR_WIDTH = 3;
	//parameter PDATA_WIDTH = 8;


//==============================================================
//------------- Constructor Functions -------------------------
//------------- new : links the apb interface -----------------
//==============================================================
	function new(virtual Apb_Interface.apb_driver apb_intf);
		
		this.apb_intf = apb_intf;
	
	endfunction






//==============================================================
//------------- TASK apb_write --------------------------------
//------------- des : writes data across apb interface --------
//-------------		  (no ack from slave)  --------------------
//==============================================================
	task apb_write (
		input logic [PADDR_WIDTH - 1 : 0] addr ,
		input logic [PDATA_WIDTH - 1 : 0] data 
	//	input access_size_t		 access_size_t 
	) ;

	@(apb_intf.apb_intf_pos);

		apb_intf.apb_intf_pos.PSEL 		<= 1'b1;
		apb_intf.apb_intf_pos.PADDR 	<= addr;
		apb_intf.apb_intf_pos.PENABLE 	<= 1'b0;
		apb_intf.apb_intf_pos.PWDATA 	<= data;
		apb_intf.apb_intf_pos.PWRITE 	<= 1'b1;

	@(apb_intf.apb_intf_pos);

		apb_intf.apb_intf_pos.PENABLE 	<= 1'b1;

	@(apb_intf.apb_intf_pos);
		
		apb_intf.apb_intf_pos.PSEL 		<= 1'b0;
		apb_intf.apb_intf_pos.PENABLE 	<= 1'b0;

	endtask : apb_write






//==============================================================
//------------- TASK apb_read ---------------------------------
//------------- des : reads data across apb interface ---------
//-------------		  (no ack from slave)  --------------------
//==============================================================
	task apb_read (
		input logic [PADDR_WIDTH - 1 : 0] addr
	//	input logic [PDATA_WIDTH - 1 : 0] data 
	//	input access_size_t		 access_size_t 
	) ;

	@(apb_intf.apb_intf_pos);

		apb_intf.apb_intf_pos.PSEL 		<= 1'b1;
		apb_intf.apb_intf_pos.PADDR 	<= addr;
		apb_intf.apb_intf_pos.PENABLE 	<= 1'b0;
		apb_intf.apb_intf_pos.PWRITE 	<= 1'b0;

	@(apb_intf.apb_intf_pos);

		apb_intf.apb_intf_pos.PENABLE 	<= 1'b1;

	@(apb_intf.apb_intf_pos);
		
		apb_intf.apb_intf_pos.PSEL 		<= 1'b0;
		apb_intf.apb_intf_pos.PENABLE 	<= 1'b0;

	endtask : apb_read

//==============================================================
//------------- TASK apb_initialize ---------------------------
//------------- des : initializes apb interface ---------------
//-------------------------------------------------------------
//==============================================================
	task apb_initialize();
		
		apb_intf.apb_intf_pos.PSEL 		<= 1'b0;
		apb_intf.apb_intf_pos.PENABLE 	<= 1'b0;
		apb_intf.apb_intf_pos.PWRITE 	<= 1'b0;
		apb_intf.apb_intf_pos.PADDR 	<= 1'b0;

	endtask : apb_initialize

//==============================================================
//------------- TASK apb_start --------------------------------
//-------------------------------------------------------------
//==============================================================

	task reset();
		
		apb_intf.PRESETn	<=	1'b0;
		@(apb_intf.apb_intf_pos);
		@(apb_intf.apb_intf_pos);
		@(apb_intf.apb_intf_pos);
		apb_intf.PRESETn	<=	1'b1;

	endtask : reset

//==============================================================
//------------- TASK apb_start --------------------------------
//-------------------------------------------------------------
//==============================================================

	task start();
		
		fork
		//reset();
		apb_initialize();
		join

	endtask : start



endclass




