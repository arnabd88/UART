module Uart_Checker	(

	Uart_Interface 		u_uart_intf			,
	Event_Interface		u_event_intf		

	);

	`MODULE_REGMAP regmap	;

	//--------------------------------
	// to access: LCR	-> 	LCR_Reg::reg_lcr[bit index]
	// to access: LSR	->  LSR_Reg::reg_lsr[bit index] 
	// to access: FCR	->  FCR_Reg::reg_fcr[bit index] 
	// to access: MCR	->  MCR_Reg::reg_mcr[bit index] 
	// to access: MSR	->  MSR_Reg::reg_msr[bit index] 
	// to access: IIR	->  IIR_Reg::reg_iir[bit index] 
	// to access: IER	->  IER_Reg::reg_ier[bit index] 
	// to access: DLL	->  DLL_Reg::reg_dll[bit index] 
	// to access: DLM	->  DLM_Reg::reg_dlm[bit index] 
	//--------------------------------

	wire BRKC, TEMT	, PE, THRE, LOOPBACK;
	integer XMIT_TOP, RCVR_TOP;
	wire [7:0] MSR;


	wire [PDATA_WIDTH-1:0] LCR_WIRE, LSR_WIRE, IIR_WIRE, MSR_WIRE, IER_WIRE, MCR_WIRE, FCR_WIRE;
	assign BRKC				=		(regmap!==null) ? LCR_Reg::reg_lcr[6] : 1'b0	;
	assign TEMT				=		(regmap!==null) ? LSR_Reg::reg_lsr[6] : 1'b0	;
	assign OVER_RUN_ERR		=		(regmap!==null) ? LSR_Reg::reg_lsr[1] : 1'b0	;
	assign PARITY_ERR		=		(regmap!==null) ? LSR_Reg::reg_lsr[2] : 1'b0	;
	assign FRAMING_ERR		=		(regmap!==null) ? LSR_Reg::reg_lsr[3] : 1'b0	;
	assign BREAK_ERR		=		(regmap!==null) ? LSR_Reg::reg_lsr[4] : 1'b0	;
	assign NO_PEND_INT  	=	 	(regmap!==null) ? IIR_Reg::reg_iir[0] : 1'b0 	;
	assign RCVR_LINE_IE 	=	 	(regmap!==null) ? IER_Reg::reg_ier[2] : 1'b0 	;
	assign OVER_RUN_ERR 	=	 	(regmap!==null) ? LSR_Reg::reg_lsr[1] : 1'b0 	;
	assign PARITY_ERR		=	 	(regmap!==null) ? LSR_Reg::reg_lsr[2] : 1'b0 	;
	assign FRAMING_ERR		=	 	(regmap!==null) ? LSR_Reg::reg_lsr[3] : 1'b0 	;
	assign BREAK_ERR		=	 	(regmap!==null) ? LSR_Reg::reg_lsr[4] : 1'b0 	;
	assign IIR_BIT_1  		=	 	(regmap!==null) ? IIR_Reg::reg_iir[1] : 1'b0 	;
	assign IIR_BIT_2  		=	 	(regmap!==null) ? IIR_Reg::reg_iir[2] : 1'b0 	;
	assign IIR_BIT_3	  	=	 	(regmap!==null) ? IIR_Reg::reg_iir[3] : 1'b0 	;
	assign MSR[7:0]			= 		(regmap!==null) ? MSR_Reg::reg_msr[7:0] : 0		;
	assign LOOPBACK			=		(regmap!==null) ? MCR_Reg::reg_mcr[4] : 1'b0	;







	assign THRE =	(regmap!==null) ? LSR_Reg::reg_lsr[5] : 1'b0	;

	assign LSR_WIRE = (regmap!==null) ? LSR_Reg::reg_lsr : 1'b0	;
	assign IIR_WIRE = (regmap!==null) ? IIR_Reg::reg_iir : 1'b0	;
	assign IER_WIRE = (regmap!==null) ? IER_Reg::reg_ier : 1'b0	;
	assign MSR_WIRE = (regmap!==null) ? MSR_Reg::reg_msr : 1'b0	;
	assign MCR_WIRE = (regmap!==null) ? MCR_Reg::reg_mcr : 1'b0	;
	assign LCR_WIRE = (regmap!==null) ? LCR_Reg::reg_lcr : 1'b0	;
	assign FCR_WIRE = (regmap!==null) ? FCR_Reg::reg_fcr : 1'b0	;

	assign XMIT_TOP = (regmap!==null) ? XMIT_FIFO_Reg::xmit_fifo_top : 1;
	assign RCVR_TOP = (regmap!==null) ? RCVR_FIFO_Reg::rcvr_fifo_top : 1;



	reg [7:0] MSR_MIRROR;




	initial 
		begin
			$nc_mirror("MSR_MIRROR","testbench.u_duv:U1:MSR");
			@(u_event_intf.init_regmap);
			u_uart_intf.regmap_mbx.peek(regmap);
		end



//property xyz;
//	@(u_uart_intf.B_CLK) disable iff (regmap == null)
//	(u_uart_intf.sTX == 1) |-> (u_uart_intf.sTX == 1);
//	endproperty: xyz
//
//prop_xyz : assert property (xyz);
//
//abc	:	assert property (@(u_uart_intf.B_CLK) (u_uart_intf.sTX == 1) |-> (u_uart_intf.sTX == 1));
//
//
///
//                               ; //  else messagef("Assertion Failure: Break condition failure");



/////////////////*************/////////////////////
property overrun_intr;

	@(u_uart_intf.uart_intf_tx_pos) disable iff (regmap == null)

	(OVER_RUN_ERR == 1'b1) && (RCVR_LINE_IE == 1'b1) |->	(u_uart_intf.IRQ	==	'b1)	;

	endproperty: overrun_intr

prop_overrun_intr : assert property (overrun_intr) begin
					$display("INTERRUPT_PROP_SUCCESS",$time);
					$display("OVER_RUN_ERR = %b <> u_uart_intf.IRQ = %b",OVER_RUN_ERR,u_uart_intf.IRQ, $time);
				end
				else begin
					$display("INTERRUPT_PROP_FAIL",$time);
				end






///////////////*************/////////////////////
property parity_intr;

	@(u_uart_intf.uart_intf_tx_pos) disable iff (regmap == null)
	(PARITY_ERR == 1'b1) && (RCVR_LINE_IE == 1'b1) |->	(u_uart_intf.IRQ	==	'b1)	;

	endproperty: parity_intr

prop_parity_intr : assert property (parity_intr) begin
					$display("INTERRUPT_PROP_SUCCESS",$time);
					$display("PARITY_ERR = %b <> u_uart_intf.IRQ = %b",PARITY_ERR,u_uart_intf.IRQ, $time);
				end
				else begin
					$display("INTERRUPT_PROP_FAIL",$time);
				end



/////////////////*************/////////////////////
property framing_intr;

	@(u_uart_intf.uart_intf_tx_pos) disable iff (regmap == null)

	(FRAMING_ERR == 1'b1) && (RCVR_LINE_IE == 1'b1) |->	(u_uart_intf.IRQ	==	'b1)	;

	endproperty: framing_intr

prop_framing_intr : assert property (framing_intr) begin
					$display("INTERRUPT_PROP_SUCCESS",$time);
					$display("FRAMING_ERR = %b <> u_uart_intf.IRQ = %b",FRAMING_ERR,u_uart_intf.IRQ, $time);
				end
				else begin
					$display("INTERRUPT_PROP_FAIL",$time);
				end



/////////////////*************/////////////////////
property break_intr;

	@(u_uart_intf.uart_intf_tx_pos) disable iff (regmap == null)

	(BREAK_ERR == 1'b1) && (RCVR_LINE_IE == 1'b1) |->	(u_uart_intf.IRQ	==	'b1)	;

	endproperty: break_intr

prop_break_intr : assert property (break_intr) begin
					$display("INTERRUPT_PROP_SUCCESS",$time);
					$display("BREAK_ERR = %b <> u_uart_intf.IRQ = %b",BREAK_ERR,u_uart_intf.IRQ, $time);
				end
				else begin
					$display("INTERRUPT_PROP_FAIL",$time);
				end





/////////////////*************/////////////////////
property no_break_no_xfer;

	//@(u_uart_intf.B_CLK) disable iff (!u_apb_intf.PRESETn )
  @(u_uart_intf.uart_intf_tx_pos) disable iff ((regmap == null) || (LOOPBACK == 'b1))

	(BRKC == 1'b0) && (TEMT == 1'b1) |-> (u_uart_intf.sTX == 1);

	endproperty: no_break_no_xfer

Prop_no_break_no_xfer : assert property(no_break_no_xfer)
			
								;//		else messagef("Assertion Failure: No Break No Tranfer condition failure");


/////////////////*************/////////////////////
property no_break_and_xfer;

	//@(u_uart_intf.B_CLK) disable iff (!u_apb_intf.PRESETn )
  @(u_apb_intf.apb_intf_pos) disable iff (regmap == null )

	$fell(BRKC) |-> u_uart_intf.sTX[*1:$] ##1 $rose(u_uart_intf.B_CLK)  ;

	endproperty: no_break_and_xfer

Prop_no_break_and_xfer : assert property(no_break_and_xfer)
			
								;//		else messagef("Assertion Failure: No Break No Tranfer condition failure");


/////////////////*************/////////////////////
property break_condn;

	//@(u_uart_intf.B_CLK) disable iff (!u_apb_intf.PRESETn )
  @(u_uart_intf.uart_intf_tx_pos) disable iff (regmap == null )

	//(BRKC == 1'b1) |-> (u_uart_intf.sTX == 0);
	$rose(BRKC) |=> (u_uart_intf.sTX == 0);

	endproperty: break_condn

Prop_break_condn : assert property(break_condn)
			
								;//		else messagef("Assertion Failure: No Break No Tranfer condition failure");

/////////////////*************/////////////////////
property break_release;

	//@(u_uart_intf.B_CLK) disable iff (!u_apb_intf.PRESETn )
  @(u_uart_intf.uart_intf_tx_pos) disable iff ((regmap == null )|| (LOOPBACK == 'b1))

	//(BRKC == 1'b1) |-> (u_uart_intf.sTX == 0);
	(BRKC == 1'b0) && (TEMT == 1'b1) |=> (u_uart_intf.sTX == 1);

	endproperty: break_release

Prop_break_release : assert property(break_release)
			
								;//		else messagef("Assertion Failure: No Break No Tranfer condition failure");

/////////////////*************/////////////////////
property continuous_break;

	//@(u_uart_intf.B_CLK) disable iff (!u_apb_intf.PRESETn )
  @(u_uart_intf.uart_intf_tx_pos) disable iff (regmap == null )

	(BRKC == 1'b1)	|-> (u_uart_intf.sTX == 1'b0) ;

	endproperty: continuous_break

Prop_continuous_break : assert property(continuous_break)
			
								;//		else messagef("Assertion Failure: No Break No Tranfer condition failure");


/////////////////*************/////////////////////
property no_pending_interrupt;

	@(u_uart_intf.B_CLK) disable iff (!u_apb_intf.PRESETn && regmap == null )

	 //(u_uart_intf.IRQ == 0) |-> (NO_PEND_INT == 1'b1) ;
	 (NO_PEND_INT == 1'b1) |-> (u_uart_intf.IRQ == 0); 

	endproperty: no_pending_interrupt

Prop_no_pending_interrupt : assert property(no_pending_interrupt)

							;	//		else messagef("Assertion Failure: No Interrupt Pending Condition failure");


/////////////////*************/////////////////////
property pending_interrupt;

	@(u_uart_intf.B_CLK) disable iff (!u_apb_intf.PRESETn && regmap == null )

	// (u_uart_intf.IRQ == 1) |-> (NO_PEND_INT == 1'b0) ;
	(NO_PEND_INT == 1'b0) |-> (u_uart_intf.IRQ == 1); 

	endproperty: pending_interrupt

Prop_pending_interrupt : assert property(pending_interrupt)

							;	//		else messagef("Assertion Failure: Interrupt Pending Condition failure");


/////////////////*************/////////////////////
property output_chk_at_rst;
	
	//@(u_apb_intf.apb_intf_neg) disable iff (u_event_intf.init_regmap_prop == 0 )
	@(u_apb_intf.apb_intf_neg) disable iff (regmap == null )


	(u_apb_intf.PRESETn == 0) |-> ((u_uart_intf.sTX == 1) && (u_uart_intf.DTRn == 1) && (u_uart_intf.RTSn == 1) && (u_uart_intf.OUT1n == 1) && (u_uart_intf.OUT2n == 1) && (u_uart_intf.RXRDYn == 1));

	endproperty: output_chk_at_rst

prop_output_chk_at_rst : assert property(output_chk_at_rst)

							;	//		else messagef("Assertion Failure: Output pin value check at reset condition failure");



/////////////////*************/////////////////////
property line_status_intr_enable_chk;

	@(u_uart_intf.uart_intf_tx_pos) disable iff (!u_apb_intf.PRESETn && regmap == null)

	((RCVR_LINE_IE == 1'b1) && ((OVER_RUN_ERR == 1'b1) || (PARITY_ERR == 1'b1) || (FRAMING_ERR == 1'b1) || (BREAK_ERR == 1'b1)))  ##3 ((u_apb_intf.PADDR == 3'h2) && (u_apb_intf.PSEL == 'b1) && (u_apb_intf.PWRITE == 'b0)) |=> ((u_uart_intf.IRQ == 1'b1) && (u_apb_intf.PRDATA[1] == 1'b1) && (u_apb_intf.PRDATA[2] == 1) && (u_apb_intf.PRDATA[3] == 1'b0) );

	endproperty: line_status_intr_enable_chk

prop_line_status_intr_enable_chk : assert property(line_status_intr_enable_chk)

							;	//		else messagef("Assertion Failure: Output pin value check at reset condition failure");



/////////////////*************/////////////////////
property line_status_intr_disable_chk;

	@(u_uart_intf.uart_intf_tx_pos) disable iff (!u_apb_intf.PRESETn && regmap == null)

	((RCVR_LINE_IE == 1'b0) && ((OVER_RUN_ERR == 1'b1) || (PARITY_ERR == 1'b1) || (FRAMING_ERR == 1'b1) || (BREAK_ERR == 1'b1))) ##3 ((u_apb_intf.PADDR == 3'h2) && (u_apb_intf.PSEL == 'b1) && (u_apb_intf.PWRITE == 'b0)) |=> ((u_uart_intf.IRQ == 1'b0) && (u_apb_intf.PRDATA[1] == 1'b1) && (u_apb_intf.PRDATA[2] == 1) && (u_apb_intf.PRDATA[3] == 1'b0) );

	endproperty: line_status_intr_disable_chk

prop_line_status_intr_disable_chk : assert property(line_status_intr_disable_chk)


							;	//		else messagef("Assertion Failure: Output pin value check at reset condition failure");



property MSR_Clear_chk;

	@(u_apb_intf.apb_intf_pos) disable iff (!u_apb_intf.PRESETn && regmap == null)

	((u_apb_intf.PADDR[2:0] == 3'h6) && (u_apb_intf.PWRITE == 1'b0)) |=> (MSR == 8'b00000000);
	
	endproperty: MSR_Clear_chk

prop_MSR_Clear_chk : assert property(MSR_Clear_chk)

							; //		else messagef("Assertion Failure: Output pin value check at reset condition failure");

//property MSR_Clear_chk;
//
//	@(u_apb_intf.apb_intf_pos) disable iff (!u_apb_intf.PRESETn && regmap == null)
//
//	((u_apb_intf.PADDR[2:0] == 3'h6) && (u_apb_intf.PWRITE == 1'b0)) |=> (MSR_MIRROR == 8'b00000000);
//	
//	endproperty: MSR_Clear_chk
//
//prop_MSR_Clear_chk : assert property(MSR_Clear_chk)
//
//							; //		else messagef("Assertion Failure: Output pin value check at reset condition failure");
//

//property MSR_Intr_disable_chk;
//
//	@(u_uart_intf.uart_intf_tx_pos) disable iff (!u_apb_intf.PRESETn && regmap == null)
//
//	((u_apb_intf.PADDR[2:0] == 2'h6) && (u_apb_intf.PWRITE == 1'b0) ) 
//

/////////////////*************/////////////////////
property MSR_Clear_chk_new;

	@(u_apb_intf.apb_intf_pos) disable iff (!u_apb_intf.PRESETn && regmap == null)

	((u_apb_intf.PADDR[2:0] == 3'h6) && (u_apb_intf.PSEL == 1) && (u_apb_intf.PWRITE == 1'b0)) ##2 ((u_apb_intf.PADDR[2:0] == 3'h6) && (u_apb_intf.PSEL == 1) && (u_apb_intf.PWRITE == 1'b0)) |=> (u_apb_intf.PRDATA == 8'b00000000);
	
	endproperty: MSR_Clear_chk_new

prop_MSR_Clear_chk_new : assert property(MSR_Clear_chk_new);

endmodule
