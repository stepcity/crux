org 0x7C00

use16

start16:
    cli
    
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax

a20.1:
    in al, 0x64
    test al, 0x02
    jnz a20.1
    
    mov al, 0xD1
    out 0x64, al

a20.2:
    in al, 0x64
    test al, 0x2
    jnz a20.2
    
    mov al, 0xDF
    out 0x60, al
    
    mov ax, 0x0003
    int 0x10
    
    lgdt [gdtptr]
    
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax
    
    jmp 0x08:start32

use32

start32:
    mov ax, 0x0010
    mov ds, ax
    mov es, ax
    mov ss, ax
    
    xor ax, ax
    mov fs, ax
    mov gs, ax
    
    mov esi, 0x00001000
    mov edi, 0x00010000 ; 0x00010000 -> 0xC0010000
    call read_seg
    
    cmp DWORD [0x00010000], 0x544F4F42 ; 0x00010000 -> 0xC0010000
    jne .fail
    
    mov esi, [0x00010004] ; 0x00010004 -> 0xC0010004
    mov edi, 0x00011000 ; 0x00011000 -> 0xC0011000
    call read_seg
    
    jmp DWORD [0x00010008] ; 0x00010008 -> 0xC0010008
.fail:
    mov esi, msg_err
    mov ebx, 0x000B8000
.fail_print:
    lodsb
    
    or al, al
    jz .fail_loop
    
    or eax, 0x00000F00
    mov WORD [ebx], ax
    
    add ebx, 2
    
    jmp .fail_print
.fail_loop:
    jmp .fail_loop

disk_wait:
    mov edx, 0x000001F7
.loop:
    in al, dx
    and al, 0xC0
    cmp al, 0x40
    jne .loop
    
    ret

read_seg:
    mov ebx, 1
    
    add esi, edi
    
    jmp .test
.loop:
    call read_sec
    
    add edi, 0x00000200
    inc ebx
.test:
    cmp edi, esi
    jb .loop
.return:
    ret

read_sec:
    call disk_wait
    
    mov al, 1
    mov dx, 0x01F2
    out dx, al
    
    mov eax, ebx
    mov dx, 0x01F3
    out dx, al
    
    mov eax, ebx
    shr eax, 8
    mov dx, 0x01F4
    out dx, al
    
    mov eax, ebx
    shr eax, 16
    mov dx, 0x01F5
    out dx, al
    
    mov eax, ebx
    shr eax, 24
    or al, 0xE0
    mov dx, 0x01F6
    out dx, al
    
    mov al, 0x20
    mov dx, 0x01F7
    out dx, al
    
    call disk_wait
    
    mov ecx, 0x00000080
    mov dx, 0x01F0
    cld
    rep insd
    
    ret

align 4
gdt:
    ; NULL
    dd 0x00000000
    dd 0x00000000
    
    ; CODE: R-W (9Ah), 4KiB (Ch), B(0000:0000h) to L(F:FFFFh)
    dd 0x0000FFFF
    dd 0x00CF9A00
    
    ; DATA: -X- (92h), 4KiB (Ch), B(0000:0000h) to L(F:FFFFh)
    dd 0x0000FFFF
    dd 0x00CF9200
gdtptr:
    dw gdtptr - gdt - 1
    dd gdt

msg_err:
    db "BOOT - FAILURE", 0

    times 510 - ($ - $$) nop
magic:
    dw 0xAA55
