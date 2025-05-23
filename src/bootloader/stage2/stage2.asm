org 0x0000
bits 16

jmp start

%include "gdt.inc"
%include "stdio.inc"

%define ENDL 0x0D, 0x0A

start:
    cli
    mov ax, 0x2000
    mov ds, ax
    mov si, msg_loading
    call puts
.halt:
    cli
    hlt

msg_loading: db 'Preparing to load operating system...', ENDL, 0
