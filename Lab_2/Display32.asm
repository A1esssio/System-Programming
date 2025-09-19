format ELF

public _start

macro syscall {
    int 0x80
}

macro cout _data, _length {
    mov eax, 4
    mov ebx, 1
    mov ecx, _data
    mov edx, _length
    syscall
}

macro cin _bufferInput, _length {
    mov eax, 3
    mov ebx, 0
    mov ecx, _bufferInput
    mov edx, _length
    syscall
}

; clear output buffer
; macro clearBufferOutput {
;     push eax
;     push edi
;     push ecx
;         mov edi, bufferOutput
;         mov ecx, 256
;         xor eax, eax
;         rep stosb
;     pop ecx
;     pop edi
;     pop eax
; }

macro rootSquare _source, _result {
    fld dword [_source]
    fsqrt
    fst dword [_result]
}

section '.data' writeable
    messageOption:
        db 'Choose one program:', 10
        db '1 - input string direction reverse', 10
        db '2 - if the number of characters is a multiple of 4, then display a triangle', 10
        db '    else, display a matrix', 10
        db '3 - number digit sum', 10, 10
        db 'q / Q - quite the programm', 10
    messageOptionEnd:
    lengthMessageOption equ messageOptionEnd - messageOption

    messageInstructionProgram:
        db 0x1B, '[H', 0x1B, '[J'
        db 'Write string (length < 50):', 10
    messageInstructionProgramEnd:
    lengthMessageInstructionProgram equ messageInstructionProgramEnd - messageInstructionProgram

    messageInstructionProgramSecond:
        db 0x1B, '[H', 0x1B, '[J'

    messageInvalidOption:
        db 0x1B, '[H', 0x1B, '[J'
        db 'Error: choose between 1, 2 and 3', 10, 10, 0
    messageInvalidOptionEnd:
    lengthMessageInvalidOption equ messageInvalidOptionEnd - messageInvalidOption

    messageInvalidSizeString:
        db 0x1B, '[H', 0x1B, '[J'
        db 'Error: string size must be < 50 symbols', 10, 10, 0
    messageInvalidSizeStringEnd:
    lengthMessageInvalidSizeString equ messageInvalidSizeStringEnd - messageInvalidSizeString

    messageResult:
        db 'Result:'
    messageResultEnd:
    lengthMessageResult equ messageResultEnd - messageResult

    terminalClear db 0x1B, '[H', 0x1B, '[J'
    newLine db 10

    lengthInput dd 0
    lengthOutput dd 0

    lineNumber dd 0
    currentIndent dd 0
    charsNumber dd 0
    BufferOutputPosition dd 0

section '.bss' writeable
    bufferInput rb 256
    bufferOutput rb 256
    bufferCalculation rb 4
    bufferResult rb 4

section '.error' executable
    invalidRangeOption:
        cout messageInvalidOption, lengthMessageInvalidOption
        jmp main
    
    invalidLengthString:
        cout messageInvalidSizeString, lengthMessageInvalidSizeString
        jmp main

section '.text' executable
_start:
    cout terminalClear, 6
main:
    cout messageOption, lengthMessageOption

    cin bufferInput, 256

    ; al - the youngest byte
    ; eax (32 bits): |00000000|00000000|00000000|00000010| (value 2)
    ; al (8 bits):                              |00000010| (same value 2)
    mov [lengthInput], eax

    cmp dword [lengthInput], 2
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
    je return

    executionFirst:
        cout messageInstructionProgram, lengthMessageInstructionProgram

        cin bufferInput, 256
        dec eax

        mov dword [lengthInput], eax
        mov dword [lengthOutput], eax

        cmp dword [lengthInput], 50
        ja invalidLengthString
        
        push ebx
        push esi
        push edi
            reverseString:
                ; set begin and end pointers
                ; esi (Source Index)
                ; edi (Destination Index)
                mov edi, bufferOutput
                mov ebx, dword [lengthInput]
                mov esi, bufferInput
                add esi, dword [lengthInput]
                dec esi

                cycleReversion:
                    mov al, [esi]
                    mov [edi], al

                    inc edi
                    dec esi

                    dec ebx
                    jnz cycleReversion
        pop edi
        pop esi
        pop ebx

            cout newLine, 1
            cout messageResult, lengthMessageResult
            cout newLine, 1
            cout bufferOutput, [lengthOutput]
            cout newLine, 1
            cout newLine, 1

            jmp main

    executionSecond:
        cout messageInstructionProgram, lengthMessageInstructionProgram

        cin bufferInput, 256
        dec eax
        
        mov dword [lengthInput], eax
        mov dword [lengthOutput], 0

        ; variables initializing
        mov dword [lineNumber], 0
        mov dword [currentIndent], 0
        mov dword [charsNumber], 0
        mov dword [BufferOutputPosition], 0

        mov esi, bufferInput    ; start input buffer
        mov edi, bufferOutput   ; start output buffer

        ; define type of cout
        push eax
        push ebx
            mov eax, dword [lengthInput]
            imul eax, 8
            inc eax
            mov dword [bufferCalculation], eax

            fild dword [bufferCalculation]  ; st0 = value
            fsqrt                           ; st0 = sqrt(value)
            frndint                         ; round up
            fistp dword [bufferCalculation] ; float to int

            mov ebx, dword [bufferCalculation]
            imul ebx, ebx

            cmp ebx, eax
            
            ; define number of lines
            mov eax, dword [bufferCalculation]
            dec eax
            xor edx, edx
            mov ebx, 2
            div ebx
            mov dword [lineNumber], eax
        pop ebx
        pop eax
        
        jne matrix

        triangle:
            push eax
            push ebx
                xor eax, eax
                xor ebx, ebx
                cycleLine:
                    cycleChar:
                        
                        inc ebx
                    inc eax
            pop ebx
            pop eax

        matrix:

    return:
        mov eax, 1
        xor ebx, ebx
        syscall
