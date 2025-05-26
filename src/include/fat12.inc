%ifndef __FAT12_INC_354GHF7556FDCC56AAB_INCLUDED__
%define __FAT12_INC_354GHF7556FDCC56AAB_INCLUDED__

        ;;
        ;; THE INCLUDE "floppy16.inc" MUST BE INCLUDED BEFORE THIS
        ;;

%define ROOT_OFFSET 0x2e00
%define FAT_SEG 0x2c0
%define ROOT_SEG 0x2e0

datasector  dw 0x0000
cluster     dw 0x0000

absoluteSector db 0x00
absoluteHead   db 0x00
absoluteTrack  db 0x00

        ;; load the root

load_root:
    pusha
    push es                            ; store registers

    xor cx, cx
    xor dx, dx
    mov ax, 32                         ; size of one dir entry
    mul word [RootDirEntries]          ; total bytes for root dir
    div word [BytesPerSector]          ; number of sectors
    xchg ax, cx                        ; save to cx (sectors to read)

    mov al, byte [NumberOfFats]
    mul word [SectorsPerFat]
    add ax, word [ReservedForBoot]
    mov word [datasector], ax          ; start of root dir

    push word ROOT_SEG
    pop es
    mov bx, 0x0000                     ; offset

    mov ax, word [datasector]          ; LBA address of root
    mov dl, [DriveNo]                  ; set drive number (must be passed to load_root earlier)
    mov ax, word [datasector]
    mov dl, [DriveNo]
    call disk_read

    pop es                             ; restore registers
    popa
    ret                                ; return

    ;;
    ;; load the fat
    ;;

load_fat:
    pusha
    push es

    xor ax, ax
    mov al, byte [NumberOfFats]
    mul word [SectorsPerFat]
    mov cx, ax                        ; sectors to read

    mov ax, word [ReservedForBoot]    ; FAT begins right after reserved sectors

    push word FAT_SEG
    pop es
    xor bx, bx

    mov dl, [DriveNo]                ; set drive number

    call disk_read

    pop es                           ; restore registers
    popa
    ret                              ; return

    ;;
    ;; find the file
    ;;

find_file:
    push cx                          ; store registers
    push dx
    push bx
    mov bx, si                       ; copy filename

    mov cx, word [RootDirEntries]    ; load loop counter
    mov edi, ROOT_OFFSET             ; locate first root entry
    cld                              ; clear direction flag

.loop:
    push cx
    mov cx, 11                       ; 11 character name in si
    mov si, bx                       ; image name in bx
    push di
    rep cmpsb                        ; test for match
    pop di
    je .found
    pop cx
    add di, 32                       ; next directory entry
    loop .loop

.not_found:
    pop bx                           ; restore registers
    pop dx
    pop cx
    mov ax, -1                       ; set error code
    ret                              ; return

.found:
    pop bx                           ; restore registers
    pop dx
    pop cx
    mov ax, di
    ret                              ; return

    ;;
    ;; load the file
    ;;

load_file:
    xor ecx, ecx
    push ecx

.find_file:
    push bx                          ; bx -> bp points to buffer
    push bp

    call find_file                   ; find the file
    cmp ax, -1                       ; check for error
    jne .load_image_pre
    pop bp
    pop bx
    pop ecx
    mov ax, -1
    ret                              ; error

.load_image_pre:
    push word ROOT_SEG
    mov di, ax
    mov dx, word [es:di + 0x1A]      ; es:di points to a file entry in the root directory table
    mov word [cluster], dx           ; reference the table for first file cluster
    pop bx
    pop es
    push bx
    push es
    call load_fat

.load_image:
    mov ax, [cluster]
    cmp ax, 0x000
    je done
    cmp ax, 0xFF0
    jae done

    push bx
    push es
    mov dl, [DriveNo]
    mov cx, 1
    call lba_to_chs
    call disk_read
    pop es
    pop bx

    ; decode next cluster
    mov ax, [cluster]
    mov bx, ax
    mov dx, ax
    shr dx, 1
    add bx, dx
    mov ax, FAT_SEG
    mov es, ax
    mov dx, word [es:bx]
    test word [cluster], 1
    jz .even
    shr dx, 4
    jmp .next

.even:
    and dx, 0x0FFF

.next:
    mov [cluster], dx
    jmp .load_image

done:
    pop ecx
    ret

%endif
