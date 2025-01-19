# OS development
## - making the binary file easier to compile with a makefile.
## - creating a 'file table' (really just a string), 
## - Finally displaying BIOS int 0x16 to receive keystrokes and user input.

---

### Makefile is located in ```Project-OS/OS Dev - 1/bin```

---

### To build the OS

```
make OS
```

---

### Run OS.bin file 

```bash
qemu-system-x86_64 -boot a -fda OS.bin
 ```

---

### To delete all the .bin files

```bash
make clean
```

---

### Facing Some errors

---
<img width="1202" alt="oops" src="https://github.com/user-attachments/assets/1c6707ef-c6ea-4426-bf36-14586c4f272a" />

---

### After Fixing..................

---

<img width="1415" alt="success" src="https://github.com/user-attachments/assets/42efd93f-2687-409d-bdbf-6972693b2736" />

---




