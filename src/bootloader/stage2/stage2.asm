org 0x500
bits 16

jmp start

%include "stdio32.inc"
%include "stdio.inc"
%include "gdt.inc"
%include "a20.inc"

%define ENDL 0x0D, 0x0A
msg_loading: db 'Preparing to enter protected mode...', ENDL, 0

start:
    cli                          ; disable interrupts
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ax, 0x9000               ; stack begins at 0x9000 - 0xffff
    mov ss, ax
    mov sp, 0xFFFF
    sti                          ; enable interrupts

    mov si, msg_loading          ; Print loading message
    call puts

    call install_gdt             ; install the gdt
    call enable_a20_output_port

    ;; set PE bit
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode_start ; jump to protected mode at memory address 0x08

protected_mode_start:
    [bits 32]                    ; set to 32 bits

    mov ax, 0x10                 ; set up 32 bit stack
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000             ; set to safe location

    call clear_screen32          ; clear screen

    mov eax, cr0                 ; if not in 32 bit mode go to fail
    test eax, 1
    jz .fail                     ; jump to fail

    mov edx, msg_pm              ; set edx to happy message
    call puts32                  ; print the string with VGA
    jmp .hang                    ; jump to hang

.fail:
    mov edx, msg_pm_fail         ; set edx to sad message
    call puts32                  ; if falure: print fail message to screen

.hang:
    cli
    hlt
    jmp .hang                    ; loop forever (until I make more shit like a kernel)


    msg_pm db 'Entered protected mode :)', 0
    msg_pm_fail db 'Failed to enter protected mode :(', 0
