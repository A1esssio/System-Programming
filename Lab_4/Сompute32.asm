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

        cmp eax, edx
        jb .inputNormal

        .flush:
            mov eax, 3
            mov ebx, 0
            mov ecx, _bufferInput       ; временный буфер
            mov edx, 1                  ; читаем по 1 символу
            syscall
            
            cmp eax, 1
            jne .flushed
            cmp byte [ecx], 10          ; дошли до '\n'
            jne .flush

        .flushed:
            mov eax, -1
            jmp invalidLengthInput

        .inputNormal:
            dec eax
            mov edi, _bufferInput
            add edi, eax
            mov byte [edi], 0
    pop ecx
    pop edx
    pop ebx
}

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

section '.data' writeable
    messageOptionProgram:
        db 'Choose one program:', 10
        db '1 - compute sum using the formula', 10
        db '2 - integers number between 1 - n are not divisible by 3 or 7, but are divisible by 5', 10
        db '3 - get a number from the digits of the number n written in reverse order.', 10, 10
        db 'q / Q - quite the programm', 10
    messageOptionEnd:
    kLengthMessageOptionProgram equ messageOptionEnd - messageOptionProgram

    messageInstruction:
        db 'Write positive number (input length 255 digits):', 10
    messageInstructionEnd:
    kLengthMessageInstruction = messageInstructionEnd - messageInstruction

    messageInvalidNumberArgument:
        db 0x1B, '[H', 0x1B, '[J'
        db 'Error: write 1 or 3 additional arguments', 10, 10
    messageInvalidOptionEnd:
    kLengthMessageInvalidNumberArgument equ messageInvalidOptionEnd - messageInvalidNumberArgument

    messageInvalidLengthInput:
        db 0x1B, '[H', 0x1B, '[J'
        db 'Error: input length must be 255 digits', 10, 10
    messageInvalidLengthInputEnd:
    kLengthMessageInvalidLengthInput equ messageInvalidLengthInputEnd - messageInvalidLengthInput

    messageInvalidLengthNumber:
        db 0x1B, '[H', 0x1B, '[J'
        db 'Error: number must be <= 111 111 110 for this mirroring method', 10, 10
    messageInvalidLengthNumberEnd:
    kLengthMessageInvalidLengthNumber equ messageInvalidLengthNumberEnd - messageInvalidLengthNumber

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

section '.error' executable
    invalidRangeOption:
        cout messageInvalidNumberArgument, kLengthMessageInvalidNumberArgument
        jmp main

    invalidLengthInput:
        cout messageInvalidLengthInput, kLengthMessageInvalidLengthInput
        jmp main
    
    invalidLengthNumber:
        cout messageInvalidLengthNumber, kLengthMessageInvalidLengthNumber
        jmp main

section '.text' executable    
_start:
    cout terminalClear, 6
main:
    cout messageOptionProgram, kLengthMessageOptionProgram

    cin bufferInput, 256
    mov [lengthInput], eax

    cmp dword [lengthInput], 1
    jne invalidRangeOption

    mov al, [bufferInput]

    cmp al, 'q'
    je return
    cmp al, 'Q' 
    je return

    cmp al, '1'
    jb invalidRangeOption
    cmp al, '3'
    ja invalidRangeOption

    cmp al, '1'
    je executionFirst
    cmp al, '2'
    je executionSecond
    cmp al, '3'
    je executionThird

    executionFirst:
        cout terminalClear, 6

        cout messageInstruction, kLengthMessageInstruction

        push eax
        push ebx
        push esi
        push ecx
        push edi
            cin bufferInput, 256
            mov dword [lengthInput], eax

            mov eax, bufferInput
            call CastCharInt        ; int in ecx

            ; make number positive
            test ecx, ecx
            jns .positive
            neg ecx
            .positive:

            xor eax, eax            ; sum result
            mov esi, 1              ; analogue k
            .cycleSum:
                .formula:
                    mov edi, 1      ; formula result
                    test esi, 1     ; check the first bit
                    jz .evenNumber  ; if ZF=1, even number

                    imul edi, -1

                    .evenNumber:
                    mov ebx, esi
                    add ebx, 4
                    imul ebx, esi
                    imul edi, ebx

                    mov ebx, esi
                    add ebx, 8
                    imul edi, ebx
                
                add eax, edi
                inc esi
                cmp esi, ecx
                jbe .cycleSum

            call CastIntChar
        pop edi
        pop ecx
        pop esi
        pop ebx
        pop eax
    
        cout messageResult, kLengthMessageResult
        cout newLine, 1
        cout bufferOutput, [lengthOutput]
        cout newLine, 1
        cout newLine, 1

        jmp main

    executionSecond:
        cout terminalClear, 6

        cout messageInstruction, kLengthMessageInstruction

        push eax
        push ebx
        push esi
        push ecx
        push edx
            cin bufferInput, 256
            mov dword [lengthInput], eax

            mov eax, bufferInput
            call CastCharInt        ; int in ecx

            ; make number positive
            test ecx, ecx
            jns .positive
            neg ecx
            .positive:

            inc ecx
            xor esi, esi            ; similarity counter
            .cycleCheckStatement:
                dec ecx
                cmp ecx, 1
                jb .cycleCheckStatementDone

                mov eax, ecx
                xor edx, edx
                mov ebx, 3
                div ebx
                test edx, edx
                jz .cycleCheckStatement

                mov eax, ecx
                xor edx, edx
                mov ebx, 7
                div ebx
                test edx, edx
                jz .cycleCheckStatement

                mov eax, ecx
                xor edx, edx
                mov ebx, 5
                div ebx
                test edx, edx
                jnz .cycleCheckStatement

                inc esi
                jmp .cycleCheckStatement
            .cycleCheckStatementDone:

            mov eax, esi
            call CastIntChar
        pop edx
        pop ecx
        pop esi
        pop ebx
        pop eax

        cout messageResult, kLengthMessageResult
        cout newLine, 1
        cout bufferOutput, [lengthOutput]
        cout newLine, 1
        cout newLine, 1

        jmp main

    executionThird:
        cout terminalClear, 6

        cout messageInstruction, kLengthMessageInstruction

        push eax
        push ebx
        push esi
        push ecx
        push edx
            cin bufferInput, 256
            mov dword [lengthInput], eax

            mov eax, bufferInput
            call CastCharInt        ; int in ecx

            ; make number positive
            test ecx, ecx
            jns .positive
            neg ecx
            .positive:

            cmp ecx, 111111110
            ja invalidLengthNumber

            mov eax, ecx
            xor ecx, ecx
            .cycleMirror:
                imul ecx, 10
                xor edx, edx
                mov ebx, 10
                div ebx
                add ecx, edx
                test eax, eax
                jnz .cycleMirror
            
            mov eax, ecx
            call CastIntChar
        pop edx
        pop ecx
        pop esi
        pop ebx
        pop eax

        cout messageResult, kLengthMessageResult
        cout newLine, 1
        cout bufferOutput, [lengthOutput]
        cout newLine, 1
        cout newLine, 1

        jmp main

    return:
        mov eax, 1
        xor ebx, ebx
        syscall
