;; Prints characters from strings in bx register.

print_string:
	pusha						;store all registers value on the stack
	mov ah, 0x0e
print_char:

	mov al, [bx]				;move character value at address in bx into al
	cmp al, 0					;jump if equal (al=0) to halt
	je end_print
	int 0x10					;print character in al
	add bx, 1					;move 1 byte forward to get next char
	jmp print_char				;loop

end_print:
	popa						;restore reg from stack
	ret
