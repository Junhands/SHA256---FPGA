# sha256 #
Hardware implementation of the SHA-256 cryptographic hash function with
support for SHA-256.


## Introduction
Hardware implementation of the SHA-256 cryptographic hash function with
support for SHA-256. The implementation is written in
Verilog 2001 compliant code. The implementation includes the main core
as well as wrappers that provides interfaces for simple integration.

This is a low area implementation that iterates over the rounds but
there is no sharing of operations such as adders.

The hardware implementation is complemented by a functional model
written in C.

Note that the core does **NOT** implement padding of final block. The
caller is expected to handle padding.


## Implementation details ##
The sha256 design is divided into the following sections.
- rtl - RTL source files
- tb  - Testbenches for the RTL files
- software - Functional model written in C
- FSM - SHA256-Hash function architecture & finate state machine discription
[Icarus Verilog](http://iverilog.icarus.com/). There are also targets
for linting the core using [Verilator](http://www.veripool.org/wiki/verilator).

The top level entity is called sha256_core. This entity has wide
interfaces (512 bit block input, 256 bit digest). In order to make it
usable you probably want to wrap the core with a bus interface.

The actual core consists of the following files:
- sha256_core.v - The core itself with wide interfaces.
- sha256_avalon_slave - IP wrapper using avalon bus
- sha256_axi4_lite_slave - IP wrapper using axi4 lite 

The provided top level wrappers, provides a simple 32-bit memory like
interface. The core (sha256_core) will sample all data inputs when given
the init or next signal. the wrapper contains additional data registers. 
This allows you to load a new block while the core is processing the
previous block.


## Fpga-results ##

### Altera Cyclone FPGAs ###
Implementation results using Altera Quartus-II 13.1.

**Cyclone IV E**
- EP4CE6F17C6
- 2821 LEs
- 1549 registers
- 95.45 MHz
- 67 cycles latency

**Cyclone IV GX**
- EP4CGX22CF19C6
- 2772 LEs
- 1549 registers
- 95.69 MHz
- 67 cycles latency

**Cyclone V**
- 5CGXFC7C7F23C8
- 1044 ALMs
- 1708 registers
- 95.53 MHz
- 67 cycles latency




