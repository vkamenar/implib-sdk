@echo off
VERIFY errors 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 GOTO :EOF
TITLE ImpLib SDK
echo Compiling the import libraries
echo.

FOR /f "delims=" %%i IN ('dir /A-D /B /S src\MSVCRT\*.def src\Win32\*.def 2^>NUL ^| findstr /E /R ".*.def" ^|sort') DO CALL :BLD %%i
del /s src\.tmp.asm >nul 2>&1
pause
ENDLOCAL
@echo on
GOTO :EOF

:BLD
 SET F=%~n1
 CALL :DO_BLD %1 lib\%F%.lib 1 including
 CALL :DO_BLD %1 lib\stripped\%F%.lib 0 without
 GOTO :EOF

:DO_BLD
 IF NOT EXIST %2 GOTO FASM
 XCOPY /L /D /Y %1 %2 | FINDSTR /B /C:"1 " >nul && GOTO FASM
 GOTO :EOF
:FASM
 echo Compiling %2, %4 original thunk
 (
  echo include 'implib.inc'
  echo KEEP_ORIGINAL_THUNK equ %3
  more +1 %1
 ) >src\.tmp.asm
 bin\FASM src\.tmp.asm %2
