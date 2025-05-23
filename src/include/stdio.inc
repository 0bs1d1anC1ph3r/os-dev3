%ifndef __STDIO_INC_98076GH98798HJGGH_INCLUDED__
%define __STDIO_INC_98076GH98798HJGGH_INCLUDED__

bits 16

    ;;  Prints a string to the screen
    ;;  Params:
    ;;      - ds:si points to a string
    ;;

puts:
    ;; save registers we will modify
    push si
    push ax
    push bx

.loop:
    lodsb                       ; loads next character in al
    or al, al                   ; verify if next character is NULL?
    jz .done

    mov ah, 0x0E                ; call bios interrupt
    mov bh, 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret

%endif ;__STDIO_INC_98076GH98798HJGGH_INCLUDED__
