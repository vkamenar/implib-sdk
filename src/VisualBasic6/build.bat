@echo off
TITLE ImpLib SDK sample project: Visual Basic 6 with OpenAL
PUSHD "%~dp0"
echo Compiling the OpenAL32 import library for Visual Basic 6
echo.
..\..\bin\FASM openal32.def openal32.lib
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

echo.
SET VB6=%ProgramFiles(X86)%\Microsoft Visual Studio\VB98
IF EXIST "%VB6%\vb6.exe" GOTO VB6FOUND
SET VB6=%ProgramFiles%\Microsoft Visual Studio\VB98
IF EXIST "%VB6%\vb6.exe" GOTO VB6FOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\VisualBasic.ClassModule\shell\open\command" /s 2^>nul ^| find "REG_SZ"') DO SET VB6=%%j
SET VB6=%VB6:~0,-13%
IF EXIST "%VB6%\vb6.exe" GOTO VB6FOUND
ECHO -ERR: Visual Basic 6 not found.
GOTO EXIT
:VB6FOUND
IF EXIST "%VB6%\LNK.EXE" GOTO LNKFOUND
ECHO -ERR: VB6LINK not found in %VB6%. Please, check the readme for information on how to install VB6LINK.
GOTO EXIT
:LNKFOUND
echo Compiling the Visual Basic 6 sample project
echo.
"%VB6%\vb6.exe" /make vb6_openal.vbp

:EXIT
pause
POPD
@echo on