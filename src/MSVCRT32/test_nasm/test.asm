; MSVCRT functions:
EXTERN __imp___getdrives
%define _getdrives [__imp___getdrives]
EXTERN __imp__printf
%define printf [__imp__printf]
EXTERN __imp___getch
%define _getch [__imp___getch]

section .text
msg   db "All disk drives available:",13,10,0
fmt   db "Drive: %c",13,10,0
sExit db "Press any key to exit",0
align 4
GLOBAL _start
_start:
	push ebx
	push esi
	push msg
	call printf
	pop edx ; fix the stack
	call _getdrives
	xor esi,esi
	mov ebx,eax
_loop:
	inc esi
	cmp esi,27
	je _end
	test ebx,1
	jz _nodrive
	lea eax,[esi+40h]
	push eax
	push fmt
	call printf
	add esp,8 ; fix the stack
_nodrive:
	shr ebx,1
	jmp _loop
_end:

	; Wait for some input before exiting
	push sExit
	call printf
	pop edx ; fix the stack
	call _getch
	pop esi
	pop ebx
	ret