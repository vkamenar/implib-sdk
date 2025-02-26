@echo off
SETLOCAL
REM === CONFIG BEGIN =================================================

REM If you have MASM64 installed, set the installation path:
SET MASM=C:\MASM64

REM === CONFIG END ===================================================
TITLE ImpLib SDK (MASM64 Win64 example)
IF EXIST "%MASM%\ml64.exe" GOTO MASMFOUND
SET MASM=%MASM%\bin
IF EXIST "%MASM%\ml64.exe" GOTO MASMFOUND
SET MASM=%MASM%64
IF EXIST "%MASM%\ml64.exe" GOTO MASMFOUND
ECHO MASM not found. Please, specify the correct path, if MASM64 is installed.
GOTO EXIT
:MASMFOUND
"%MASM%\ml64" /c test.asm
IF %ERRORLEVEL% NEQ 0 GOTO EXIT
SET LNKEXE="%MASM%\link"
IF EXIST "%LNKEXE%.exe" GOTO MSLINKFOUND
SET LNKEXE="%MASM%\polink"
IF EXIST "%LNKEXE%.exe" GOTO POLINKFOUND
ECHO Linker not found.
GOTO EXIT
:MSLINKFOUND
echo Linking the Win64 executable using MS linker

REM Optional file size optimization flag:
REM   To remove the debug directory (undocumented flag): /EMITPOGOPHASEINFO
"%LNKEXE%" /ENTRY:start /SUBSYSTEM:CONSOLE /MACHINE:X64 /LIBPATH:..\..\..\lib\Win64 test.obj
GOTO EXIT
:POLINKFOUND
echo Linking the Win64 executable using Polink

REM Optional file size optimization flags:
REM   Merge '.data' section to '.text': /MERGE:.data=.text
"%LNKEXE%" /ENTRY:start /SUBSYSTEM:CONSOLE /MACHINE:X64 /LIBPATH:..\..\..\lib\Win64 test.obj

:EXIT
pause
ENDLOCAL
@echo on