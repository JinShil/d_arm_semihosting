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

void write(in string s)
{
    foreach(c; s)
    {
        semihosting.write(c);
    }
}

// These are marked extern(C) to avoid name mangling, so we can refer to them in our linker script
alias ISR = void function(); // Alias Interrupt Service Routine function pointers
extern(C) immutable ISR ResetHandler = &OnReset; // Pointer to entry point, OnReset
extern(C) immutable ISR HardFaultHandler = &OnHardFault; // Pointer to hard fault handler, OnHardFault

// Handle any hard faults here
void OnHardFault()
{
    // Display a message notifying us that a hard fault occurred
    //trace.writeLine("Hard Fault");
    write("hard fault");
    
    // Enter an infinite loop so we can use the debugger
    // to examine registers, memory, etc...
    while(true) { }
}

void OnReset()
{
    // Test SYS.WRITEC
    write("This string is printing 1 char at a time\n");

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

// defined in the linker
extern(C) extern __gshared ubyte __text_end__;
extern(C) extern __gshared ubyte __data_start__;
extern(C) extern __gshared ubyte __data_end__;
extern(C) extern __gshared ubyte __bss_start__;
extern(C) extern __gshared ubyte __bss_end__;

extern(C) void* memset(void* dest, int value, size_t num)
{
    // naive implementation for the moment.  Eventually,
    // this should be implemented in assembly
    
    byte* d = cast(byte*)dest;
    for(int i = 0; i < num; i++)
    {
        d[i] = cast(byte)value;
    }
    
    return dest;
} 

extern(C) void* memcpy(void* dest, void* src, size_t num)
{    
    // naive implementation for the moment.  Eventually,
    // this should be implemented in assembly
    
    ubyte* d = cast(ubyte*)dest;
    ubyte* s = cast(ubyte*)src;
    
    for(int i = 0; i < num; i++)
    {
        d[i] = s[i];
    }
    
    return dest;
}