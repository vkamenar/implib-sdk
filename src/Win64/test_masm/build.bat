@echo off
SETLOCAL
REM === CONFIG BEGIN =================================================

REM If you have MASM64 installed, set the installation path:
SET MASM=C:\Tools\MASM64

REM === CONFIG END ===================================================
TITLE ImpLib SDK (MASM Win64 example)
echo Building a Win64 executable with MASM64 and either the MS linker or polink
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
IF EXIST "%LNKEXE%.exe" GOTO LINKFOUND
SET LNKEXE="%MASM%\polink"
IF EXIST "%LNKEXE%.exe" GOTO LINKFOUND
ECHO Linker not found.
GOTO EXIT
:LINKFOUND
"%LNKEXE%" /ENTRY:start /SUBSYSTEM:CONSOLE /MACHINE:X64 /MERGE:.rdata=.text /LIBPATH:..\..\..\lib\Win64\stripped -ignore:4078 test.obj
:EXIT
pause
ENDLOCAL
@echo on