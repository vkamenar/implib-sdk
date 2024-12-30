@echo off
VERIFY errors 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 GOTO :EOF
TITLE ImpLib SDK
echo Compiling the import libraries
echo.

FOR /f "delims=" %%i IN ('dir /A-D /B /S src\MSVCRT32\*.def src\Win32\*.def src\Win64\*.def 2^>NUL ^| findstr /E /R ".*.def" ^|sort') DO CALL :BLD "%%i"
pause
ENDLOCAL
@echo on
GOTO :EOF

:BLD
 SET F=%~n1
 SET P=%~p1
 FOR %%f IN ("%P:~0,-1%") DO SET P="%%~nxf"
 SET P=%P:"=%
 CALL :DO_BLD %1 lib\%P%\%F%.lib 1 including
 CALL :DO_BLD %1 lib\%P%\stripped\%F%.lib 0 without
 GOTO :EOF

:DO_BLD
 IF NOT EXIST %2 GOTO FASM
 XCOPY /L /D /Y %1 %2 | FINDSTR /B /C:"1 " >nul && GOTO FASM
 GOTO :EOF
:FASM
 SET /p impline=< %1
 echo Compiling %2, %4 original thunk
 (
  echo %impline%
  echo KEEP_ORIGINAL_THUNK equ %3
  more +1 %1
 ) >"%~1.tmp"
 bin\FASM "%~1.tmp" %2
 del /s "%~1.tmp" >nul 2>&1
