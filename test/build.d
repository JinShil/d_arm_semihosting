#!/usr/bin/rdmd

import std.algorithm;
import std.array;
import std.file;
import std.path;
import std.process;
import std.stdio;

void run(string cmd)
{
    writeln(cmd);
    auto result = executeShell(cmd);
    writeln(result.output);
}

void main(string[] args)
{
    immutable auto sourceDir = "source";
    immutable auto binaryDir = "binary";
    immutable auto objectFile = buildPath(binaryDir, "firmware.o");
    immutable auto outputFile = buildPath(binaryDir, "firmware");

    // Create any directories that may not exist
    if (!binaryDir.exists())
    {
        mkdir(binaryDir);
    }

    // remove any intermediate files
    auto cmd = "rm -f " ~ binaryDir ~ "/*";
    run(cmd);

    immutable auto sourceFiles = sourceDir
		.dirEntries("*.d", SpanMode.depth)
        .map!"a.name"
        .join(" ");

    // compile to temporary assembly file
    cmd = "arm-none-eabi-gdc -c -g -Os -nophoboslib -nostdinc -nodefaultlibs -nostdlib"
          ~ " -mthumb -mcpu=cortex-m4 -mtune=cortex-m4"
          ~ " -fno-bounds-check"
          ~ " -fno-invariants"
          ~ " -fno-in"
          ~ " -fno-out"
          ~ " -fno-assert"          
          ~ " -ffunction-sections"
          ~ " -fdata-sections" 
          
          ~ " " ~ sourceFiles
          ~ " -o " ~ objectFile;                  
    run(cmd);

    // cmd = "ldc2 -c -march=thumb -mcpu=cortex-m4"
    //       ~ " " ~ sourceFiles
    //       ~ " -of " ~ objectFile;                  
    // run(cmd);

    // link, creating executable
    cmd = "arm-none-eabi-ld " ~ objectFile ~ " -Tlinker.ld --gc-sections -o " ~ outputFile;
    run(cmd);
    
    // display the size
    run("arm-none-eabi-size " ~ outputFile);
}