// Most of the Win32 API uses the STDCALL calling convention
__stdcall int MessageBoxA(int, char*, char*, int);
__stdcall int ExitProcess(int);

void start(char *argv0){
	MessageBoxA(0, "Hello, world!", "Test", 0);
	ExitProcess(0);
}
