@echo off
SETLOCAL
REM === CONFIG BEGIN =====================================

REM If MinGW32 is installed, set the installation path here:
SET GCC=C:\Tools\mingw32

REM === CONFIG END =======================================
TITLE ImpLib SDK (GCC Win32 example)
SET GCCEXE="%GCC%\gcc"
IF EXIST "%GCCEXE%.exe" GOTO GCCFOUND
SET GCCEXE="%GCC%\bin\gcc"
IF EXIST "%GCCEXE%.exe" GOTO GCCFOUND
ECHO GCC not found. Please, specify the correct path, if MinGW32 is installed.
GOTO EXIT
:GCCFOUND
"%GCCEXE%" -c test.c -o test.o
IF %ERRORLEVEL% NEQ 0 GOTO EXIT
SET LDLINK="%GCC%\ld"
IF EXIST "%LDLINK%.exe" GOTO LDLINKFOUND
SET LDLINK="%GCC%\bin\ld"
IF EXIST "%LDLINK%.exe" GOTO LDLINKFOUND
ECHO GNU linker not found.
GOTO EXIT
:LDLINKFOUND
echo Linking the Win32 executable using the GNU Linker (LD)
"%LDLINK%" -m i386pe -subsystem windows -o test.exe -e _start -L..\..\..\lib\Win32\stripped test.o -lkernel32 -luser32
:EXIT
pause
ENDLOCAL
@echo on