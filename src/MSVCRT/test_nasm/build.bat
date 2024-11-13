@echo off
SETLOCAL
REM === CONFIG BEGIN =====================================

REM If you have NASM installed, set the installation path:
SET NASM=C:\Tools\NASM

REM === CONFIG END =======================================
TITLE ImpLib SDK
echo Building an executable using the MSVCRT library with NASM and Polink
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
"%NASMEXE%" -fwin32 test.asm
SET POLINK="%NASM%\polink"
IF EXIST "%POLINK%.exe" GOTO LINKFOUND
ECHO Polink linker not found.
GOTO EXIT
:LINKFOUND
"%POLINK%" /ENTRY:start /SUBSYSTEM:CONSOLE test.obj ..\..\..\lib\msvcrt.lib
:EXIT
pause
ENDLOCAL
@echo on
