# ImpLib SDK

<img src="https://implib.sourceforge.io/logo.png" align="left" hspace="8" vspace="8" alt="ImpLib SDK"/>ImpLib SDK combines free programming tools for authoring custom import libraries with advanced features, like *cdecl2stdcall* conversion, importing by ordinal, removing *original thunk*, accessing internal undocumented functions. There are many non-standard use cases, like interfacing a DLL with *cdecl* calling convention from Visual Basic 6, prototyping a set of DLL functions for PureBasic, mangling the symbolic aliases for an existing 
object file in Visual C / MASM32 / NASM and so on. ImpLib SDK provides a set of tools to solve this kind of problems. It is not necessary to know the internal structure of an Import Library file to use these tools.

The ImpLib SDK is also useful to overcome any legal restrictions when redistributing the import libraries for certain DLL files, like the Microsoft® C++ runtime. The [import libraries for the CRT or STL](https://learn.microsoft.com/en-us/cpp/c-runtime-library/crt-library-features?view=msvc-160) are part of the Windows SDK. Even though the SDK is available for free, redistributing these files is not allowed according to the current license agreements. An alternative is to generate these import libraries using the ImpLib SDK, as it doesn't restrict redistribution.

The [ImpLib SDK Guide](https://implib.sourceforge.io/EN.HTM) provides a more detailed description and a set of usage tutorials.

The ImpLib SDK is free even for commercial use and redistribution of any kind, as long as all copyrights are preserved. The whole package is provided "AS IS". Check the license file included in the current release for additional info.
