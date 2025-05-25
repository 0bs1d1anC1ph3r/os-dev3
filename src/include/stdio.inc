%ifndef __STDIO_INC_67343546FDCC56AAB872_INCLUDED__
%define __STDIO_INC_67343546FDCC56AAB872_INCLUDED__

        ;;
        ;; printing in 16 bit real mode
        ;;

bits 16

puts:
    pusha                      		   ; save registers

.print_loop:
		lodsb                      	   ; load next byte from string from SI to AL
		or	al, al			           ; is next char null
		jz	.print_loop_done           ; if null jump to .print_loop_done
		mov	ah, 0x0E		           ; print the character
		int	10h		    	           ; invoke BIOS
		jmp	.print_loop 	           ; loop

.print_loop_done:
		popa                           ; restore registers
		ret			    	           ; we are done, so return

%endif ;__STDIO_INC_67343546FDCC56AAB872_INCLUDED__
