@echo off
TITLE ImpLib SDK sample: Visual Basic 6 with OpenAL32
PUSHD "%~dp0"
echo Compiling the OpenAL32 import library for Visual Basic 6
echo.
..\..\bin\FASM openal32.def openal32.lib

pause
POPD
@echo on
