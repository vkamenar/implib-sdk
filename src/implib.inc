; IMPLIB.INC v2.0.4
; =================
; (c) 2006-2025 Vladimir Kamenar

; Build custom import libraries for Windows DLL (32-bit).
; These macros can be combined in a single library:
; implib   - general purpose symbol definition macro.
; pbimplib - mod intended for PureBasic Userlib.
; vbimplib - mod intended for Visual Basic 6. It is useful for calling
;            CDECL DLL functions directly from Visual Basic 6, without
;            wrapper DLLs and/or delegators.
; MACRO implib   dllname, name, thunk, pubname
; MACRO pbimplib dllname, cconv, argcount, name, pb_name, pubname
; MACRO vbimplib module, dllname, cconv, argcount, name, vb_name, pubname
; Parameters:
;    dllname  : DLL file name. Enclose in quotes if the file name contains
;               whitespaces, '-' or other non-alphanumeric characters.
;    cconv    : Calling convention. Possible values: STDCALL, CDECL, PBCALL
;    argcount : Number of DWORD arguments. (QWORD counts as 2 DWORDs and so on.)
;    name     : Symbol name or an ordinal value, prefixed with "ord." This value
;               should match exactly the required DLL exported symbol.
;    module   : Visual Basic module name.
;    pubname  : Optional public name. This symbolic name allows calling an external
;               function directly (not using a thunk). If not specified, 'name'
;               prefixed with '__imp_' is used as the pubname.
;    thunk    : Optional thunk name. A thunk function consists of a single
;               jmp [pubname] instruction. If not specified, 'name' is assumed
;               to be the thunk name as well.
;    pb_name  : Optional PureBasic function name. If not specified, 'name' is used
;               as the PureBasic name.
;    vb_name  : Optional Visual Basic function name. If not specified, 'name' is used
;               as the Visual Basic name.
; Examples:
;    implib   dsound.dll,   ord.1, _DirectSoundCreate@12
;    implib   kernel32.dll, ExitProcess, _ExitProcess@4, __imp__ExitProcess@4
;    pbimplib openal32.dll, CDECL, 2, ord.1, alGenBuffers
;    vbimplib openal32, openal32.dll, CDECL, 2, alGenBuffers

; === CONFIG BEGIN ===============================================

; Set to 0 to disable original thunk (lookup table) to reduce the IAT size in
; the executable by 4 x n bytes, n being the number of imported symbols. You
; won't be able to bind (using BIND.EXE from PSDK) an IAT without original thunk!
KEEP_ORIGINAL_THUNK equ 1

; Optional header is not required in object files. Very old MS LINK versions
; may use it. The following option is included for compatibility.
USE_OPTIONAL_HEADER equ 0

; @comp.id symbols are appended by the MS linker, possibly for watermarking.
USE_COMPID equ 0

; Rename archive members for compatibility with LLVM linker.
RENAME_AR_MEMBERS equ 0

; Disable the 2nd linker member.
LINKER_MEMBER_2_REMOVE equ 1

; === CONFIG END =================================================

STDCALL=0
CDECL=1
PBCALL=2
str_tbl_size=0
lng_tbl_size=0
syms_indexed=0
syms=0
IMAGE_FILE_MACHINE_I386=14Ch
IMAGE_FILE_32BIT_MACHINE=100h
IMAGE_CNT_CODE=20h
IMAGE_CNT_INITIALIZED_DATA=40h
IMAGE_LNK_COMDAT=1000h
IMAGE_ALIGN_1BYTES=100000h
IMAGE_ALIGN_2BYTES=200000h
IMAGE_ALIGN_4BYTES=300000h
IMAGE_MEM_EXECUTE=20000000h
IMAGE_MEM_READ=40000000h
IMAGE_MEM_WRITE=80000000h
IMAGE_SYM_CLASS_EXTERNAL=2
IMAGE_SYM_CLASS_STATIC=3
IMAGE_SYM_CLASS_SECTION=104
IMAGE_SYM_DTYPE_FUNCTION=20h
IMAGE_REL_I386_DIR32=6
IMAGE_REL_I386_DIR32NB=7
IMAGE_COMDAT_SELECT_NODUPLICATES=1
IMAGE_COMDAT_SELECT_ASSOCIATIVE=5

use32
org 0

macro print_ts{
	xx=%t
	yy=1000000000000
	zz=11
	repeat 11
		yy=yy/10
		if xx>=yy
			db '0'+(xx/yy)mod 10
			zz=zz-1
		end if
	end repeat
	db '0'+xx mod 10
	times zz db ' '
}

macro pack_sz xx{
	yy=100000000
	zz=7
	repeat 7
		yy=yy/10
		if xx>=yy
			db '0'+(xx/yy)mod 10
			zz=zz-1
		end if
	end repeat
	db '0'+xx mod 10
	times zz db ' '
	db '  ',60h,0Ah
}

