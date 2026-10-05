global exit
global string_length
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
