%ifndef __STDIO_32_INC_67343546FDCC56AAB872_INCLUDED__
%define __STDIO_32_INC_67343546FDCC56AAB872_INCLUDED__

        ;;
        ;; printing in 32 protected mode
        ;;

bits 32

%define COLS_BYTES (COLS*2)
%define VIDMEMORY      0xB8000          ; video memory
%define COLS           80               ; width
%define LINES          25               ; length
%define CHAR_ATTRIBUTE 7                ; character attribute (white text on black background)

_CurX db 0                              ; cursor x location
_CurY db 0                              ; cursor y location

      ;;
      ;; print a character
      ;;

putch32:
    pusha                               ; save registers
    mov   edi, VIDMEMORY

    movzx eax, byte [_CurY]             ; zero-extend Y
    imul  eax, COLS                     ; EAX = Y * 80

    movzx ecx, byte [_CurX]             ; zero-extend X
    add   eax, ecx                      ; EAX = Y*80 + X

    shl   eax, 1                        ; 2 bytes per cell → EAX = byte offset

    add   edi, eax                      ; edi → VIDMEMORY + offset

    cmp   bl, 0x0A                      ; is new line?
    je    .newline                      ; if yes make a new line

    mov   ah, CHAR_ATTRIBUTE            ; character attribute
    mov   al, bl
    mov   [edi], ax

    inc   byte [_CurX]
    cmp   byte [_CurX], COLS            ; if past cols, go to new lew
    jb    .done

.newline:
    mov   byte [_CurX], 0
    inc   byte [_CurY]

.done:
    popa                                ; restore registers
    ret                                 ; return

      ;;
      ;; print a string
      ;;

puts32:
    pusha                               ; save registers
    mov edi, edx                        ; edx must be the string

.loop:
    mov bl, byte [edi]                  ; get the next character
    cmp bl, 0                           ; is the next character 0 (NULL terminator)
    je .done                            ; if NULL terminator jump to .done

    call putch32                        ; call the putch32 (put character)

    inc edi                             ; go to the next character
    jmp .loop                           ; keep looping
.done:
    mov bh, byte [_CurY]                ; get cursor y position
    mov bl, byte [_CurX]                ; get cursor x position
    call move_cursor                    ; update the cursor

    popa                                ; restore registers
    ret                                 ; return

move_cursor:
    pusha                               ; save registers

      ;; get cursor position

    xor eax, eax                        ; clear eax
    mov al, [_CurY]                     ; get y position
    mov cl, COLS
    mul cl                              ; EAX = y * COLS
    add al, [_CurX]                     ; add x

    mov bx, ax                          ; bx = final offset (character index)

      ;; set low byte cursor index to VGA register

    mov dx, 0x03D4                      ; write to CRT intex register
    mov al, 0x0F
    out dx, al                          ; low byte

    mov dx, 0x03D5                      ; write to data register
    mov al, bl
    out dx, al                          ; low byte

      ;; set high byte cursor index to VGA register

    xor eax, eax                        ; clear eax

    mov dx, 0x03D4                      ; write to CRT index register
    mov al, 0x0E
    out dx, al                          ; high byte

    mov dx, 0x03D5                      ; write to data register
    mov al, bh
    out dx, al                          ; high byte

    popa                                ; restore registers
    ret                                 ; return

clear_screen32:
    pusha                               ; save registers
    cld
    mov edi, VIDMEMORY                  ; set video memory
    mov cx, 2000
    mov ah, CHAR_ATTRIBUTE              ; set character attribute
    mov al, ' '
    rep stosw

    mov byte [_CurX], 0                 ; set cursor x to 0
    mov byte [_CurY], 0                 ; set cursor y to 0

    popa                                ; restore registers
    ret                                 ; return

%endif ;__STDIO_32_INC_67343546FDCC56AAB872_INCLUDED__
