[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14429852.svg)](https://doi.org/10.5281/zenodo.14429852) 
[![SWH](https://archive.softwareheritage.org/badge/swh:1:dir:3771978edce480da3965c332adaaa6cd45cbedcd/)](https://archive.softwareheritage.org/swh:1:dir:3771978edce480da3965c332adaaa6cd45cbedcd;origin=https://doi.org/10.5281/zenodo.14429852)

# ImpLib SDK

<img src="https://vkamenar.github.io/implib/logo.png" align="left" hspace="8" vspace="8" alt="ImpLib SDK"/>ImpLib SDK combines free programming tools for authoring custom import libraries for Windows DLL (32 and 64-bit). The SDK supports advanced features, like *cdecl2stdcall* conversion, importing by ordinal, removing *original thunk*, accessing internal undocumented functions. There are many use cases, like interfacing a DLL with a calling convention incompatible with the compiler, mangling the symbolic aliases for an existing object file, fixing conflicts when the same symbol is exported by multiple DLL and so on. ImpLib SDK provides a set of tools to solve this kind of problems. It is not necessary to understand the internal structure of an Import Library file to use these tools.

The ImpLib SDK is also useful to overcome any legal restrictions when redistributing the import libraries for certain DLL files, like the Microsoft® C++ runtime. The [import libraries for the CRT or STL](https://learn.microsoft.com/en-us/cpp/c-runtime-library/crt-library-features?view=msvc-160) are part of the Windows SDK. Even though the SDK is available for free, redistributing these files is not allowed according to the current license agreements. An alternative is to generate these import libraries using the ImpLib SDK, as it doesn't restrict redistribution.

The import libraries generated by the ImpLib SDK are compatible with any linker supporting the MS COFF object file format. The SDK was tested extensively using the following linkers:
* Pelle's Linker (polink)
* MS Linker
* GNU Linker (LD)
* LLVM linker (lld-link)

The [ImpLib SDK Guide](https://vkamenar.github.io/implib/EN.HTM) provides a more detailed description and a set of tutorials.

The ImpLib SDK can also generate import libraries for Visual Basic 6, [even if the DLL uses a non-*stdcall* calling convention, like *cdecl*](https://github.com/vkamenar/implib-sdk/discussions/3). One of the sample projects included into the ImpLib SDK shows how to use the OpenAL API with Visual Basic 6. The OpenAL DLL uses the *cdecl* calling convention.

The ImpLib SDK is free even for commercial use and redistribution of any kind, as long as all copyrights are preserved. The whole package is provided "AS IS". Check the [license](/LICENSE) file for additional information.

## Installation and Usage

Unpack the ImpLib SDK release into any directory. Then launch ```build_libs.bat```. This batch file builds or rebuilds the sample import libraries: MSVCRT, Win32 and Win64 system API libraries.

The output libraries are stored under the ```lib``` subdirectory. Two import libraries are created for each input file. One of the libraries follows the MS format and internal naming conventions. The other one uses the format and naming compatible with GNU LD and LLVM. The latter is stored into the ```lib\lld``` subdirectory.

If you add new import library definitions or modify the sample files, just rerun ```build_libs.bat```. Only new or modified files will be recompiled.
