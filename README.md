# An ARM Semihosting Library in D

This repository is an ARM Semihosting library written in the D programming language intended to be used with ARM Cortex-M microcontrollers.

It exposes each semihosting operation as a function rather than exposing and `enum` of operations and a single function that takes one of said `enum`s.  The hope is that users won't need to learn how to use each operation, but instead, can understand how to use each operation by glancing at each operation's function definition.

This library is very incomplete; it currently only implements the semihosting *write* operations.  

## Building and Testing

A simple test that uses the semihosting library can be found in the *test* directory.  It has been implemented and tested on only a Linux host and an STM32F4 MCU.  Other MCUs can likely be supported by modifying *linker.ld* and *openocd.sh* appropriately.

To build the test program, change into the *test* and run `rdmd build.d`.  

This test program can only be built with the GDC ARM cross-compiler like [this one](https://github.com/JinShil/arm-none-eabi-gdc).  Support for LDC has not yet been added.

The test program is designed to be run with [OpenOCD](http://openocd.org/) and the *arm-none-eabi-gdb* debugger, a component of the [GNU ARM Embedded Toolchain](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm).  Both of which may be obtained from a linux distribution's package manager.

   1.  Execute *openocd.sh* to start and instance of the OpenOCD GDB server.
   2.  Execute *gdb.sh* to start an instance of *arm-none-eabi-gdb* client.  It will connect to the OpenOCD GDB server, upload the binary, and begin executing the program.
   3.  Test output should appear in the OpenOCD window.


## References
  * [What is semihosting?](http://www.keil.com/support/man/docs/armcc/armcc_pge1358787046598.htm)

## License
  * See the LICENSE file.