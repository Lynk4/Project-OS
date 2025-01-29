;;; =======================================================================
;;; Kernel.asm: basic 'kernel' loaded from our bootsector
;;; =======================================================================

    ;; --------------------------------------------------------------------
    ;; Screen & Menu Set up
    ;; --------------------------------------------------------------------
main_menu:
    ;; Reset screen state
    call resetTextScreen

    ;; print menu header & options
    mov si, menuString
    call print_string

    ;; --------------------------------------------------------------------
    ;; Get user input, print to screen & choose menu option or run command
    ;; --------------------------------------------------------------------
get_input:
    mov di, cmdString           ; di now pointing to cmdString
keyloop:
    mov ax, 0x00                ; ah = 0x00, al = 0x00
    int 0x16                    ; BIOS int get keystroke ah=00, character goes into al

    mov ah, 0x0e
    cmp al, 0xD                 ; did user press 'enter' key?
    je run_command
    int 0x10                    ; if not, print input character to screen
    mov [di], al                ; store input character to string
    inc di                      ; go to next byte at di/cmdString
    jmp keyloop                 ; loop for next character from user

run_command:
    mov byte [di], 0            ; null terminate cmdString from di
    mov al, [cmdString]
    cmp al, 'F'                 ; file table command/menu option
    je filebrowser
    cmp al, 'R'                 ; 'warm' reboot option
    je reboot
    cmp al, 'P'                 ; print register values
    je registers_print
    cmp al, 'G'                 ; graphics mode test
    je graphics_test
    cmp al, 'N'                 ; e(n)d our current program
    je end_program
    mov si, failure             ; command not found, boo! D:
    call print_string
    jmp get_input

    ;; -----------------------------------------------------------
    ;; Menu F) - File/Program browser & loader
    ;; -----------------------------------------------------------
filebrowser:
    ;; Reset screen state
    call resetTextScreen

    mov si, fileTableHeading
    call print_string

    ;; Load File Table string from its memory location (0x1000:0000), print file
    ;;  and program names & sector numbers to screen, for user to choose
    ;; -------------------------------------------------------------------
    xor cx, cx              ; reset counter for # chars in file/pgm name
    mov ax, 0x1000          ; file table location
    mov es, ax              ; ES = 0x1000
    xor bx, bx              ; ES:BX = 0x1000:0
    mov ah, 0x0e            ; get ready to print to screen

fileTable_Loop:
    inc bx
    mov al, [ES:BX]
    cmp al, '}'             ; at end of filetable?
    je get_program_name
    cmp al, '-'             ; at sector number of element?
    je sectorNumber_Loop
    cmp al, ','             ; between table elements?
    je next_element
    inc cx                  ; increment counter
    int 0x10
    jmp fileTable_Loop

sectorNumber_Loop:
    cmp cx, 21
    je fileTable_Loop
    mov al, ' '
    int 0x10
    inc cx
    jmp sectorNumber_Loop

next_element:
    xor cx, cx              ; reset counter
    mov al, 0xA
    int 0x10
    mov al, 0xD
    int 0x10
    mov al, 0xA
    int 0x10
    mov al, 0xD
    int 0x10
    jmp fileTable_Loop

    ;; After File table printed to screen, user can input program to load
    ;; ------------------------------------------------------------------
get_program_name:
    mov ah, 0x0e                ; print newline...
    mov al, 0xA
    int 0x10
    mov al, 0xD
    int 0x10
    mov di, cmdString           ; di now pointing to cmdString
    mov byte [cmdLength], 0     ; reset counter & length of user input

pgm_name_loop:
    mov ax, 0x00                ; get keystroke
    int 0x16                    ; character goes into al

    mov ah, 0x0e                ; teletype output
    cmp al, 0xD                 ; did user press 'enter' key?
    je start_search

    inc byte [cmdLength]        ; if not, add to counter
    mov [di], al                ; store input char to command string
    inc di
    int 0x10                    ; print input character to screen
    jmp pgm_name_loop           ; loop for next character from user

