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
	ERR_VB64
};

// Syntax mods
#define MOD_PB 1 // PureBasic
#define MOD_VB 2 // Visual Basic 6

// Error messages
char error_msgs[][16] = {
	{ "Locked / missing" },
	{ "Can\'t open file " },
	{ "Unreadable / bad" },
	{ "No exports found" },
	{ "Not enough heap " },
	{ "VB6 is 32-bit   " }
};

char usage[288] = "\n ImpLib SDK DLL2DEF\n"
               " USAGE: dll2def [options] file [output]\n"
               "   file   - input filename\n"
               "   output - optional output filename\n"
               " Options:\n"
               "   /COMPACT - Don\'t add comments\n"
               "   /PB      - PureBasic mod\n"
               "   /VB      - Visual Basic 6 mod\n"
               " Example:\n"
               " dll2def \\windows\\system32\\kernel32.dll test.def\n";

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
		if(c == '%'){ // A single instance of a '%' in the mask is expected
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
char buf1k[1024], dll_name[80], pub_name[80], imppfx[269], compact, output_filename[80];
char parse_pe(char *filename, HANDLE hFile, HANDLE hOut, HANDLE hHeap, char cur_mod, char do_quot){
char *cur1, *cur2, *buf = buf1k, c, x64;
RVA_2_FileOffset export_dir;
RVA_2_FileOffset_node *sections = 0, **current_node = &sections;
int dll_name_len, aux, i, file_pos, size_of_optional_header, is_PE32plus, num_sections, imppfxlen;
int ordinal_base, ordinals_array, pointers_array, psymbols_array, pub_name_len;
WORD ordinal;
	if(hOut == INVALID_HANDLE_VALUE)
		return ERR_OUTPUT;
	if(!hHeap)
		return ERR_NO_FREE_MEM;

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
	is_PE32plus = 0;
	size_of_optional_header = *(WORD*)(buf + 0x14);
	if(size_of_optional_header > 2){
		if((aux = *(WORD*)(buf + 0x18)) != 0x10B && aux != 0x20B)
			return ERR_BAD_FORMAT;
		if(aux == 0x20B){
			is_PE32plus = 1;
			if(cur_mod == MOD_VB)
				return ERR_VB64;
		}
	}

	// Parse PE filename
	cur1 = filename;
	cur2 = dll_name;
	dll_name_len = 0;
	while((c = *cur1++) && (c != '.' || *(cur1 + 3)))
		if(dll_name_len < sizeof(dll_name) - 1 && c != ' ' && c != '-' && c != ','){
			if(c >= 'a' && c <= 'z')
				c &= 0xDF; // to uppercase
			*cur2++ = c;
			dll_name_len++;
		}

	// [pb|vb]implib dllname, ...
	cur1 = imppfx;
	switch(cur_mod){
	case MOD_PB:
		// cmemcpy(cur1, "pbimplib", 8);
		*(int*)cur1 = 'mibp';
		*(int*)(cur1 + 4) = 'bilp';
		cur1 += 8;
		break;
	case MOD_VB:
		// cmemcpy(cur1, "vbimplib ", 9);
		*(int*)cur1 = 'mibv';
		*(int*)(cur1 + 4) = 'bilp';
		*(cur1 + 8) = ' ';
		cur1 += 9;
		cmemcpy(cur1, dll_name, dll_name_len);
		cur1 += dll_name_len;
		*cur1++ = ',';
		break;
	default:
		// cmemcpy(cur1, "implib", 6);
		*(int*)cur1 = 'lpmi';
		*(short*)(cur1 + 4) = 'bi';
		cur1 += 6;
	}
	*cur1++ = ' ';
	if(do_quot)
		*cur1++ = '\'';
	if((aux = strlen(filename)) > 78)
		aux = 78;
	cmemcpy(cur1, filename, aux);
	cur1 += aux;
	if(do_quot)
		*cur1++ = '\'';
	if(cur_mod != 0 && is_PE32plus == 0){
		cmemcpy(cur1, ", STDCALL, 0, ", 14);
		cur1 += 12;
	}else
		*(short*)cur1 = ' ,';
	imppfxlen = cur1 + 2 - imppfx;

	// DEF header
	WriteFile(hOut, "include \'", 9, &aux, 0);
	cur1 = buf + GetModuleFileName(0, buf, sizeof(buf1k) - 1);
	while(cur1 > buf && *(cur1 - 1) != '\\')
		cur1--;
	*(int*)cur1 = 'lpmi';
	*(short*)(cur1 + 4) = 'bi';
	aux = 0;
	if(x64){
		*(short*)(cur1 + 6) = '46';
		aux = 2;
	}
	*(int*)(cur1 + aux + 6) = 'cni.';
	*(cur1 + aux + 10) = 0;
	i = (int)GetFileAttributes(buf);
	*(int*)(cur1 + aux + 10) = 0x0D0A0D27; // "'\r\n\r"
	*(cur1 + aux + 14) = '\n';
	if(i != INVALID_FILE_ATTRIBUTES){
		aux += cur1 - buf;
		cur1 = buf;
	}
	WriteFile(hOut, cur1, aux + 15, &aux, 0);
	aux = is_PE32plus ? 0x78 : 0x68;
	if(size_of_optional_header < aux)
		return ERR_NO_EXPORT;

	// Jump to the Optional Header -> Data Directories -> Export Table
	aux += file_pos - 0xA;
	if(SetFilePointer(hFile, aux, 0, FILE_BEGIN) != aux)
		return ERR_BAD_FORMAT;
	file_pos += size_of_optional_header - 2;
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
		*current_node = (RVA_2_FileOffset_node*)HeapAlloc(hHeap, 0, sizeof(RVA_2_FileOffset_node));
		if(!*current_node)
			return ERR_NO_FREE_MEM;
		(*(*current_node)).node.VirtualAddress = *(DWORD*)(buf + 0x0C);
		if((aux = *(DWORD*)(buf + 0x08)) == 0) // Virtual Size
			aux = *(DWORD*)(buf + 0x10);   // Size of Raw Data
		(*(*current_node)).node.VirtualSize    = aux;
		(*(*current_node)).node.FileOffset     = *(DWORD*)(buf + 0x14);
		current_node = &(RVA_2_FileOffset_node*)(*(*current_node)).next_node;
	}

	// Jump to the Export directory
	file_pos = do_RVA_2_FileOffset(sections, export_dir.VirtualAddress);
	if(!file_pos || SetFilePointer(hFile, file_pos, 0, FILE_BEGIN) != file_pos)
		return ERR_BAD_FORMAT;

	// Read in the Export directory Table
	memset(buf, 0, 40);
	ReadFile(hFile, buf, 40, &aux, 0);
	ordinal_base = *(WORD*)(buf + 0x10);
	num_sections = *(DWORD*)(buf + 0x18);
	pointers_array = do_RVA_2_FileOffset(sections, *(DWORD*)(buf + 0x1C));
	psymbols_array = do_RVA_2_FileOffset(sections, *(DWORD*)(buf + 0x20));
	ordinals_array = do_RVA_2_FileOffset(sections, *(DWORD*)(buf + 0x24));
	if(!num_sections || !pointers_array || !psymbols_array || !ordinals_array)
		return ERR_NO_EXPORT;

	// Parse the Name Pointer RVA Table
	while(num_sections--){

		// Get the symbol's name
		if(SetFilePointer(hFile, psymbols_array, 0, FILE_BEGIN) != psymbols_array || !ReadFile(hFile, &i, 4, &aux, 0) || aux != 4)
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
			*(short*)buf = ' ;';
			cmemcpy(buf + 2, dll_name, dll_name_len);
			buf[2 + dll_name_len] = '.';
			cur1 = "#%\r\n";
			if(pub_name_len){
				cmemcpy(&buf[3 + dll_name_len], pub_name, pub_name_len);
				cur1 = " ord.%\r\n";
			}
			aux = 3 + dll_name_len + pub_name_len;
			aux += cprintf(&buf[aux], cur1, ordinal + ordinal_base);
			WriteFile(hOut, buf, aux, &aux, 0);

			// Get the symbol's RVA (just to check if it's a forwarder chain)
			if(ordinal & 0x80000000 ||
			   SetFilePointer(hFile, pointers_array + ordinal * 4, 0, FILE_BEGIN) != pointers_array + (ordinal << 2) ||
			   !ReadFile(hFile, &i, 4, &aux, 0) || aux != 4)
				return ERR_BAD_FORMAT;
			if((DWORD)i >= export_dir.VirtualAddress && (DWORD)i < export_dir.VirtualAddress + export_dir.VirtualSize){

				// It's a forwarder RVA
				file_pos = do_RVA_2_FileOffset(sections, i);
				if(!file_pos || SetFilePointer(hFile, file_pos, 0, FILE_BEGIN) != file_pos)
					return ERR_BAD_FORMAT;
				*(int*)buf = '>- ;';
				buf[4] = ' ';
				ReadFile(hFile, buf + 5, 512, &aux, 0);
				buf[aux + 5] = 0;
				if(!(aux = strlen(buf + 5))){
					*(int*)(buf + 5) = '...';
					aux = 3;
				}
				*(short*)(buf + aux + 5) = 0x0A0D;
				WriteFile(hOut, buf, aux + 7, &aux, 0);
			}
		}
		cmemcpy(cur1 = imppfx + imppfxlen, pub_name, pub_name_len);
		cur1 += pub_name_len;
		*(short*)cur1 = 0x0A0D;
		WriteFile(hOut, imppfx, cur1 + 2 - imppfx, &aux, 0);
	}
	return 0;
}

