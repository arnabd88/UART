class RandAddrGen;



        randc logic  [31:0]                    reg_addr_index;

        rand  access_size_t                    acc_size_gen;

        rand  bit    [ADDR_OFFSET_WIDTH-1:0]  addr_offst_gen;



        rand_acc_size_t  access_mode;

        rand_offst_size_t  offset_mode;



        constraint index_range   { reg_addr_index inside { [0:NUM_REG-1]};}

        constraint offset_range  { if (offset_mode == RAND_OFFST)

                                        addr_offst_gen dist { 0 := 1, 1 := 1, 2 := 1, 3 := 1};

                                   else if (offset_mode == OFFST_0)

                                        addr_offst_gen == 0;

                                   else if (offset_mode == OFFST_1)

                                        addr_offst_gen == 1;

                                   else if (offset_mode == OFFST_2)

                                        addr_offst_gen == 2;

                                   else if (offset_mode == OFFST_3)

                                        addr_offst_gen == 3;

                                 }



        constraint acc_size_dist { if (access_mode == RAND_ACC)

                                        acc_size_gen dist { BYTE1 := 1, BYTE2 := 1, BYTE3 := 1, BYTE4 := 1, HWRD1 := 1, HWRD2 := 1, WRD := 1};

                                   else if (access_mode == BYTE1_ACC)

                                        acc_size_gen == BYTE1;

                                   else if (access_mode == BYTE2_ACC)

                                        acc_size_gen == BYTE2;

                                   else if (access_mode == BYTE3_ACC)

                                        acc_size_gen == BYTE3;

                                   else if (access_mode == BYTE4_ACC)

                                        acc_size_gen == BYTE4;

                                   else if (access_mode == HWRD1_ACC)

                                        acc_size_gen == HWRD1;

                                   else if (access_mode == HWRD2_ACC)

                                        acc_size_gen == HWRD2;

                                   else if (access_mode == WRD_ACC)

                                        acc_size_gen == WRD;

                                 }

        



        /////////////////////////////////////////////////////////

        // Function: new

        // -----------------------------------------------------

        // Description: new function of the class

        ////////////////////////////////////////////////////////

  

        function new (rand_acc_size_t access_mode, rand_offst_size_t  offset_mode);

            this.access_mode = access_mode; //RAND_ACC/BYTE1_ACC/etc

            this.offset_mode = offset_mode;

           $display("rand: access_mode %d offset_mode %d", access_mode, offset_mode);

        endfunction: new



endclass: RandAddrGen

