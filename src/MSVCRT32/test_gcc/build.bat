@echo off
SETLOCAL
REM === CONFIG BEGIN =====================================

REM If MinGW32 is installed, set the installation path here:
SET GCC="C:\mingw32"

REM === CONFIG END =======================================
TITLE ImpLib SDK (GCC MSVCRT example)
SET GCCEXE="%GCC%\gcc"
IF EXIST "%GCCEXE%.exe" GOTO GCCFOUND
SET GCCEXE="%GCC%\bin\gcc"
IF EXIST "%GCCEXE%.exe" GOTO GCCFOUND
ECHO GCC not found. Please, specify the correct path, if MinGW32 is installed.
GOTO EXIT
:GCCFOUND

REM Optional file size optimization flags:
REM   To remove EH sections: -fomit-frame-pointer -fno-exceptions -fno-asynchronous-unwind-tables -fno-unwind-tables
REM   To remove the GCC version information: -fno-ident
"%GCCEXE%" -c test.c -o test.o

IF %ERRORLEVEL% NEQ 0 GOTO EXIT
SET LDLINK="%GCC%\ld"
IF EXIST "%LDLINK%.exe" GOTO LDLINKFOUND
SET LDLINK="%GCC%\bin\ld"
IF EXIST "%LDLINK%.exe" GOTO LDLINKFOUND
ECHO GNU linker not found.
GOTO EXIT
:LDLINKFOUND
echo Linking the Win32 executable to MSVCRT.DLL using the GNU Linker (LD)

REM Optional file size optimization flags:
REM   To remove symbol tables (debug directory): -s
REM   To remove the .reloc section: --disable-reloc-section
"%LDLINK%" -m i386pe -subsystem console -o test.exe -e _start test.o ..\..\..\lib\MSVCRT32\lld\msvcrt.lib

:EXIT
pause
ENDLOCAL
@echo on