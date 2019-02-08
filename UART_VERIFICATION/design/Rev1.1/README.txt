

BUG FIXES	:
--------------

a. Changed Q0 and Q1 values to 1 from 0 at initialization during reset in (gh_edge_det.vhd). Causing issues during start-up and reset where false edges were getting triggered.(Line 51-52)

b. Removed TSR_EMPTY=1 check while setting TX_RDYS in U1:gh_jkff in file (gh_uart_16550.vhd) during MODE0. Causing spec violation wherein TXRDY should change state when the TX_FIFO is empty and not wait for TSR to get cleared.(Line 367)


