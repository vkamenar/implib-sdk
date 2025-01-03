includelib kernel32.lib

externdef __imp_GetStdHandle:PTR PROC
externdef __imp_WriteFile:PTR PROC
externdef __imp_ExitProcess:PTR PROC

.code
msg db "Hello, World!",13,10 ; CRLF to add a new line
msg_len EQU $ - msg
align 8
start proc
	sub rsp,40h ; reserve shadow space, 16-byte stack alignment
	mov rcx,-11
	call [__imp_GetStdHandle]
	mov rcx,rax              ; WriteFile: hFile
	lea rdx,[msg]            ; WriteFile: lpBuffer
	mov r8d,msg_len          ; WriteFile: nNumberOfBytesToWrite
	lea r9,[rsp+48]          ; WriteFile: lpNumberOfBytesWritten
	mov QWORD PTR [rsp+32],0 ; WriteFile: lpOverlapped = NULL
	call [__imp_WriteFile]
	xor ecx,ecx
	call [__imp_ExitProcess]
start endp
end