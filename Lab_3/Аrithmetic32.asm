format ELF

public _start

macro syscall {
    int 0x80
}

macro cout _data, _length {
    push eax
    push ebx
    push edx
    push ecx
        mov eax, 4
        mov ebx, 1
        mov ecx, _data
        mov edx, _length
        syscall
    pop ecx
    pop edx
    pop ebx
    pop eax
}

macro cin _bufferInput, _length {
    push ebx
    push edx
    push ecx
        mov eax, 3
        mov ebx, 0
        mov ecx, _bufferInput
        mov edx, _length
        syscall
    pop ecx
    pop edx
    pop ebx
}

section '.data' writeable
    messageOptionProgram:
        db 'Choose one program:', 10
        db '1 - argument ASCII code', 10
        db '2 - arithmetic', 10, 10
        db 'q / Q - quite the programm', 10
    messageOptionEnd:
    kLengthMessageOptionProgram equ messageOptionEnd - messageOptionProgram

    messageInvalidNumberArgument:
        db 0x1B, '[H', 0x1B, '[J'
        db 'Error: write 1 or 3 additional arguments', 10, 10
    messageInvalidOptionEnd:
    kLengthMessageInvalidNumberArgument equ messageInvalidOptionEnd - messageInvalidNumberArgument

    messageResult:
        db 'Result:'
    messageResultEnd:
    kLengthMessageResult equ messageResultEnd - messageResult

    terminalClear db 0x1B, '[H', 0x1B, '[J'
    newLine db 10

    lengthInput dd 0
    lengthOutput dd 0

section '.bss' writeable
    bufferInput rb 256
    bufferOutput rb 256
    bufferCalculation rb 4

    addressA rb 4
    addressB rb 4
    addressC rb 4

section '.error' executable
    invalidNumberArgument:
        cout messageInvalidNumberArgument, kLengthMessageInvalidNumberArgument
        jmp return

section '.function' executable
    ; IfCharDigit:
    ;     cmp [eax], '0'
    ;     jb error

    ;     cmp [eax], '9'
    ;     ja error
    ;     ret

    ; input - address char eax
    ; output - int ecx
    CastCharInt:
        push ebx
            xor ebx, ebx
            cmp byte [eax], '-'
            sete bl ; if equal bl = 1, else bl = 0
            inc eax

            xor ecx, ecx
            .cycle:
                add ecx, eax
                dec ecx, '0'
                inc eax

                cmp [eax], 0
                je .cycleEnd

                imul ecx, 10
                jmp .cycle
            .cycleEnd:

            cmp bl, 1
            jne .return

            imul ecx, -1

            .return:
        pop ebx
        ret

section '.text' executable    
_start:
    cout terminalClear, 6
main:
    pop eax
    cmp eax, 2
    je executionFirst

    cmp eax, 4
    je executionSecond

    jmp invalidNumberArgument

    ; get an argument's ASCII code
    executionFirst:
        cout terminalClear, 6

        pop eax ; get address of ./Arithmetic32

        pop eax ; get address of argument
        movzx eax, byte [eax] ; get the sumbol

        mov ebx, 10
        xor ecx, ecx
        push eax
            .cycleGetLength:
                xor edx, edx
                div ebx

                inc ecx

                cmp eax, 0
                jg .cycleGetLength
        pop eax

        mov edi, bufferOutput
        add edi, ecx
        dec edi
        xor esi, esi
        .cycleCastASCII:
            mov ebx, 10
            xor edx, edx
            div ebx
            add edx, '0'

            mov ebx, edx
            mov byte [edi], bl
            dec edi

            inc esi

            cmp eax, 0
            jne .cycleCastASCII
        
        mov dword [lengthOutput], esi

        cout messageResult, kLengthMessageResult
        cout newLine, 1
        cout bufferOutput, [lengthOutput]
        cout newLine, 1
        cout newLine, 1

        jmp return

    ; (((b/a)+c)-a)
    ; get the result of an arithmetic expression
    executionSecond:
        pop eax ; get address of ./Arithmetic32

        pop eax ; get address of the argument a
        call CastCharInt
        mov 


        ; pop eax ; get address of the argument b

        ; pop eax ; get address of the argument c

    return:
        mov eax, 1
        xor ebx, ebx
        syscall
