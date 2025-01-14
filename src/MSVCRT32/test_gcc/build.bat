@echo off
SETLOCAL
REM === CONFIG BEGIN =====================================

REM If MinGW32 is installed, set the installation path here:
SET GCC=C:\Tools\mingw32

REM === CONFIG END =======================================
TITLE ImpLib SDK (GCC MSVCRT example)
SET GCCEXE="%GCC%\gcc"
IF EXIST "%GCCEXE%.exe" GOTO GCCFOUND
SET GCCEXE="%GCC%\bin\gcc"
IF EXIST "%GCCEXE%.exe" GOTO GCCFOUND
ECHO GCC not found. Please, specify the correct path, if MInGW32 is installed.
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
echo Linking the Win32 executable to MSVCRT.DLL using the GNU Linker (LD)
"%LDLINK%" -m i386pe -subsystem console -o test.exe -e _start test.o ..\..\..\lib\MSVCRT32\stripped\msvcrt.lib
:EXIT
pause
ENDLOCAL
@echo on