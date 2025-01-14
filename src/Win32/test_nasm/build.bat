@echo off
SETLOCAL
REM === CONFIG BEGIN =====================================

REM If you have MinGW32 or a standalone NASM installation,
REM set the installation path here:
SET NASM=C:\Tools\mingw32

REM === CONFIG END =======================================
TITLE ImpLib SDK (NASM Win32 example)
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
echo Linking the Win32 executable using Polink
"%POLINK%" /ENTRY:start /SUBSYSTEM:WINDOWS /MERGE:.data=.text /LIBPATH:..\..\..\lib\Win32\stripped test.obj kernel32.lib user32.lib
GOTO EXIT
:LDLINKFOUND
echo Linking the Win32 executable using the GNU Linker (LD)
"%LDLINK%" -m i386pe -subsystem windows -o test.exe -e _start -L..\..\..\lib\Win32\stripped test.obj -lkernel32 -luser32
:EXIT
pause
ENDLOCAL
@echo on