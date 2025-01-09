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

	;; Tele-type output
				
	mov bx, testString			;moving memory address at testString
	call print_string			
	mov bx, string2
	call print_string

	mov dx, 0x12AB				;sample hex numbers to print
	call print_hex
	;; end pgm
	jmp $						;keep jumping to here; never ending
	
	;;included files
	include 'print_string.asm'
	include 'print_hex.asm'

	
testString: db 'char TEST: Testing', 0xA, 0xD, 0 		;0/null to null terminate

string2: 	db 'Hex Test:', 0



	;;Boot Sector Magic........
	times 510-($-$$) db 0		;pad file with 0s until 510th Byte
	dw 0xaa55					;BIOS magic number 512th Bytes
