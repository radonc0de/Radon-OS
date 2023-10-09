#ifndef IDT_H
#define IDT_H

#include <stdint.h>
struct idt_desc
{
	uint16_t offset_1; // Offset bits 0 - 15
	uint16_t selector; // Selectors thats in GDT
	uint8_t zero; // Does nothing, unnused set to zero
	uint8_t type_attr; // Descriptor type and attributes
	uint16_t offset_2; // Offset bits 16-21
} __attribute__((packed));

struct idtr_desc
{
	uint16_t limit; // Size f descriptor table - 1
	uint32_t base; // Base address of the start of the IDT
} __attribute__((packed));

void idt_init();
void enable_interrupts();
void disable_interrupts();

#endif