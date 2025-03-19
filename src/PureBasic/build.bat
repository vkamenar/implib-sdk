@echo off
TITLE ImpLib SDK sample project: PureBasic with OpenAL
PUSHD "%~dp0"
echo Compiling the OpenAL32 and OpenAL64 import libraries for PureBasic
echo.
..\..\bin\FASM openal32.def Pbopenal.lib
IF %ERRORLEVEL% NEQ 0 GOTO EXIT
..\..\bin\FASM openal64.def Pbopenal64.lib
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

echo.
REM Try to locate the PureBasic 32-bit installation directory
SET PB32_HOME=%ProgramFiles(X86)%
IF "%ProgramFiles(X86)%" == "" SET PB32_HOME=%ProgramFiles%
SET PB32_HOME=%PB_HOME%\PureBasic
IF EXIST "%PB32_HOME%\SDK\LibraryMaker.exe" GOTO PB32FOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\PureBasic (x86)_is1" /s 2^>nul ^| find "InstallLocation"') DO SET PB32_HOME=%%j
IF EXIST "%PB32_HOME%\SDK\LibraryMaker.exe" GOTO PB32FOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\PureBasic_is1" /s 2^>nul ^| find "InstallLocation"') DO SET PB32_HOME=%%j
IF EXIST "%PB32_HOME%\SDK\LibraryMaker.exe" GOTO PB32FOUND
SET PB32_HOME=
:PB32FOUND
REM Try to locate the PureBasic 64-bit installation directory
SET PB64_HOME=%ProgramW6432%\PureBasic
IF EXIST "%PB64_HOME%\SDK\LibraryMaker.exe" GOTO PB64FOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\PureBasic (x64)_is1" /s 2^>nul ^| find "InstallLocation"') DO SET PB64_HOME=%%j
IF EXIST "%PB64_HOME%\SDK\LibraryMaker.exe" GOTO PB54FOUND
SET PB64_HOME=
:PB64FOUND
IF NOT "%PB32_HOME%%PB64_HOME%" == "" GOTO PBFOUND
ECHO -ERR: PureBasic not found. It is required to generate the User-Libs.
GOTO EXIT

:PBFOUND
REM Convert to short path format. Othewise the LibraryMaker will fail.
SET PB_HOME=%PB64_HOME%
IF "%PB_HOME%" == "" SET PB_HOME=%PB32_HOME%
for %%x in ("%PB_HOME%\") do set SH_PBHOME=%%~dpsx
echo Generating the User-Libs for PureBasic.
echo.
%SH_PBHOME%\SDK\LibraryMaker .\PBopenal.desc
IF %ERRORLEVEL% NEQ 0 GOTO EXIT
IF NOT "%PB32_HOME%" == "" move /Y PBopenal "%PB32_HOME%\PureLibraries\UserLibraries\"
%SH_PBHOME%\SDK\LibraryMaker .\PBopenal64.desc
IF %ERRORLEVEL% NEQ 0 GOTO EXIT
IF NOT "%PB64_HOME%" == "" move /Y PBopenal64 "%PB64_HOME%\PureLibraries\UserLibraries\"

:BUILD_EXE
echo.
echo Compiling the sample PureBasic applications
echo.
IF "%PB32_HOME%" == "" GOTO PB64BUILD
"%PB32_HOME%\Compilers\pbcompilerc" /CONSOLE -z /EXE test.exe pb_openal.pb
:PB64BUILD
IF "%PB64_HOME%" == "" GOTO EXIT
"%PB64_HOME%\Compilers\pbcompilerc" /CONSOLE -z /EXE test64.exe pb_openal.pb
:EXIT
pause
POPD
ENDLOCAL
@echo on