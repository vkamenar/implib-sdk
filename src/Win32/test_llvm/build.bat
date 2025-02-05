@echo off
SETLOCAL
REM === CONFIG BEGIN =====================================

REM If LLVM is installed, set the installation path here:
SET LLVM="C:\Program Files (x86)\LLVM"

REM === CONFIG END =======================================
TITLE ImpLib SDK (LLVM Win32 example)
SET CLANGEXE="%LLVM%\clang"
IF EXIST "%CLANGEXE%.exe" GOTO CLANGFOUND
SET CLANGEXE="%LLVM%\bin\clang"
IF EXIST "%CLANGEXE%.exe" GOTO CLANGFOUND
ECHO CLANG not found. Please, specify the correct path, if LLVM is installed.
GOTO EXIT
:CLANGFOUND
"%CLANGEXE%" -c test.c -o test.o
IF %ERRORLEVEL% NEQ 0 GOTO EXIT
SET LLDLINK="%LLVM%\lld-link"
IF EXIST "%LLDLINK%.exe" GOTO LLDLNKFOUND
SET LLDLINK="%LLVM%\bin\lld-link"
IF EXIST "%LLDLINK%.exe" GOTO LLDLNKFOUND
ECHO LLD linker not found.
GOTO EXIT
:LLDLNKFOUND
echo Linking the Win32 executable using the LLD linker

REM Optional file size optimization flags:
REM   To remove the .reloc section: /FIXED
REM   To merge .rdata section into .text: /MERGE:.rdata=.text
"%LLDLINK%" /SAFESEH:NO /SUBSYSTEM:WINDOWS /ENTRY:start /LIBPATH:..\..\..\lib\Win32 test.o kernel32.lib user32.lib

:EXIT
pause
ENDLOCAL
@echo on