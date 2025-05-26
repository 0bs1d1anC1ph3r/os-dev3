%ifndef __FLOPPY16_INC_673JGHFF43CC56AAB872_INCLUDED__
%define __FLOPPY16_INC_673JGHFF43CC56AAB872_INCLUDED__

        ;;
        ;; MUST HAVE stdio.inc INCLUDED BEFORE YOU INCLUDE THIS, AS WELL AS bdp.inc INCLUDED BEFORE THIS!!!
        ;; MUST ALSO HAVE A fatal_disk_error FUNCTION DEFINED
        ;;

bits 16

lba_to_chs:
    push ax
    push dx

    xor dx, dx                  ; dx = 0
    div word [SectorsPerTrack]  ; ax = LBA / SectorsPerTrack

    inc dx                      ; dx = (LBA % SectorsPerTrack + 1) = sector
    mov cx, dx                  ; cx = sector

    xor dx, dx                  ; dx = 0
    div word [Sides]            ; ax = (LBA / SectorsPerTrack) / Sides = cylinder
                                ; dx = (LBA / SectorsPerTrack) % Sides = side
    mov dh, dl                  ; dh = side
    mov ch, al                  ; ch = cylinder (lower 8 bits)
    shl ah, 6
    or cl, ah                   ; put upper 2 bits of cylinder in CL

    pop ax
    mov dl, al                  ; restore dl
    pop ax
    ret

    ;;
    ;; Disk read
    ;; params:
    ;; ax = LBA addr
    ;; cl = number of sectors to read (up to 128)
    ;; dl = drive number
    ;; es:bx memory addr to store read data
    ;;

disk_read:
    push ax
    push bx
    push cx
    push dx
    push di

    push cx
    call lba_to_chs             ; modifies CH, CL, DH
    pop ax

    mov ah, 02h
    mov di, 3                   ; retry count

.retry:
    pusha
    stc
    int 13h
    jnc .done           ; if success, jump to done

    popa
    call disk_reset     ; reset disk on error
    dec di
    jnz .retry
    jmp fatal_disk_error

.done:
    popa

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

disk_reset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc fatal_disk_error
    popa
    ret

%endif
