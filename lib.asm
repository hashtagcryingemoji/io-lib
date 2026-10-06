global exit
global string_length
global print_string
global print_char
global print_newline
global print_uint
global print_int
global string_equals
global read_char
global parse_uint
global parse_int
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

; Выводит беззнаковое 8-байтовое число в десятичном формате 
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
    mov rax, rdi
    mov r8, 10
    sub rsp, 24
    lea r9, [rsp + 23]
    mov byte [r9], 0
    .loop_pru:
    xor rdx, rdx
    div r8
    add dl, '0'
    dec r9
    mov [r9], dl
    test rax, rax
    jnz .loop_pru

    mov rdi, r9
    call print_string
    add rsp, 24
    ret

; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
    test rdi, rdi
    jns print_uint ; если беззнаковое 
    neg rdi ; превращаем в модуль
    push rdi
    mov rdi, '-'
    call print_char
    pop rdi
    jmp print_uint

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
    push r12
    push rsi
    push rdi
    call string_length
    mov r12, rax ; длина первой строки в r12
    mov rdi, [rsp + 8] ; указатель на вторую строку в rdi
    call string_length
    pop rdi
    pop rsi
    cmp rax, r12
    jne .ne ; если не равны, то выходим
    .loop_se:
    cmp r12, 0
    je .eq
    dec r12
    mov r10b, byte [rsi]
    mov r11b, byte [rdi]
    cmp r10b, r11b
    jne .ne
    inc rsi
    inc rdi
    jmp .loop_se
    .eq:
    mov rax, 1
    jmp .return_se

    .ne:
    xor rax, rax
    .return_se:
    pop r12
    ret

; Читает один символ из stdin и возвращает его в rax. Возвращает 0 если достигнут конец потока
read_char:
    push 0 ; буффер
    xor rax, rax
    xor rdi, rdi
    mov rsi, rsp
    mov rdx, 1
    syscall ; read 1 символа
    cmp rax, -1
    jne .success
    xor rax, rax
    add rsp, 8
    jmp .return_rc
    
    .success:
    pop rax
    
    .return_rc:
    ret 

; Принимает указатель на строку в rdi, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
    xor rdx, rdx
    xor rax, rax

    .loop_uint:
    movzx r11, byte [rdi] ; текущий char в r11

    cmp r11, '0'
    jb .return_pu
    cmp r11, '9'
    ja .return_pu

    sub r11, '0' ; перевод
    imul rax, 10
    add rax, r11
    inc rdi
    inc rdx
    jmp .loop_uint
    
    .return_pu:
    ret

; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
; rdx = 0 если число прочитать не удалось
parse_int:
    xor rdx, rdx
    xor rax, rax
    
    .loop_int:
    movzx r11, byte [rdi]
    push r11
    cmp r11, '+'          ; в начале может быть знак '+', а может и не быть
    je .sign_int
    cmp r11, '-'
    je .sign_int
    call parse_uint
    jmp .return_pi

.sign_int:
    inc rdi
    call parse_uint
    test rdx, rdx
    jz .return_pi
    inc rdx
    cmp byte [rsp], '-'
    jne .return_pi
    neg rax
    
.return_pi:
    add rsp, 8
    ret  
