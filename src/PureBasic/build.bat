@echo off
TITLE ImpLib SDK sample project: PureBasic with OpenAL
PUSHD "%~dp0"
echo Compiling the OpenAL32 import library for PureBasic
echo.
..\..\bin\FASM openal32.def Pbopenal.lib
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

echo.
REM Try to locate the PureBasic (32-bit) installation directory
SET PB64=0
SET PB_HOME=%ProgramFiles(X86)%
IF "%ProgramFiles(X86)%" == "" SET PB_HOME=%ProgramFiles%
SET PB_HOME=%PB_HOME%\PureBasic
IF EXIST "%PB_HOME%\SDK\LibraryMaker.exe" GOTO PBFOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\PureBasic (x86)_is1" /s 2^>nul ^| find "InstallLocation"') DO SET PB_HOME=%%j
IF EXIST "%PB_HOME%\SDK\LibraryMaker.exe" GOTO PBFOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\PureBasic_is1" /s 2^>nul ^| find "InstallLocation"') DO SET PB_HOME=%%j
IF EXIST "%PB_HOME%\SDK\LibraryMaker.exe" GOTO PBFOUND

REM Check if 64-bit version is available
SET PB64=1
SET PB_HOME=%ProgramW6432%\PureBasic
IF EXIST "%PB_HOME%\SDK\LibraryMaker.exe" GOTO PBFOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\PureBasic (x64)_is1" /s 2^>nul ^| find "InstallLocation"') DO SET PB_HOME=%%j
IF EXIST "%PB_HOME%\SDK\LibraryMaker.exe" GOTO PBFOUND

ECHO -ERR: PureBasic not found. It is required to generate the User-Lib.
GOTO EXIT

:PBFOUND
REM Convert to short path format. Othewise the LibraryMaker will fail.
for %%x in ("%PB_HOME%\") do set SH_PBHOME=%%~dpsx
echo Generating the User-Lib for PureBasic.
echo.
%SH_PBHOME%\SDK\LibraryMaker .\PBopenal.desc /TO %SH_PBHOME%\PureLibraries\UserLibraries\
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

IF %PB64% == 0 GOTO BUILD_EXE
ECHO -WNG: The User-Lib was created, but this sample project requires a 32-bit PureBasic compiler to create the executable.
GOTO EXIT

:BUILD_EXE
echo.
echo Compiling the sample PureBasic application
echo.
%SH_PBHOME%\Compilers\pbcompilerc /CONSOLE -z /EXE test.exe pb_openal.pb
:EXIT
pause
POPD
ENDLOCAL
@echo on