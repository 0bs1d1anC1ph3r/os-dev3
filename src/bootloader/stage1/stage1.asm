org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

jmp short bootloader_start
nop

    ;;
    ;; Disk description table
    ;;
OEMLabel                db 'DISKBOOT'
BytesPerSector          dw 512
SectorsPerCluster       db 1
ReservedForBoot         dw 1
NumberOfFats            db 2
RootDirEntries          dw 0E0h

LogicalSectors          dw 2880
MediumByte              db 0F0h
SectorsPerFat           dw 9
SectorsPerTrack         dw 18
Sides                   dw 2
HiddenSectors           dd 0
LargeSectors            dd 0

DriveNo                 db 0
                        db 0    ; reserved
Signature               db 29h
VolumeID                dd 12h, 34h, 56h, 78h
VolumeLabel             db 'FUCK YOU   '
FileSystem              db 'FAT12   '

    ;;
    ;; Main bootloader code
    ;;

%include "stdio.inc"

bootloader_start:
    mov ax, 0               ; 4k stack space above buffer
    mov ds, ax
    mov es, ax

    mov ss, ax
    mov sp, 0x7C00

    push es
    push word .after
    retf

.after:
    mov [DriveNo], dl

    mov si, msg_loading
    call puts

    push es
    mov ah, 08h             ; get drive parameters
    int 13h

    jc fatal_disk_error
    pop es

    and cl, 0x3F                ; maximum sector number
    xor ch, ch
    mov [SectorsPerTrack], cx   ; sector numbers start at 1

    inc dh
    mov [Sides], dh

    ;;
    ;; Load the root directory from the disk
    ;; Start of root = ReservedForRoot + NumberOfFats * SectorsPerFat = logical 19
    ;; Number of root = RootDirEntries * 32 bytes/entry / 512 bytes/sector = 14
    ;; Start of usr data = (start of root) + (number of root) = logical 33
    ;;

.read_root_dir:
    ;; calculate root directory start LBA
    mov ax, [SectorsPerFat]
    mov bl, [NumberOfFats]
    xor bh, bh
    mul bx
    add ax, [ReservedForBoot]
    push ax                 ; save start sector

    ;; calculate the root dir size
    mov ax, [RootDirEntries]
    shl ax, 5
    xor dx, dx
    div word [BytesPerSector]
    test dx, dx
    jz .skip_inc
    inc ax

.skip_inc:
    mov cl, al          ; root directory size

    pop ax              ; restore root directory start LBA
    mov dl, [DriveNo]   ; dl = drive number
    mov bx, buffer      ; es:bx = buffer
    call disk_read

    xor bx, bx              ; search for stage2.bin
    mov di, buffer

.search_stage2:
    mov si, file_stage2_bin
    mov cx, 11
    push di
    repe cmpsb
    pop di
    je .found_stage2

    add di, 32
    inc bx
    cmp bx, [RootDirEntries]
    jl .search_stage2

    jmp stage2_not_found_error

.found_stage2:
    mov ax, [di + 26]           ; first logical cluster field (offset 26)
    mov [stage2_cluster], ax

    ;; load FAT from disk into memory
    mov ax, [ReservedForBoot]
    mov bx, buffer
    mov cl, [SectorsPerFat]
    mov dl, [DriveNo]

    call disk_read

    ;; Read stage2 and process FAT chain
    mov bx, STAGE2_LOAD_SEGMENT
    mov es, bx
    mov bx, STAGE2_LOAD_OFFSET

.load_stage2_loop:
    ;; read the next cluster
    mov ax, [stage2_cluster]
    sub ax, 2                   ; clusters start at 2
    movzx cx, byte [SectorsPerCluster]
    mul cx                      ; AX = (cluster - 2) * secs_per_cluster
    add ax, 33
    mov cl, 1
    mov dl, [DriveNo]
    call disk_read

    add bx, [BytesPerSector]

    ;; compute location of next cluster
    mov ax, [stage2_cluster]
    mov cx, 3
    mul cx
    mov cx, 2
    div cx                      ; ax = index of entery in FAT, dx = cluster mod 2

    mov si, buffer              ; buffer
    add si, ax
    mov ax, [ds:si]             ; read entery from FAT table at index ax

    or dx, dx
    jz .even

.odd:
    shr ax, 4
    jmp .next_cluster_after

.even:
    and ax, 0x0FFF

.next_cluster_after:
    cmp ax, 0x0FF8              ; end of chain
    jae .read_finish

    mov [stage2_cluster], ax
    jmp .load_stage2_loop

.read_finish:
    ;; jmp to stage2
    mov dl, [DriveNo]

    ;; set segment registers
    mov ax, STAGE2_LOAD_SEGMENT
    mov ds, ax
    mov es, ax

    jmp STAGE2_LOAD_SEGMENT:STAGE2_LOAD_OFFSET

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
    dec di              ; reduce retry count
    test di, di
    jnz .retry          ; try again if di > 0

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

    ;;
    ;; Error handlers
    ;;

fatal_disk_error:
    mov si, msg_read_failed
    call puts
    jmp wait_key_and_reboot

stage2_not_found_error:
    mov si, msg_stage2_not_found
    call puts
    jmp wait_key_and_reboot


wait_key_and_reboot:
    mov ah, 0
    int 16h
    int 0x19

    ;;
    ;; Variables and stuff
    ;;

msg_loading:            db 'Loading...', ENDL, 0
msg_read_failed:        db 'Disk failed', ENDL, 0
msg_stage2_not_found:   db 'No STAGE2.bin', ENDL, 0
file_stage2_bin:        db 'STAGE2  BIN'
stage2_cluster:         dw 0
STAGE2_LOAD_SEGMENT     equ 0x0
STAGE2_LOAD_OFFSET      equ 0x500

times 510-($-$$) db 0
dw 0xAA55

buffer:
