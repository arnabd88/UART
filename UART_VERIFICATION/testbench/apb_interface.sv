//=======================================================================================================\\
//
//---------------- APB INTERFACE FILE -------------------------------------------------------------------\\
//-------- Describes two separate clocking blocks for posedge and negedge of PCLK -----------------------\\
//
//=======================================================================================================\\

interface Apb_Interface (input PCLK);

    logic PRESETn 	;
    logic PSEL    	;
    logic PENABLE	; 
    logic PWRITE 	; 
    logic [PADDR_WIDTH-1:0]	PADDR  	; 
    logic [PDATA_WIDTH-1:0]	PWDATA 	; 
    logic [PDATA_WIDTH-1:0]	PRDATA 	; 


	clocking	apb_intf_pos@(posedge PCLK);
		
			default input #2ns output #1ns;

			output PADDR;
			output PWRITE;
			output PENABLE;
			output PSEL;
			output PWDATA;
			input PRDATA;

	endclocking

	clocking	apb_intf_neg@(negedge PCLK);
		
			default input #2ns output #1ns;

			output PADDR;
			output PWRITE;
			output PENABLE;
			output PSEL;
			output PWDATA;
			input PRDATA;

	endclocking

	
	modport apb_driver ( clocking apb_intf_pos, apb_intf_neg, output PRESETn);

endinterface
