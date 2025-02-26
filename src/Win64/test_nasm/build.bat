@echo off
SETLOCAL
REM === CONFIG BEGIN =====================================

REM If you have MinGW-w64 or a standalone NASM installation,
REM set the installation path here:
SET NASM=C:\mingw64

REM === CONFIG END =======================================
TITLE ImpLib SDK (NASM Win64 example)
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
IF %ERRORLEVEL% NEQ 0 GOTO EXIT
SET POLINK="%NASM%\polink"
IF EXIST "%POLINK%.exe" GOTO POLINKFOUND
SET POLINK="%NASM%\bin\polink"
IF EXIST "%POLINK%.exe" GOTO POLINKFOUND
SET LDLINK="%NASM%\ld"
IF EXIST "%LDLINK%.exe" GOTO LDLINKFOUND
SET LDLINK="%NASM%\bin\ld"
IF EXIST "%LDLINK%.exe" GOTO LDLINKFOUND
ECHO No linker found (neither Polink nor LD).
GOTO EXIT
:POLINKFOUND
echo Linking the Win64 executable using Polink

REM Optional file size optimization flag:
REM   Merge '.data' section to '.text': /MERGE:.data=.text
"%POLINK%" /ENTRY:start /SUBSYSTEM:CONSOLE /LIBPATH:..\..\..\lib\Win64 test.obj kernel32.lib
GOTO EXIT
:LDLINKFOUND
echo Linking the Win64 executable using the GNU Linker (LD)

REM Optional file size optimization flags:
REM   To remove symbol tables (debug symbols): -s
REM   To remove the relocations: --disable-reloc-section
"%LDLINK%" -m i386pep -subsystem console -o test.exe -e start -L..\..\..\lib\Win64\lld test.obj -lkernel32 -luser32

:EXIT
pause
ENDLOCAL
@echo on