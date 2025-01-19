;;;
;;; Kernel.asm: basic 'kernel' loaded from our bootsector
;;;
    ;; Set video mode
    mov ah, 0x00                ; int 0x10/ ah 0x00 = set video mode
    mov al, 0x01                ; 40x25 text mode
    int 0x10

    ;; Change color/Palette
    mov ah, 0x0B
    mov bh, 0x00
    mov bl, 0x01
    int 0x10

    ;;Print Screen heading & Menu options
    mov si, menuString
    call print_string

    ;;;Get user input..print chosen choose menu options..
get_input:
        mov di, cmdString         ;di now pointing to cmdString
keyloop:
    mov ah, 0x00                 ;ah = 0x00, al=0x00
    int 0x16                      ;BIOS int get keystrokes

    mov ah, 0x0e
    cmp al, 0xD                 ;Did user press 'enter' key?
    je run_command
    int 0x10                     ;print input character to Screen.
    mov [di], al
    inc di
    jmp keyloop                  ;loop for next char from user.

run_command:
    mov byte [di], 0
    mov al, [cmdString]
    cmp al, 'F'                ;fileTable command.
    jne not_found
    cmp al, 'N'
    je end_Program
    mov si, success
    call print_string
    jmp get_input

not_found:
    mov si, failure
    call print_string
    jmp get_input

print_string:
    mov ah, 0x0e                ; int 10h/ ah 0x0e BIOS teletype output
    mov bh, 0x0                 ; page number
    mov bl, 0x07                ; color

print_char:
    mov al, [si]                ; move character value at address in bx into al
    cmp al, 0
    je end_print                ; jump if equal (al = 0) to halt label
    int 0x10                    ; print character in al
    add si, 1                   ; move 1 byte forward/ get next character
    jmp print_char              ; loop

end_print:
    ret
end_Program:
    cli                         ;clear interrupts
    hlt                         ; halt the cpu


menuString:     db '-----------------------------------------', 0xA, 0xD,\
                'Kernel Booted, Welcome Mr. K4nt..!', 0xA, 0xD, \
                '-----------------------------------------', 0xA, 0xD, 0xA, 0xD, \
                'F) File & Program Browser/Loader', 0xA, 0xD, 0

success:    db 0xA, 0xD, 'Command run succesfully!..', 0xA, 0xD, 0
failure:    db 0xA, 0xD, 'OOPS something went wrong!... :(', 0xA, 0xD, 0
cmdString:  db ''
    ;; Sector Padding magic
    times 512-($-$$) db 0       ; pads out 0s until we reach 512th byte
