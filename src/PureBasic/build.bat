@echo off
TITLE ImpLib SDK sample project: PureBasic with OpenAL
PUSHD "%~dp0"
echo Compiling the OpenAL32 import library for PureBasic
echo.
..\..\bin\FASM openal32.def Pbopenal.lib
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

echo.
SET PB_HOME="C:\Program Files (x86)\PureBasic"
IF EXIST "%PB_HOME%\SDK\LibraryMaker.exe" GOTO PBFOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\PureBasic_is1" /s 2^>nul ^| find "InstallLocation"') DO SET PB_HOME=%%j
IF EXIST "%PB_HOME%\SDK\LibraryMaker.exe" GOTO PBFOUND
ECHO -ERR: PureBasic not found. It is required to generate the User-Lib.
GOTO EXIT
:PBFOUND
REM Convert to short path format. Othewise the LibraryMaker will fail.
for %%x in ("%PB_HOME%\") do set SH_PBHOME=%%~dpsx
echo Generating the User-Lib for PureBasic.
echo.
%SH_PBHOME%\SDK\LibraryMaker .\PBopenal.desc
IF %ERRORLEVEL% NEQ 0 GOTO EXIT
copy /Y PBopenal "%PB_HOME%\PureLibraries\UserLibraries\PBopenal"
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

echo.
echo Compiling the sample PureBasic application
echo.
%SH_PBHOME%\Compilers\pbcompilerc /CONSOLE -z /EXE test.exe pb_openal.pb
:EXIT
pause
POPD
ENDLOCAL
@echo on