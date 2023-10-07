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



