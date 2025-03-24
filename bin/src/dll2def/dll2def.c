/*
	DLL2DEF source code
	Copyright (c) 2006-2025, Vladimir Kamenar.
	All rights reserved.

	This tool is a command-line utility to extract the dynamic-link library symbols
	in plain text format. DLL2DEF supports both 32 and 64-bit DLL.

	The DLL2DEF tool expects a DLL name and the DEF file name, for example:
		dll2def \windows\system32\kernel32.dll kernel32.def

	The DEF file name is optional. If not specified, a DEF-file with the same name
	as the DLL will be generated.

	Optional switches:
		/COMPACT - don't include comments with misc information
		/PB      - generate a DEF file for PureBasic
		/VB      - generate a DEF file for Visual Basic 6

	Please, check the user guide for more information:
		https://implib.sourceforge.io/EN.HTM
*/

#define WINDOWS_IGNORE_PACKING_MISMATCH // workaroud for C2118 in W10 SDK
#include <windows.h>

// Error codes
enum ERR_CODES{
	ERR_OK,
	ERR_FILE_NOT_FOUND,
	ERR_OUTPUT,
	ERR_BAD_FORMAT,
	ERR_NO_EXPORT,
	ERR_NO_FREE_MEM,
	ERR_BAD_FILENAME,
	ERR_VB64
};

// Error messages
char error_msgs[][34] = {
	"\": File locked or not found      \n",
	"\": Error opening the output file \n",
	"\": Unreadable or invalid PE image\n",
	"\": No export found               \n",
	"\": Not enough memory             \n",
	"\": Not a valid filename          \n",
	"\": Visual Basic 6 is 32-bit only \n"
};

// Syntax mods
#define MOD_PB 1 // PureBasic
#define MOD_VB 2 // Visual Basic 6

typedef struct struct_RVA_2_FileOffset{
	DWORD VirtualAddress;
	DWORD VirtualSize;
	DWORD FileOffset;
} RVA_2_FileOffset;

typedef struct struct_RVA_2_FileOffset_node{
	RVA_2_FileOffset node;
	void *next_node;
} RVA_2_FileOffset_node;

// Convert an RVA value into a regular file offset
DWORD do_RVA_2_FileOffset(RVA_2_FileOffset_node *sections, DWORD RVA){
	while(sections){
		if(RVA >= (*sections).node.VirtualAddress && RVA <= (*sections).node.VirtualAddress + (*sections).node.VirtualSize)
			return RVA - (*sections).node.VirtualAddress + (*sections).node.FileOffset;
		sections = (*sections).next_node;
	}
	return 0;
}

// A simple memcpy replacement if linking without CRT
void cmemcpy(char *dest, char *src, int n){
	for(int i = 0; i < n; i++)
		dest[i] = src[i];
}

// A simple sprintf replacement to avoid a dependency on user32!_wsprintf
int cprintf(char *dest, char *mask, int ord){

	// An ordinal is up to 5 digits long
	int x, n = ord & 0xFFFF, len = n <= 9 ? 1 : n <= 99 ? 2 : n <= 999 ? 3 : n <= 9999 ? 4 : 5;

	char *outp = dest, c;
	while(c = *mask++)
		if(c == '%'){ /* A single instance of a '%' in the mask is expected */
			outp += len;
			x = 0;
			while(len-- > 0){
				*(outp - ++x) = (char)(0x30 + n % 10);
				n /= 10;
			}
		}else
			*outp++ = c;
	return outp - dest;
}

