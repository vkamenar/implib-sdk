@echo off
SETLOCAL
REM === CONFIG BEGIN ===========================================

REM PureBasic installation path.
SET PB_HOME=C:\Program Files (x86)\PureBasic

REM === CONFIG END =============================================
TITLE Building Pbopenal...
PUSHD "%~dp0"

REM Convert to short path format. Othewise the LibraryMaker will fail.
for %%x in ("%PB_HOME%\") do set SH_PBHOME=%%~dpsx

IF EXIST "%SH_PBHOME%\Compilers\fasm.exe" GOTO FASMFOUND
ECHO PureBasic not found. To generate the User-Lib, install PureBasic
ECHO and set PB_HOME configuration option to the location where PureBasic
ECHO is installed.
GOTO EXIT
:FASMFOUND
"%SH_PBHOME%\Compilers\fasm" openal32.def Pbopenal.lib
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

REM Run LibraryMaker to convert the import library to User-Lib format
IF EXIST "%SH_PBHOME%\SDK\LibraryMaker.exe" GOTO PBFOUND
ECHO PureBasic SDK not found.
GOTO EXIT
:PBFOUND
%SH_PBHOME%\SDK\LibraryMaker .\PBopenal.desc

:EXIT
pause
POPD
ENDLOCAL
@echo on
