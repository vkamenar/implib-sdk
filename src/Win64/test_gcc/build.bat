@echo off
SETLOCAL
REM === CONFIG BEGIN =====================================

REM If MinGW64 is installed, set the installation path here:
SET GCC=C:\mingw64

REM === CONFIG END =======================================
TITLE ImpLib SDK (GCC Win64 example)
SET GCCEXE="%GCC%\gcc"
IF EXIST "%GCCEXE%.exe" GOTO GCCFOUND
SET GCCEXE="%GCC%\bin\gcc"
IF EXIST "%GCCEXE%.exe" GOTO GCCFOUND
ECHO GCC not found. Please, specify the correct path, if MinGW64 is installed.
GOTO EXIT
:GCCFOUND

REM Optional file size optimization flags:
REM   To remove EH sections (.pdata and .xdata): -fno-asynchronous-unwind-tables -fno-unwind-tables
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
echo Linking the Win64 executable using the GNU Linker (LD)

REM Optional file size optimization flags:
REM   To remove symbol tables (debug symbols): -s
REM   To remove the relocations: --disable-reloc-section
"%LDLINK%" -m i386pep -subsystem console -o test.exe -e start -L..\..\..\lib\Win64\lld test.o -lkernel32

:EXIT
pause
ENDLOCAL
@echo on
