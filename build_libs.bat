@echo off
VERIFY errors 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 GOTO :EOF
TITLE ImpLib SDK
echo Compiling the import libraries from src\Win32
echo Please, be patient - it takes some minutes to compile...
echo.

FOR /f "delims=" %%i IN ('dir /A-D /B /S src\MSVCRT\msvcrt.def src\Win32 2^>NUL ^| findstr /E /R ".*.def" ^|sort') DO CALL :FASM %%i

GOTO EXIT
:FASM
 SET F=%~n1

 echo Compiling lib\%F%.lib, including original thunk
 (
  echo include '..\implib.inc'
  echo KEEP_ORIGINAL_THUNK equ 1
  more +1 %1
 ) >src\Win32\.tmp.asm
 bin\FASM src\Win32\.tmp.asm lib\%F%.lib

 echo Compiling lib\stripped\%F%.lib, without original thunk
 (
  echo include '..\implib.inc'
  echo KEEP_ORIGINAL_THUNK equ 0
  more +1 %1
 ) >src\Win32\.tmp.asm
 bin\FASM src\Win32\.tmp.asm lib\stripped\%F%.lib

 GOTO :EOF

:EXIT
del /s src\Win32\.tmp.asm >nul 2>&1
pause
ENDLOCAL
@echo on
