format ELF
public _start

msg:
    db "Galenko", 10
    db "Aleksey", 10
    db "Vladimirovich", 10
msgEnd:

    msg_len = msgEnd - msg

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, msg_len
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80
