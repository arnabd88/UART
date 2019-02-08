class Generic_RegBase;



        // Variables

        bit           [ADDR_WIDTH-1:0]  reg_addr;         // Address of the register

        bit           [DATA_WIDTH-1:0]  reg_val;          // Data in the register

        bit_access_t  [DATA_WIDTH-1:0]  reg_bit_acc_type; // Access type of each bit in the register



        bit           [DATA_WIDTH-1:0]  vccdet_mask;      // Reset mask for vccdet

        bit           [DATA_WIDTH-1:0]  rsth_mask;        // Reset mask for Reset High side (SVSH)

        bit           [DATA_WIDTH-1:0]  por_mask;         // Reset mask for POR

        bit           [DATA_WIDTH-1:0]  rbtrst_mask;      // Reset mask for reboot reset

        bit           [DATA_WIDTH-1:0]  hardrst_mask;     // Reset mask for Hard Reset

        bit           [DATA_WIDTH-1:0]  softrst_mask;     // Reset mask for Soft Reset



        bit           [DATA_WIDTH-1:0]  vccdet_val;       // Reset value after vccdet

        bit           [DATA_WIDTH-1:0]  rsth_val;         // Reset value after Reset High side (SVSH)

        bit           [DATA_WIDTH-1:0]  por_val;          // Reset Value after POR

        bit           [DATA_WIDTH-1:0]  rbtrst_val;       // Reset Value after reboot reset

        bit           [DATA_WIDTH-1:0]  hardrst_val;      // Reset value after Hard Reset

        bit           [DATA_WIDTH-1:0]  softrst_val;      // Reset value after Soft Reset



        bit           [DATA_WIDTH-1:0]  reg_wr_en;        // enable bits for registers; can be tied at toplevel to disable writes based on passwords

        bit           [DATA_WIDTH-1:0]  reg_rd_en;        // enable bits for registers; can be tied at toplevel to disable writes based on passwords



        string                           reg_name;



        // Variables for the collate_bit_fields funtion

        bit            [DATA_WIDTH-1:0] reg_randomized_value;

        bit                        [7:0] bits_31_24_rand_tmp;

        bit                        [7:0] bits_23_16_rand_tmp;

        bit                        [7:0] bits_15_8_rand_tmp;

        bit                        [7:0] bits_7_0_rand_tmp;





        function new();

           reg_wr_en = '1;

           reg_rd_en = '1;

        endfunction: new

      

        /////////////////////////////////////////////////////////

        // Task: reset_por

        // -----------------------------------------------------

        // Description: Assigns the reset value upon por

        //

        ////////////////////////////////////////////////////////

        

       virtual task reset_por;



           int i;

           foreach(por_mask[i])

           begin

              if(por_mask[i] == 1) reg_val[i] = por_val[i];

           end

           // messagef(DEBUG,INFO,`HIERARCHY, $sformatf("Resetting reg_val to %h for %s", reg_val, reg_name));

           update_bit_fields();    



        endtask: reset_por



        /////////////////////////////////////////////////////////

        // Task: reset_hardrst

        // -----------------------------------------------------

        // Description: Assigns the reset value upon hardrst

        //

        ////////////////////////////////////////////////////////

        

        task reset_hardrst;



           int i;

           foreach(hardrst_mask[i])

           begin

              if(hardrst_mask[i] == 1) reg_val[i] = hardrst_val[i];

           end

           // messagef(DEBUG,INFO,`HIERARCHY, $sformatf("Resetting reg_val to %h for %s", reg_val, reg_name));

           update_bit_fields();    



        endtask: reset_hardrst





        /////////////////////////////////////////////////////////

        // Task: update_bit_fields

        // -----------------------------------------------------

        // Description: Updates individual bit-fields from the

        //              reg_val

        ////////////////////////////////////////////////////////

        

        virtual task update_bit_fields ();

          // will be specific to each register; so defined in the

          // register specific class



        endtask: update_bit_fields

        

        /////////////////////////////////////////////////////////

        // Task: write_reg_bits

        // -----------------------------------------------------

        // Description: Write a byte/halfword/word to the

        // register

        ////////////////////////////////////////////////////////

        

        task write_reg_bits ( input int                     msb,

                              input int                     lsb,

                              input logic [DATA_WIDTH-1:0] wr_data);

           int i;

		   // $display("Write_reg_bits = %b",wr_data);



           for (i = lsb ; i <= msb ; i ++)

           begin
		   		// $display("reg_bit_acc_type = %b",reg_bit_acc_type[i]);
		   		// $display("reg_wr_en = %b",reg_wr_en[i]);

              if ((reg_bit_acc_type[i] == RW) && (reg_wr_en[i] == 1)) reg_val[i] = wr_data[i];

              if ((reg_bit_acc_type[i] == W ) && (reg_wr_en[i] == 1)) reg_val[i] = wr_data[i];

              // For read-only, reg_val should retain old value

           end
		   // $display("WRITE: reg_val = %b",reg_val,$time);

           // messagef(DEBUG,INFO,`HIERARCHY,$sformatf("Updating %s, wr_data=%h, reg_wr_en=%h, reg_val=%h",reg_name,wr_data,reg_wr_en,reg_val));

                

        endtask: write_reg_bits

        

        /////////////////////////////////////////////////////////

        // Task: write_reg

        // -----------------------------------------------------

        // Description: Write to the register

        ////////////////////////////////////////////////////////



        task write_reg ( input logic [ADDR_OFFSET_WIDTH-1:0] wr_addr_offst,

                         input logic [       DATA_WIDTH-1:0] wr_data,

                         input access_size_t                  access_size,

                         input logic[BYTE_LANES-1:0] byte_en);


		$display("addr_offst = %b",wr_addr_offst,$time);
		$display("write_reg: wr_data	=	%b", wr_data);
		$display("byte_en	=	%b", byte_en);
