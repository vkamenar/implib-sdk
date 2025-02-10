.386
.model flat,stdcall

; MSVCRT API
include msvcrt.inc
includelib msvcrt.lib

.DATA
buf   db 128 dup(0)
sDate db "The current date is: %s",13,10,0
sTime db "The current time is: %s",13,10,0
sExit db "Press any key to exit",0

.CODE
start:
	; Set time zone from TZ environment variable.
	; If TZ is not set, the operating system default value is used.
	invoke _tzset

	; Print the current date
	invoke _strdate_s,OFFSET buf,128
	invoke printf,OFFSET sDate,OFFSET buf

	; Print the current time
	invoke _strtime_s,OFFSET buf,128
	invoke printf,OFFSET sTime,OFFSET buf

	; Wait for some input before exiting
	invoke printf,OFFSET sExit
	invoke _getch
	ret
END start