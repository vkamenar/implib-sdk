/*
	DLL2DEF source code
	Copyright (c) 2006-2025, Vladimir Kamenar.
	All rights reserved.
*/

#define WINDOWS_IGNORE_PACKING_MISMATCH /* workaroud for C2118 in W10 SDK */
#include <windows.h>

/* Error codes */
enum ERR_CODES{
	ERR_OK,
	ERR_FILE_NOT_FOUND,
	ERR_OUTPUT,
	ERR_BAD_FORMAT,
	ERR_NO_EXPORT,
	ERR_NO_FREE_MEM,
	ERR_BAD_FILENAME
};

/* Error messages */
char error_msgs[][34] = {
	"\": File locked or not found      \n",
	"\": Error opening the output file \n",
	"\": Unreadable or invalid PE image\n",
	"\": No export found               \n",
	"\": Not enough memory             \n",
	"\": Not a valid filename          \n"
};

/* Syntax mods */
#define MOD_NO 0
#define MOD_PB 1
#define MOD_VB 2

typedef struct struct_RVA_2_FileOffset{
	DWORD VirtualAddress;
	DWORD VirtualSize;
	DWORD FileOffset;
} RVA_2_FileOffset;

typedef struct struct_RVA_2_FileOffset_node{
	RVA_2_FileOffset node;
	void *next_node;
} RVA_2_FileOffset_node;

/* Convert an RVA value into a regular file offset */
DWORD do_RVA_2_FileOffset(RVA_2_FileOffset_node *sections, DWORD RVA){
	while(sections){
		if(RVA >= (*sections).node.VirtualAddress &&
			RVA <= (*sections).node.VirtualAddress + (*sections).node.VirtualSize)
			return RVA - (*sections).node.VirtualAddress + (*sections).node.FileOffset;
		sections = (*sections).next_node;
	}
	return 0;
}

/* A simple memcpy replacement if linking without CRT */
void cmemcpy(char *dest, char *src, int n){
	for(int i = 0; i < n; i++)
		dest[i] = src[i];
}

/* A simple sprintf replacement to avoid a dependency on user32!_wsprintf */
int cprintf(char *dest, char *mask, int n){

	/* An ordinal can't be >6 digits */
	int x, len = n <= 9 ? 1 : n <= 99 ? 2 : n <= 999 ? 3 : n <= 9999 ? 4 : n <= 99999 ? 5 : 6;

	char *outp = dest, c;
	while(c = *mask++){
		if(c == '%'){ /* A single instance of a '%' in the mask is expected */
			outp += len;
			x = 0;
			while(len-- > 0){
				*(outp - ++x) = (char)(0x30 + n % 10);
				n /= 10;
			}
		}else
			*outp++ = c;
	}
	return outp - dest;
}

