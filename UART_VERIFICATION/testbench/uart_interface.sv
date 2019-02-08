

interface Uart_Interface (input BR_CLK);

    logic sRX	   	;
    logic CTSn  	; 
    logic DSRn  	; 
    logic RIn   	; 
    logic DCDn  	; 
    logic sTX   	; 
    logic DTRn  	; 
    logic RTSn  	; 
    logic OUT1n 	; 
    logic OUT2n 	; 
    logic TXRDYn	; 
    logic RXRDYn	; 
    logic IRQ   	; 
    logic B_CLK 	; 

	mailbox #(`MODULE_REGMAP) regmap_mbx = new();

	clocking uart_intf_tx_pos@(posedge BR_CLK) ;
		
		default input #2ns output #1ns	;
			input 	TXRDYn	;
			input 	RXRDYn	;
			input 	IRQ		;
			input 	OUT1n	;
			input	OUT2n	;
			output CTSn		;
			output DSRn		;
			output RIn		;
			output DCDn		;

	endclocking

	clocking uart_intf_rx_pos@(posedge B_CLK)	;
		
		default input #2ns output #1ns	;
			output sRX		;
			input  sTX		;
	
	endclocking


	modport uart_driver( clocking uart_intf_tx_pos, uart_intf_rx_pos, input B_CLK );

endinterface
