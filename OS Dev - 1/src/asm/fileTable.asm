;;fileTable.asm: basic file table made with db, string.........

db '{calculator-04, program2-06}'

    ;; sector padding magic;
    times 512-($-$$) db 0   ;pad rest off file to 0s till 512th byte/end of sector.
