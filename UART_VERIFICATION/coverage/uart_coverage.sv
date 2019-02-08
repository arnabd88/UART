///////////////////////////////////////////////////////////////////////////
//
//	Coverage Intent : to check toggle of each bit data write to registers
//
//
//////////////////////////////////////////////////////////////////////////

		covergroup cg_adr_lsr;
		//cover_wr_adr	  : coverpoint u_apb_intf.PADDR {
			//	bins wr_addr_val	=	{XMIT_FIFO_ADDR, LCR_ADDR, FCR_ADDR, MCR_ADDR, IER_ADDR};
		//	}
		cover_rd_adr	  : coverpoint u_apb_intf.PADDR {
				bins rd_addr_val	=	{LSR_ADDR};//, IIR_ADDR, MSR_ADDR};
			}
		cover_d	  	  : coverpoint u_apb_intf.PWDATA {
				wildcard bins data_7_1 = {8'b1???????};
				wildcard bins data_7_0 = {8'b0???????};
				wildcard bins data_6_1 = {8'b?1??????};
				wildcard bins data_6_0 = {8'b?0??????};
				wildcard bins data_5_1 = {8'b??1?????};
				wildcard bins data_5_0 = {8'b??0?????};
				wildcard bins data_4_1 = {8'b???1????};
				wildcard bins data_4_0 = {8'b???0????};
				wildcard bins data_3_1 = {8'b????1???};
				wildcard bins data_3_0 = {8'b????0???};
				wildcard bins data_2_1 = {8'b?????1??};
				wildcard bins data_2_0 = {8'b?????0??};
				//wildcard bins data_1_1 = {8'b??????1?};
				wildcard bins data_1_1 = {8'b??????11};
				wildcard bins data_1_0 = {8'b??????0?};
				wildcard bins data_0_1 = {8'b???????1};
				wildcard bins data_0_0 = {8'b???????0};
			}
		cover_we	  : coverpoint u_apb_intf.PWRITE {bins sel = {1'b0};}
		cover_psel	  : coverpoint u_apb_intf.PSEL {
				bins sel = {1'b1};
			}
		//cross_wr_adr_d	  : cross cover_wr_adr,cover_d, cover_we, cover_psel;
		//cross_rd_adr_d	  : cross cover_rd_adr,cover_d, cover_we, cover_psel;
		cross_rd_adr_d	  : cross cover_rd_adr,cover_d;
	//	cross_d_we	  : cross cover_d,cover_we;
	//	cross_we_adr  : cross cover_we,cover_adr;
	endgroup


	covergroup cg_adr_iir;
		//cover_wr_adr	  : coverpoint u_apb_intf.PADDR {
		//		bins wr_addr_val	=	/*{XMIT_FIFO_ADDR, LCR_ADDR, FCR_ADDR, MCR_ADDR,*/ {IER_ADDR};
		//	}
		cover_rd_adr	  : coverpoint u_apb_intf.PADDR {
				bins rd_addr_val	=	/*{LSR_ADDR,*/ {IIR_ADDR};//, MSR_ADDR};
			}
		cover_d_3_0	  	  : coverpoint u_apb_intf.PWDATA[3:0] { ignore_bins ig_data	=	{8,9,10,11,14,15};}
		cover_d_7_4			:	coverpoint u_apb_intf.PWDATA[7:4];
		cover_we	  : coverpoint u_apb_intf.PWRITE {bins sel = {1'b0};}
		cover_psel	  : coverpoint u_apb_intf.PSEL {
				bins sel = {1'b1};
			}
		//cross_wr_adr_d	  : cross cover_wr_adr,cover_d, cover_we, cover_psel;
		cross_rd_adr_d	  : cross cover_rd_adr,cover_d_3_0, cover_d_7_4, cover_we, cover_psel;
	//	cross_d_we	  : cross cover_d,cover_we;
	//	cross_we_adr  : cross cover_we,cover_adr;
	endgroup

		covergroup cg_adr_msr;
		//cover_wr_adr	  : coverpoint u_apb_intf.PADDR {
				//bins wr_addr_val	=	{XMIT_FIFO_ADDR, LCR_ADDR, FCR_ADDR, MCR_ADDR, IER_ADDR};
		//	}
		cover_rd_adr	  : coverpoint u_apb_intf.PADDR {
				bins rd_addr_val	=	/*{LSR_ADDR, IIR_ADDR,*/ {MSR_ADDR};
			}
		cover_d	  	  : coverpoint u_apb_intf.PWDATA {
				wildcard bins data_7_1 = {8'b1???????};
				wildcard bins data_7_0 = {8'b0???????};
				wildcard bins data_6_1 = {8'b?1??????};
				wildcard bins data_6_0 = {8'b?0??????};
				wildcard bins data_5_1 = {8'b??1?????};
				wildcard bins data_5_0 = {8'b??0?????};
				wildcard bins data_4_1 = {8'b???1????};
				wildcard bins data_4_0 = {8'b???0????};
				wildcard bins data_3_1 = {8'b????1???};
				wildcard bins data_3_0 = {8'b????0???};
				wildcard bins data_2_1 = {8'b?????1??};
				wildcard bins data_2_0 = {8'b?????0??};
				wildcard bins data_1_1 = {8'b??????1?};
				wildcard bins data_1_0 = {8'b??????0?};
				wildcard bins data_0_1 = {8'b???????1};
				wildcard bins data_0_0 = {8'b???????0};
			}
		cover_we	  : coverpoint u_apb_intf.PWRITE {bins sel = {1'b0};}
		cover_psel	  : coverpoint u_apb_intf.PSEL {
				bins sel = {1'b1};
			}
	//	cross_wr_adr_d	  : cross cover_wr_adr,cover_d, cover_we, cover_psel;
		cross_rd_adr_d	  : cross cover_rd_adr,cover_d, cover_we, cover_psel;
	//	cross_d_we	  : cross cover_d,cover_we;
	//	cross_we_adr  : cross cover_we,cover_adr;
	endgroup
covergroup cg_adr_ier;
		cover_wr_adr	  : coverpoint u_apb_intf.PADDR {
				bins wr_addr_val	=	/*{XMIT_FIFO_ADDR, LCR_ADDR, FCR_ADDR, {MCR_ADDR},*/ {IER_ADDR};
			}
	//	cover_rd_adr	  : coverpoint u_apb_intf.PADDR {
	//			bins rd_addr_val	=	{LSR_ADDR, IIR_ADDR, MSR_ADDR};
	//		}
		cover_d	  	  : coverpoint u_apb_intf.PWDATA {
				wildcard bins data_7_1 = {8'b1???????};
				wildcard bins data_7_0 = {8'b0???????};
				wildcard bins data_6_1 = {8'b?1??????};
				wildcard bins data_6_0 = {8'b?0??????};
				wildcard bins data_5_1 = {8'b??1?????};
				wildcard bins data_5_0 = {8'b??0?????};
				wildcard bins data_4_1 = {8'b???1????};
				wildcard bins data_4_0 = {8'b???0????};
				wildcard bins data_3_1 = {8'b????1???};
				wildcard bins data_3_0 = {8'b????0???};
				wildcard bins data_2_1 = {8'b?????1??};
				wildcard bins data_2_0 = {8'b?????0??};
				wildcard bins data_1_1 = {8'b??????1?};
				wildcard bins data_1_0 = {8'b??????0?};
				wildcard bins data_0_1 = {8'b???????1};
				wildcard bins data_0_0 = {8'b???????0};
			}
		cover_we	  : coverpoint u_apb_intf.PWRITE {bins sel = {1'b1};}
		cover_psel	  : coverpoint u_apb_intf.PSEL {
				bins sel = {1'b1};
			}
		cross_wr_adr_d	  : cross cover_wr_adr,cover_d, cover_we, cover_psel;
		//cross_rd_adr_d	  : cross cover_rd_adr,cover_d, cover_we, cover_psel;
	//	cross_d_we	  : cross cover_d,cover_we;
	//	cross_we_adr  : cross cover_we,cover_adr;
	endgroup



	covergroup cg_adr_mcr;
		cover_wr_adr	  : coverpoint u_apb_intf.PADDR {
				bins wr_addr_val	=	/*{XMIT_FIFO_ADDR, LCR_ADDR, FCR_ADDR,*/ {MCR_ADDR};//, IER_ADDR};
			}
	//	cover_rd_adr	  : coverpoint u_apb_intf.PADDR {
	//			bins rd_addr_val	=	{LSR_ADDR, IIR_ADDR, MSR_ADDR};
	//		}
		cover_d	  	  : coverpoint u_apb_intf.PWDATA {
				wildcard bins data_7_1 = {8'b1???????};
				wildcard bins data_7_0 = {8'b0???????};
				wildcard bins data_6_1 = {8'b?1??????};
				wildcard bins data_6_0 = {8'b?0??????};
				wildcard bins data_5_1 = {8'b??1?????};
				wildcard bins data_5_0 = {8'b??0?????};
				wildcard bins data_4_1 = {8'b???1????};
				wildcard bins data_4_0 = {8'b???0????};
				wildcard bins data_3_1 = {8'b????1???};
				wildcard bins data_3_0 = {8'b????0???};
				wildcard bins data_2_1 = {8'b?????1??};
				wildcard bins data_2_0 = {8'b?????0??};
				wildcard bins data_1_1 = {8'b??????1?};
				wildcard bins data_1_0 = {8'b??????0?};
				wildcard bins data_0_1 = {8'b???????1};
				wildcard bins data_0_0 = {8'b???????0};
			}
		cover_we	  : coverpoint u_apb_intf.PWRITE {bins sel = {1'b1};}
		cover_psel	  : coverpoint u_apb_intf.PSEL {
				bins sel = {1'b1};
			}
		cross_wr_adr_d	  : cross cover_wr_adr,cover_d, cover_we, cover_psel;
		//cross_rd_adr_d	  : cross cover_rd_adr,cover_d, cover_we, cover_psel;
	//	cross_d_we	  : cross cover_d,cover_we;
	//	cross_we_adr  : cross cover_we,cover_adr;
	endgroup

	covergroup cg_adr_fcr;
		cover_wr_adr	  : coverpoint u_apb_intf.PADDR {
				bins wr_addr_val	=	/*{XMIT_FIFO_ADDR, LCR_ADDR,*/ {FCR_ADDR};//, MCR_ADDR, IER_ADDR};
			}
	//	cover_rd_adr	  : coverpoint u_apb_intf.PADDR {
	//			bins rd_addr_val	=	{LSR_ADDR, IIR_ADDR, MSR_ADDR};
	//		}
		cover_d	  	  : coverpoint u_apb_intf.PWDATA {
				wildcard bins data_7_1 = {8'b1???????};
				wildcard bins data_7_0 = {8'b0???????};
				wildcard bins data_6_1 = {8'b?1??????};
				wildcard bins data_6_0 = {8'b?0??????};
				wildcard bins data_5_1 = {8'b??1?????};
				wildcard bins data_5_0 = {8'b??0?????};
				wildcard bins data_4_1 = {8'b???1????};
				wildcard bins data_4_0 = {8'b???0????};
				wildcard bins data_3_1 = {8'b????1???};
				wildcard bins data_3_0 = {8'b????0???};
				wildcard bins data_2_1 = {8'b?????1??};
				wildcard bins data_2_0 = {8'b?????0??};
				wildcard bins data_1_1 = {8'b??????1?};
				wildcard bins data_1_0 = {8'b??????0?};
				wildcard bins data_0_1 = {8'b???????1};
				wildcard bins data_0_0 = {8'b???????0};
			}
		cover_we	  : coverpoint u_apb_intf.PWRITE {bins sel = {1'b1};}
		cover_psel	  : coverpoint u_apb_intf.PSEL {
				bins sel = {1'b1};
			}
		cross_wr_adr_d	  : cross cover_wr_adr,cover_d, cover_we, cover_psel;
		//cross_rd_adr_d	  : cross cover_rd_adr,cover_d, cover_we, cover_psel;
	//	cross_d_we	  : cross cover_d,cover_we;
	//	cross_we_adr  : cross cover_we,cover_adr;
	endgroup

	covergroup cg_adr_lcr;
		cover_wr_adr	  : coverpoint u_apb_intf.PADDR {
				bins wr_addr_val	=	/*{XMIT_FIFO_ADDR,*/ {LCR_ADDR};//, FCR_ADDR, MCR_ADDR, IER_ADDR};
			}
	//	cover_rd_adr	  : coverpoint u_apb_intf.PADDR {
	//			bins rd_addr_val	=	{LSR_ADDR, IIR_ADDR, MSR_ADDR};
	//		}
		cover_d	  	  : coverpoint u_apb_intf.PWDATA {
				wildcard bins data_7_1 = {8'b1???????};
				wildcard bins data_7_0 = {8'b0???????};
				wildcard bins data_6_1 = {8'b?1??????};
				wildcard bins data_6_0 = {8'b?0??????};
				wildcard bins data_5_1 = {8'b??1?????};
				wildcard bins data_5_0 = {8'b??0?????};
				wildcard bins data_4_1 = {8'b???1????};
				wildcard bins data_4_0 = {8'b???0????};
				wildcard bins data_3_1 = {8'b????1???};
				wildcard bins data_3_0 = {8'b????0???};
				wildcard bins data_2_1 = {8'b?????1??};
				wildcard bins data_2_0 = {8'b?????0??};
				wildcard bins data_1_1 = {8'b??????1?};
				wildcard bins data_1_0 = {8'b??????0?};
				wildcard bins data_0_1 = {8'b???????1};
				wildcard bins data_0_0 = {8'b???????0};
			}
		cover_we	  : coverpoint u_apb_intf.PWRITE {bins sel = {1'b1};}
		cover_psel	  : coverpoint u_apb_intf.PSEL {
				bins sel = {1'b1};
			}
		cross_wr_adr_d	  : cross cover_wr_adr,cover_d, cover_we, cover_psel;
		//cross_rd_adr_d	  : cross cover_rd_adr,cover_d, cover_we, cover_psel;
	//	cross_d_we	  : cross cover_d,cover_we;
	//	cross_we_adr  : cross cover_we,cover_adr;
	endgroup

	covergroup cg_adr_xmit_fifo;
		cover_wr_adr	  : coverpoint u_apb_intf.PADDR {
				bins wr_addr_val	=	{XMIT_FIFO_ADDR};//, LCR_ADDR, FCR_ADDR, MCR_ADDR, IER_ADDR};
			}
		//cover_rd_adr	  : coverpoint u_apb_intf.PADDR {
		//		bins rd_addr_val	=	{LSR_ADDR, IIR_ADDR, MSR_ADDR};
		//	}
		cover_d	  	  : coverpoint u_apb_intf.PWDATA {
				wildcard bins data_7_1 = {8'b1???????};
				wildcard bins data_7_0 = {8'b0???????};
				wildcard bins data_6_1 = {8'b?1??????};
				wildcard bins data_6_0 = {8'b?0??????};
				wildcard bins data_5_1 = {8'b??1?????};
				wildcard bins data_5_0 = {8'b??0?????};
				wildcard bins data_4_1 = {8'b???1????};
				wildcard bins data_4_0 = {8'b???0????};
				wildcard bins data_3_1 = {8'b????1???};
				wildcard bins data_3_0 = {8'b????0???};
				wildcard bins data_2_1 = {8'b?????1??};
				wildcard bins data_2_0 = {8'b?????0??};
				wildcard bins data_1_1 = {8'b??????1?};
				wildcard bins data_1_0 = {8'b??????0?};
				wildcard bins data_0_1 = {8'b???????1};
				wildcard bins data_0_0 = {8'b???????0};
			}
		cover_we	  : coverpoint u_apb_intf.PWRITE {bins sel = {1'b1};}
		cover_psel	  : coverpoint u_apb_intf.PSEL {
				bins sel = {1'b1};
			}
		cross_wr_adr_d	  : cross cover_wr_adr,cover_d, cover_we, cover_psel;
		//cross_rd_adr_d	  : cross cover_rd_adr,cover_d, cover_we, cover_psel;
	//	cross_d_we	  : cross cover_d,cover_we;
	//	cross_we_adr  : cross cover_we,cover_adr;
	endgroup


	covergroup LSR_INTR_seq;
		cover_seq		:	coverpoint u_apb_intf.PADDR
			{
				bins trans	=	(LCR_ADDR =>  IER_ADDR	=> FCR_ADDR => IIR_ADDR => LSR_ADDR);
			}

	endgroup

	covergroup cg_MODE0;
		cover_fcr		:	coverpoint u_apb_intf.PADDR	
			{
				bins check	=	{FCR_ADDR}	;
			}
		cover_mode_set	:	coverpoint	u_apb_intf.PWDATA[3]	{
				bins check	=	{1'b1,1'b0}	;
			}
		cover_write_en	:	coverpoint	u_apb_intf.PWRITE	{
				bins check	=	{1'b1}	;
			}
		cover_psel		:	coverpoint	u_apb_intf.PSEL		{
				bins check	=	{1'b1}	;
			}

		cross_MODE0		:	cross cover_fcr, cover_mode_set, cover_write_en, cover_psel;
	endgroup

	covergroup cg_xmit_fifo;
		cover_xmit		: coverpoint `XMIT_FIFO_TOP	{
				bins xmit_fifo_cov[]	=	{[-1:15]};
		}
	endgroup


	covergroup cg_rcvr_fifo;
		cover_rcvr		: coverpoint `RCVR_FIFO_TOP	{
				bins rcvr_fifo_cov[]	=	{[-1:15]};
		}
	endgroup

	covergroup cg_intr;
		cover_intr		:	coverpoint `ID_INT	{
				bins intr_val_cov		=	{2'b00, 2'b01, 2'b10, 2'b11};
		}
	endgroup

	covergroup cg_intr_seq;

		cover_seq		:	coverpoint `ID_INT	{
				bins intr_seq1[]		=	(2'b10,2'b01,2'b00 => 2'b11);
				bins intr_seq2[]		=	(2'b01,2'b00 => 2'b10);
				bins intr_seq3[]		=	(2'b00 => 2'b01);

				bins intr_seq4[]		=	(2'b11 => 2'b10,2'b01,2'b00);
				bins intr_seq5[]		=	(2'b10 => 2'b01, 2'b00);
				bins intr_seq6[]		=	(2'b01 => 2'b00);
		}
	endgroup

	covergroup cg_timeout_seq;

		cover_seq		:	coverpoint `IIR[3:1]	{
				bins timeout_seq1		=	(3'b010	=>	3'b110);
				bins timeout_seq2		=	(3'b110	=>	3'b000);
				bins timeout_seq3		=	(3'b110	=>	3'b010);
		}
	endgroup




// Added on 14th March -- Debanjan

	covergroup THRE_detect_seq;

		cover_seq		:	coverpoint u_apb_intf.PADDR
			{
				bins trans[]	=	(LCR_ADDR => IER_ADDR => FCR_ADDR => XMIT_FIFO_ADDR => IIR_ADDR);
			}

	endgroup
	
	
	covergroup THRESHOLD_detect_seq;
			cover_seq		:	coverpoint u_apb_intf.PADDR
				{
					bins trans[]	=	(LCR_ADDR => IER_ADDR => FCR_ADDR => IIR_ADDR => IIR_ADDR);
				}
	endgroup
	
	
	covergroup MCR_drive_seq;
			cover_seq		:	coverpoint u_apb_intf.PADDR
				{
					bins trans[]	=	(IER_ADDR => MSR_ADDR => MCR_ADDR => MCR_ADDR);
				}
	endgroup
	
	
	covergroup MSR_LOOPBK_seq;
			cover_seq		:	coverpoint u_apb_intf.PADDR
				{
					bins trans[]	=	(MCR_ADDR => LCR_ADDR => FCR_ADDR => IER_ADDR => MSR_ADDR => XMIT_FIFO_ADDR => RCVR_FIFO_ADDR => IIR_ADDR);
				}
	endgroup
	
	covergroup MSR_detect_seq;
			cover_seq		:	coverpoint u_apb_intf.PADDR
				{
					bins trans[]	=	(IER_ADDR => MSR_ADDR => IIR_ADDR);
				}
	endgroup

				
// Utkarsh

		covergroup cg_iir_trans_cov;

		iir_trans_cov_seq	:	coverpoint `IIR[3:1]	{
				bins cov_seq1[]			= 	(4'b0001 => 4'b0000 => 4'b0001);
				bins cov_seq2[] 			= 	(4'b0001 => 4'b0000 => 4'b0100 => 4'b0000 => 4'b0001);
				bins cov_seq3[]			= 	(4'b0001 => 4'b0000 => 4'b0100 => 4'b1100 => 4'b0100 => 4'b0000 => 4'b0001);
				bins cov_seq4[]			= 	(4'b0001 => 4'b0110 => 4'b0000 => 4'b0001);
				bins cov_seq5[]			=	(4'b0001 => 4'b1110 => 4'b1100);
				bins cov_seq6[]			=	(4'b0001 => 4'b0010 => 4'b0001);
				bins cov_seq7[]			=	(4'b0001 => 4'b0010 => 4'b0100 => 4'b0010);
				bins cov_seq8[]			=	(4'b0010 => 4'b0000 => 4'b0001);
				bins cov_seq9[]			=	(4'b0001 => 4'b0000 => 4'b0010);

		}
	endgroup



	covergroup cg_msr_trans_cov;

		msr_trans_cov	:	coverpoint `MSR[3:0]	{
				bins cov_seq1[]			=	(4'b0000 => 4'b1111 => 4'b0000);
				bins cov_seq2[]			=	(4'b0000 => 4'b1011 => 4'b1111 => 4'b0000);

		}
	endgroup


	covergroup cg_lcr_5_ot_3_trans_cov;

		lcr_5_ot_3_trans_cov_seq	:	coverpoint `LCR[5:3]	{
				bins cov_seq1[]			=	(3'b000 => 3'b001 => 3'b011);
				bins cov_seq2[]			=	(3'b000 => 3'b010 => 3'b011);
				bins cov_seq3[]			=	(3'b000 => 3'b011 => 3'b001);
				bins cov_seq4[]			=	(3'b000 => 3'b011 => 3'b010);
		}
	endgroup


	covergroup cg_lcr_2_to_0_trans_cov;

		lcr_2_to_0_trans_cov_seq	:	coverpoint `LCR[2:0]	{
				bins cov_seq1[]			=	(3'b000 => 3'b001);
				bins cov_seq2[]			=	(3'b001 => 3'b000);
				bins cov_seq3[]			=	(3'b010 => 3'b011);
				bins cov_seq4[]			=	(3'b011 => 3'b010);
				bins cov_seq5[]			=	(3'b100 => 3'b101);
				bins cov_seq6[]			=	(3'b101 => 3'b100);
				bins cov_seq7[]			=	(3'b110 => 3'b111);
				bins cov_seq8[]			=	(3'b111 => 3'b110);
		}
	endgroup


	covergroup cg_mcr_4_to_0_trans_cov;
		mcr_4_to_0_trans_cov		:	coverpoint `MCR[4:0]	{
				bins cov_seq1[]			=	(5'b01111 => 5'b11111 => 5'b10000);
				bins cov_seq2[]			=	(5'b00000 => 5'b10000 => 5'b11111);
		}
	endgroup


// regmap reg check

	covergroup cg_adr_lcr_reg;
		cover_reg_lsb	  : coverpoint `LCR[2:0];
										  //wildcard ignore_bins stick_dis = {8'b??1?????};
										//} 
		cover_reg_msb	  : coverpoint `LCR[7:6] {ignore_bins data = {2,3}; }
		cover_reg_mid	  : coverpoint `LCR[4:3] {ignore_bins data = {2,0}; }

		cross_lcr_reg_bits:	cross cover_reg_lsb, cover_reg_msb, cover_reg_mid;
		
	endgroup

//--- new

	covergroup cg_adr_mcr_reg;
		cover_reg		:	coverpoint `MCR[3:0]{bins data = {0,15};}
	endgroup


	covergroup cg_adr_fcr_reg;
		cover_reg_7_6		:	coverpoint `FCR[7:6];
		cover_reg_dma		:	coverpoint `FCR[3];
		cover_reg_2_1		:	coverpoint `FCR[2:1];
		cross_cover			:	cross cover_reg_7_6, cover_reg_dma, cover_reg_2_1;
	endgroup


	covergroup cg_adr_ier_reg;
		cover_reg_3_0		:	coverpoint `IER[3:0];
	endgroup


	covergroup cg_adr_iir_reg;
		cover_reg_1			:	coverpoint `IIR[0];
		cover_interrupt		:	coverpoint `IIR[3:1] {bins data = {0,1,2,3,6};}
		cross_cover			:	cross cover_reg_1, cover_interrupt;
	endgroup


	covergroup cg_adr_lsr_reg;
		cover_reg_trns			:	coverpoint `LSR[6:5] {ignore_bins data_ig = {2};}
		cover_reg_rcvr_7		:	coverpoint `LSR[7];
		cover_reg_rcvr_err		:	coverpoint `LSR[4:2];
		cover_reg_ovr_run		:	coverpoint `LSR[1];
		cover_reg_rcvr_0		:	coverpoint `LSR[0];
		cover_corner			:	coverpoint `LSR {wildcard bins data_7_1 = {8'b??????00};
													 wildcard bins data_0_7_1 = {8'b0??000??};
													}
		cross_rcvr_7_rcvr_err	:	cross cover_reg_rcvr_7, cover_reg_rcvr_err {bins data = binsof(cover_reg_rcvr_7) intersect {0};}
		cross_rcvr_trans		:	cross cover_reg_trns, cover_reg_rcvr_7, cover_reg_rcvr_0;
	endgroup

		
		
		
		
		
		
		
		
//--------------------------------------------------------------------------------------------------		
		
		
			cg_adr_lsr				u_cg_adr_lsr			=	new();
			cg_adr_lcr				u_cg_adr_lcr			=	new();
			cg_adr_fcr				u_cg_adr_fcr			=	new();
			cg_adr_mcr				u_cg_adr_mcr			=	new();
			cg_adr_msr				u_cg_adr_msr			=	new();
			cg_adr_ier				u_cg_adr_ier			=	new();
			cg_adr_iir				u_cg_adr_iir			=	new();
			cg_adr_xmit_fifo		u_cg_adr_xmit_fifo		=	new();

			cg_MODE0				u_cg_MODE0				=	new();

			LSR_INTR_seq 			u_LSR_INTR_seq			=	new();

			cg_xmit_fifo			u_cg_xmit				=	new();

			cg_rcvr_fifo			u_cg_rcvr				=	new();

			cg_intr					u_cg_intr				=	new();

			cg_intr_seq				u_cg_intr_seq			=	new();

			cg_timeout_seq			u_cg_timeout_seq		=	new();

			THRE_detect_seq			u_THRE_detect_seq		=	new();

			THRESHOLD_detect_seq	u_THRESHOLD_detect_seq	=	new();

			MCR_drive_seq			u_MCR_drive_seq			=	new();

			MSR_LOOPBK_seq			u_MSR_LOOPBK_seq		=	new();

			MSR_detect_seq			u_MSR_detect_seq		=	new();

			cg_iir_trans_cov		u_cg_iir_trans_cov			=	new();

			cg_msr_trans_cov		u_cg_msr_trans_cov			=	new();

			cg_lcr_5_ot_3_trans_cov	u_cg_lcr_5_ot_3_trans_cov	=	new();

			cg_lcr_2_to_0_trans_cov u_cg_lcr_2_to_0_trans_cov	=	new();

			cg_mcr_4_to_0_trans_cov u_cg_mcr_4_to_0_trans_cov	=	new();
			
			cg_adr_lcr_reg			u_cg_adr_lcr_reg			=	new();
			cg_adr_mcr_reg			u_cg_adr_mcr_reg			=	new();
			cg_adr_fcr_reg			u_cg_adr_fcr_reg			=	new();
			cg_adr_ier_reg			u_cg_adr_ier_reg			=	new();
			cg_adr_lsr_reg			u_cg_adr_lsr_reg			=	new();
			cg_adr_iir_reg			u_cg_adr_iir_reg			=	new();
