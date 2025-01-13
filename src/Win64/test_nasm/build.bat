@echo off
SETLOCAL
REM === CONFIG BEGIN =====================================

REM If you have NASM installed, set the installation path:
SET NASM=C:\Tools\NASM

REM === CONFIG END =======================================
TITLE ImpLib SDK
echo Building a Win64 executable with NASM and Polink or LD
echo.
SET NASMEXE="%NASM%\nasmw"
IF EXIST "%NASMEXE%.exe" GOTO NASMFOUND
SET NASMEXE="%NASM%\nasm"
IF EXIST "%NASMEXE%.exe" GOTO NASMFOUND
SET NASMEXE="%NASM%\bin\nasmw"
IF EXIST "%NASMEXE%.exe" GOTO NASMFOUND
SET NASMEXE="%NASM%\bin\nasm"
IF EXIST "%NASMEXE%.exe" GOTO NASMFOUND
ECHO NASM not found. Please, specify the correct path, if NASM is installed.
GOTO EXIT
:NASMFOUND
"%NASMEXE%" -fwin64 test.asm
SET POLINK="%NASM%\polink"
IF EXIST "%POLINK%.exe" GOTO POLINKFOUND
SET LDLINK="%NASM%\ld"
IF EXIST "%LDLINK%.exe" GOTO LDLINKFOUND
ECHO No linker found (neither Polink nor LD).
GOTO EXIT
:POLINKFOUND
"%POLINK%" /ENTRY:start /SUBSYSTEM:CONSOLE /MERGE:.data=.text /LIBPATH:..\..\..\lib\Win64\stripped test.obj kernel32.lib
GOTO EXIT
:LDLINKFOUND
"%LDLINK%" -m i386pep -subsystem console -o test.exe -e start -L..\..\..\lib\Win64\stripped test.obj -lkernel32 -luser32
:EXIT
pause
ENDLOCAL
@echo on