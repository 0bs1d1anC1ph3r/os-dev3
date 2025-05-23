%ifndef __STDIO_INC_67343546FDCC56AAB872_INCLUDED__
%define __STDIO_INC_67343546FDCC56AAB872_INCLUDED__

bits 16

puts:
		pusha				; save registers
.print_loop:
		lodsb				; load next byte from string from SI to AL
		or	al, al			; Does AL=0?
		jz	.print_loop_done; Yep, null terminator found-bail out
		mov	ah, 0x0E		; Nope-Print the character
		int	10h		    	; invoke BIOS
		jmp	.print_loop		; Repeat until null terminator found
.print_loop_done:
		popa				; restore registers
		ret			    	; we are done, so return

%endif ;__STDIO_INC_67343546FDCC56AAB872_INCLUDED__
