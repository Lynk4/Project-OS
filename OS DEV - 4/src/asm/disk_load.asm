;;;
;;; Disk_Load: Read DH sectors into ES:BX memory location from drive DL
;;;
disk_load:
    push dx         ; store DX on stack so we can check number of sectors actually read later

retry:
    mov ah, 0x02    ; int 13h/ah=02h, BIOS read disk sectors into memory
    mov al, dh      ; number of sectors we want to read ex. 1
    mov ch, 0x00    ; cylinder 0
    mov dh, 0x00    ; head 0
    mov cl, 0x02    ; start reading at CL sector (sector 2 in this case, right after our bootsector)

    int 0x13        ; BIOS interrupts for disk functions

    jc retry   ; jump if disk read error (carry flag set/ = 1)

    pop dx          ; restore DX from the stack
