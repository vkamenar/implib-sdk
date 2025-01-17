// MSVCRT uses the C linkage convention (CDECL)
__cdecl int printf(const char *, ...);

void start(char *argv0){
	printf("Hello World!");
}
