bits 16
org 0x500

%define ENDL 0x0D, 0x0A

%include "stdio.inc"

start:
    ; print loading msg
    cli
    push cs
    pop ds
    mov si, msg_loading
    call puts

.halt:
    cli
    hlt

msg_loading: db 'Preparing to load operating system...', ENDL, 0