/* Process a single PE file (DLL) and dump it's export */
char buf[1024], dll_name[80], pub_name[80];
int current_mod, compact;
WIN32_FIND_DATA fdata;
int parse_pe(char *filename, HANDLE hFile, HANDLE hOut, HANDLE hHeap){
char c, *cur1, *cur2, x64;
RVA_2_FileOffset export_dir;
RVA_2_FileOffset_node *sections = 0, **current_node = &sections;
DWORD dll_name_len, aux, i, file_pos, size_of_optional_header, is_PE32plus, num_sections;
DWORD ordinal_base, num_pointers, ordinals_array, pointers_array, psymbols_array, pub_name_len;
HANDLE hFind;
WORD ordinal;
	if(hFile == INVALID_HANDLE_VALUE)
		return ERR_FILE_NOT_FOUND;
	if(hOut == INVALID_HANDLE_VALUE)
		return ERR_OUTPUT;
	if(!hHeap)
		return ERR_NO_FREE_MEM;

	/* Parse PE filename */
	cur1 = filename;
	cur2 = dll_name;
	dll_name_len = 0;
	while(1){
		c = *cur1++;
		if(!c)
			break;
		if(c == ',' || c == '\'' || c == '\"')
			return ERR_BAD_FILENAME;
		if(c == '.' && !*(cur1 + 3))
			break;
		if(dll_name_len < sizeof(dll_name) - 1){
			if(c >= 'a' && c <= 'z')
				c -= 'a' - 'A';
			*cur2++ = c;
			dll_name_len++;
		}
	}

	/* Read in a fragment of the MSDOS header */
	if(!ReadFile(hFile, buf, 0x40, &aux, 0) || aux != 0x40)
		return ERR_BAD_FORMAT;

	/* Jump to the COFF File Header */
	aux = *(DWORD*)(buf + 0x3C);
	if(SetFilePointer(hFile, aux, 0, FILE_BEGIN) != aux)
		return ERR_BAD_FORMAT;
	file_pos = aux + 0x1A;

	/* Read in the COFF file header */
	if(!ReadFile(hFile, buf, 0x1A, &aux, 0) || aux != 0x1A || *(DWORD*)buf != 0x4550)
		return ERR_BAD_FORMAT;
	x64 = *(short*)(buf + 4) == (short)0x8664;
	num_sections = *(char*)(buf + 6);

	/* Check if optional header contains a reference to an export directory */
	size_of_optional_header = *(WORD*)(buf + 0x14);
	is_PE32plus = 0;
	if(size_of_optional_header > 2){
		aux = *(WORD*)(buf + 0x18);
		if(aux != 0x10B && aux != 0x20B)
			return ERR_BAD_FORMAT;
		if(aux == 0x20B)
			is_PE32plus = 1;
	}

	/* DEF header */
	WriteFile(hOut, "include \'", 9, &aux, 0);
	cur1 = buf + GetModuleFileName(0, buf, sizeof(buf) - 1);
	while(cur1 > buf && *(cur1 - 1) != '\\')
		cur1--;
	aux = 11;
	cur2 = "implib.inc";
	if(x64){
		aux = 13;
		cur2 = "implib64.inc";
	}
	cmemcpy(cur1, cur2, aux);
	hFind = FindFirstFile(buf, &fdata);
	cmemcpy(cur1 + aux - 1, "\'\r\n\r\n", 5);
	if(hFind != INVALID_HANDLE_VALUE){
		FindClose(hFind);
		aux += cur1 - buf;
		cur1 = buf;
	}
	WriteFile(hOut, cur1, aux + 4, &aux, 0);

	aux = is_PE32plus ? 0x78 : 0x68;
	if(size_of_optional_header < aux)
		return ERR_NO_EXPORT;

	/* Jump to the Optional Header -> Data Directories -> Export Table */
	aux -= 0xA;
	file_pos += aux;
	if(SetFilePointer(hFile, aux, 0, FILE_CURRENT) != file_pos)
		return ERR_BAD_FORMAT;
	file_pos = file_pos - aux + size_of_optional_header - 2;
	if(!ReadFile(hFile, &export_dir, 8, &aux, 0) || aux != 8)
		return ERR_BAD_FORMAT;
	if(!export_dir.VirtualAddress || !export_dir.VirtualSize)
		return ERR_NO_EXPORT;

	/* Jump to the Section Headers Table */
	if(SetFilePointer(hFile, file_pos, 0, FILE_BEGIN) != file_pos)
		return ERR_BAD_FORMAT;

	/* Load all section bounds into a linked list, wich will be used later
	   in RVA 2 file offset convertions */
	while(num_sections--){
		if(!ReadFile(hFile, buf, 0x28, &aux, 0) || aux != 0x28)
			return ERR_BAD_FORMAT;
		*current_node = (RVA_2_FileOffset_node*)HeapAlloc(hHeap, HEAP_NO_SERIALIZE | HEAP_ZERO_MEMORY, sizeof(RVA_2_FileOffset_node));
		if(!*current_node)
			return ERR_NO_FREE_MEM;
		(*(*current_node)).node.VirtualAddress = *(DWORD*)(buf + 0x0C);
		(*(*current_node)).node.VirtualSize    = *(DWORD*)(buf + 0x08);
		(*(*current_node)).node.FileOffset     = *(DWORD*)(buf + 0x14);
		current_node = &(RVA_2_FileOffset_node*)(*(*current_node)).next_node;
	}

	/* Jump to the Export directory */
	export_dir.FileOffset = do_RVA_2_FileOffset(sections, export_dir.VirtualAddress);
	file_pos = export_dir.FileOffset;
	if(!file_pos || SetFilePointer(hFile, file_pos, 0, FILE_BEGIN) != file_pos)
		return ERR_BAD_FORMAT;
	/* Read in the Export directory Table */
	aux = 40;
	if(export_dir.VirtualSize < 40){
		aux = export_dir.VirtualSize;
		memset(buf, 0, 40);
	}
	ReadFile(hFile, buf, aux, &aux, 0);
	ordinal_base = *(WORD*)(buf + 0x10);
	num_pointers = *(DWORD*)(buf + 0x14);
	num_sections = *(DWORD*)(buf + 0x18);
	pointers_array = do_RVA_2_FileOffset(sections, *(DWORD*)(buf + 0x1C));
	psymbols_array = do_RVA_2_FileOffset(sections, *(DWORD*)(buf + 0x20));
	ordinals_array = do_RVA_2_FileOffset(sections, *(DWORD*)(buf + 0x24));
	if(!num_pointers || !num_sections || !pointers_array || !psymbols_array || !ordinals_array)
		return ERR_NO_EXPORT;

	/* Parse the Name Pointer RVA Table */
	while(num_sections--){

		/* Get the symbol's name */
		if(SetFilePointer(hFile, psymbols_array, 0, FILE_BEGIN) != psymbols_array)
			return ERR_BAD_FORMAT;
		if(!ReadFile(hFile, &i, 4, &aux, 0) || aux != 4)
			return ERR_BAD_FORMAT;
		psymbols_array += 4;
		pub_name[0] = 0;
		if(i){
			file_pos = do_RVA_2_FileOffset(sections, i);
			if(!file_pos || SetFilePointer(hFile, file_pos, 0, FILE_BEGIN) != file_pos)
				return ERR_BAD_FORMAT;
			ReadFile(hFile, pub_name, sizeof(pub_name) - 3, &aux, 0);
			pub_name[aux] = 0;
		}

		/* Get the symbol's ordinal */
		if(SetFilePointer(hFile, ordinals_array, 0, FILE_BEGIN) != ordinals_array || !ReadFile(hFile, &ordinal, 2, &aux, 0) || aux != 2)
			return ERR_BAD_FORMAT;
		ordinals_array += 2;
		pub_name_len = strlen(pub_name);
		if(!pub_name_len)
			pub_name_len = cprintf(pub_name, "ord.%", ordinal + ordinal_base);
		if(!compact){

			/* ; DLLNAME.NAME ORD:# */
			buf[0] = ';';
			buf[1] = ' ';
			cmemcpy(buf + 2, dll_name, dll_name_len);
			buf[2 + dll_name_len] = '.';
			if(pub_name_len){
				cmemcpy(&buf[3 + dll_name_len], pub_name, pub_name_len);
				aux = cprintf(&buf[3 + dll_name_len + pub_name_len], " ORD:%\r\n", ordinal + ordinal_base);
			}else
				aux = cprintf(&buf[3 + dll_name_len], "#%\r\n", ordinal + ordinal_base);
			WriteFile(hOut, buf, 3 + dll_name_len + pub_name_len + aux, &aux, 0);

			/* Get the symbol's RVA (just to check if it's a forwarder chain) */
			if(ordinal & 0x80000000)
				return ERR_BAD_FORMAT;
			if(SetFilePointer(hFile, pointers_array + ordinal * 4, 0, FILE_BEGIN) != pointers_array + ordinal * 4)
				return ERR_BAD_FORMAT;
			if(!ReadFile(hFile, &i, 4, &aux, 0) || aux != 4)
				return ERR_BAD_FORMAT;
			if(i >= export_dir.VirtualAddress && i < export_dir.VirtualAddress + export_dir.VirtualSize){

				/* It's a forwarder RVA */
				file_pos = do_RVA_2_FileOffset(sections, i);
				if(!file_pos || SetFilePointer(hFile, file_pos, 0, FILE_BEGIN) != file_pos)
					return ERR_BAD_FORMAT;
				cmemcpy(buf, "; -> ", 5);
				ReadFile(hFile, buf + 5, 512, &aux, 0);
				buf[aux + 5] = 0;
				aux = strlen(buf + 5);
				if(!aux){
					buf[5] = '.';
					buf[6] = '.';
					buf[7] = '.';
					aux = 3;
				}
				buf[aux+5] = '\r';
				buf[aux+6] = '\n';
				WriteFile(hOut, buf, aux + 7, &aux, 0);
			}
		}

		/* [pb|vb]implib dllname, ... */
		switch(current_mod){
			case MOD_PB:
				cur1 = "pbimplib ";
				aux = 9;
			break;
			case MOD_VB:
				cmemcpy(buf, "vbimplib ", 9);
				cmemcpy(buf + 9, dll_name, dll_name_len);
				buf[9 + dll_name_len]  = ',';
				buf[10 + dll_name_len] = ' ';
				cur1 = buf;
				aux = 11 + dll_name_len;
			break;
			default:
				cur1 = "implib ";
				aux = 7;
		}
		WriteFile(hOut, cur1, aux, &aux, 0);
		WriteFile(hOut, filename, strlen(filename), &aux, 0);
		if(current_mod != MOD_NO)
			WriteFile(hOut, ", STDCALL, 0, ", 14, &aux, 0);
		else
			WriteFile(hOut, ", ", 2, &aux, 0);
		pub_name[pub_name_len++] = '\r';
		pub_name[pub_name_len++] = '\n';
		WriteFile(hOut, pub_name, pub_name_len, &aux, 0);
	}
	return 0;
}

