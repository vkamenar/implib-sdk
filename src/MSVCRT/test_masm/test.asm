.386
.model flat,stdcall

; MSVCRT API
include msvcrt.inc
includelib msvcrt.lib

.CODE
format db "Hello, world!",0

start:
	invoke printf,OFFSET format
	ret
END start