start_search:
    mov di, cmdString           ; reset di, point to start of command string
    xor bx, bx                  ; reset ES:BX to point to beginning of file table

check_next_char:
    mov al, [ES:BX]             ; get file table char
    cmp al, '}'                 ; at end of file table?
    je pgm_not_found            ; if yes, program was not found

    cmp al, [di]                ; does user input match file table character?
    je start_compare

    inc bx                      ; if not, get next char in filetable and recheck
    jmp check_next_char

start_compare:
    push bx                     ; save file table position
    mov byte cl, [cmdLength]

compare_loop:
    mov al, [ES:BX]             ; get file table char
    inc bx                      ; next byte in input/filetable
    cmp al, [di]                ; does input match filetable char?
    jne restart_search          ; if not search again from this point in filetable

    dec cl                      ; if it does match, decrement length counter
    jz found_program            ; counter = 0, input found in filetable
    inc di                      ; else go to next byte of input
    jmp compare_loop

restart_search:
    mov di, cmdString           ; else, reset to start of user input
    pop bx                      ; get the saved file table position
    inc bx                      ; go to next char in file table
    jmp check_next_char         ; start checking again

pgm_not_found:
    mov si, notFoundString      ; did not find program name in file table
    call print_string
    mov ah, 0x00                ; get keystroke, print to screen
    int 0x16
    mov ah, 0x0e
    int 0x10
    cmp al, 'Y'
    je filebrowser              ; reload file browser screen to search again
    jmp fileTable_end           ; else go back to main menu

    ;; Get sector number after pgm name in file table
    ;; ----------------------------------------------
found_program:
    inc bx
    mov cl, 10              ; use to get sector number
    xor al, al              ; reset al to 0

next_sector_number:
    mov dl, [ES:BX]         ; checking next byte of file table
    inc bx
    cmp dl, ','             ; at end of sector number?
    je load_program         ; if so, load program from that sector
    cmp dl, 48              ; else, check if al is '0'-'9' in ascii
    jl sector_not_found     ; before '0', not a number
    cmp dl, 57
    jg sector_not_found     ; after '9', not a number
    sub dl, 48              ; convert ascii char to integer
    mul cl                  ; al * cl (al * 10), result in AH/AL (AX)
    add al, dl              ; al = al + dl
    jmp next_sector_number

sector_not_found:
    mov si, sectNotFound    ; did not find program name in file table
    call print_string
    mov ah, 0x00            ; get keystroke, print to screen
    int 0x16
    mov ah, 0x0e
    int 0x10
    cmp al, 'Y'
    je filebrowser          ; reload file browser screen to search again
    jmp fileTable_end       ; else go back to main menu

    ;; read disk sector of program to memory and execute it by far jumping
    ;; -------------------------------------------------------------------
load_program:
    mov cl, al              ; cl = sector # to start loading/reading at

    mov ah, 0x00            ; int 13h ah 0 = reset disk system
    mov dl, 0x00
    int 0x13

    mov ax, 0x8000          ; memory location to load pgm to
    mov es, ax
    xor bx, bx              ; ES:BX -> 0x8000:0x0000

    mov ah, 0x02            ; int 13 ah 02 = read disk sectors to memory
    mov al, 0x01            ; # of sectors to read
    mov ch, 0x00            ; track #
    mov dh, 0x00            ; head #
    mov dl, 0x00            ; drive #

    int 0x13
    jnc pgm_loaded          ; carry flag not set, success

    mov si, notLoaded       ; else error, program did not load correctly
    call print_string
    mov ah, 0x00
    int 0x16
    jmp filebrowser         ; reload file table

pgm_loaded:
    mov ax, 0x8000          ; program loaded, set segment registers to location
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    jmp 0x8000:0x0000       ; far jump to program

fileTable_end:
    mov si, goBackMsg       ; show go back message
    call print_string
    mov ah, 0x00            ; get keystroke
    int 0x16
    jmp main_menu           ; go back to main menu

    ;; -----------------------------------------------------------
    ;; Menu R) - Reboot: far jump to reset vector
    ;; -----------------------------------------------------------
