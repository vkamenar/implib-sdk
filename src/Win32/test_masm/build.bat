@echo off
SETLOCAL
REM === CONFIG BEGIN =================================================

REM If you have MASM (or MASM32) installed, set the installation path:
SET MASM="C:\Tools\MASM32"

REM === CONFIG END ===================================================
TITLE ImpLib SDK (MASM Win32 example)
echo Building a Win32 executable with MASM and the MS linker
IF EXIST "%MASM%\ml.exe" GOTO MASMFOUND
SET MASM=%MASM%\bin
IF EXIST "%MASM%\ml.exe" GOTO MASMFOUND
ECHO MASM not found. Please, specify the correct path, if MASM or MASM32 is installed.
GOTO EXIT
:MASMFOUND
"%MASM%\ml" /c /coff test.asm
IF %ERRORLEVEL% NEQ 0 GOTO EXIT
SET MSLNK="%MASM%\link32"
IF EXIST "%MSLNK%.exe" GOTO LINKFOUND
SET MSLNK="%MASM%\link"
IF EXIST "%MSLNK%.exe" GOTO LINKFOUND
ECHO Linker not found.
GOTO EXIT
:LINKFOUND

REM Optional file size optimization flags:
REM   To remove the debug directory (undocumented flag): /EMITPOGOPHASEINFO
REM   To remove the .reloc section: /DYNAMICBASE:NO
"%MSLNK%" /SAFESEH:NO /SUBSYSTEM:WINDOWS /LIBPATH:..\..\..\lib\Win32\stripped -ignore:4078 test.obj

:EXIT
pause
ENDLOCAL
@echo on