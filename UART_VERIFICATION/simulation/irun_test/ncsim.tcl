database -open waves  -shm -into waves.shm -default
#probe -create top -depth all -vcd -waveform
probe -create testbench -depth all -shm -waveform
probe -create testbench.u_monitor -depth all -shm -waveform
#probe -create top -memories -all testbench.u_spi_slave.mem -shm -waveform
#probe -create top -memories -all top.u_simple_spi_top.rfifo.mem top.u_simple_spi_top.wfifo.mem -shm -waveform
#probe -create top -memories -all top.u_monitor.read_fifo top.u_monitor.write_fifo -shm -waveform
run 
exit
