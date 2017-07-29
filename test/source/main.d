/*
Copyright © 2017 Michael V. Franklin

This file is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This file is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this file.  If not, see <http://www.gnu.org/licenses/>.
*/

import semihosting;

// defined in the linker
private extern(C) extern __gshared ubyte __text_end__;
private extern(C) extern __gshared ubyte __data_start__;
private extern(C) extern __gshared ubyte __data_end__;
private extern(C) extern __gshared ubyte __bss_start__;
private extern(C) extern __gshared ubyte __bss_end__;

// These are marked extern(C) to avoid name mangling, so we can refer to them in our linker script
private alias ISR = void function(); // Alias Interrupt Service Routine function pointers
private extern(C) immutable ISR resetHandler = &onReset; // Pointer to entry point, OnReset
private extern(C) immutable ISR hardFaultHandler = &onHardFault; // Pointer to hard fault handler, OnHardFault

private void write(in string s)
{
    foreach(c; s)
    {
        semihosting.write(c);
    }
}

// Handle any hard faults here
private void onHardFault()
{
    // Display a message notifying us that a hard fault occurred
    //trace.writeLine("Hard Fault");
    write("hard fault");
    
    // Enter an infinite loop so we can use the debugger
    // to examine registers, memory, etc...
    while(true) { }
}

private extern(C) void* memset(void* dest, int value, size_t num)
{
    // naive implementation for the moment.  Eventually,
    // this should be implemented in assembly
    ubyte* d = cast(ubyte*)dest;

    while(num--)
    {
        *d++ = cast(ubyte)value;
    }
    
    return dest;
} 

private extern(C) void* memcpy(void* dest, void* src, size_t num)
{    
    // naive implementation for the moment.  Eventually,
    // this should be implemented in assembly

    ubyte* d = cast(ubyte*)dest;
    ubyte* s = cast(ubyte*)src;

    while(num--)
    {
        *d++ = *s++;
    }

    return dest;
}

private void onReset()
{
    // copy data segment out of ROM and into RAM
    size_t dataSize = &__data_end__ - &__data_start__;
    immutable(byte[]) dataROM = (cast(immutable byte*)&__text_end__)[0 .. dataSize];
    byte[] dataRAM = (cast(byte*)&__data_start__)[0 .. dataSize];
    dataRAM[0 .. dataSize] = dataROM[0 .. dataSize];
    
    // zero-initialize bss
    size_t bssSize = &__bss_end__ - &__bss_start__;
    byte[] bss = (cast(byte*)&__bss_start__)[0 .. bssSize];
    bss[] = 0;

    // Test SYS.WRITEC
    write("1 char at a time\n");

    // Test SYS.WRITE0
    string nullTerminatedString = "This is a null terminated string\n\0";
    semihosting.write(nullTerminatedString.ptr);

    // Test SYS.WRITE
    immutable int STDERR = 2;
    semihosting.write(STDERR, "Test\n");

    // Done
    while(true)
    {}
}
