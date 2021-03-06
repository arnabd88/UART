`include "uart_defines.sv"
`include "fifo.sv"
`include "generic_rand_addr_gen.sv"
`include "generic_regbase.sv"
`include "generic_regmap.sv"
`include "uart_registers.sv"
`include "uart_regmap.sv"
`include "stimulus.sv"
`include "messagef_pkg.sv"
`include "apb_interface.sv"
`include "uart_interface.sv"
`include "event_interface.sv"
`include "uart_clock_module.sv"
`include "monitor.sv"
`include "uart_tx_bfm.sv"
`include "uart_rx_bfm.sv"
`include "generator.sv"
`include "generic_test.sv"
`include "apb_driver.sv"
`include "uart_driver_bfm.sv"
`include "driver.sv"
`include "Uart_Env.sv"
//------------- TEST INCLUDE HEADER -------------------------
`include "uart_frame_transmit.sv"
`include "uart_THRE_interrupt_test.sv"
`include "uart_modem_control.sv"
`include "uart_loopback.sv"
`include "uart_timeout_test.sv"
`include "uart_mode0.sv"
`include "uart_mode1.sv"
`include "uart_brake_intr_check.sv"
`include "uart_error_injection_tc.sv"
`include "uart_rcvr_trigger_intr_check.sv"
`include "uart_overrun_check.sv"
`include "uart_iir_trans_cov.sv"
//------------ END TEST INCLUDE HEADER ---------------------
`include "uart_test.sv"
`include "Root_Test_Admin.sv"
`include "uart_checker.sv"
`include "testbench.sv"

