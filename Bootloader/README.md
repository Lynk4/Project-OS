# BOOTLOADER.........

---

### TO run the bootloader......

```bash
fasm boot.asm
```

```bash
fasm kernel.asm
```

### joining boot.bin and kernel.bin

```bash
cat boot.bin kernel.bin > os.bin
```

### run with qemu......
```bash
qemu-system-x86_64 -boot a -fda os.bin
```

---
<img width="1440" alt="Screenshot 2025-01-14 at 11 44 04 PM" src="https://github.com/user-attachments/assets/39a22bb8-a3b8-4c83-8068-21c59edef808" />

### After fixing some errors...

### final result........

---
<img width="1440" alt="Screenshot 2025-01-15 at 12 08 39 AM" src="https://github.com/user-attachments/assets/b5448c99-24a1-4739-abe7-34a1d251cbd3" />

---

