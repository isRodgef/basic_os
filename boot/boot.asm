;; how does the gdt look here? and the loading of protected mode?
[org 0x7c00]
[bits 16]

section code

.switch:
    mov ax, 0x4f01 ; query for VBE mode
    mov cx, 0x117 ; set to mode we want
    mov bx, 0x0800 ; set to 800x600
    mov es, bx
    mov di, 0x00
    int 0x10 ; call BIOS

    ; make switch to graphics mode
    mov ax, 0x4f02
    mov bx, 0x117
    int 0x10

    xor ax, ax
    mov ds, ax
    mov es, ax

    mov bx, 0x1000 ; Location to load kernel from hard disk
    mov ah, 0x02
    mov al, 1 ;30 ; Number of sectors to read
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    int 0x13 ; Read sectors

    cli
    lgdt [gdt_descriptor] ; Load the GDT descriptor

    mov eax, cr0 ; Get CR0
    or eax, 0x01 ; Set protected mode bit
    mov cr0, eax ; Set CR0

    ; Far jump to switch to protected mode
    jmp code_seg:protected_mode ; Load new code segment

[bits 32]
protected_mode:
    ; Set up segment registers for protected mode
    mov ax, data_seg
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Set up the stack
    mov ebp, 0x90000
    mov esp, ebp

    ; Call kernel
    call 0x1000
    jmp $

gdt_begin:
gdt_null_descriptor:
    dd 0x00
    dd 0x00
gdt_code_seg:
    dw 0xffff
    dw 0x00
    db 0x00
    db 10011010b ; Code segment descriptor flags
    db 11001111b
    db 0x00
gdt_data_seg:
    dw 0xffff
    dw 0x00
    db 0x00
    db 10010010b ; Data segment descriptor flags
    db 11001111b
    db 0x00
gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_begin - 1
    dd gdt_begin

code_seg equ gdt_code_seg - gdt_begin
data_seg equ gdt_data_seg - gdt_begin

welcome: db 'Welcome to Poes OS',0

times 510 - ($ - $$) db 0x00

db 0x55
db 0xaa
