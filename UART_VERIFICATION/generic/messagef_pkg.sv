package messagef_pkg;



`define HIERARCHY $sformatf("%m\t")



typedef enum {INFO = 0, ERROR = 1} msg_severity_t;

typedef enum {LOW = 0, HIGH = 1, DEBUG = 2} msg_verbosity_t;



msg_verbosity_t global_verbosity;

int             error_count_pkg = 100; // will be reinitalized in start  of testcase

bit             test_ended_pkg  = 1'b0;



function void set_message_verbosity ( input msg_verbosity_t msg_verbosity);

   begin

      global_verbosity = msg_verbosity;

   end

endfunction

    

function void ip_viol(  input string          ip_viol_level);

begin

        

   case(ip_viol_level)

    "ERROR" : error_count_pkg = error_count_pkg + 1;

   endcase

end

endfunction



function void messagef( input msg_verbosity_t msg_verbosity,

                        input msg_severity_t  msg_severity,

                        input string          msg_hierarchy,

                        input string          msg_txt);

begin

        

   case(msg_severity)

      INFO:

      begin

         case(global_verbosity)

         DEBUG:

         begin

            if (msg_verbosity == HIGH || msg_verbosity == LOW)

               $display( "INFO  @ ",$realtime,"ns : ", msg_hierarchy, ":\t", msg_txt);

            else

               $display( "DEBUG @ ",$realtime,"ns : ", msg_hierarchy, ":\t", msg_txt);

         end

         HIGH:

         begin

            if (msg_verbosity == HIGH || msg_verbosity == LOW)

            begin

               $display( "INFO  @ ",$realtime,"ns : ", msg_hierarchy, ":\t", msg_txt);

            end



         end

         LOW:

         begin

            if ( msg_verbosity == LOW)

            begin

               $display( "INFO  @ ",$realtime,"ns : ", msg_hierarchy, ":\t", msg_txt);

            end

         end

         endcase

      end

      ERROR:

      begin

         error_count_pkg = error_count_pkg + 1;

         $display("-----------------------------------------------------------------");

         $display( "Dut Error @ ",$realtime,"ns : ", msg_hierarchy, ":\n", msg_txt);

         $display("-----------------------------------------------------------------\n");

         `ifndef REGRESSION

             // $stop();

         `endif

      end

   endcase

end

endfunction



	function int	get_trigger_level	(bit[1:0] TRIG_LEVEL);

		case(TRIG_LEVEL)

			2'b00	:	return	0	;
			2'b01	:	return	3	;
			2'b10	:	return	7	;
			2'b11	:	return	13	;
			default	:	return	0	;

		endcase

	endfunction





endpackage: messagef_pkg



import messagef_pkg::*;
