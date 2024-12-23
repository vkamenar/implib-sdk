EXTERN __imp__MessageBoxA@16
EXTERN __imp__ExitProcess@4
%define MessageBox [__imp__MessageBoxA@16]
%define ExitProcess [__imp__ExitProcess@4]

section .text
ttl db "Test",0
msg db "Hello, world!",0

GLOBAL _start
_start:
	push 0
	push ttl
	push msg
	push 0
	call MessageBox
	push eax
	call ExitProcess