reboot:
    jmp 0xFFFF:0x0000

    ;; -----------------------------------------------------------
    ;; Menu P) - Print Register Values
    ;; -----------------------------------------------------------
registers_print:
    ;; Reset screen state
    call resetTextScreen

    ;; print register values to screen
    mov si, printRegHeading
    call print_string

    call print_registers

    ;; Go back to main menu
    mov si, goBackMsg
    call print_string
    mov ah, 0x00
    int 0x16                ; get keystroke
    jmp main_menu           ; go back to main menu

    ;; -----------------------------------------------------------
    ;; Menu G) - Graphics Mode Test(s)
    ;; -----------------------------------------------------------
graphics_test:
    ;; Reset screen state (gfx)
    call resetGraphicsScreen

    ;; Test Square
    mov ah, 0x0C            ; int 0x10 ah 0x0C - write gfx pixel
    mov al, 0x02            ; green
    mov bh, 0x00            ; page #

    ;; Starting pixel of square
    mov cx, 100             ; column #
    mov dx, 100             ; row #
    int 0x10

    ;; Pixels for columns
squareColLoop:
    inc cx
    int 0x10
    cmp cx, 150
    jne squareColLoop

    ;; Go down one row
    inc dx
    int 0x10
    mov cx, 99
    cmp dx, 150
    jne squareColLoop       ; pixels for next row

    mov ah, 0x00
    int 0x16                ; get keystroke
    jmp main_menu

    ;; -----------------------------------------------------------
    ;; Menu N) - End Pgm
    ;; -----------------------------------------------------------
end_program:
    cli                         ; clear interrupts
    hlt                         ; halt the cpu

    ;; ===========================================================
    ;; End Main Logic
    ;; ===========================================================

    ;; -----------------------------------------------------------
    ;; Include Files
    ;; -----------------------------------------------------------
    include "../print/print_string.asm"
    include "../print/print_hex.asm"
    include "../print/print_registers.asm"
    include "../screen/resetTextScreen.asm"
    include "../screen/resetGraphicsScreen.asm"

    ;; -----------------------------------------------------------
    ;; Variables
    ;; -----------------------------------------------------------
menuString:     db '---------------------------------',0xA,0xD,\
        'Kernel Booted, Welcome Mr. KANT....!', 0xA, 0xD,\
        '---------------------------------', 0xA, 0xD, 0xA, 0xD,\
        'F) File & Program Browser/Loader', 0xA, 0xD,\
        'R) Reboot', 0xA, 0xD, \
        'P) Print Register Values', 0xA, 0xD,\
        'G) Graphics Mode Test', 0xA, 0xD, 0

success:        db 0xA, 0xD, 'Program found!', 0xA, 0xD, 0
failure:        db 0xA, 0xD, 'Oops! Something went wrong :(', 0xA, 0xD, 0
notLoaded:      db 0xA, 0xD, 'Error! Program Not Loaded, Try Again', 0xA, 0xD, 0

fileTableHeading:       db '------------         ------',0xA,0xD,\
        'File/Program         Sector', 0xA, 0xD,\
        '------------         ------',0xA, 0xD, 0

printRegHeading:        db '--------   ------------',0xA,0xD,\
        'Register   Mem Location', 0xA,0xD,\
        '--------   ------------',0xA,0xD,0

notFoundString:     db 0xA,0xD,'program not found!, try again? (Y)',0xA,0xD,0
sectNotFound:       db 0xA,0xD,'sector not found!, try again? (Y)',0xA,0xD,0

cmdLength:          db 0

goBackMsg:      db 0xA, 0xD, 0xA, 0xD, 'Press any key to go back...', 0
dbgTest:        db 'Test',0
cmdString:      db ' ', 0

    ;; -----------------------------------------------------------
    ;; Sector Padding magic
    ;; -----------------------------------------------------------
    times 1536-($-$$) db 0       ; pads out 0s until we reach 512th byte
