#! /usr/bin/perl



	if(!defined @ARGV) {
		print "\n\nUSAGE : ./script.pl -input <Options_file> [-simvision [svf file name|no]] [-rtl <rtl_version>]\n\n";
		exit;
		}
	
	my %input_args = @ARGV;
	my $rtlVersion = 0;
	if (!defined ($input_args{"-input"})) {
		die ("\nPlease enter a valid input file\nRun ./script.pl for more info.\n\n");
	}
	my (%definedHash, %tcHash,%paramHash);
	my ($flag,$count,$i) = 0;
	open(FILE, "<$input_args{-input}") or die "Couldn't open file $input_args{-input}\n";
	if (defined $input_args{"-rtl"}) {
		$rtlVersion = $input_args{"-rtl"};
	}else {
		my @rtlVersionArr = `ls ../../design/`;
		foreach (@rtlVersionArr) {
			if ($_ =~ m/golden/i){ 
				$rtlVersion = $_;
				chomp ($rtlVersion);
			}
		}
	}
	
	if (system("ls ../../test_dir/uart_test.sv.golden")) {
		print ("Info: Copying uart_test.sv to uart_test.sv.golden for future reference\n");
		system("cp ../../test_dir/uart_test.sv ../../test_dir/uart_test.sv.golden; chmod 555 ../../test_dir/uart_test.sv.golden");
	} else {
		warn ("uart_test.sv.golden copy already exists or copy permission not granted!!!");
	}
	if (system("ls ../../testbench/uart_defines.sv.golden")) {
		print ("Info: Copying uart_defines.sv to uart_defines.sv.golden for future reference\n");
		system ("cp ../../testbench/uart_defines.sv ../../testbench/uart_defines.sv.golden; chmod 555 ../../testbench/uart_defines.sv.golden");
	} else {
		warn ("uart_defines.sv.golden copy already exists or copy permission is denied");
	}
	if (system("ls Compile")) {
		print ("Info: Copying Compile to Compile.golden for future reference\n");
		system ("cp Compile Compile.golden; chmod 555 Compile.golden");
	} else {
		warn ("Compile.golden copy already exists or copy permission is denied");
	}
	if (system ("ls ../../testbench/topsim.golden.sv")) {
		system ("cp ../../testbench/topsim.sv ../../testbench/topsim.sv.golden; chmod 555 ../../testbench/topsim.sv.golden");
		print ("info: Copying topsim.sv.golden from topsim.sv for fuure reference");
	} else {
		warn ("topsim.sv.golden copy already exists or copy permission is denied");
	}

	##############################################################################################
	########################### Compile File #####################################################
	##############################################################################################

	my $path = `pwd`;
	chomp ($path);
	$path =~ s/(\/\w+\/\w+)$//;
	my @homeArr = ("\/",$path);
	print ("\nThe Home directory reads : $path\n\n");
	open (COMPILE_HAND, "<Compile.golden");
	my @compileArr = <COMPILE_HAND>;
	for (my $i = 0; $i <@compileArr; $i++) {
		my $line = $compileArr[$i];
		if ($line =~ m/-incdir/) {
			$line =~ m/(.*)\/home.*verification\w*\/(.*)/i;
			$line = $1.$path."\/".$2;
			$compileArr[$i] = $line;
		}
		if ($line =~ m/design.*/) {
			$line =~ s/Rev\d\.\d\//$rtlVersion\//;
			$compileArr[$i] = $line;
		}
	}
	close COMPILE_HAND;
	open (COMPILE_HAND, ">./Compile");
	foreach my $line (@compileArr){ 
		chomp($line);
		print COMPILE_HAND "$line\n" if (($line !~ /^\s*$/) or ($line !~ /^\s*#/));
	}
	close COMPILE_HAND;

		
	##############################################################################################


	##############################################################################################
	########################## PARSING INPUT FILE ################################################
	##############################################################################################
	
	while (<FILE>) {
			my $line;
			chomp($line = $_);
			if ($line =~ m/=DEFINES=/) {
				$flag = 1;
				next;
			}elsif ($line =~ m/=TEST\s*CASES=/) {
				$flag = 2;
				next;
			}elsif ($line =~ m/=PARAMETERS=/) {
				$flag = 3;
				next;
			}elsif ($line =~ m/^=/) {
				$flag = 0;
				next;
		}
	
		if ($flag == 1) {
			next if ($line =~ m/^\s*$/);
			if ($line =~ m/^\s*(\S+)\s+(\S+.*)\s*$/) {
				$definedHash{$1} = $2 ;
			} else {
				warn("$line is not a valid statement inside TEST CASE TAG\n");
			}
			
		}elsif ($flag == 2) {
			next if ($line =~ m/^\s*$/);
			if ($line =~ m/^\s*(\S+)\s*$/) {
				$tcHash{$count++} = $1 ;
			} else {
				warn("$line is not a valid statement inside DEFINES TAG\n");
			}
		
		}if ($flag == 3) {
			next if ($line =~ m/^\s*$/);
			if ($line =~ m/^\s*(\S+)\s+(\S+.*)\s*$/) {
				$paramHash{$1} = $2 ;
			} else {
				warn("$line is not a valid statement inside TEST CASE TAG\n");
			}
			
		}
 	}

	##############################################################################################


	

	##############################################################################################
	############################# Modifying uart_test.sv file ####################################
	##############################################################################################
	my $totalTC = keys %tcHash;
	open (UART_TEST_FILE, "< ../../test_dir/uart_test.sv.golden") or die ("uart_test.sv is not accesable");
	
	my @uart_testArr;
	$flag = 0;
	foreach my $line (<UART_TEST_FILE>) {
	   if ($line =~ m/function\s+create_test_object\s+\(/) {
	   	$flag = 1;
	   } elsif (($line =~ m/endfunction/) and ($flag == 10)) {
	   	$flag = 0;
	   } elsif ($line =~ m/task\s+start/) {
	   	$flag = 2;
	   } elsif (($flag == 10) and ($line =~ m/endtask/)) {
	   	$flag = 0;
	   } elsif ($line =~ m/\/\/-------------------\s*TEST LIST\s*----/) {
	   	$flag = 3;
	   } elsif (($flag == 10) and ($line =~ m/\/\/---------------------/)) {
	   	$flag = 0;
	   }
	
	   push(@uart_testArr,$line) if ($flag == 0);
	
	   if (($flag == 1) or ($flag == 2) or ($flag == 3)) {
	   	if ($flag == 1) {
	   	
	   		push(@uart_testArr,"\t\tfunction create_test_object	(int test_index);\n");
	   		my $string = "\t\t=	new(regmap, mbx, uart_drv_mbx,	u_apb_intf, u_uart_intf, u_event_intf);";
	   		for ($i = 1; $i <= keys %tcHash; $i++) {
	   			if ($i == 1) {push (@uart_testArr,"\t\t\tif(test_index == $i) begin\n");}
	   			else {push (@uart_testArr,"\t\t\telse if(test_index == $i) begin\n");}
	   			push (@uart_testArr,"\t\t\ttest_$tcHash{$i-1}\t$string\n");
	   			push (@uart_testArr,"\t\t\tend\n");
	   		}
			$flag = 10;
	   	
	   	} elsif ($flag == 2) {
	   		push (@uart_testArr,"\ttask start(ref int diff_counter);\n\n");
	   		push (@uart_testArr,"\t\t\$display\(\"QUEUE_SIZE = \%d\", obj_queue.size\(\), \$time\);\n");
	   		push (@uart_testArr,"\t\tif(obj_queue.size() <= MAX_TEST_COUNT) begin\n");
	   		push (@uart_testArr,"\t\t\tu_event_intf.test_num	=	random_object_id	;\n");
	   			for ($i = 1; $i <= keys %tcHash; $i++) {
	   				if ($i == 1) { push (@uart_testArr,"\n\t\t\tif(random_object_id == $i) begin\n");}
	   				else {push (@uart_testArr,"\n\t\t\telse if(random_object_id == $i) begin\n");}
	   				##push (@uart_testArr,"\t\t\t\t\$display\(\"uc($tcHash{$i-1}\) -> \", \$time);\n");
	   				push (@uart_testArr,"\t\t\t\ttest_$tcHash{$i-1}.start(diff_counter);\n");
	   				push (@uart_testArr,"\t\t\tend\n\n");
	   			}
	   		push (@uart_testArr,"\t\t\telse begin\n\t\t\t\t-> u_event_intf.test_end ;\n\t\t\tend\t\t\nend\n");
	   		$flag = 10;
	   } elsif ($flag == 3)	{
	   		push (@uart_testArr,"//---------------------------------TEST LIST---------------------------------\n\n");
	   		push (@uart_testArr,"\t\tgeneric_test\t\ttest_generic\t;\n");
	   		for ($i = 1; $i<= keys %tcHash; $i++) {
	   			push (@uart_testArr,"\t\t$tcHash{$i-1}\t\ttest_$tcHash{$i-1}\t;\n");
	   		}
			$flag = 10;
	   	 }
	   }
	  }
	
	close UART_TEST_FILE	;
	open (UART_TEST_FILE, "> ../../test_dir/uart_test.sv");
	foreach my $line (@uart_testArr) {
		print UART_TEST_FILE $line;
	}
	close UART_TEST_FILE	;
	#######################################################################################




	#######################################################################################
	############################# Modifying UART_DEFINES file #############################
	#######################################################################################

	open (DEF_FILE, "<../../testbench/uart_defines.sv.golden");
	my @defArr = <DEF_FILE>;
	foreach my $define (keys %definedHash) {
		my $found = 0;
		for (my $i = 0; $i < @defArr; $i++) {
			my $value = $definedHash{$define};
			if ($defArr[$i] =~ /\`define\s+$define/) {
				$defArr[$i] = "\t\`define $define $value\n";
				$found = 1;
			}
		}
		if ($found == 0) {
			push (@defArr, "\t`define $define $definedHash{$define}\n");
		}
	}
	foreach my $param (keys %paramHash) {
		my $found = 0;
		for (my $i = 0; $i < @defArr; $i++) {
			my $value = $paramHash{$param};
			if ($defArr[$i] =~ /PARAMETER/) {
				$defArr[$i] = "\tPARAMETER $param\t=\t$value;\n";
				$found = 1;
			}
		}
		if ($found == 0) {
			push (@defArr, "\tPARAMETER $param\t=\t$paramHash{$param};\n");
		}

	}
	close DEF_FILE;
	open (DEF_FILE, ">../../testbench/uart_defines.sv");
	foreach (@defArr) {print DEF_FILE $_;}
	close DEF_FILE;

	#######################################################################################




	#######################################################################################
	############################# Modifying UART_DEFINES file #############################
	#######################################################################################

	open (TOPSIM_HANDLE, "< ../../testbench/topsim.sv.golden");
	my @topArr;
	$flag = 0;
	#for (my $i = 0; $i < @topArr; $i++) {
	foreach (<TOPSIM_HANDLE>) {
		my $line = $_;
		if ($line =~ m/--\s*TEST\s*INCLUDE\s*HEADER\s*--/){
			$flag = 1;
		} elsif (($line =~ m/--\s*END\s*TEST\s*INCLUDE\s*HEADER\s*--/) and ($flag == 10)) {
			$flag = 0;
		}
		push (@topArr,"$line")if ($flag == 0);
		if ($flag == 1) {
			push (@topArr, "//------------- TEST INCLUDE HEADER -------------------------\n");
			foreach my $key (keys %tcHash) {
				my $tc = $tcHash{$key};
				push (@topArr,"\`include \"$tc\.sv\"\n");
			}
			$flag = 10;
		}
	}
	close TOPSIM_HANDLE;
	open (TOPSIM_HANDLE, "> ../../testbench/topsim.sv");
	foreach (@topArr) {print TOPSIM_HANDLE $_;}
	close TOPSIM_HANDLE;


	#######################################################################################




	my @cmdArr = ("./Compile");
	my $compileStatus = 1;
	my @compile_log = `./Compile`;
	my $compile_flag = pop @compile_log;
	if (($compile_flag =~ /\*E/i) or (($compile_flag =~ /\*F/i))) {
		$compileStatus = 0;
	}
	print "\n\ncompileStatus = $compileStatus >> $compile_flag\n";

	print %input_args;
	if ($compileStatus == 1) {
		if (defined $input_args{"-simvision"}) {
			my $svf = $input_args{"-simvision"};
			`simvision -waves waves.shm/waves.trn -input $svf &`;
		}
	}