// Program entry point
void start(void){
unsigned __int64 kw;
int aux;
char *args, *cursor, *output, *ends, *buf = buf1k, ch, err, cur_mod = 0, do_quot = 0;
HANDLE hHeap, hDLL, hDEF = INVALID_HANDLE_VALUE;
CONSOLE_SCREEN_BUFFER_INFO console_info;
HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);

	// If executing as a service or otherwise detached from the console, STDOUT might be unavailable
	if(hOut == INVALID_HANDLE_VALUE)
		hOut = 0;
	else if(hOut){

		// If this is a console, initialize the console info buffer (it is used to apply color attributes)
		GetConsoleScreenBufferInfo(hOut, &console_info);
		console_info.dwCursorPosition.Y++;
		console_info.dwCursorPosition.X = 1;
	}

	// Parse the command-line
	args = GetCommandLine();
	aux = 0;
	while(ch = *args){
		if(ch == '\"')
			aux ^= 1;
		if(!aux && (ch == ' ' || ch == '\t'))
			break;
		args++;
	}
	while((ch = *args) == ' ' || ch == '\t')
		args++;

	while(*args == '/'){
		cursor = args++;
		kw = 0;
		while((ch = *args) && ch != ' ' && ch != '\t'){
			args++;
			kw = kw << 8 | (ch | 0x20) & 0xFF; // to lowercase
		}
		if(kw == 0x7062)
			cur_mod = MOD_PB;
		else if(kw == 0x7662)
			cur_mod = MOD_VB;
		else if(kw == 0x636F6D70616374)
			compact = 1;
		else if(hOut){
			cmemcpy(buf, cursor, aux = args - cursor);
			cmemcpy(buf + aux, " isn\'t a valid arg, ignoring\n", 29);
			WriteFile(hOut, buf, aux + 29, &aux, 0);
			console_info.dwCursorPosition.Y++;
		}
		while((ch = *args) == ' ' || ch == '\t')
			args++;
	}

	// No parameters
	if(!(*args)){
		if(hOut){
			WriteFile(hOut, usage, sizeof(usage), &aux, 0);
			FillConsoleOutputAttribute(hOut, FOREGROUND_GREEN, 20, console_info.dwCursorPosition, &aux);
		}
		ExitProcess(0);
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
	err = ERR_FILE_NOT_FOUND;
	hDLL = CreateFile(args, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
	if(hDLL != INVALID_HANDLE_VALUE){
		cursor = args + aux;
		ends = cursor;
		while(ends > args && (ch = *(ends - 1)) != '\\'){
			ends--;
			if(ch == ' ' || ch == '-' || ch == ',')
				do_quot = 1;
		}
		if(!output){
			output = cursor;
			while(output > ends && *output != '.')
				output--;
			if(output == ends)
				output = cursor;
			if((aux = output - ends) > sizeof(output_filename) - 5)
				aux = sizeof(output_filename) - 5;
			cmemcpy(output = output_filename, ends, aux);
			*(int*)(output + aux) = 'fed.';
		}
		hDEF = CreateFile(output, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
		hHeap = HeapCreate(HEAP_NO_SERIALIZE, 4096, 0);

		// Process a single PE file
		err = parse_pe(ends, hDLL, hDEF, hHeap, cur_mod, do_quot);
		CloseHandle(hDLL);
		if(hHeap)
			HeapDestroy(hHeap);
	}

	// DEF footer
	if(hDEF != INVALID_HANDLE_VALUE){
		WriteFile(hDEF, "\r\nendlib\r\n", 10, &aux, 0);
		CloseHandle(hDEF);
	}

	// Print the error message, if any
	if(err && hOut){

		// Build the error message
		cursor = buf;
		*((int*)cursor)++ = 'E- \n';
		*((int*)cursor)++ = '\" RR';

		// Append either the input or the output filename, depending on the error code
		if(err != ERR_OUTPUT)
			output = args;
		cmemcpy(cursor, output, aux = strlen(output));
		cursor += aux;

		// Append the actual error message
		*(unsigned short*)cursor = ' "';
		cmemcpy(cursor + 2, error_msgs[err - 1], sizeof(error_msgs[0]));
		*(cursor + 2 + sizeof(error_msgs[0])) = '\n';
		WriteFile(hOut, buf, cursor + 3 + sizeof(error_msgs[0]) - buf, &aux, 0);

		// Highlight the error
		FillConsoleOutputAttribute(hOut, FOREGROUND_RED, 4, console_info.dwCursorPosition, &aux);
	}
	ExitProcess(0);
}
