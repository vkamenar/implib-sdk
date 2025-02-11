// MSVCRT uses the C linkage convention (CDECL)
__cdecl int printf(const char *, ...);
__cdecl int _getch(void);
__cdecl int srand(unsigned int);
__cdecl int rand(void);
__cdecl int time(int*);

void start(char *argv0){
	printf("Pseudorandom numbers:\n");

	// Set the starting seed value for the pseudorandom
	// number generator to the current time in seconds (UTC)
	srand(time(0));

	for(int i = 0; i < 5; i++){
		printf("  %6d\n", rand());
	}

	// Wait for some input before exiting
	printf("\nPress any key to exit");
	_getch();
}
