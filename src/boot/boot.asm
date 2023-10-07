ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start
    nop
    
 times 33 db 0

start:
    jmp 0:step2

step2:
    cli ; Clear Interrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enables Interrupts

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32
    ;jmp $

; GDT
gdt_start:

gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
gdt_code:       ; CS SHOULD POINT TO THIS
    dw 0xffff   ; Segment limit first 0-15 bits
    dw 0        ; Base first 0-15 bits
    db 0        ; Base 16-23 bits
    db 0x9a     ; Access byte
    db 11001111b    ; High 4 bit flags and low 4 bit flags
    db 0        ; Base 24-31 bits

; offset 0x10
gdt_data:       ; Linked to DS, SS, ES, FS, GS
    dw 0xffff   ; Segment limit first 0-15 bits
    dw 0        ; Base first 0-15 bits
    db 0        ; Base 16-23 bits
    db 0x92     ; Access byte
    db 11001111b    ; High 4 bit flags and low 4 bit flags
    db 0        ; Base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1
    dd gdt_start

[BITS 32]
load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax ; Backup the LBA
    ; Send highest 8 bits of the lba to hdd controller
    shr eax, 24
    or eax, 0xE0 ; Select the master drive
    mov dx, 0x1F6
    out dx, al
    ; Finished sending highest 8 bits of lba

    ; Send total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ; Finished sending the total sectors to read

    mov eax, ebx ; Restore backup LBA
    mov dx, 0x1F3
    out dx, al
    ; Finshed sending more bits of LBA

    mov dx, 0x1F4
    mov eax, ebx; Restore backup LBA
    shr eax, 8
    out dx, al
    ; Finished  sending more bits of LBA

    ; Send upper 16 bits of LBA
    mov dx, 0x1F5
    mov eax, ebx ; Restore backup LBA
    shr eax, 16
    out dx, al
    ; Finished sending upper 16 bits of LBA

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; Read all sectors to memory
.next_sector:
    push ecx

; Checking if we need to read
.try_again:
    mov dx, 0x1f7
    in al, dx
    test al, 8
    jz .try_again

; Read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ; End of reading sectors to memory
    ret


times 510-($ - $$) db 0
dw 0xAA55


