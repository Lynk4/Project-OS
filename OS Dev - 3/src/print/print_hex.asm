;;prints hexadecimal values using register DX and print_string.asm

;; 
;;Ascii 0-9 A-F = hex 0x30-0x39
;;Ascii A-F = hex 0x41-0x46
;;Ascii a-f = hex 0x61-0x66
print_hex:
    pusha
    mov cx, 0                   ;initialize loop counter

hex_loop:
    cmp cx, 4                   
    je end_hexloop

    ;;convert DX hex values to ascii
    mov ax, dx
    and ax, 0x000F 
    add al, 0x30             ;0001 0010 1010 1011 
    cmp al, 0x39                ; is hex value 0-9 
    jle move_intoBX
    add al, 0x7                 ; get ascii

move_intoBX:
    mov bx, hexString + 5   ;base address + length of string
    sub bx, cx              ;subtract loop counter;increment the counter
    mov [bx], al
    ror dx, 4   
                
    add cx, 1 
    jmp hex_loop

    ;;Move ascii char into bx string

end_hexloop:
    mov bx, hexString
    call print_string

    popa
    ret

    ;; Data
hexString:  db '0x0000', 0
