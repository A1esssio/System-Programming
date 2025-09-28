format ELF64 executable 3

entry start

segment readable writeable
    messageOptionProgram:
        db 'Choose one program:', 10, '1 - input string direction reverse', 10
        db '2 - if (length != 21) -> input string to matrix convertation,', 10
        db '    else -> triangular arrangement', 10
        db '3 - number digit sum', 10
    messageOptionEnd:

    kLengthMessageOptionProgram = messageOptionEnd - messageOptionProgram

    messageInvalidNumberArgument:
        db 'Error: choose between 1, 2 and 3', 10, 10, 0
    messageInvalidOptionEnd:

    kLengthMessageInvalidNumberArgument = messageInvalidOptionEnd - messageInvalidNumberArgument

    bufferInput rb 2
    lengthInput db 0

segment readable executable

start:
    ; output
    mov rax, 1
    mov rdi, 1
    mov rsi, messageOptionProgram
    mov rdx, kLengthMessageOptionProgram
    0x80

    ; input
    mov rax, 0
    mov rdi, 0
    mov rsi, bufferInput
    mov rdx, 2
    0x80

    ; al - the youngest bite
    ; RAX (64 бита): |00000000|00000000|00000000|00000010| (значение 2)
    ; AL (8 бит):                               |00000010| (то же значение 2)
    mov [lengthInput], al

    cmp byte [lengthInput], 2
    jne invalidRangeInputMenu

    mov al, [bufferInput]

    cmp al, '1'
    je optionFirst

    cmp al, '2'
    je optionSecond

    cmp al, '3'
    je optionThird

    invalidRangeInputMenu:
        mov rax, 1
        mov rdi, 1
        mov rsi, messageInvalidNumberArgument
        mov rdx, kLengthMessageInvalidNumberArgument
        0x80
        jmp start 
    
    optionFirst:
        jmp return

    optionSecond:
        jmp return

    optionThird:
        jmp return
    
    

    return:
        mov rax, 60
        xor rdi, rdi
        0x80
