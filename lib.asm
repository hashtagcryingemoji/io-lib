global exit
global string_length
global print_string
global print_char
global print_newline
section .text
 
 
; Принимает в rdi код возврата и завершает текущий процесс
exit: 
    mov rax, 60
    syscall

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    mov rax, rdi
    .loop:
    cmp byte [rdi], 0
    je .end
    inc rdi
    jmp .loop
    .end:
    sub rdi, rax
    mov rax, rdi
    ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
    push r12 ; сохраняем callee-saved регистр
    mov r12, rdi ; сохраняем копию rdi во временный регистр
    ; выравнивание не нужно так как сделан push
    call string_length ; возвращаем в rax длину строки
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    mov rsi, r12
    syscall
    pop r12
    ret

; Принимает код символа в rdi и выводит его в stdout
print_char:
    push rdi
    mov rax, 1
    mov rdi, 1
    mov rsi, rsp ; rsp указатель на бывший контент rdi
    mov rdx, 1
    syscall
    pop rdi
    ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    mov rdi, 0xA 
    jmp print_char
