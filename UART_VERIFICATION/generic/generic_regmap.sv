class Generic_Regmap;



        /////////////////////////////////////////////////////////

        // rand variables for individual bit fields

        /////////////////////////////////////////////////////////





        rand RandAddrGen        addrgen;

        rand rand_acc_size_t    access_mode;  //RAND_ACC/BYTE1_ACC/etc

        rand rand_offst_size_t  offset_mode;



 

        // list of addresses of all the registers

        bit          [ADDR_WIDTH-1:0]         regmap_addr [$];





        int                                    rand_reg_addr_index[$];

        access_size_t                               rand_acc_size_gen[$]; //array of accesses..BYTE1/HWRD1/etc

        bit          [ADDR_OFFSET_WIDTH-1:0]          rand_addr_offst_gen[$];



        /////////////////////////////////////////////////////////

        // Function: post_randomize

        // -----------------------------------------------------

        // Description: post_randomize function of the class

        ////////////////////////////////////////////////////////





        function void post_randomize;

        begin

           //// messagef(DEBUG,INFO,`HIERARCHY," POST_RANDOMIZATION for regmap");

           addrgen   = new(access_mode, offset_mode);

           $display("access_mode %d offset_mode %d", access_mode, offset_mode);

           if ( rand_reg_addr_index.size() !=0 )

           begin

                for(int i = NUM_REG -1; i>=0; i--)

                begin

                    rand_reg_addr_index.delete(i);

                    rand_acc_size_gen.delete(i);

                    rand_addr_offst_gen.delete(i);

                end

           end

           for(int i = 0; i<NUM_REG; i++)

           begin

              assert(addrgen.randomize());

              // messagef(DEBUG,INFO,`HIERARCHY,$sformatf("Index generated: %d", addrgen.reg_addr_index));

              rand_reg_addr_index.push_back(addrgen.reg_addr_index);

              rand_acc_size_gen.push_back(addrgen.acc_size_gen);  //BYTE1/WRD/etc

              rand_addr_offst_gen.push_back(addrgen.addr_offst_gen);


           end

        end

        endfunction





        /////////////////////////////////////////////////////////

        // Task: start

        // -----------------------------------------------------

        // Description: starts any forever running tasks

        //              

        ////////////////////////////////////////////////////////



        task start();



        endtask: start





        

endclass: Generic_Regmap

