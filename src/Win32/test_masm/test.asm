.386
.model flat,stdcall

includelib user32.lib

MessageBoxA PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD

.CODE
ttl db "Test",0
msg db "Hello, world!",0

start:
	invoke MessageBoxA, 0, OFFSET msg, OFFSET ttl, 0
	retn
END start
