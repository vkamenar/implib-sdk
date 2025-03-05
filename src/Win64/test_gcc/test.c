int GetStdHandle(int);
int WriteFile(int, char*, int, int*, void*);
int ExitProcess(int);

#define STD_OUTPUT_HANDLE -11
#define MSG "Hello, World!\r\n"

void start(char *argv0){
	int written;
	WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), MSG, sizeof(MSG) - 1, &written, 0);
	ExitProcess(0);
}