; Copy n bytes from src to dest (don't handle overlap)
macro do_cpy src,dest,n{
	repeat n
		load chr from src+%-1
		store chr at dest+%-1
	end repeat
}

; Copy n bytes from src to dest (handle overlap)
macro do_memcpy src,dest,n{
	d=1
	if src+n>dest
		src=src+n-1
		dest=dest+n-1
		d=-1
	end if
	repeat n
		load chr from src
		store chr at dest
		src=src+d
		dest=dest+d
	end repeat
}

macro addcompid{
if USE_COMPID
	db '@comp.id'
	dd 131F62h
	dw -1,0,IMAGE_SYM_CLASS_STATIC
end if
}

; Update linker directory: make sure string tables are sorted in ascending lexical order
macro add2dir new_str,new_str_size{
	if new_str_size<=1
		display '-ERR: Empty string',13,10
	end if
	syms_indexed=syms_indexed+1
if ~defined LINKER_MEMBER_2_REMOVE
	str_found2=sym_arr2
	obj_cursor=obj_tbl2-4
	repeat syms_indexed
		str_found1=str_found2
		chr=1
		while chr
			load chr from str_found2
			str_found2=str_found2+1
		end while
		strcmp_r=0
		load chr from str_found1
		load chr2 from new_str
		while strcmp_r>=0 & chr>=chr2
			if chr=chr2 & chr=0
				display '-WNG: [',`new_str,'] Duplicate symbol',13,10
			end if
			strcmp_r=chr2-chr
			load chr from str_found1+%
			load chr2 from new_str+%
		end while
		obj_cursor=obj_cursor+4
		if strcmp_r<0
			do_memcpy obj_cursor,obj_cursor+4,obj_tbl2+(syms_indexed-1)*4-obj_cursor
			do_memcpy str_found1,str_found1+new_str_size,sym_arr2+str_tbl_size-str_found1
			break
		end if
	end repeat
	store dword obj_addr at obj_cursor
	do_cpy new_str,str_found1,new_str_size
end if
	obj_cursor=((obj_addr shl 24)or((obj_addr and 0FF00h) shl 8)or((obj_addr and 0FF0000h) shr 8)or(obj_addr shr 24))and 0FFFFFFFFh
	store dword obj_cursor at obj_tbl1
	obj_tbl1=obj_tbl1+4
	do_cpy new_str,lnk1_str_tbl,new_str_size
	lnk1_str_tbl=lnk1_str_tbl+new_str_size
	str_tbl_size=str_tbl_size+new_str_size
}

; Add a new long name to the file table
macro add2long namelen,sfx{
	if namelen eqtype 2
		dllname_spot=longnames_arr
		xx_addr=dllname_spot-longnames_sz
		longnames_arr=longnames_arr+namelen+2
		if RENAME_AR_MEMBERS
			store sfx at longnames_arr-2
			longnames_arr=longnames_arr+1
			lng_tbl_size=lng_tbl_size+1
		end if
		lng_tbl_size=lng_tbl_size+namelen+2
		store word 0A2Fh at longnames_arr-2
	end if
	db '/'
	yy=100000000
	zz=7
	repeat 7
		yy=yy/10
		if xx_addr>=yy
			db '0'+(xx_addr/yy)mod 10
			zz=zz-1
		end if
	end repeat
	db '0'+xx_addr mod 10,'       '
	times zz db ' '
}

macro nxt_even_addr{
	times $ and 1 db 0Ah
	obj_addr=$
}

macro islongname dllname{
	virtual at 0
		db `dllname
		dllnamelen=$
		namelen=$
		if $>3
			load D from $-4
			if D='.'
				namelen=$-4
			end if
		end if
		dllhash = 0
		repeat dllnamelen
			load chr from %-1
			dllhash = (dllhash * 31 + chr) and 7FFFFFFFFFFFFFh
		end repeat
	end virtual
}

; Parse ordinal value, if applicable
macro chkordinal name{
	byordinal=0
	ordinal_value=0
	virtual at 0
		db `name
		if $>4
			load prefix dword from 0
			if prefix=2E64726Fh
				byordinal=1
				count=$-4
				repeat count
					load chr from %+3
					chr=chr-'0'
					if chr>9
						display '-WNG: Bad ordinal ',`name,13,10
					else
						ordinal_value=ordinal_value*10+chr
					end if
				end repeat
				if ordinal_value>0FFFFh
					ordinal_value=ordinal_value and 0FFFFh
					display '-WNG: Ordinal ',`name,' truncated to 16-bit',13,10
				end if
			end if
		end if
	end virtual
}

	; Archive file signature (Unix ar)
	db '!<arch>',0Ah
	; 1st header
	db '/               '     ; name
	print_ts
	db '            0       ' ; owner id, group id, file mode (not used in Win)
	pack_sz lnk_member1_size

	; 1st linker member
lnk_member1:
	dd ((num_syms shl 24) or ((num_syms and 0FF00h) shl 8) or ((num_syms and 0FF0000h) shr 8)) and 0FFFFFFFFh ; # of public symbols in big endian
	obj_tbl1=$
	times num_syms dd 0
	lnk1_str_tbl=$
	times symarr_size db 0
	lnk_member1_size=$-lnk_member1

if ~defined LINKER_MEMBER_2_REMOVE

	; 2nd linker member (optional)
	nxt_even_addr
	db '/               '
	print_ts
	db '            0       ' ; owner id, group id, file mode (not used in Win)
	pack_sz lnk_member2_size
lnk_member2:
	dd num_syms ; number of object files
	label obj_tbl2 dword
	times num_syms dd 0
	dd num_syms ; number of public symbols
	times num_syms dw %
	label sym_arr2 byte
	times symarr_size db 0
	lnk_member2_size=$-lnk_member2
end if

macro coffhdr{
	dd 6+KEEP_ORIGINAL_THUNK-RENAME_AR_MEMBERS+USE_COMPID
	dw 0E0h*USE_OPTIONAL_HEADER,IMAGE_FILE_32BIT_MACHINE
	if USE_OPTIONAL_HEADER
		dw 10Bh,0,0,0,0
		db 0
		dd 1000h,200h,4
		dq 0,0,0
		dd 3,100000h,1000h,100000h,1000h,0,1
		dq 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	end if
	db '.idata$2'
	dd 0,0,20
}

macro implib dllname,name,thunk,pubname{
	islongname dllname
	syms=syms+1
	longname=1
	longnamelen=namelen
	if RENAME_AR_MEMBERS
		if namelen<15
			longname=0
		end if
	else
		longnamelen=dllnamelen
		if dllnamelen<16
			longname=0
		end if
	end if
	if ~defined def.#dllhash

		; __IMPORT_DESCRIPTOR_<DLL>
		nxt_even_addr
		dllname_spot=$
		if RENAME_AR_MEMBERS
			if ~longname
				times namelen+1 db 'h'
				db '/'
				times 14-namelen db ' '
			end if
		else if ~longname
			times dllnamelen+1 db '/'
			times 15-dllnamelen db ' '
		end if
		if longname

			; Long names table
			db '//                                              '
			pack_sz longnames_size
		longnames_sz:
			longnames_arr=$
			times longnames_len db 0
			longnames_size=$-longnames_sz
			nxt_even_addr
			add2long longnamelen,'h'
		end if
		print_ts
		db '            0       ' ; owner id, group id, file mode (not used in Win)
		pack_sz (descr_strtbl_end.#dllhash-descr.#dllhash)
	descr.#dllhash:
		dw IMAGE_FILE_MACHINE_I386,2+RENAME_AR_MEMBERS*(1+KEEP_ORIGINAL_THUNK)
		dd %t,descr_sym_tbl.#dllhash-descr.#dllhash
		coffhdr
		dd null_imp_descr.#dllhash-descr.#dllhash,descr_rel.#dllhash-descr.#dllhash
		dd 0,2+KEEP_ORIGINAL_THUNK,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_1BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		db '.idata$6'
		dd 0,0,(null_imp_descr.#dllhash-descr_dllname.#dllhash+2) and -2,descr_dllname.#dllhash-descr.#dllhash,0
		dd 0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		if RENAME_AR_MEMBERS
			db '.idata$5'
			dd 0,0,0,0,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
			if KEEP_ORIGINAL_THUNK
				db '.idata$4'
				dd 0,0,0,0,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
			end if
		end if
	descr_dllname.#dllhash db `dllname
		do_cpy descr_dllname.#dllhash,dllname_spot,longnamelen
	null_imp_descr.#dllhash dq 0,0
		if KEEP_ORIGINAL_THUNK
		descr_rel.#dllhash:
			dd 0,3+USE_COMPID ; Import lookup table RVA (characteristics) --> .idata$4
			dw IMAGE_REL_I386_DIR32NB
		else
			dd 0
		descr_rel.#dllhash:
		end if
		dd 12,2+USE_COMPID ; DLL name RVA --> .idata$6
		dw IMAGE_REL_I386_DIR32NB
		dd 16,3+USE_COMPID+KEEP_ORIGINAL_THUNK ; Import address table RVA (thunk table) --> .idata$5
		dw IMAGE_REL_I386_DIR32NB
	descr_sym_tbl.#dllhash:
		addcompid
		dd 0,descr_strtbl2.#dllhash-descr_strtbl.#dllhash,0,1
		dw IMAGE_SYM_CLASS_EXTERNAL
		db '.idata$2'
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_MEM_READ or IMAGE_MEM_WRITE,1
		dw IMAGE_SYM_CLASS_SECTION
		db '.idata$6'
		dd 0,2
		dw IMAGE_SYM_CLASS_STATIC
		if KEEP_ORIGINAL_THUNK
			db '.idata$4'
			if RENAME_AR_MEMBERS
				dd 0,4
				dw IMAGE_SYM_CLASS_STATIC
			else
				dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_MEM_READ or IMAGE_MEM_WRITE,0
				dw IMAGE_SYM_CLASS_SECTION
			end if
		end if
		db '.idata$5'
		if RENAME_AR_MEMBERS
			dd 0,3
			dw IMAGE_SYM_CLASS_STATIC
		else
			dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_MEM_READ or IMAGE_MEM_WRITE,0
			dw IMAGE_SYM_CLASS_SECTION
			dd 0,4,0,0
			dw IMAGE_SYM_CLASS_EXTERNAL
		end if
		dd 0,descr_strtbl_1.#dllhash-descr_strtbl.#dllhash,0,0
		dw IMAGE_SYM_CLASS_EXTERNAL
	descr_strtbl.#dllhash dd descr_strtbl_end.#dllhash-$
		if ~RENAME_AR_MEMBERS
			db '__NULL_IMPORT_DESCRIPTOR',0
		end if
	descr_strtbl2.#dllhash db '__IMPORT_DESCRIPTOR_'
		times namelen+1 db 0
		do_cpy descr_dllname.#dllhash,descr_strtbl2.#dllhash+20,namelen
		add2dir descr_strtbl2.#dllhash,$-descr_strtbl2.#dllhash
		descr_strtbl_1.#dllhash db 07Fh
		times namelen db 0
		do_cpy descr_dllname.#dllhash,descr_strtbl_1.#dllhash+1,namelen
		db '_NULL_THUNK_DATA',0
	descr_strtbl_end.#dllhash:

		; [7Fh]<DLL>_NULL_THUNK_DATA
		nxt_even_addr
		dllname_spot=$
		if RENAME_AR_MEMBERS
			if ~longname
				times namelen+1 db 't'
				db '/'
				times 14-namelen db ' '
			else
				add2long namelen,'t'
			end if
		else if ~longname
			times dllnamelen+1 db '/'
			times 15-dllnamelen db ' '
		else
			dllname_spot=0
			add2long
		end if
		if dllname_spot
			do_cpy descr_dllname.#dllhash,dllname_spot,longnamelen
		end if
		print_ts
		db '            0       ' ; owner id, group id, file mode (not used in Win)
		pack_sz (descr_strtbl2_end.#dllhash-descr2.#dllhash)
	descr2.#dllhash:
		dw IMAGE_FILE_MACHINE_I386,1+KEEP_ORIGINAL_THUNK
		dd %t,descr_sym_tbl2.#dllhash-descr2.#dllhash,1+USE_COMPID
		dw 0,IMAGE_FILE_32BIT_MACHINE
		db '.idata$5'
		dd 0,0,4,48,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		if KEEP_ORIGINAL_THUNK
			db '.idata$4'
			dd 0,0,4,88,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		end if
	descr_sym_tbl2.#dllhash:
		addcompid
		dd 0,4,0,1
		dw IMAGE_SYM_CLASS_EXTERNAL
		dd descr_strtbl2_end.#dllhash-$
		descr_strtbl3.#dllhash db 07Fh
		times namelen db 0
		do_cpy descr_dllname.#dllhash,descr_strtbl3.#dllhash+1,namelen
		db '_NULL_THUNK_DATA',0
	descr_strtbl2_end.#dllhash:
		add2dir descr_strtbl3.#dllhash,$-descr_strtbl3.#dllhash

		nxt_even_addr
		dllname_spot=$
		if RENAME_AR_MEMBERS
			if ~longname
				times namelen+1 db 's'
				db '/'
				times 14-namelen db ' '
			else
				add2long namelen,'s'
			end if
		else if ~longname
			times dllnamelen+1 db '/'
			times 15-dllnamelen db ' '
		else
			dllname_spot=0
			add2long
		end if
		if dllname_spot
			do_cpy descr_dllname.#dllhash,dllname_spot,longnamelen
		end if
		define def.#dllhash 1
	else

		nxt_even_addr
		if ~longname
			if RENAME_AR_MEMBERS
			shortlib.#name#.#dllhash:
				times namelen+1 db 's'
				do_cpy descr_dllname.#dllhash,shortlib.#name#.#dllhash,namelen
				db '/'
				times 14-namelen db ' '
			else
				db `dllname,'/'
				times 15-dllnamelen db ' '
			end if
		else
			add2long
		end if
	end if
	print_ts
	db '            0       ' ; owner id, group id, file mode (not used in Win)
	pack_sz (strtbl_end.#name#.#dllhash-lnk_memberN.#name#.#dllhash)
lnk_memberN.#name#.#dllhash:
	chkordinal name
	dw IMAGE_FILE_MACHINE_I386,3+KEEP_ORIGINAL_THUNK-byordinal
	dd %t,symbol_table.#name#.#dllhash-lnk_memberN.#name#.#dllhash
	dd 9+KEEP_ORIGINAL_THUNK*2-byordinal*2+USE_COMPID
	dw 0,IMAGE_FILE_32BIT_MACHINE
	db '.text',0,0,0
	dd 0,0,6,thunk.#name#.#dllhash-lnk_memberN.#name#.#dllhash,rel1.#name#.#dllhash-lnk_memberN.#name#.#dllhash
	dd 0,1,IMAGE_CNT_CODE or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_EXECUTE
	db '.idata$5'
	dd 0,0,4,rel2.#name#.#dllhash-lnk_memberN.#name#.#dllhash
	if byordinal=0
		dd rel2.#name#.#dllhash-lnk_memberN.#name#.#dllhash,0,1
	else
		dd 0,0,0
	end if
	dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	if KEEP_ORIGINAL_THUNK
		db '.idata$4'
		dd 0,0,4,rel2.#name#.#dllhash-lnk_memberN.#name#.#dllhash
		if byordinal=0
			dd rel2.#name#.#dllhash-lnk_memberN.#name#.#dllhash,0,1
		else
			dd 0,0,0
		end if
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	end if
	if byordinal=0
		db '.idata$6'
		dd 0,0,symbol_table.#name#.#dllhash-data3.#name#.#dllhash
		dd data3.#name#.#dllhash-lnk_memberN.#name#.#dllhash,0,0,0
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		thunk.#name#.#dllhash:
			dw 25FFh ; +00000000 jmp [pubname]
		rel2.#name#.#dllhash dd 0,6+KEEP_ORIGINAL_THUNK*2+USE_COMPID ; --> .idata$6
			dw IMAGE_REL_I386_DIR32NB
		rel1.#name#.#dllhash dd 2,5+USE_COMPID ; --> public name
			db IMAGE_REL_I386_DIR32
		data3.#name#.#dllhash db 0,0,`name,0
			times ($-data3.#name#.#dllhash) and 1 db 0
	else
		thunk.#name#.#dllhash:
			dw 25FFh,0,0 ; jmp [pubname]
		rel1.#name#.#dllhash dd 2,5+USE_COMPID ; --> public name
			dw IMAGE_REL_I386_DIR32
		rel2.#name#.#dllhash dd 80000000h+ordinal_value
	end if
symbol_table.#name#.#dllhash:
	addcompid
	db '.text',0,0,0
	dd 0,1
	db IMAGE_SYM_CLASS_STATIC,1
	dd 6,1,0
	dw 0
	dd IMAGE_COMDAT_SELECT_NODUPLICATES
	dd 0,thunkname.#name#.#dllhash-strtbl.#name#.#dllhash,0
	dw 1,IMAGE_SYM_DTYPE_FUNCTION,IMAGE_SYM_CLASS_EXTERNAL
	db '.idata$5'
	dd 0,2
	db IMAGE_SYM_CLASS_STATIC,1
	dd 4,1,0
	dw 0
	dd IMAGE_COMDAT_SELECT_NODUPLICATES
	dd 0,4,0,2
	dw IMAGE_SYM_CLASS_EXTERNAL
	if KEEP_ORIGINAL_THUNK
		db '.idata$4'
		dd 0,3
		db IMAGE_SYM_CLASS_STATIC,1
		dd 4,1,0
		dw 2
		dd IMAGE_COMDAT_SELECT_ASSOCIATIVE
	end if
	if byordinal=0
		db '.idata$6'
		dd 0,3+KEEP_ORIGINAL_THUNK
		db IMAGE_SYM_CLASS_STATIC,1
		dd symbol_table.#name#.#dllhash-data3.#name#.#dllhash,0,0
		dw 2
		dd IMAGE_COMDAT_SELECT_ASSOCIATIVE
	end if
	dd 0,strtbl_2.#name#.#dllhash-strtbl.#name#.#dllhash,0,0
	dw IMAGE_SYM_CLASS_EXTERNAL
strtbl.#name#.#dllhash dd strtbl_end.#name#.#dllhash-$
publicname.#name#.#dllhash:
if pubname eqtype 0
	db `pubname,0
	publicname_end.#name#.#dllhash:
	thunkname.#name#.#dllhash db `thunk,0
else
	db '__imp_'
	if thunk eqtype 0
		thunkname.#name#.#dllhash db `thunk,0
	else
		thunkname.#name#.#dllhash db `name,0
	end if
	publicname_end.#name#.#dllhash:
end if
strtbl_2.#name#.#dllhash db '__IMPORT_DESCRIPTOR_'
	times namelen+1 db 0
	do_cpy descr_dllname.#dllhash,strtbl_2.#name#.#dllhash+20,namelen
strtbl_end.#name#.#dllhash:
	add2dir thunkname.#name#.#dllhash,strtbl_2.#name#.#dllhash-thunkname.#name#.#dllhash
	add2dir publicname.#name#.#dllhash,publicname_end.#name#.#dllhash-publicname.#name#.#dllhash
}

macro pbimplib dllname,cconv,argcount,name,pb_name,pubname{
	argc=argcount
	if argc>31 | argc<0
		argc=0
		display '-WNG: [argcount] should be in the range [0..31], defaulting to 0',13,10
	end if
	if cconv>PBCALL | cconv<STDCALL
		display '-WNG: [cconv] has an invalid value, defaulting to STDCALL',13,10
	end if
	islongname dllname
	syms=syms+1
	longname=1
	longnamelen=namelen
	if RENAME_AR_MEMBERS
		if namelen<15
			longname=0
		end if
	else
		longnamelen=dllnamelen
		if dllnamelen<16
			longname=0
		end if
	end if
	if ~defined def.#dllhash

		; __IMPORT_DESCRIPTOR_<DLL>
		nxt_even_addr
		dllname_spot=$
		if RENAME_AR_MEMBERS
			if ~longname
				times namelen+1 db 'h'
				db '/'
				times 14-namelen db ' '
			end if
		else if ~longname
			times dllnamelen+1 db '/'
			times 15-dllnamelen db ' '
		end if
		if longname

			; Long names table
			db '//                                              '
			pack_sz longnames_size
		longnames_sz:
			longnames_arr=$
			times longnames_len db 0
			longnames_size=$-longnames_sz
			nxt_even_addr
			add2long longnamelen,'h'
		end if
		print_ts
		db '            0       ' ; owner id, group id, file mode (not used in Win)
		pack_sz (descr_strtbl_end.#dllhash-descr.#dllhash)
	descr.#dllhash:
		dw IMAGE_FILE_MACHINE_I386,2+RENAME_AR_MEMBERS*(1+KEEP_ORIGINAL_THUNK)
		dd %t,descr_sym_tbl.#dllhash-descr.#dllhash
		coffhdr
		dd null_imp_descr.#dllhash-descr.#dllhash,descr_rel.#dllhash-descr.#dllhash
		dd 0,2+KEEP_ORIGINAL_THUNK,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_1BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		db '.idata$6'
		dd 0,0,(null_imp_descr.#dllhash-descr_dllname.#dllhash+2) and -2,descr_dllname.#dllhash-descr.#dllhash,0
		dd 0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		if RENAME_AR_MEMBERS
			db '.idata$5'
			dd 0,0,0,0,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
			if KEEP_ORIGINAL_THUNK
				db '.idata$4'
				dd 0,0,0,0,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
			end if
		end if
	descr_dllname.#dllhash db `dllname
		do_cpy descr_dllname.#dllhash,dllname_spot,longnamelen
	null_imp_descr.#dllhash dq 0,0
		if KEEP_ORIGINAL_THUNK
		descr_rel.#dllhash:
			dd 0,3+USE_COMPID ; Import lookup table RVA (characteristics) --> .idata$4
			dw IMAGE_REL_I386_DIR32NB
		else
			dd 0
		descr_rel.#dllhash:
		end if
		dd 12,2+USE_COMPID ; DLL name RVA --> .idata$6
		dw IMAGE_REL_I386_DIR32NB
		dd 16,3+USE_COMPID+KEEP_ORIGINAL_THUNK ; Import address table RVA (thunk table) --> .idata$5
		dw IMAGE_REL_I386_DIR32NB
	descr_sym_tbl.#dllhash:
		addcompid
		dd 0,descr_strtbl2.#dllhash-descr_strtbl.#dllhash,0,1
		dw IMAGE_SYM_CLASS_EXTERNAL
		db '.idata$2'
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_MEM_READ or IMAGE_MEM_WRITE,1
		dw IMAGE_SYM_CLASS_SECTION
		db '.idata$6'
		dd 0,2
		dw IMAGE_SYM_CLASS_STATIC
		if KEEP_ORIGINAL_THUNK
			db '.idata$4'
			if RENAME_AR_MEMBERS
				dd 0,4
				dw IMAGE_SYM_CLASS_STATIC
			else
				dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_MEM_READ or IMAGE_MEM_WRITE,0
				dw IMAGE_SYM_CLASS_SECTION
			end if
		end if
		db '.idata$5'
		if RENAME_AR_MEMBERS
			dd 0,3
			dw IMAGE_SYM_CLASS_STATIC
		else
			dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_MEM_READ or IMAGE_MEM_WRITE,0
			dw IMAGE_SYM_CLASS_SECTION
			dd 0,4,0,0
			dw IMAGE_SYM_CLASS_EXTERNAL
		end if
		dd 0,descr_strtbl_1.#dllhash-descr_strtbl.#dllhash,0,0
		dw IMAGE_SYM_CLASS_EXTERNAL
	descr_strtbl.#dllhash dd descr_strtbl_end.#dllhash-$
		if ~RENAME_AR_MEMBERS
			db '__NULL_IMPORT_DESCRIPTOR',0
		end if
	descr_strtbl2.#dllhash db '__IMPORT_DESCRIPTOR_'
		times namelen+1 db 0
		do_cpy descr_dllname.#dllhash,descr_strtbl2.#dllhash+20,namelen
		add2dir descr_strtbl2.#dllhash,$-descr_strtbl2.#dllhash
		descr_strtbl_1.#dllhash db 07Fh
		times namelen db 0
		do_cpy descr_dllname.#dllhash,descr_strtbl_1.#dllhash+1,namelen
		db '_NULL_THUNK_DATA',0
	descr_strtbl_end.#dllhash:

		; [7Fh]<DLL>_NULL_THUNK_DATA
		nxt_even_addr
		dllname_spot=$
		if RENAME_AR_MEMBERS
			if ~longname
				times namelen+1 db 't'
				db '/'
				times 14-namelen db ' '
			else
				add2long namelen,'t'
			end if
		else if ~longname
			times dllnamelen+1 db '/'
			times 15-dllnamelen db ' '
		else
			dllname_spot=0
			add2long
		end if
		if dllname_spot
			do_cpy descr_dllname.#dllhash,dllname_spot,longnamelen
		end if
		print_ts
		db '            0       ' ; owner id, group id, file mode (not used in Win)
		pack_sz (descr_strtbl2_end.#dllhash-descr2.#dllhash)
	descr2.#dllhash:
		dw IMAGE_FILE_MACHINE_I386,1+KEEP_ORIGINAL_THUNK
		dd %t,descr_sym_tbl2.#dllhash-descr2.#dllhash,1+USE_COMPID
		dw 0,IMAGE_FILE_32BIT_MACHINE
		db '.idata$5'
		dd 0,0,4,48,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		if KEEP_ORIGINAL_THUNK
			db '.idata$4'
			dd 0,0,4,88,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		end if
	descr_sym_tbl2.#dllhash:
		addcompid
		dd 0,4,0,1
		dw IMAGE_SYM_CLASS_EXTERNAL
		dd descr_strtbl2_end.#dllhash-$
		descr_strtbl3.#dllhash db 07Fh
		times namelen db 0
		do_cpy descr_dllname.#dllhash,descr_strtbl3.#dllhash+1,namelen
		db '_NULL_THUNK_DATA',0
	descr_strtbl2_end.#dllhash:
		add2dir descr_strtbl3.#dllhash,$-descr_strtbl3.#dllhash

		nxt_even_addr
		dllname_spot=$
		if RENAME_AR_MEMBERS
			if ~longname
				times namelen+1 db 's'
				db '/'
				times 14-namelen db ' '
			else
				add2long namelen,'s'
			end if
		else if ~longname
			times dllnamelen+1 db '/'
			times 15-dllnamelen db ' '
		else
			dllname_spot=0
			add2long
		end if
		if dllname_spot
			do_cpy descr_dllname.#dllhash,dllname_spot,longnamelen
		end if
		define def.#dllhash 1
	else

		nxt_even_addr
		if ~longname
			if RENAME_AR_MEMBERS
			shortlib.#name#.#dllhash:
				times namelen+1 db 's'
				do_cpy descr_dllname.#dllhash,shortlib.#name#.#dllhash,namelen
				db '/'
				times 14-namelen db ' '
			else
				db `dllname,'/'
				times 15-dllnamelen db ' '
			end if
		else
			add2long
		end if
	end if
	print_ts
	db '            0       ' ; owner id, group id, file mode (not used in Win)
	pack_sz (strtbl_end.#name#.#dllhash-lnk_memberN.#name#.#dllhash)
lnk_memberN.#name#.#dllhash:
	chkordinal name
	dw IMAGE_FILE_MACHINE_I386,3+KEEP_ORIGINAL_THUNK-byordinal
	dd %t,symbol_table.#name#.#dllhash-lnk_memberN.#name#.#dllhash
	dd 9+KEEP_ORIGINAL_THUNK*2-byordinal*2+USE_COMPID
	dw 0,IMAGE_FILE_32BIT_MACHINE
	db '.text',0,0,0
	xx=6
	if cconv=CDECL & argc>0
		if argc=1
			xx=14
		else
			xx=12+argc*4
		end if
	end if
	if cconv=PBCALL & argc>0
		xx=7
	end if
	dd 0,0,xx,thunk.#name#.#dllhash-lnk_memberN.#name#.#dllhash,rel1.#name#.#dllhash-lnk_memberN.#name#.#dllhash
	dd 0,1,IMAGE_CNT_CODE or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_EXECUTE
	db '.idata$5'
	dd 0,0,4,rel2.#name#.#dllhash-lnk_memberN.#name#.#dllhash
	if byordinal=0
		dd rel2.#name#.#dllhash-lnk_memberN.#name#.#dllhash,0,1
	else
		dd 0,0,0
	end if
	dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	if KEEP_ORIGINAL_THUNK
		db '.idata$4'
		dd 0,0,4,rel2.#name#.#dllhash-lnk_memberN.#name#.#dllhash
		if byordinal=0
			dd rel2.#name#.#dllhash-lnk_memberN.#name#.#dllhash,0,1
		else
			dd 0,0,0
		end if
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	end if
	xx=2
	if cconv=CDECL
		xx=2+argc*4
	else if cconv=PBCALL & argc>0
		xx=5
	end if
	if byordinal=0
		db '.idata$6'
		dd 0,0,symbol_table.#name#.#dllhash-data3.#name#.#dllhash
		dd data3.#name#.#dllhash-lnk_memberN.#name#.#dllhash,0,0,0
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		thunk.#name#.#dllhash:
			if cconv=CDECL
				if argc>0
					times argc db 0FFh,74h,24h,argc*4 ; push [esp+argc*4]
					dw 15FFh,0,0 ; call [pubname]
					if argc=1
						db 59h ; pop ecx
					else
						db 83h,0C4h,argc*4 ; add esp,argc*4
					end if
					db 0C2h,argc*4 ; +00 retn argc*4
				else
					dw 25FFh ; +00000000 jmp [pubname]
				end if
			else
				if cconv=PBCALL & argc>0
					db 5Ah,58h,52h ; pop edx / pop eax / push edx
				end if
				dw 25FFh ; +00000000 jmp [pubname]
			end if
		rel2.#name#.#dllhash dd 0,6+KEEP_ORIGINAL_THUNK*2+USE_COMPID ; --> .idata$6
			dw IMAGE_REL_I386_DIR32NB
		rel1.#name#.#dllhash dd xx,5+USE_COMPID ; --> public name
			db IMAGE_REL_I386_DIR32
		data3.#name#.#dllhash db 0,0,`name,0
			times ($-data3.#name#.#dllhash) and 1 db 0
	else
		thunk.#name#.#dllhash:
			if cconv=CDECL
				if argc>0
					times argc db 0FFh,74h,24h,argc*4 ; push [esp+argc*4]
					dw 15FFh,0,0 ; call [pubname]
					if argc=1
						db 59h ; pop ecx
					else
						db 83h,0C4h,argc*4 ; add esp,argc*4
					end if
					db 0C2h,argc*4,0 ; retn argc*4
				else
					dw 25FFh,0,0 ; jmp [pubname]
				end if
			else
				if cconv=PBCALL & argc>0
					db 5Ah,58h,52h ; pop edx / pop eax / push edx
				end if
				dw 25FFh,0,0 ; jmp [pubname]
			end if
		rel1.#name#.#dllhash dd xx,5+USE_COMPID ; --> public name
			dw IMAGE_REL_I386_DIR32
		rel2.#name#.#dllhash dd 80000000h+ordinal_value
	end if
symbol_table.#name#.#dllhash:
	addcompid
	db '.text',0,0,0
	dd 0,1
	db IMAGE_SYM_CLASS_STATIC,1
	dd 6,1,0
	dw 0
	dd IMAGE_COMDAT_SELECT_NODUPLICATES
	dd 0,thunkname.#name#.#dllhash-strtbl.#name#.#dllhash,0
	dw 1,IMAGE_SYM_DTYPE_FUNCTION,IMAGE_SYM_CLASS_EXTERNAL
	db '.idata$5'
	dd 0,2
	db IMAGE_SYM_CLASS_STATIC,1
	dd 4,1,0
	dw 0
	dd IMAGE_COMDAT_SELECT_NODUPLICATES
	dd 0,4,0,2
	dw IMAGE_SYM_CLASS_EXTERNAL
	if KEEP_ORIGINAL_THUNK
		db '.idata$4'
		dd 0,3
		db IMAGE_SYM_CLASS_STATIC,1
		dd 4,1,0
		dw 2
		dd IMAGE_COMDAT_SELECT_ASSOCIATIVE
	end if
	if byordinal=0
		db '.idata$6'
		dd 0,3+KEEP_ORIGINAL_THUNK
		db IMAGE_SYM_CLASS_STATIC,1
		dd symbol_table.#name#.#dllhash-data3.#name#.#dllhash,0,0
		dw 2
		dd IMAGE_COMDAT_SELECT_ASSOCIATIVE
	end if
	dd 0,strtbl_2.#name#.#dllhash-strtbl.#name#.#dllhash,0,0
	dw IMAGE_SYM_CLASS_EXTERNAL
strtbl.#name#.#dllhash dd strtbl_end.#name#.#dllhash-$
publicname.#name#.#dllhash:
if pubname eqtype 0
	db `pubname,0
	thunkname.#name#.#dllhash db '_PB_',`pb_name,0
else
	db '__imp_',`name,0
	thunkname.#name#.#dllhash:
	if pb_name eqtype 0
		db '_PB_',`pb_name,0
	else
		db '_PB_',`name,0
	end if
end if
strtbl_2.#name#.#dllhash db '__IMPORT_DESCRIPTOR_'
	times namelen+1 db 0
	do_cpy descr_dllname.#dllhash,strtbl_2.#name#.#dllhash+20,namelen
strtbl_end.#name#.#dllhash:
	add2dir thunkname.#name#.#dllhash,strtbl_2.#name#.#dllhash-thunkname.#name#.#dllhash
	add2dir publicname.#name#.#dllhash,thunkname.#name#.#dllhash-publicname.#name#.#dllhash
}

macro vbimplib module,dllname,cconv,argcount,name,vb_name,pubname{
	if RENAME_AR_MEMBERS
		RENAME_AR_MEMBERS equ 0
		display '-WNG: RENAME_AR_MEMBERS ignored, it is not compatible with VB',13,10
	end if
	argc=argcount
	if argc>31 | argc<0
		argc=0
		display '-WNG: [argcount] should be in the range [0..31], defaulting to 0',13,10
	end if
	if cconv>PBCALL | cconv<STDCALL
		display '-WNG: [cconv] has an invalid value, defaulting to STDCALL',13,10
	end if
	islongname dllname
	syms=syms+1
	longname=1
	if dllnamelen<16
		longname=0
	end if
	if ~defined def.#dllhash

		; __IMPORT_DESCRIPTOR_<DLL>
		nxt_even_addr
		dllname_spot=$
		if ~longname
			times dllnamelen+1 db '/'
			times 15-dllnamelen db ' '
		else

			; Long names table
			db '//                                              '
			pack_sz longnames_size
		longnames_sz:
			longnames_arr=$
			times longnames_len db 0
			longnames_size=$-longnames_sz
			nxt_even_addr
			add2long dllnamelen,'h'
		end if
		print_ts
		db '            0       ' ; owner id, group id, file mode (not used in Win)
		pack_sz (descr_strtbl_end.#dllhash-descr.#dllhash)
	descr.#dllhash:
		dw IMAGE_FILE_MACHINE_I386,2
		dd %t,descr_sym_tbl.#dllhash-descr.#dllhash
		coffhdr
		dd null_imp_descr.#dllhash-descr.#dllhash,descr_rel.#dllhash-descr.#dllhash
		dd 0,2+KEEP_ORIGINAL_THUNK,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_1BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		db '.idata$6'
		dd 0,0,(null_imp_descr.#dllhash-descr_dllname.#dllhash+2) and -2,descr_dllname.#dllhash-descr.#dllhash,0
		dd 0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	descr_dllname.#dllhash db `dllname
		do_cpy descr_dllname.#dllhash,dllname_spot,dllnamelen
	null_imp_descr.#dllhash dq 0,0
		if KEEP_ORIGINAL_THUNK
		descr_rel.#dllhash:
			dd 0,3+USE_COMPID ; Import lookup table RVA (characteristics) --> .idata$4
			dw IMAGE_REL_I386_DIR32NB
		else
			dd 0
		descr_rel.#dllhash:
		end if
		dd 12,2+USE_COMPID ; DLL name RVA --> .idata$6
		dw IMAGE_REL_I386_DIR32NB
		dd 16,3+USE_COMPID+KEEP_ORIGINAL_THUNK ; Import address table RVA (thunk table) --> .idata$5
		dw IMAGE_REL_I386_DIR32NB
	descr_sym_tbl.#dllhash:
		addcompid
		dd 0,29,0,1
		dw IMAGE_SYM_CLASS_EXTERNAL
		db '.idata$2'
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_MEM_READ or IMAGE_MEM_WRITE,1
		dw IMAGE_SYM_CLASS_SECTION
		db '.idata$6'
		dd 0,2
		dw IMAGE_SYM_CLASS_STATIC
		if KEEP_ORIGINAL_THUNK
			db '.idata$4'
			dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_MEM_READ or IMAGE_MEM_WRITE,0
			dw IMAGE_SYM_CLASS_SECTION
		end if
		db '.idata$5'
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_MEM_READ or IMAGE_MEM_WRITE,0
		dw IMAGE_SYM_CLASS_SECTION
		dd 0,4,0,0
		dw IMAGE_SYM_CLASS_EXTERNAL
		dd 0,descr_strtbl_1.#dllhash-descr_strtbl.#dllhash,0,0
		dw IMAGE_SYM_CLASS_EXTERNAL
	descr_strtbl.#dllhash dd descr_strtbl_end.#dllhash-$
		db '__NULL_IMPORT_DESCRIPTOR',0
	descr_strtbl2.#dllhash db '__IMPORT_DESCRIPTOR_'
		times namelen+1 db 0
		do_cpy descr_dllname.#dllhash,descr_strtbl2.#dllhash+20,namelen
		add2dir descr_strtbl2.#dllhash,$-descr_strtbl2.#dllhash
		descr_strtbl_1.#dllhash db 07Fh
		times namelen db 0
		do_cpy descr_dllname.#dllhash,descr_strtbl_1.#dllhash+1,namelen
		db '_NULL_THUNK_DATA',0
	descr_strtbl_end.#dllhash:

		; [7Fh]<DLL>_NULL_THUNK_DATA
		nxt_even_addr
		if ~longname
			db `dllname,'/'
			times 15-dllnamelen db ' '
		else
			add2long
		end if
		print_ts
		db '            0       ' ; owner id, group id, file mode (not used in Win)
		pack_sz (descr_strtbl2_end.#dllhash-descr2.#dllhash)
	descr2.#dllhash:
		dw IMAGE_FILE_MACHINE_I386,1+KEEP_ORIGINAL_THUNK
		dd %t,descr_sym_tbl2.#dllhash-descr2.#dllhash,1+USE_COMPID
		dw 0,IMAGE_FILE_32BIT_MACHINE
		db '.idata$5'
		dd 0,0,4,48,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		if KEEP_ORIGINAL_THUNK
			db '.idata$4'
			dd 0,0,4,88,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		end if
	descr_sym_tbl2.#dllhash:
		addcompid
		dd 0,4,0,1
		dw IMAGE_SYM_CLASS_EXTERNAL
		dd descr_strtbl2_end.#dllhash-$
		descr_strtbl3.#dllhash db 07Fh
		times namelen db 0
		do_cpy descr_dllname.#dllhash,descr_strtbl3.#dllhash+1,namelen
		db '_NULL_THUNK_DATA',0
	descr_strtbl2_end.#dllhash:
		add2dir descr_strtbl3.#dllhash,$-descr_strtbl3.#dllhash
		define def.#dllhash 1
	end if

	nxt_even_addr
	if ~longname
		db `dllname,'/'
		times 15-dllnamelen db ' '
	else
		add2long
	end if
	print_ts

	db '            0       ' ; owner id, group id, file mode (not used in Win)
	pack_sz (strtbl_end.#name#.#dllhash-lnk_memberN.#name#.#dllhash)
lnk_memberN.#name#.#dllhash:
	chkordinal name
	dw IMAGE_FILE_MACHINE_I386,3+KEEP_ORIGINAL_THUNK-byordinal
	dd %t,symbol_table.#name#.#dllhash-lnk_memberN.#name#.#dllhash
	dd 9+KEEP_ORIGINAL_THUNK*2-byordinal*2+USE_COMPID
	dw 0,IMAGE_FILE_32BIT_MACHINE
	db '.text',0,0,0
	xx=6
	if cconv=CDECL & argc>0
		if argc=1
			xx=14
		else
			xx=12+argc*4
		end if
	end if
	if cconv=PBCALL & argc>0
		xx=7
	end if
	dd 0,0,xx,thunk.#name#.#dllhash-lnk_memberN.#name#.#dllhash,rel1.#name#.#dllhash-lnk_memberN.#name#.#dllhash
	dd 0,1,IMAGE_CNT_CODE or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_EXECUTE
	db '.idata$5'
	dd 0,0,4,rel2.#name#.#dllhash-lnk_memberN.#name#.#dllhash
	if byordinal=0
		dd rel2.#name#.#dllhash-lnk_memberN.#name#.#dllhash,0,1
	else
		dd 0,0,0
	end if
	dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	if KEEP_ORIGINAL_THUNK
		db '.idata$4'
		dd 0,0,4,rel2.#name#.#dllhash-lnk_memberN.#name#.#dllhash
		if byordinal=0
			dd rel2.#name#.#dllhash-lnk_memberN.#name#.#dllhash,0,1
		else
			dd 0,0,0
		end if
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_4BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	end if
	xx=2
	if cconv=CDECL
		xx=2+argc*4
	else if cconv=PBCALL & argc>0
		xx=5
	end if
	if byordinal=0
		db '.idata$6'
		dd 0,0,symbol_table.#name#.#dllhash-data3.#name#.#dllhash
		dd data3.#name#.#dllhash-lnk_memberN.#name#.#dllhash,0,0,0
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		thunk.#name#.#dllhash:
			if cconv=CDECL
				if argc>0
					times argc db 0FFh,74h,24h,argc*4 ; push [esp+argc*4]
					dw 15FFh,0,0 ; call [pubname]
					if argc=1
						db 59h ; pop ecx
					else
						db 83h,0C4h,argc*4 ; add esp,argc*4
					end if
					db 0C2h,argc*4 ; +00 retn argc*4
				else
					dw 25FFh ; +00000000 jmp [pubname]
				end if
			else
				if cconv=PBCALL & argc>0
					db 5Ah,58h,52h ; pop edx / pop eax / push edx
				end if
				dw 25FFh ; +00000000 jmp [pubname]
			end if
		rel2.#name#.#dllhash dd 0
			dd 6+KEEP_ORIGINAL_THUNK*2+USE_COMPID ; --> .idata$6
			dw IMAGE_REL_I386_DIR32NB
		rel1.#name#.#dllhash dd xx,5+USE_COMPID ; --> public name
			db IMAGE_REL_I386_DIR32
		data3.#name#.#dllhash db 0,0,`name,0
			times ($-data3.#name#.#dllhash) and 1 db 0
	else
		thunk.#name#.#dllhash:
			if cconv=CDECL
				if argc>0
					times argc db 0FFh,74h,24h,argc*4 ; push [esp+argc*4]
					dw 15FFh,0,0 ; call [pubname]
					if argc=1
						db 59h ; pop ecx
					else
						db 83h,0C4h,argc*4 ; add esp,argc*4
					end if
					db 0C2h,argc*4,0 ; retn argc*4
				else
					dw 25FFh,0,0 ; jmp [pubname]
				end if
			else
				if cconv=PBCALL & argc>0
					db 5Ah,58h,52h ; pop edx / pop eax / push edx
				end if
				dw 25FFh,0,0 ; jmp [pubname]
			end if
		rel1.#name#.#dllhash dd xx
			dd 5+USE_COMPID ; --> public name
			dw IMAGE_REL_I386_DIR32
		rel2.#name#.#dllhash dd 80000000h+ordinal_value
	end if
symbol_table.#name#.#dllhash:
	addcompid
	db '.text',0,0,0
	dd 0,1
	db IMAGE_SYM_CLASS_STATIC,1
	dd 6,1,0
	dw 0
	dd IMAGE_COMDAT_SELECT_NODUPLICATES
	dd 0,thunkname.#name#.#dllhash-strtbl.#name#.#dllhash,0
	dw 1,IMAGE_SYM_DTYPE_FUNCTION,IMAGE_SYM_CLASS_EXTERNAL
	db '.idata$5'
	dd 0,2
	db IMAGE_SYM_CLASS_STATIC,1
	dd 4,1,0
	dw 0
	dd IMAGE_COMDAT_SELECT_NODUPLICATES
	dd 0,4,0,2
	dw IMAGE_SYM_CLASS_EXTERNAL
	if KEEP_ORIGINAL_THUNK
		db '.idata$4'
		dd 0,3
		db IMAGE_SYM_CLASS_STATIC,1
		dd 4,1,0
		dw 2
		dd IMAGE_COMDAT_SELECT_ASSOCIATIVE
	end if
	if byordinal=0
		db '.idata$6'
		dd 0,3+KEEP_ORIGINAL_THUNK
		db IMAGE_SYM_CLASS_STATIC,1
		dd symbol_table.#name#.#dllhash-data3.#name#.#dllhash,0,0
		dw 2
		dd IMAGE_COMDAT_SELECT_ASSOCIATIVE
	end if
	dd 0,strtbl_2.#name#.#dllhash-strtbl.#name#.#dllhash,0,0
	dw IMAGE_SYM_CLASS_EXTERNAL
strtbl.#name#.#dllhash dd strtbl_end.#name#.#dllhash-$
publicname.#name#.#dllhash:
if pubname eqtype 0
	db `pubname,0
else
	db '__imp_',`name,0
end if
thunkname.#name#.#dllhash:
if vb_name eqtype 0
	db '?',`vb_name
else
	db '?',`name
end if
	db '@',`module,'@@AAGXXZ',0
strtbl_2.#name#.#dllhash db '__IMPORT_DESCRIPTOR_'
	times namelen+1 db 0
	do_cpy descr_dllname.#dllhash,strtbl_2.#name#.#dllhash+20,namelen
strtbl_end.#name#.#dllhash:
	add2dir thunkname.#name#.#dllhash,strtbl_2.#name#.#dllhash-thunkname.#name#.#dllhash
	add2dir publicname.#name#.#dllhash,thunkname.#name#.#dllhash-publicname.#name#.#dllhash
}

macro endlib{
	if ~RENAME_AR_MEMBERS
		nxt_even_addr
		db '_null_lib_i.o/  '
		print_ts
		db '            0       1'
		if USE_COMPID
			db '45'
		else
			db '23'
		end if
		db '       ',60h,0Ah
	null_imp_descr:
		dw IMAGE_FILE_MACHINE_I386,1
		dd %t,null_imp_descr_sym_tbl-null_imp_descr,1+USE_COMPID
		dw 0,IMAGE_FILE_32BIT_MACHINE
		db '.idata$3'
		dd 0,0,20,null_imp_descr_data-null_imp_descr,0,0,0
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_1BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	null_imp_descr_data dq 0,0
		if USE_COMPID
			dd 0
		end if
	null_imp_descr_sym_tbl:
		addcompid
		dd 0,4,0,1
		dw IMAGE_SYM_CLASS_EXTERNAL
		dd 1Dh
		db '__NULL_IMPORT_DESCRIPTOR',0
		add2dir $-25,25
	end if
	num_syms=syms_indexed
	symarr_size=str_tbl_size
	longnames_len=lng_tbl_size
	display 'DLL symbols indexed: '
	yy=100000000
	repeat 7
		yy=yy/10
		if syms>=yy
			display '0'+(syms/yy)mod 10
		end if
	end repeat
	display '0'+syms mod 10,13,10
	if lnk_member1_size>93952
		display '-WNG: If using 32-bit MS linker, error LNK1102 may appear when loading this library due to its size',13,10
	end if
}
