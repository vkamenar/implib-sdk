; MSVCRT!printf
EXTERN __imp__printf
%define printf [__imp__printf]

section .text
format db "Hello, world!",0

GLOBAL _start
_start:
	push format
	call printf
	add esp,4 ; fix the stack
	ret
