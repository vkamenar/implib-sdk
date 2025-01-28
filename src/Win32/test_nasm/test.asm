EXTERN __imp__Beep@8
EXTERN __imp__MessageBoxA@16
EXTERN __imp__ExitProcess@4
%define Beep [__imp__Beep@8]
%define MessageBox [__imp__MessageBoxA@16]
%define ExitProcess [__imp__ExitProcess@4]

section .text
ttl db "Test",0
msg db "Hello, world!",0
align 4
GLOBAL _start
_start:
	push 300   ; dwDuration: 300 ms
	push 750   ; dwFreq: 750 Hz
	call Beep
	push 0     ; uType: MB_OK
	push ttl   ; lpCaption
	push msg   ; lpText
	push 0     ; hWnd: no owner window
	call MessageBox
	push eax   ; uExitCode
	call ExitProcess