/*

              case (access_size)

                 BYTE1   : write_reg_bits( 7, 0,wr_data);

                 BYTE2   : write_reg_bits(15, 8,wr_data);

                 BYTE3   : write_reg_bits(23,16,wr_data);

                 BYTE4   : write_reg_bits(31,24,wr_data);

                 HWRD1   : write_reg_bits(15, 0,wr_data);

                 HWRD2   : write_reg_bits(31,16,wr_data);

                 WRD         : write_reg_bits(31, 0,wr_data);

                 default : // messagef(LOW,ERROR,`HIERARCHY,$sformatf("Illegal access_size: %h",access_size));

              endcase

*/

              case (byte_en)

                 4'b0001   : write_reg_bits( 7, 0,wr_data);

                 4'b0010   : write_reg_bits(15, 8,wr_data);

                 4'b0100   : write_reg_bits(23,16,wr_data);

                 4'b1000   : write_reg_bits(31,24,wr_data);

                 4'b0011   : write_reg_bits(15, 0,wr_data);

                 4'b1100   : write_reg_bits(31,16,wr_data);

                 4'b1111   : write_reg_bits(31, 0,wr_data);



                 4'b0101   : begin

                                write_reg_bits( 7, 0,wr_data);

                                write_reg_bits(23,16,wr_data);

                             end

                 4'b0110   : begin

                                write_reg_bits(15, 8,wr_data);

                                write_reg_bits(23,16,wr_data);

                             end

                 4'b0111   : begin

                                write_reg_bits( 7, 0,wr_data);

                                write_reg_bits(15, 8,wr_data);

                                write_reg_bits(23,16,wr_data);

                             end

                 4'b1001   : begin

                                write_reg_bits( 7, 0,wr_data);

                                write_reg_bits(31,24,wr_data);

                             end

                 4'b1010   : begin

                                write_reg_bits(15, 8,wr_data);

                                write_reg_bits(31,24,wr_data);

                             end

                 4'b1011   : begin

                                write_reg_bits( 7, 0,wr_data);

                                write_reg_bits(15, 8,wr_data);

                                write_reg_bits(31,24,wr_data);

                             end

                 4'b1101   : begin

                                write_reg_bits( 7, 0,wr_data);

                                write_reg_bits(23,16,wr_data);

                                write_reg_bits(31,24,wr_data);

                             end

                 4'b1110   : begin

                                write_reg_bits(15, 8,wr_data);

                                write_reg_bits(23,16,wr_data);

                                write_reg_bits(31,24,wr_data);

                             end

                 //default : // messagef(LOW,ERROR,`HIERARCHY,$sformatf("Illegal access_size: %h",access_size));

              endcase



           // messagef(DEBUG, INFO,`HIERARCHY,$sformatf("%s.regval updated to %h", reg_name, reg_val));
		   $display ("Update bit fields",$time);

           update_bit_fields();    



        endtask: write_reg



        /////////////////////////////////////////////////////////

        // Task: read_reg_bits

        // -----------------------------------------------------

        // Description: Write a byte/halfword/word to the

        // register

        /////////////////////////////////////////////////////////

        

        task read_reg_bits (  input  int                     msb,

                              input  int                     lsb,

                              output logic [DATA_WIDTH-1:0] rd_data);



           int                     i;

           logic [DATA_WIDTH-1:0] rd_data_tmp;



           rd_data_tmp = '0;

           for (i = lsb ; i <= msb ; i ++)

           begin

               if ((reg_bit_acc_type[i] == RW) && (reg_rd_en[i] == 1)) rd_data_tmp[i] = reg_val[i];

               if ((reg_bit_acc_type[i] == RO) && (reg_rd_en[i] == 1)) rd_data_tmp[i] = reg_val[i];

               if ( reg_bit_acc_type[i] == R )                         rd_data_tmp[i] = 0;

               if ( reg_bit_acc_type[i] == W )                         rd_data_tmp[i] = 0;

           end



           rd_data = rd_data_tmp;
		   $display("READ: reg_val = %d",reg_val,$time);

          

           // messagef(DEBUG,INFO,`HIERARCHY,$sformatf("Reading %s, rd_data=%h, reg_rd_en=%h, reg_val=%h",reg_name,rd_data,reg_rd_en,reg_val));



        endtask: read_reg_bits



        /////////////////////////////////////////////////////////

        // Task: read_reg

        // -----------------------------------------------------

        // Description: Read from the register

        ////////////////////////////////////////////////////////



        task read_reg ( input  logic [ADDR_OFFSET_WIDTH-1:0] rd_addr_offst,

                        output logic [DATA_WIDTH-1:0]        rd_data,

                        input  access_size_t                  access_size );



           bit [DATA_WIDTH-1:0] rd_data_tmp;



              case (access_size)

                 BYTE1   : read_reg_bits( 7, 0,rd_data_tmp);

                 BYTE2   : read_reg_bits(15, 8,rd_data_tmp);

                 BYTE3   : read_reg_bits(23,16,rd_data_tmp);

                 BYTE4   : read_reg_bits(31,24,rd_data_tmp);

                 HWRD1   : read_reg_bits(15, 0,rd_data_tmp);

                 HWRD2   : read_reg_bits(31,16,rd_data_tmp);

                 WRD         : read_reg_bits(31, 0,rd_data_tmp);

               //  default : // messagef(LOW,ERROR,`HIERARCHY,$sformatf("Illegal access_size: %h",access_size));

              endcase



           // messagef(DEBUG, INFO,`HIERARCHY,$sformatf("%s.regval read as %h", reg_name, rd_data_tmp));

           rd_data = rd_data_tmp;

                    

        endtask: read_reg



        /////////////////////////////////////////////////////////

        // Task: set_bits

        // -----------------------------------------------------

        // Description: Set Bits of a Register.

        //              HW setting of bits

        ////////////////////////////////////////////////////////



        task set_bits ( input logic [DATA_WIDTH-1:0] set_mask);



           reg_val = reg_val || set_mask;

           // messagef(DEBUG, INFO,`HIERARCHY,$sformatf("%s.regval bits set; reg_val is now %h", reg_name, reg_val));

           update_bit_fields();    



        endtask: set_bits





        /////////////////////////////////////////////////////////

        // Task: clear_bits

        // -----------------------------------------------------

        // Description: Clear Bits of a Register

        //              HW clearing of bits

        ////////////////////////////////////////////////////////



        task clear_bits ( input logic [DATA_WIDTH-1:0] clear_mask);



           reg_val = reg_val && (~clear_mask);

           // messagef(DEBUG, INFO,`HIERARCHY,$sformatf("%s.regval bits cleared; reg_val is now %h", reg_name, reg_val));

           update_bit_fields();    



        endtask: clear_bits

        

        /////////////////////////////////////////////////////////

        // Function: collate_bit_fields();

        // -----------------------------------------------------

        // Description: Returns the randomized bitfields for the

        //              register, arranged as byte/hw/word

        ////////////////////////////////////////////////////////

        

        function bit [DATA_WIDTH-1:0] collate_bit_fields (input logic [ADDR_OFFSET_WIDTH-1:0] wr_addr_offst,

                                                           input access_size_t                  access_size,

                                                           input reset_t                        write_type = NONE);

        begin



           if ( write_type == NONE)

           begin

               if(access_size == WRD)

               begin

                  reg_randomized_value = { bits_31_24_rand_tmp,

                                           bits_23_16_rand_tmp,

                                           bits_15_8_rand_tmp,

                                           bits_7_0_rand_tmp};

               end

               if(access_size == HWRD1)

               begin

                  reg_randomized_value = {  ~bits_15_8_rand_tmp+8'h71,

                                            ~bits_7_0_rand_tmp+8'h11,

                                            bits_15_8_rand_tmp,

                                            bits_7_0_rand_tmp};

               end

               if(access_size == HWRD2)

               begin

                  reg_randomized_value = {  bits_31_24_rand_tmp,

                                                  bits_23_16_rand_tmp,

                                                  ~bits_31_24_rand_tmp+8'h13,

                                                  ~bits_23_16_rand_tmp+8'h17};

               end

               if(access_size == BYTE1)

               begin

                  reg_randomized_value = {  ~bits_7_0_rand_tmp+8'h23,

                                                  ~bits_7_0_rand_tmp+8'h29,

                                                  ~bits_7_0_rand_tmp+8'h31,

                                                  bits_7_0_rand_tmp};

               end

               if(access_size == BYTE2)

               begin

                        reg_randomized_value = {  ~bits_15_8_rand_tmp+8'h37,

                                                  ~bits_15_8_rand_tmp+8'h41,

                                                  bits_15_8_rand_tmp,

                                                  ~bits_15_8_rand_tmp+8'h43};

               end

               if(access_size == BYTE3)

               begin

                        reg_randomized_value = {  ~bits_23_16_rand_tmp+8'h47,

                                                  bits_23_16_rand_tmp,

                                                  ~bits_23_16_rand_tmp+8'h51,

                                                  ~bits_23_16_rand_tmp+8'h53};

               end

               if(access_size == BYTE4)

               begin

                        reg_randomized_value = {  bits_31_24_rand_tmp,

                                                  ~bits_31_24_rand_tmp+8'h59,

                                                  ~bits_31_24_rand_tmp+8'h61,

                                                  ~bits_31_24_rand_tmp+8'h67};

               end



               // messagef(DEBUG, INFO,`HIERARCHY,$sformatf("Randomized data for %s is %h", reg_name,reg_randomized_value));

           end //write_type == NONE

           if (write_type == VCCDET  ) reg_randomized_value = ~vccdet_val;

           if (write_type == RSTH  ) reg_randomized_value = ~rsth_val;

           if (write_type == POR  ) reg_randomized_value = ~por_val;

           if (write_type == RBTRST  ) reg_randomized_value = ~rbtrst_val;

           if (write_type == HARDRST  ) reg_randomized_value = ~hardrst_val;

           if (write_type == SOFTRST ) reg_randomized_value = ~softrst_val;



           return reg_randomized_value;

        end

        endfunction: collate_bit_fields



endclass: Generic_RegBase