char usage[] = " USAGE: dll2def [options] file [output]\n"
               "        file   - input file name.\n"
               "        output - optional output file name.\n"
               "        options:\n"
               "         /COMPACT - Don't place any comments.\n"
               "         /PB      - Enable PureBasic mod.\n"
               "         /VB      - Enable Visual Basic 6 mod.\n"
               " Example:\n"
               " dll2def \\windows\\system32\\kernel32.dll test.def\n";

/* Program entry point */
char output_filename[80];
void start(void){
int i, aux;
char *args, *cursor, *output, *ends;
HANDLE hDLL, hDEF, hHeap;
HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);

	/* Parse command-line arguments */
	args = GetCommandLine();
	i = 0;
	while(*args){
		if(*args == '\"')
			i ^= 1;
		if((*args == ' ' || *args == '\t') && !i)
			break;
		args++;
	}
	while(*args == ' ' || *args == '\t')
		args++;
	if(!*args)
		goto PrintUsage;
	while(*args == '/'){
		args++;
		cursor = args;
		while(*cursor && *cursor != ' ' && *cursor != '\t')
			cursor++;
		aux = cursor - args;
		if(*cursor)
			*cursor++ = 0;
		if(!strcmp(args, "PB"))
			current_mod = MOD_PB;
		else if(!strcmp(args, "VB"))
			current_mod = MOD_VB;
		else if(!strcmp(args, "COMPACT"))
			compact = 1;
		else{
			cmemcpy(buf, args - 1, aux + 1);
			cmemcpy(buf + aux + 1, " is not a valid option. Ignoring.\n", 34);
			WriteFile(hOut, buf, aux + 35, &aux, 0);
		}
		args = cursor;
		while(*args == ' ' || *args == '\t')
			args++;
	}
	if(*args == '\"'){
		args++;
		while(*args == ' ' || *args == '\t')
			args++;
		output = args;
		while(*output && *output != '\"')
			output++;
		ends = output - 1;
		while(ends > args && (*ends == ' ' || *ends == '\t'))
			ends--;
		if(*output)
			output++;
		*ends++ = 0;
		aux = ends - args;
	}else{
		output = args;
		while(*output && *output != ' ' && *output != '\t')
			output++;
		aux = output - args;
		if(*output)
			*output++ = 0;
	}
	while(*output == ' ' || *output == '\t' || *output == '\"')
		output++;
	ends = output;
	while(*(ends+1))
		ends++;
	while(ends > output && (*ends == ' ' || *ends == '\t' || *ends == '\"'))
		ends--;
	*(ends + 1) = 0;
	if(aux <= 2)
		goto PrintUsage;
	if(!(*output))
		output = 0;
	hDLL = CreateFile(args, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
	cursor = args + strlen(args);
	ends = cursor;
	while(ends > args && *(ends-1) != '\\')
		ends--;
	if(!output){
		output = cursor;
		while(output > ends && *output != '.')
			output--;
		if(output == ends)
			output = cursor;
		aux = output - ends;
		if(aux > sizeof(output_filename) - 5)
			aux = sizeof(output_filename) - 5;
		cmemcpy(output_filename, ends, aux);
		cmemcpy(output_filename + aux, ".def", 5);
		output = output_filename;
	}

	hDEF = CreateFile(output, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

	/* Process a single PE file */
	hHeap = HeapCreate(HEAP_NO_SERIALIZE, 4096, 0);
	i = parse_pe(ends, hDLL, hDEF, hHeap);
	if(hDLL != INVALID_HANDLE_VALUE)
		CloseHandle(hDLL);

	/* DEF footer */
	if(hDEF != INVALID_HANDLE_VALUE){
		WriteFile(hDEF, "\r\nendlib\r\n", 10, &aux, 0);
		CloseHandle(hDEF);
	}

	if(hHeap)
		HeapDestroy(hHeap);
	if(i){
		cursor = buf;
		cmemcpy(cursor, "-ERR \"", 6);
		cursor += 6;
		if(i != ERR_OUTPUT)
			output = args;
		aux = strlen(output);
		cmemcpy(cursor, output, aux);
		cursor += aux;
		cmemcpy(cursor, error_msgs[i - 1], 34);
		WriteFile(hOut, buf, cursor + 34 - buf, &aux, 0);
	}

Exit:
	CloseHandle(hOut);
	ExitProcess(0);
PrintUsage:
	WriteFile(hOut, usage, sizeof(usage) - 1, &aux, 0);
	goto Exit;
}
