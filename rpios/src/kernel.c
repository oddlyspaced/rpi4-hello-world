#include "common.h"
#include "mini_uart.h"

void kernel_main() {
	uart_init();
	uart_send_string("Raspberry PI Bare Metal OS Initializing...\n");
	uart_send_string("Board: Raspberry Pi 4\n");

	while(1) {
		uart_send(uart_recv());
	}
}
