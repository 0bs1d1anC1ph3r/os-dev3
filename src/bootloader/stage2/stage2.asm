org 0x500
bits 16

jmp start

%include "stdio32.inc"
%include "stdio.inc"
%include "gdt.inc"
%include "a20.inc"
%include "bdp.inc"
%include "floppy16.inc"
%include "fat12.inc"
%include "common.inc"

%define ENDL 0x0D, 0x0A

msg_loading: db 'Preparing to enter protected mode...', ENDL, 0
msg_read_failed: db 'Disk failed', ENDL, 0
msg_test:    db 'Here', ENDL, 0

fatal_disk_error:
    mov si, msg_read_failed
    call puts
    jmp wait_key_and_reboot

wait_key_and_reboot:
    mov ah, 0
    int 16h
    int 0x19

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

    call load_root               ; load root directory table

    mov bx, IMAGE_RMODE_BASE
    mov bp, IMAGE_RMODE_BASE
    mov esi, ImageName
    call load_file
    mov dword [ImageSize], ecx
    cmp ax, -1
    je enter_protected_mode
    mov si, msg_read_failed
    call puts
    mov ah, 0
    int 0x16
    int 0x19
    cli
    hlt

enter_protected_mode:
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

.copy_image:
    mov eax, dword [ImageSize]
    movzx ebx, word [BytesPerSector]
    mul ebx
    mov ebx, 4
    div ebx
    cld
    mov esi, IMAGE_RMODE_BASE
    mov edi, IMAGE_PMODE_BASE
    mov ecx, eax
    rep movsd

    jmp .hang

.fail:
    mov edx, msg_pm_fail         ; set edx to sad message
    call puts32                  ; if falure: print fail message to screen

.hang:
    cli
    hlt
    jmp .hang                    ; loop forever (until I make more shit like a kernel)


    msg_pm db 'Entered protected mode :)', 0x0A, 0
    msg_pm_fail db 'Failed to enter protected mode :(', 0x0A, 0
