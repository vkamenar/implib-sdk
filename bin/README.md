This directory contains the binary tools:

- **dll2def** is a command-line utility to extract the dynamic-link library symbols in plain text format. This tool supports x86 (32-bit) and x64 (64-bit) DLL.
- **VB6LINK** is a wrapper for the Microsoft linker distributed with Visual Basic 6. The purpose of the wrapper is to link native Visual Basic 6 applications to 32-bit DLL, especially when using non-*stdcall* calling conventions (e.g. *cdecl*), by injecting import libraries generated by the ImpLib SDK into the Microsoft linker command line.
- The **fasm** compiler (flat assembler). It is used as a preprocessor to generate the import libraries.
