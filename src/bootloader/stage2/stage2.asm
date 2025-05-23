org 0x0000
bits 16

%define ENDL 0x0D, 0x0A

jmp start                       ; Go to start

%include "gdt.inc"
%include "stdio.inc"

start:
    cli
    mov ax, 0x2000
    mov ds, ax
    mov si, msg_protected_mode
    call puts
.halt:
    cli
    hlt

msg_protected_mode: db 'Entering protected mode...', ENDL, 0
