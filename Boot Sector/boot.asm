;;
;; Simple boot Program....that prints a message..
;;
	org 0x7c00					; 'origin' of boot code
	
	;; set video mode......
	mov ah, 0x00				;int 0x10 ah 0x00 = set video mode
	mov al, 0x03				;80x25 text mode	
	int 0x10

	;;change color
	mov ah, 0x0B
	mov bh, 0x00
	mov bl, 0x01
	int 0x10 


	mov ah, 0x0e				;int 10/ ah 0x0e BIOS teletype
	mov bx, testString			;moving memory address at testString
	call print_string			
	mov bx, string2
	call print_string
	jmp end_pgm

print_string:
	mov al, [bx]				;move character value at address in bx into al
	cmp al, 0					;jump if equal (al=0) to halt
	je end_print
	int 0x10					;print character in al
	add bx, 1					;move 1 byte forward to get next char
	jmp print_string			;loop

end_print:
	ret

testString: db 'TEST', 0xA, 0xD, 0 		;0/null to null terminate

string2: 	db 'Hello Lynk4', 0

end_pgm:

	jmp $

	;;Boot Sector Magic........
	times 510-($-$$) db 0		;pad file with 0s until 510th Byte
	dw 0xaa55					;BIOS magic number 512th Bytes


