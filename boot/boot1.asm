org 0x00010000 ; 0x00010000 -> 0xC0010000

use32

boot_magic:
    db "BOOT"
boot_size:
    dd finish - 0x00010000 ; 0x00010000 -> 0xC0010000
boot_entry:
    dd start

msg_info:
    db "BOOT - SUCCESS", 0


start:
    mov esp, finish
.print:
    mov esi, msg_info
    mov ebx, 0x000B8000
.print_loop:
    lodsb
    or al, al
    jz .spin
    or eax, 0x00000F00
    mov WORD [ebx], ax
    add ebx, 2
    jmp .print_loop
.spin:
    jmp .spin


align 512
times 4096 db 0
finish:
