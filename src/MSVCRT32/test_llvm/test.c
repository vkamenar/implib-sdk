// MSVCRT uses the C linkage convention (CDECL)
__cdecl int printf(const char *, ...);
__cdecl int _getch(void);
__cdecl char* getenv(char*);

void start(char *argv0){

	// Print some environment variables:
	printf("PATH: %s\n", getenv("PATH"));
	printf("TEMP: %s\n", getenv("TEMP"));

	// Wait for some input before exiting
	printf("Press any key to exit");
	_getch();
}