# Radon-OS
Using [this Udemy course](https://www.udemy.com/course/developing-a-multithreaded-kernel-from-scratch/) as a template to build a fully-functional multithreaded kernel

## Real Mode Development

- For creating the bootloader, a 16-bit assembly code file is used to give the processor some very basic instructions in Real Mode. These are used to print a message, handle and invoke interrupts and access the disk
- Limited to 1MB of memory

## Protected Mode Development

- Processor has different levels of protection that control how memory and hardware can be accessed by the processor
    - Kernel runs in most priviledged ring, while programs run in least priviledged. Drivers can be ran in levels in between.
- For 32-bit instructions, up to 4GB of memory are addressable
- [Switching to protected mode](https://wiki.osdev.org/Protected_Mode)
    1. `lgdt` will load Global Descriptor Table
    2. Set protection enable bit in CR0 (control register 0)
    3. Jump to selector and offset of where to load
- [Enable A20 Line](https://wiki.osdev.org/A20)
    - Fast A20 gate can enable a20 line
- [Creating a cross-compiler for `gcc`](https://wiki.osdev.org/GCC_Cross-Compiler)
    1. Install necessary packages
    2. Download `gcc` and `binutils` source code
    3. Compile and install packages as cross-compiler
- Extracting kernel code and loading into memory separately
    - 32 bit code gets extracted to a separate kernel assembly file which gets linked to boot script
    - Linker file defines how file gets linked
    - Makefile uses the linker file to link the objects and generate the os binary
    - [ATA driver for reading from disk](https://wiki.osdev.org/ATA_read/write_sectors)
    - Alignment issues need to be dealt with as putting assembly objects first in linker can cause issues
- Running C code in protected mode
    - C objects must be compiled and objects linked, then C functions can be ran from kernel assembly script
- Hello world in C manually
    - Must set video memory manually
    - Each character is two bytes, the ASCII equivalent, then the color code.
- [Creating Interrupt Descriptor Table](https://wiki.osdev.org/Interrupt_Descriptor_Table)
	- Define interrupt descriptor table entries and register
	- A function can then be used to set interrupts 
	- Basic `memset` created to write decriptor table to memory 
- Implementing IO functions
	- Mapping C functions around assembly to allow for 1 or 2 byte input/output
- Programmable Interrupt Controller
	- Handles hardware interrupts, such as clock, keyboard inputs, disk input, etc
	- PIC needs to be remapped to start at ISR 0x20, this is where it typically starts
	- Main implementation thus far involves pushing general purpose registers to the stack using `pushad`, calling C code to handle the interrupt, writing out a 0x20 to 0x20 to acknolwedge the end of the interrupt handler, then using `popad` to restore general purpose registers and continue operation
- Implementing the heap
	- Basic heap implementation uses a memory block table to keep track of free and allocated blocks using bit flags
	- While this design does make implementation simple, this does lead to fragmentation. Page tables should be able to help this though.
	- The heap and its block table must be initialized in memory using `memset`.
	- `kmalloc`:
		- Find how many blocks are needed to fit the entire memory request.
		- Iterate through the block table to find the first occurrance of the amount of free blocks needed that are continuous.
		- Set the proper flags on these blocks and return the pointer.
	- `kfree`: 
		- Find which block index the pointer provided to free references.
		- Starting at this index in the block table, mark blocks as free until a block does not have the HEAP_BLOCK_HAS_NEXT flag set.