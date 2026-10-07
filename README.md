# io-lib

Небольшая библиотека ввода-вывода на чистом ассемблере x86-64 для Linux (NASM).
Без libc и внешних зависимостей - только прямые системные вызовы.

## Функции

- `exit` - завершает процесс с заданным кодом возврата
- `string_length` - возвращает длину нуль-терминированной строки
- `print_string` - выводит строку в stdout
- `print_char` - выводит один символ в stdout
- `print_newline` - выводит перевод строки
- `print_uint` - выводит беззнаковое число в десятичном виде
- `print_int` - выводит знаковое число в десятичном виде
- `string_equals` - сравнивает две строки, возвращает 1 при равенстве и 0 иначе
- `read_char` - читает символ из stdin, 0 при конце потока
- `parse_uint` - читает беззнаковое число из начала строки
- `parse_int` - читает знаковое число из начала строки
- `read_word` - читает слово из stdin в буфер, пропуская пробельные символы
- `string_copy` - копирует строку в буфер с проверкой размера

## Пример

```asm
%include "lib.asm"

section .text
global _start
_start:
    mov  rdi, msg
    call print_string
    call print_newline
    xor  rdi, rdi
    call exit

section .data
msg: db "hello from asm", 0
```

Сборка и запуск:

```sh
nasm -f elf64 main.asm -o main.o
ld main.o -o main
./main
```
