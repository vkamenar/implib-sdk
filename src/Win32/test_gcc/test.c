// Most of the Win32 API uses the STDCALL calling convention
__stdcall int Beep(int, int);
__stdcall int MessageBoxA(int, char*, char*, int);
__stdcall int ExitProcess(int);

void start(char *argv0){
	Beep(750, 300); // 750 Hz ~300 ms
	MessageBoxA(0, "Hello, world!", "Test", 0);
	ExitProcess(0);
}