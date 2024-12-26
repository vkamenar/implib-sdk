@echo off
SETLOCAL
REM === CONFIG BEGIN =================================================

REM If you have MASM (or MASM32) installed, set the installation path:
SET MASM=C:\Tools\MASM

REM === CONFIG END ===================================================
TITLE ImpLib SDK
echo Building a Win32 executable with MASM and the MS linker
echo.
IF EXIST "%MASM%\ml.exe" GOTO MASMFOUND
SET MASM=%MASM%\bin
IF EXIST "%MASM%\ml.exe" GOTO MASMFOUND
ECHO MASM not found. Please, specify the correct path, if MASM or MASM32 is installed.
GOTO EXIT
:MASMFOUND
"%MASM%\ml" /c /coff test.asm
SET MSLNK="%MASM%\link32"
IF EXIST "%MSLNK%.exe" GOTO LINKFOUND
SET MSLNK="%MASM%\link"
IF EXIST "%MSLNK%.exe" GOTO LINKFOUND
ECHO Linker not found.
GOTO EXIT
:LINKFOUND
"%MSLNK%" /SUBSYSTEM:WINDOWS /MERGE:.rdata=.text /LIBPATH:..\..\..\lib -ignore:4078 test.obj
:EXIT
pause
ENDLOCAL
@echo on
