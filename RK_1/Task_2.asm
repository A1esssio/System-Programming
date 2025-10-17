format ELF64

public _start

macro cout _data, _length {
    push rax
    push rbx
    push rdx
    push rsi
        mov rax, 1
        mov rbx, 1
        mov rsi, _data
        mov rdx, _length
        syscall
    pop rsi
    pop rdx
    pop rbx
    pop rax
}

macro cin _bufferInput, _length {
    push rbx
    push rdx
    push rsi
    push rdi
        mov rax, 0
        mov rbx, 0
        mov rsi, _bufferInput
        mov rdx, _length
        syscall

        cmp rax, rdx
        jb .inputNormal

        .flush:
            mov rax, 0
            mov rbx, 0
            mov rsi, _bufferInput       ; временный буфер
            mov rdx, 1                  ; читаем по 1 символу
            syscall
            
            cmp rax, 1
            jne .flushed
            cmp byte [rsi], 10          ; дошли до '\n'
            jne .flush

        .flushed:
            mov rax, -1
            jmp invalidLengthInput

        .inputNormal:
            dec rax
            mov rdi, _bufferInput
            add rdi, rax
            mov byte [rdi], 0
    pop rdi
    pop rsi
    pop rdx
    pop rbx
}

section '.function' executable
    ; input - address char rax
    ; output - int rcx
    CastCharInt:
        push rbx
        push rdi
            ; check a minus
            xor rbx, rbx
            cmp byte [rax], '-'
            sete bl ; if equal bl = 1, else bl = 0

            ; skip a minus
            cmp bl, 1
            jne .startConvert
            inc rax

            .startConvert:
                xor rcx, rcx
            .cycleConvert:
                movzx rdi, byte [rax]
                add rcx, rdi
                sub rcx, '0'
                inc rax

                cmp byte [rax], 0
                je .cycleConvertEnd

                imul rcx, 10
                jmp .cycleConvert
            .cycleConvertEnd:

            cmp bl, 1
            jne .return

            imul rcx, -1

            .return:
        pop rdi
        pop rbx
        ret
    
    ; input - int rax
    ; output - bufferOutput
    CastIntChar:
    push rcx
    push rdi
    push rdx
    push rbx
    push rsi
        ; check a sign
        xor rbx, rbx
        cmp rax, 0
        jge .positive
        
        ; negative
        mov rbx, 1              ; negative flag
        neg rax                 ; make positive
    
        .positive:
            ; find number length
            push rax
            push rbx            ; save sign flag
                mov rcx, 0
                mov rsi, 10
                
                test rax, rax   ; if zero number
                jnz .cycleIntLen
                mov rcx, 1      ; size 1 for zero number
                jmp .CycleDone
                
                .cycleIntLen:
                    xor rdx, rdx
                    div rsi
                    inc rcx
                    test rax, rax
                    jnz .cycleIntLen
                .CycleDone:
            pop rbx             ; restore sign flag
            pop rax
            
            ; consider sign in size
            test rbx, rbx
            jz .unsign
            inc rcx
            
        .unsign:
            push rbx            ; save sign flag
                mov rsi, 10
                mov rdi, bufferOutput
                add rdi, rcx
                mov byte [rdi], 0
                dec rdi
                
                .cycleConverter:
                    xor rdx, rdx
                    div rsi
                    add dl, '0'
                    mov byte [rdi], dl
                    dec rdi
                    test rax, rax
                    jnz .cycleConverter
            .conversionDone:
            pop rbx
            
            ; add sign
            test rbx, rbx
            jz .return
            mov byte [rdi], '-'
            
        .return:
            mov qword [lengthOutput], rcx
    pop rsi
    pop rbx
    pop rdx
    pop rdi
    pop rcx
    ret

section '.data' writeable
    messageInvalidInput:
        db 0x1B, '[H', 0x1B, '[J'
        db 'Error', 10, 10
    messageInvalidInputEnd:
    kLengthMessageInvalidInput equ messageInvalidInputEnd - messageInvalidInput

    newLine db 10

    lengthInput dq 0
    lengthOutput dq 0

section '.bss' writeable
    bufferInput rb 256
    bufferOutput rb 256
    fileInput rb 8
    fileOutput rb 8
    fileDiscriptorInput rb 8
    fileDiscriptorOutput rb 8

section '.error' executable
    invalidLengthInput:
        cout messageInvalidInput, kLengthMessageInvalidInput
        jmp _start

section '.text' executable    
_start:
    cin bufferInput, 256
    mov qword [lengthInput], rax

    mov rax, bufferInput
    call CastCharInt

    push rax
        mov rax, rcx
        mov rbx, 2
        xor rdx, rdx
        div rbx
        cmp rdx, 0
        je returnError
    pop rax

    push rcx
    push r8
        xor rax, rax
        mov r8, 1
        .cycle:
            add rax, r8
            add r8, 2
            cmp r8, rcx
            jle .cycle
    pop r8
    pop rcx

    push rax
        xor r8, r8
        mov rbx, 10
        .cycleLength:
            xor rdx, rdx
            div rbx
            inc r8
            cmp rdx, 0
            jne .cycleLength
    pop rax

    mov qword [lengthOutput], r8

    call CastIntChar

    cout bufferOutput, lengthOutput

    cout newLine, 1

    return:
        mov rax, 60
        xor rdi, rdi
        syscall

    returnError:
        cout messageInvalidInput, kLengthMessageInvalidInput
        mov rax, 60
        mov rdi, 1
        syscall