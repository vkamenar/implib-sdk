default rel

EXTERN __imp_GetStdHandle
EXTERN __imp_WriteFile
EXTERN __imp_ExitProcess
%define GetStdHandle [__imp_GetStdHandle]
%define WriteFile    [__imp_WriteFile]
%define ExitProcess  [__imp_ExitProcess]

section .text
msg db "Hello, World!",13,10 ; CRLF to add a new line
.len equ  $ - msg            ; string length
align 8
GLOBAL start
start:
	sub rsp,40 ; reserve shadow space, 16-byte stack alignment
	mov rcx,-11
	call GetStdHandle
	mov rcx,rax          ; WriteFile: hFile
	lea rdx,[msg]        ; WriteFile: lpBuffer
	mov r8d,msg.len      ; WriteFile: nNumberOfBytesToWrite
	lea r9,[rsp+48]      ; WriteFile: lpNumberOfBytesWritten
	mov qword [rsp+32],0 ; WriteFile: lpOverlapped = NULL
	call WriteFile
	xor ecx,ecx
	call ExitProcess
