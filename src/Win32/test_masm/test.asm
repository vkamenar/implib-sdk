.386
.model flat,stdcall

includelib user32.lib
includelib kernel32.lib

Beep        PROTO STDCALL :DWORD, :DWORD
MessageBoxA PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD
ExitProcess PROTO STDCALL :DWORD

.CODE
ttl db "Test",0
msg db "Hello, world!",0
align 4
start:
	invoke Beep, 750, 300 ; 750Hz ~300 ms
	invoke MessageBoxA, 0, OFFSET msg, OFFSET ttl, 0
	invoke ExitProcess, eax
	retn
END start
