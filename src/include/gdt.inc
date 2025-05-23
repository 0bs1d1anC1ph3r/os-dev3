%ifndef __GDT_INC_56757GHVFHBJHBJH876_INCLUDED__
%define __GDT_INC_56757GHVFHBJHBJH876_INCLUDED__

bits 16

install_gdt:
    cli                 ; clear interrupts
    pusha               ; save registers
    lgdt [toc]          ; load GDT into GDTR
    sti                 ; enable interrupts
    popa                ; restore registers
    ret                 ; return

gdt_data:
    dd 0                ; null descriptor
    dd 0

; gdt code:				; code descriptor
	dw 0FFFFh 			; limit low
	dw 0 				; base low
	db 0 				; base middle
	db 10011010b 		; access
	db 11001111b 		; granularity
	db 0 				; base high

; gdt data:				; data descriptor
	dw 0FFFFh 			; limit low (Same as code)
	dw 0 				; base low
	db 0 				; base middle
	db 10010010b 		; access
	db 11001111b 		; granularity
	db 0				; base high

end_of_gdt:
toc:
	dw end_of_gdt - gdt_data - 1 	; limit (Size of GDT)
	dd gdt_data 			; base of GDT

%endif ;__GDT_INC_56757GHVFHBJHBJH876_INCLUDED__