// Process a single PE file and dump its export
char buf1k[1024], dll_name[80], pub_name[80], qfname[80];
int compact;
WIN32_FIND_DATA fdata;
int parse_pe(char *filename, HANDLE hFile, HANDLE hOut, HANDLE hHeap, char current_mod, char mustquote){
char *cur1, *cur2, *buf = buf1k, c, x64;
RVA_2_FileOffset export_dir;
RVA_2_FileOffset_node *sections = 0, **current_node = &sections;
int dll_name_len, aux, i, file_pos, size_of_optional_header, is_PE32plus, num_sections, qfnamelen;
int ordinal_base, num_pointers, ordinals_array, pointers_array, psymbols_array, pub_name_len;
HANDLE hFind;
WORD ordinal;
	if(hFile == INVALID_HANDLE_VALUE)
		return ERR_FILE_NOT_FOUND;
	if(hOut == INVALID_HANDLE_VALUE)
		return ERR_OUTPUT;
	if(!hHeap)
		return ERR_NO_FREE_MEM;

	// Parse PE filename
	cur1 = qfname;
	if(mustquote)
		*cur1++ = '\'';
	qfnamelen = strlen(filename);
	if(qfnamelen > 78)
		qfnamelen = 78;
	cmemcpy(cur1, filename, qfnamelen);
	cur1 += qfnamelen;
	if(mustquote){
		*cur1++ = '\'';
		qfnamelen += 2;
	}
	cur1 = filename;
	cur2 = dll_name;
	dll_name_len = 0;
	while((c = *cur1++) && (c != '.' || *(cur1 + 3)))
		if(dll_name_len < sizeof(dll_name) - 1 && c != ' ' && c != '-' && c != ','){
			if(c >= 'a' && c <= 'z')
				c -= 'a' - 'A';
			*cur2++ = c;
			dll_name_len++;
		}

	// Read in a fragment of the MSDOS header
	if(!ReadFile(hFile, buf, 0x40, &aux, 0) || aux != 0x40)
		return ERR_BAD_FORMAT;

	// Jump to the COFF File Header
	aux = *(DWORD*)(buf + 0x3C);
	if(SetFilePointer(hFile, aux, 0, FILE_BEGIN) != aux)
		return ERR_BAD_FORMAT;
	file_pos = aux + 0x1A;

	// Read in the COFF file header
	if(!ReadFile(hFile, buf, 0x1A, &aux, 0) || aux != 0x1A || *(DWORD*)buf != 0x4550)
		return ERR_BAD_FORMAT;
	x64 = *(short*)(buf + 4) == (short)0x8664;
	num_sections = *(char*)(buf + 6);

	// Check if optional header contains a reference to an export directory
	size_of_optional_header = *(WORD*)(buf + 0x14);
	is_PE32plus = 0;
	if(size_of_optional_header > 2){
		if((aux = *(WORD*)(buf + 0x18)) != 0x10B && aux != 0x20B)
			return ERR_BAD_FORMAT;
		if(aux == 0x20B){
			is_PE32plus = 1;
			if(current_mod == MOD_VB)
				return ERR_VB64;
		}
	}

	// DEF header
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

	// Jump to the Optional Header -> Data Directories -> Export Table
	aux -= 0xA;
	file_pos += aux;
	if(SetFilePointer(hFile, aux, 0, FILE_CURRENT) != file_pos)
		return ERR_BAD_FORMAT;
	file_pos = file_pos - aux + size_of_optional_header - 2;
	if(!ReadFile(hFile, &export_dir, 8, &aux, 0) || aux != 8)
		return ERR_BAD_FORMAT;
	if(!export_dir.VirtualAddress || !export_dir.VirtualSize)
		return ERR_NO_EXPORT;

	// Jump to the Section Headers Table
	if(SetFilePointer(hFile, file_pos, 0, FILE_BEGIN) != file_pos)
		return ERR_BAD_FORMAT;

	// Load section bounds into a linked list, it will be used in RVA 2 file offset convertions
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

	// Jump to the Export directory
	export_dir.FileOffset = do_RVA_2_FileOffset(sections, export_dir.VirtualAddress);
	file_pos = export_dir.FileOffset;
	if(!file_pos || SetFilePointer(hFile, file_pos, 0, FILE_BEGIN) != file_pos)
		return ERR_BAD_FORMAT;
	// Read in the Export directory Table
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

	// Parse the Name Pointer RVA Table
	while(num_sections--){

		// Get the symbol's name
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

		// Get the symbol's ordinal
		if(SetFilePointer(hFile, ordinals_array, 0, FILE_BEGIN) != ordinals_array || !ReadFile(hFile, &ordinal, 2, &aux, 0) || aux != 2)
			return ERR_BAD_FORMAT;
		ordinals_array += 2;
		pub_name_len = strlen(pub_name);
		if(!pub_name_len)
			pub_name_len = cprintf(pub_name, "ord.%", ordinal + ordinal_base);
		if(!compact){

			// ; DLLNAME.NAME ord.#
			buf[0] = ';';
			buf[1] = ' ';
			cmemcpy(buf + 2, dll_name, dll_name_len);
			buf[2 + dll_name_len] = '.';
			if(pub_name_len){
				cmemcpy(&buf[3 + dll_name_len], pub_name, pub_name_len);
				aux = cprintf(&buf[3 + dll_name_len + pub_name_len], " ord.%\r\n", ordinal + ordinal_base);
			}else
				aux = cprintf(&buf[3 + dll_name_len], "#%\r\n", ordinal + ordinal_base);
			WriteFile(hOut, buf, 3 + dll_name_len + pub_name_len + aux, &aux, 0);

			// Get the symbol's RVA (just to check if it's a forwarder chain)
			if(ordinal & 0x80000000)
				return ERR_BAD_FORMAT;
			if(SetFilePointer(hFile, pointers_array + ordinal * 4, 0, FILE_BEGIN) != pointers_array + ordinal * 4)
				return ERR_BAD_FORMAT;
			if(!ReadFile(hFile, &i, 4, &aux, 0) || aux != 4)
				return ERR_BAD_FORMAT;
			if(i >= export_dir.VirtualAddress && i < export_dir.VirtualAddress + export_dir.VirtualSize){

				// It's a forwarder RVA
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

		// [pb|vb]implib dllname, ...
		switch(current_mod){
			case MOD_PB:
				cmemcpy(buf, "pbimplib ", aux = 9);
				break;
			case MOD_VB:
				cmemcpy(buf, "vbimplib ", 9);
				cmemcpy(buf + 9, dll_name, dll_name_len);
				buf[9 + dll_name_len]  = ',';
				buf[10 + dll_name_len] = ' ';
				aux = 11 + dll_name_len;
				break;
			default:
				cmemcpy(buf, "implib ", aux = 7);
		}
		cmemcpy(buf + aux, qfname, qfnamelen);
		aux += qfnamelen;
		if(current_mod != 0 && is_PE32plus == 0){
			cmemcpy(buf + aux, ", STDCALL, 0, ", 14);
			aux += 14;
		}else{
			buf[aux++] = ',';
			buf[aux++] = ' ';
		}
		cmemcpy(buf + aux, pub_name, pub_name_len);
		aux += pub_name_len;
		buf[aux++] = '\r';
		buf[aux++] = '\n';
		WriteFile(hOut, buf, aux, &aux, 0);
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

// Program entry point
char output_filename[80];
void start(void){
unsigned __int64 kw;
int i, aux;
char *args, *cursor, *output, *ends, *buf = buf1k, ch, current_mod = 0, mustquote = 0;
HANDLE hDLL, hDEF, hHeap;
HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);

	// If executing as a service or otherwise detached from the console, STDOUT might be unavailable
	if(hOut == INVALID_HANDLE_VALUE)
		hOut = 0;

	// Parse the command-line
	args = GetCommandLine();
	i = 0;
	while(ch = *args){
		if(ch == '\"')
			i ^= 1;
		if(!i && (ch == ' ' || ch == '\t'))
			break;
		args++;
	}
	while((ch = *args) == ' ' || ch == '\t')
		args++;

	// No parameters
	if(!ch){
		if(hOut)
			WriteFile(hOut, usage, sizeof(usage) - 1, &aux, 0);
		ExitProcess(0);
	}

	while(*args == '/'){
		cursor = args++;
		kw = 0;
		while((ch = *args++) && ch != ' ' && ch != '\t')
			kw = kw << 8 | (ch | 0x20) & 0xFF; // to lowercase
		if(kw == 0x7062)
			current_mod = MOD_PB;
		else if(kw == 0x7662)
			current_mod = MOD_VB;
		else if(kw == 0x636F6D70616374)
			compact = 1;
		else if(hOut){
			cmemcpy(buf, cursor, aux = args - cursor - 1);
			cmemcpy(buf + aux, " is not a valid option. Ignoring.\n", 34);
			WriteFile(hOut, buf, aux + 34, &aux, 0);
		}
		while((ch = *args) == ' ' || ch == '\t')
			args++;
	}
	if(*args == '\"'){
		output = ++args;
		while((ch = *output) && ch != '\"')
			output++;
	}else{
		output = args;
		while((ch = *output) && ch != ' ' && ch != '\t')
			output++;
	}
	aux = output - args;
	if(ch){
		*output++ = 0;
		while((ch = *output) && (ch == ' ' || ch == '\t' || ch == '\"'))
			output++;
		ends = output;
		while((ch = *ends) && ch != '\"')
			ends++;
		*ends = 0;
		if(ends == output)
			output = 0;
	}else
		output = 0;
	hDLL = CreateFile(args, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
	cursor = args + aux;
	ends = cursor;
	while(ends > args && (ch = *(ends-1)) != '\\'){
		ends--;
		if(ch == ' ' || ch == '-' || ch == ',')
			mustquote = 1;
	}
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

	// Process a single PE file
	hHeap = HeapCreate(HEAP_NO_SERIALIZE, 4096, 0);
	i = parse_pe(ends, hDLL, hDEF, hHeap, current_mod, mustquote);
	if(hDLL != INVALID_HANDLE_VALUE)
		CloseHandle(hDLL);

	// DEF footer
	if(hDEF != INVALID_HANDLE_VALUE){
		WriteFile(hDEF, "\r\nendlib\r\n", 10, &aux, 0);
		CloseHandle(hDEF);
	}

	if(hHeap)
		HeapDestroy(hHeap);
	if(i && hOut){
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
	ExitProcess(0);
}
