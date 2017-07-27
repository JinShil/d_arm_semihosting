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

/*
See "What is semihosting?" at http://www.keil.com/support/man/docs/armcc/armcc_pge1358787046598.htm
*/

private enum SYS
{
    CLOSE        = 0x02,
    CLOCK        = 0x10,
    ELAPSED      = 0x30,
    ERRNO        = 0x13,
    FLEN         = 0x0C,
    GET_CMDLINE  = 0x15,
    HEAPINFO     = 0x16,
    ISERROR      = 0x08,
    ISTTY        = 0x09,
    OPEN         = 0x01,
    READ         = 0x06,
    READC        = 0x07,
    REMOVE       = 0x0E,
    RENAME       = 0x0F,
    SEEK         = 0x0A,
    SYSTEM       = 0x12,
    TICKFREQ     = 0x31,
    TIME         = 0x11,
    TMPNAM       = 0x0D,

    /** 
    Writes the contents of a buffer to a specified file at the current file position.
    The file position is specified either:
        * explicitly, by a SYS_SEEK
        * implicitly as one byte beyond the previous SYS_READ or SYS_WRITE request.
    
    The file position is at the start of the file when the file is opened, and is lost
    when the file is closed. 
    
    Perform the file operation as a single action whenever possible. For example, do
    not split a write of 16KB into four 4KB chunks unless there is no alternative.

    Entry
    On entry, R1 contains a pointer to a three-word data block:
    
        word 1
            contains a handle for a file previously opened with SYS_OPEN
        word 2
            points to the memory containing the data to be written
        word 3
            contains the number of bytes to be written from the buffer to the file.

    Return
    On exit, r0 contains:
        * 0 if the call is successful
        * the number of bytes that are not written, if there is an error.
    */
    WRITE        = 0x05,

    /**
    Writes a character byte, pointed to by R1, to the debug channel.
    When executed under an ARM debugger, the character appears on the host debugger console.

    Entry
    On entry, r1 contains a pointer to the character.

    Return
    None. Register r0 is corrupted.
    */
    WRITEC       = 0x03,

    /**
    Writes a null-terminated string to the debug channel.

    When executed under an ARM debugger, the characters appear on the host debugger console.
    
    Entry
    On entry, r1 contains a pointer to the first byte of the string.
    
    Return
    None. Register r0 is corrupted.
    */
    WRITE0       = 0x04
}

/**
Performs a semihosting operation.
Params:
    command = The semihosting operation to perform
    message = The message to accompany the operation
*/
private int call(in SYS operation, in void* message)
{
    int value = void;

    version(GNU)
    {
        asm
        {
            "mov r0, %[op]; 
            mov r1, %[msg]; 
            bkpt #0xAB;
            mov %[retVal], r0;"
            : [retVal] "=r" value                             
            : [op] "r" operation, [msg] "r" message
            : "r0", "r1", "memory";
        };
    }

    return value;
}

/**
Writes data to a file handle returned from a call to open
Params:
    fileHandle = A file handle retuned from a call to open
    data = An array of data to write to fileHandle
Returns:
    0 if the call is successful, or the number of bytes not written if there is an error
See Also:
    open
*/
size_t write(T)(in size_t fileHandle, in T[] data)
{
    uint[3] message =
    [
        cast(uint)fileHandle
        , cast(uint)data.ptr
        , cast(uint)(data.length * T.sizeof)
    ];
    return cast(size_t)call(SYS.WRITE, &message);
}

/**
Writes a single 8-bit item to the debug channel.
Params:
    data = The 8-bit item to write
*/
void write(T)(in T data)
    if(T.sizeof == ubyte.sizeof)
{
    call(SYS.WRITEC, &data);
}

/**
Writes a null-terminated array of 8-bit items to the debug channel.
Params:
    data = The null-terminated array of 8-bit items to write
*/
void write(T)(in T* data)
    if (T.sizeof == ubyte.sizeof)
{
    call(SYS.WRITE0, data);
}