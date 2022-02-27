# Zephyr Fetch Unit

A basic fetch unit designed to interact with Xilinx Block RAM made for the Zephyr CPU project, a simple 8-bit CPU architecture.

## Operations
The fetch unit is controlled via 2-bit wide opcodes that take effect on the rising edge of the clock.

| Operation | Binary Code | Description                       |
|-----------|-------------|-----------------------------------|
| NOP       |    `000`    | No operation                      |
| STD       |    `001`    | Store data byte to memory         |
| LDI       |    `010`    | Load instruction byte from memory |
| LDD       |    `011`    | Load data byte from memory        |

In addition to the opcodes, the address bus value is fixed within the fetch unit whenever the addrBusLock signal is set low.