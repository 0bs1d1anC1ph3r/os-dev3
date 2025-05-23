%include "stdio.inc"

org 0x0
bits 16


%define ENDL 0x0D, 0x0A

start:
    ; print hello world message
    cli
    push cs
    pop ds
    mov si, msg_loading
    call puts

.halt:
    cli
    hlt

msg_loading: db 'Preparing to load operating system...', ENDL, 0
