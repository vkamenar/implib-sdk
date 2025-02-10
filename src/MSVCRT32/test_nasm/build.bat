@echo off
SETLOCAL
REM === CONFIG BEGIN =====================================

REM If you have MinGW32 or a standalone NASM installation,
REM set the installation path here:
SET NASM=C:\NASM

REM === CONFIG END =======================================
TITLE ImpLib SDK (NASM MSVCRT example)
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
"%NASMEXE%" -fwin32 test.asm
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
echo Linking the Win32 executable to MSVCRT.DLL using Polink

REM Optional file size optimization flags:
REM   Merge '.data' section to '.text': /MERGE:.data=.text
"%POLINK%" /ENTRY:start /SUBSYSTEM:CONSOLE test.obj ..\..\..\lib\MSVCRT32\msvcrt.lib
GOTO EXIT
:LDLINKFOUND
echo Linking the Win32 executable to MSVCRT.DLL using the GNU Linker (LD)

REM Optional file size optimization flags:
REM   To remove symbol tables (debug directory): -s
REM   To remove the .reloc section: --disable-reloc-section
"%LDLINK%" -m i386pe -subsystem console -o test.exe -e _start test.obj ..\..\..\lib\MSVCRT32\lld\msvcrt.lib
:EXIT
pause
ENDLOCAL
@echo on