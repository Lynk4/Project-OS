;; -----------------------------------------------------------
;; Print Strings using SI register
;; -----------------------------------------------------------
print_string:
	pusha						;push all the registers
	mov ah, 0x0e                ; int 10h/ ah 0x0e BIOS teletype output
	mov bh, 0x0                 ; page number
	mov bl, 0x07                ; color

print_char:
	lodsb                ; move character value at address in bx into al
	cmp al, 0
	je end_print                ; jump if equal (al = 0) to halt label
	int 0x10                    ; print character in al
	jmp print_char              ; loop

end_print:
	popa
	ret
