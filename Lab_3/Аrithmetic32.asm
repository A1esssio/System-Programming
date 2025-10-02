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
    messageInvalidDevider:
        db 0x1B, '[H', 0x1B, '[J'
        db 'Error: division by 0', 10, 10
    messageInvalidDeviderEnd:
    kLengthMessageInvalidDevider equ messageInvalidDeviderEnd - messageInvalidDevider

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

    operandA rb 4
    operandB rb 4
    operandC rb 4

section '.error' executable    
    invalidDevider:
        cout messageInvalidDevider, kLengthMessageInvalidDevider
        jmp return

section '.function' executable
    ; input - address char eax
    ; output - int ecx
    CastCharInt:
        push ebx
        push edi
            ; check a minus
            xor ebx, ebx
            cmp byte [eax], '-'
            sete bl ; if equal bl = 1, else bl = 0

            ; skip a minus
            cmp bl, 1
            jne .startConvert
            inc eax

            .startConvert:
                xor ecx, ecx
            .cycleConvert:
                movzx edi, byte [eax]
                add ecx, edi
                sub ecx, '0'
                inc eax

                cmp byte [eax], 0
                je .cycleConvertEnd

                imul ecx, 10
                jmp .cycleConvert
            .cycleConvertEnd:

            cmp bl, 1
            jne .return

            imul ecx, -1

            .return:
        pop edi
        pop ebx
        ret
    
    ; input - int eax
    ; output - bufferOutput
    CastIntChar:
    push ecx
    push edi
    push edx
    push ebx
    push esi
        ; check a sign
        xor ebx, ebx
        cmp eax, 0
        jge .positive
        
        ; negative
        mov ebx, 1              ; negative flag
        neg eax                 ; make positive
    
        .positive:
            ; find number length
            push eax
            push ebx            ; save sign flag
                mov ecx, 0
                mov esi, 10
                
                test eax, eax   ; if zero number
                jnz .cycleIntLen
                mov ecx, 1      ; size 1 for zero number
                jmp .CycleDone
                
                .cycleIntLen:
                    xor edx, edx
                    div esi
                    inc ecx
                    test eax, eax
                    jnz .cycleIntLen
                .CycleDone:
            pop ebx             ; restore sign flag
            pop eax
            
            ; consider sign in size
            test ebx, ebx
            jz .unsign
            inc ecx
            
        .unsign:
            push ebx            ; save sign flag
                mov esi, 10
                mov edi, bufferOutput
                add edi, ecx
                mov byte [edi], 0
                dec edi
                
                .cycleConverter:
                    xor edx, edx
                    div esi
                    add dl, '0'
                    mov byte [edi], dl
                    dec edi
                    test eax, eax
                    jnz .cycleConverter
            .conversionDone:
            pop ebx
            
            ; add sign
            test ebx, ebx
            jz .return
            mov byte [edi], '-'
            
        .return:
            mov dword [lengthOutput], ecx
    pop esi
    pop ebx
    pop edx
    pop edi
    pop ecx
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

        push eax
            mov ebx, 10
            xor ecx, ecx
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
        mov dword [operandA], ecx

        pop eax ; get address of the argument b
        call CastCharInt
        mov dword [operandB], ecx

        pop eax ; get address of the argument c
        call CastCharInt
        mov dword [operandC], ecx

        mov eax, dword [operandB]
        mov ebx, dword [operandA]
        test ebx, ebx
        jz invalidDevider
        cdq
        idiv ebx

        add eax, dword [operandC]

        sub eax, dword [operandA]

        call CastIntChar

        cout messageResult, kLengthMessageResult
        cout newLine, 1
        cout bufferOutput, [lengthOutput]
        cout newLine, 1
        cout newLine, 1

    return:
        mov eax, 1
        xor ebx, ebx
        syscall
