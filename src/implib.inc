; IMPLIB.INC v2.0.1
; =================
; (c) 2006-2025 Vladimir Kamenar

; FASM macros for building custom import libraries for Windows DLL (32-bit).
; These macros can be combined in a single library:
; implib   - general purpose symbol definition macro.
; pbimplib - mod intended for PureBasic Userlib.
; vbimplib - mod intended for Visual Basic 6. For instance, it is useful for
;            calling CDECL DLL functions directly from Visual Basic 6, without
;            wrapper DLLs and/or delegators.
; MACRO implib   dllname, name, thunk, pubname
; MACRO pbimplib dllname, cconv, argcount, name, pb_name, pubname
; MACRO vbimplib module, dllname, cconv, argcount, name, vb_name, pubname
; Parameters:
;    dllname  : DLL file name.
;    cconv    : Calling convention. Possible values: STDCALL, CDECL, PBCALL
;    argcount : Number of DWORD arguments. (QWORD counts as 2 DWORDs and so on.)
;    name     : Symbol name or an ordinal value, prefixed with ord. This value should
;               match exactly the required DLL exported symbol.
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
;    vbimplib vbopenal, openal32.dll, CDECL, 2, alGenBuffers

; === CONFIG BEGIN ==================================================

; Set to 0 to disable original thunk (lookup table) to reduce the IAT size in
; the final executable by 4 x n bytes, n being the number of imported symbols.
; You won't be able to bind (using BIND.EXE from PSDK) an IAT without original
; thunk! So, removing the lookups is recommended only when importing from
; standart API DLLs, like KERNEL32, USER32 and so on.
KEEP_ORIGINAL_THUNK equ 1

; Optional header is not required in object files. Very old MS LINK versions
; may use it. The following option is included for compatibility.
USE_OPTIONAL_HEADER equ 0

; An additional @comp.id symbol per object file is appended by MS LINK,
; possibly to watermark the import library.
USE_COMPID equ 0

; Rename archive members for compatibility with LLVM linker.
RENAME_AR_MEMBERS equ 0

; Disable the 2nd linker member.
LINKER_MEMBER_2_REMOVE equ 1

; === CONFIG END ====================================================

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
IMAGE_ALIGN_2BYTES=200000h
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
						display '-WNG: Bad ordinal: ',`name,13,10
					else
						ordinal_value=ordinal_value*10+chr
					end if
				end repeat
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
	if ~defined dllname#.alreadydefined

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
		pack_sz (dllname#.descr_strtbl_end-dllname#.descr)
	dllname#.descr:
		dw IMAGE_FILE_MACHINE_I386,2+RENAME_AR_MEMBERS*(1+KEEP_ORIGINAL_THUNK)
		dd %t,dllname#.descr_sym_tbl-dllname#.descr
		coffhdr
		dd dllname#.null_import_descr_data-dllname#.descr,dllname#.descr_rel-dllname#.descr
		dd 0,2+KEEP_ORIGINAL_THUNK,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		db '.idata$6'
		dd 0,0,(dllname#.null_import_descr_data-dllname#.descr_dllname+2) and -2,dllname#.descr_dllname-dllname#.descr,0
		dd 0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		if RENAME_AR_MEMBERS
			db '.idata$5'
			dd 0,0,0,0,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
			if KEEP_ORIGINAL_THUNK
				db '.idata$4'
				dd 0,0,0,0,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
			end if
		end if
	dllname#.descr_dllname db `dllname
		do_cpy dllname#.descr_dllname,dllname_spot,longnamelen
	dllname#.null_import_descr_data dq 0,0
		if KEEP_ORIGINAL_THUNK
		dllname#.descr_rel:
			dd 0,3+USE_COMPID ; Import lookup table RVA (characteristics) --> .idata$4
			dw IMAGE_REL_I386_DIR32NB
		else
			dd 0
		dllname#.descr_rel:
		end if
		dd 12,2+USE_COMPID ; DLL name RVA --> .idata$6
		dw IMAGE_REL_I386_DIR32NB
		dd 16,3+USE_COMPID+KEEP_ORIGINAL_THUNK ; Import address table RVA (thunk table) --> .idata$5
		dw IMAGE_REL_I386_DIR32NB
	dllname#.descr_sym_tbl:
		addcompid
		dd 0,dllname#.descr_strtbl2-dllname#.descr_strtbl,0,1
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
		end if
		if ~RENAME_AR_MEMBERS
			dd 0,4,0,0
			dw IMAGE_SYM_CLASS_EXTERNAL
		end if
		dd 0,dllname#.descr_strtbl_1-dllname#.descr_strtbl,0,0
		dw IMAGE_SYM_CLASS_EXTERNAL
	dllname#.descr_strtbl dd dllname#.descr_strtbl_end-$
		if ~RENAME_AR_MEMBERS
			db '__NULL_IMPORT_DESCRIPTOR',0
		end if
	dllname#.descr_strtbl2 db '__IMPORT_DESCRIPTOR_'
		times namelen+1 db 0
		do_cpy dllname#.descr_dllname,dllname#.descr_strtbl2+20,namelen
		add2dir dllname#.descr_strtbl2,$-dllname#.descr_strtbl2
		dllname#.descr_strtbl_1 db 07Fh
		times namelen db 0
		do_cpy dllname#.descr_dllname,dllname#.descr_strtbl_1+1,namelen
		db '_NULL_THUNK_DATA',0
	dllname#.descr_strtbl_end:

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
			do_cpy dllname#.descr_dllname,dllname_spot,longnamelen
		end if
		print_ts
		db '            0       ' ; owner id, group id, file mode (not used in Win)
		pack_sz (dllname#.descr_strtbl2_end-dllname#.descr2)
	dllname#.descr2:
		dw IMAGE_FILE_MACHINE_I386,1+KEEP_ORIGINAL_THUNK
		dd %t,dllname#.descr_sym_tbl2-dllname#.descr2,1+USE_COMPID
		dw 0,IMAGE_FILE_32BIT_MACHINE
		db '.idata$5'
		dd 0,0,4,48,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		if KEEP_ORIGINAL_THUNK
			db '.idata$4'
			dd 0,0,4,88,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		end if
	dllname#.descr_sym_tbl2:
		addcompid
		dd 0,4,0,1
		dw IMAGE_SYM_CLASS_EXTERNAL
		dd dllname#.descr_strtbl2_end-$
		dllname#.descr_strtbl3 db 07Fh
		times namelen db 0
		do_cpy dllname#.descr_dllname,dllname#.descr_strtbl3+1,namelen
		db '_NULL_THUNK_DATA',0
	dllname#.descr_strtbl2_end:
		add2dir dllname#.descr_strtbl3,$-dllname#.descr_strtbl3

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
			do_cpy dllname#.descr_dllname,dllname_spot,longnamelen
		end if
		define dllname#.alreadydefined 1
	else

		nxt_even_addr
		if ~longname
			if RENAME_AR_MEMBERS
			dllname#name#.shortlib:
				times namelen+1 db 's'
				do_cpy dllname#.descr_dllname,dllname#name#.shortlib,namelen
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
	pack_sz (dllname#name#.strtbl_end-dllname#name#.lnk_memberN)
dllname#name#.lnk_memberN:
	chkordinal name
	dw IMAGE_FILE_MACHINE_I386,3+KEEP_ORIGINAL_THUNK-byordinal
	dd %t,dllname#name#.symbol_table-dllname#name#.lnk_memberN
	dd 9+KEEP_ORIGINAL_THUNK*2-byordinal*2+USE_COMPID
	dw 0,IMAGE_FILE_32BIT_MACHINE
	db '.text',0,0,0
	dd 0,0,6,dllname#name#.thunk-dllname#name#.lnk_memberN,dllname#name#.rel1-dllname#name#.lnk_memberN
	dd 0,1,IMAGE_CNT_CODE or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_EXECUTE
	db '.idata$5'
	dd 0,0,4,dllname#name#.rel2-dllname#name#.lnk_memberN
	if byordinal=0
		dd dllname#name#.rel2-dllname#name#.lnk_memberN,0,1
	else
		dd 0,0,0
	end if
	dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	if KEEP_ORIGINAL_THUNK
		db '.idata$4'
		dd 0,0,4,dllname#name#.rel2-dllname#name#.lnk_memberN
		if byordinal=0
			dd dllname#name#.rel2-dllname#name#.lnk_memberN,0,1
		else
			dd 0,0,0
		end if
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	end if
	if byordinal=0
		db '.idata$6'
		dd 0,0,dllname#name#.symbol_table-dllname#name#.data3
		dd dllname#name#.data3-dllname#name#.lnk_memberN,0,0,0
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		dllname#name#.thunk:
			dw 25FFh ; +00000000 jmp [pubname]
		dllname#name#.rel2 dd 0,6+KEEP_ORIGINAL_THUNK*2+USE_COMPID ; --> .idata$6
			dw IMAGE_REL_I386_DIR32NB
		dllname#name#.rel1 dd 2,5+USE_COMPID ; --> public name
			db IMAGE_REL_I386_DIR32
		dllname#name#.data3 db 0,0,`name,0
			times ($-dllname#name#.data3) and 1 db 0
	else
		dllname#name#.thunk:
			dw 25FFh,0,0 ; jmp [pubname]
		dllname#name#.rel1 dd 2,5+USE_COMPID ; --> public name
			dw IMAGE_REL_I386_DIR32
		dllname#name#.rel2 dd 80000000h+ordinal_value
	end if
dllname#name#.symbol_table:
	addcompid
	db '.text',0,0,0
	dd 0,1
	db IMAGE_SYM_CLASS_STATIC,1
	dd 6,1,0
	dw 0
	dd IMAGE_COMDAT_SELECT_NODUPLICATES
	dd 0,dllname#name#.thunkname-dllname#name#.strtbl,0
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
		dd dllname#name#.symbol_table-dllname#name#.data3,0,0
		dw 2
		dd IMAGE_COMDAT_SELECT_ASSOCIATIVE
	end if
	dd 0,dllname#name#.strtbl_2-dllname#name#.strtbl,0,0
	dw IMAGE_SYM_CLASS_EXTERNAL
dllname#name#.strtbl dd dllname#name#.strtbl_end-$
dllname#name#.publicname:
if pubname eqtype 0
	db `pubname,0
	dllname#name#.publicname_end:
	dllname#name#.thunkname db `thunk,0
else
	db '__imp_'
	if thunk eqtype 0
		dllname#name#.thunkname db `thunk,0
	else
		dllname#name#.thunkname db `name,0
	end if
	dllname#name#.publicname_end:
end if
dllname#name#.strtbl_2 db '__IMPORT_DESCRIPTOR_'
	times namelen+1 db 0
	do_cpy dllname#.descr_dllname,dllname#name#.strtbl_2+20,namelen
dllname#name#.strtbl_end:
	add2dir dllname#name#.thunkname,dllname#name#.strtbl_2-dllname#name#.thunkname
	add2dir dllname#name#.publicname,dllname#name#.publicname_end-dllname#name#.publicname
}

macro pbimplib dllname,cconv,argcount,name,pb_name,pubname{
	if argcount>31 | argcount<0
		argcount=0
		display '-WNG: [argcount] should be in the range [0..31]. Defaulting to 0.',13,10
	end if
	if cconv>PBCALL | cconv<STDCALL
		display '-WNG: [cconv] has an invalid value. Defaulting to STDCALL.',13,10
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
	if ~defined dllname#.alreadydefined

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
		pack_sz (dllname#.descr_strtbl_end-dllname#.descr)
	dllname#.descr:
		dw IMAGE_FILE_MACHINE_I386,2+RENAME_AR_MEMBERS*(1+KEEP_ORIGINAL_THUNK)
		dd %t,dllname#.descr_sym_tbl-dllname#.descr
		coffhdr
		dd dllname#.null_import_descr_data-dllname#.descr,dllname#.descr_rel-dllname#.descr
		dd 0,2+KEEP_ORIGINAL_THUNK,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		db '.idata$6'
		dd 0,0,(dllname#.null_import_descr_data-dllname#.descr_dllname+2) and -2,dllname#.descr_dllname-dllname#.descr,0
		dd 0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		if RENAME_AR_MEMBERS
			db '.idata$5'
			dd 0,0,0,0,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
			if KEEP_ORIGINAL_THUNK
				db '.idata$4'
				dd 0,0,0,0,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
			end if
		end if
	dllname#.descr_dllname db `dllname
		do_cpy dllname#.descr_dllname,dllname_spot,longnamelen
	dllname#.null_import_descr_data dq 0,0
		if KEEP_ORIGINAL_THUNK
		dllname#.descr_rel:
			dd 0,3+USE_COMPID ; Import lookup table RVA (characteristics) --> .idata$4
			dw IMAGE_REL_I386_DIR32NB
		else
			dd 0
		dllname#.descr_rel:
		end if
		dd 12,2+USE_COMPID ; DLL name RVA --> .idata$6
		dw IMAGE_REL_I386_DIR32NB
		dd 16,3+USE_COMPID+KEEP_ORIGINAL_THUNK ; Import address table RVA (thunk table) --> .idata$5
		dw IMAGE_REL_I386_DIR32NB
	dllname#.descr_sym_tbl:
		addcompid
		dd 0,dllname#.descr_strtbl2-dllname#.descr_strtbl,0,1
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
		end if
		if ~RENAME_AR_MEMBERS
			dd 0,4,0,0
			dw IMAGE_SYM_CLASS_EXTERNAL
		end if
		dd 0,dllname#.descr_strtbl_1-dllname#.descr_strtbl,0,0
		dw IMAGE_SYM_CLASS_EXTERNAL
	dllname#.descr_strtbl dd dllname#.descr_strtbl_end-$
		if ~RENAME_AR_MEMBERS
			db '__NULL_IMPORT_DESCRIPTOR',0
		end if
	dllname#.descr_strtbl2 db '__IMPORT_DESCRIPTOR_'
		times namelen+1 db 0
		do_cpy dllname#.descr_dllname,dllname#.descr_strtbl2+20,namelen
		add2dir dllname#.descr_strtbl2,$-dllname#.descr_strtbl2
		dllname#.descr_strtbl_1 db 07Fh
		times namelen db 0
		do_cpy dllname#.descr_dllname,dllname#.descr_strtbl_1+1,namelen
		db '_NULL_THUNK_DATA',0
	dllname#.descr_strtbl_end:

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
			do_cpy dllname#.descr_dllname,dllname_spot,longnamelen
		end if
		print_ts
		db '            0       ' ; owner id, group id, file mode (not used in Win)
		pack_sz (dllname#.descr_strtbl2_end-dllname#.descr2)
	dllname#.descr2:
		dw IMAGE_FILE_MACHINE_I386,1+KEEP_ORIGINAL_THUNK
		dd %t,dllname#.descr_sym_tbl2-dllname#.descr2,1+USE_COMPID
		dw 0,IMAGE_FILE_32BIT_MACHINE
		db '.idata$5'
		dd 0,0,4,48,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		if KEEP_ORIGINAL_THUNK
			db '.idata$4'
			dd 0,0,4,88,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		end if
	dllname#.descr_sym_tbl2:
		addcompid
		dd 0,4,0,1
		dw IMAGE_SYM_CLASS_EXTERNAL
		dd dllname#.descr_strtbl2_end-$
		dllname#.descr_strtbl3 db 07Fh
		times namelen db 0
		do_cpy dllname#.descr_dllname,dllname#.descr_strtbl3+1,namelen
		db '_NULL_THUNK_DATA',0
	dllname#.descr_strtbl2_end:
		add2dir dllname#.descr_strtbl3,$-dllname#.descr_strtbl3

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
			do_cpy dllname#.descr_dllname,dllname_spot,longnamelen
		end if
		define dllname#.alreadydefined 1
	else

		nxt_even_addr
		if ~longname
			if RENAME_AR_MEMBERS
			dllname#name#.shortlib:
				times namelen+1 db 's'
				do_cpy dllname#.descr_dllname,dllname#name#.shortlib,namelen
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
	pack_sz (dllname#name#.strtbl_end-dllname#name#.lnk_memberN)
dllname#name#.lnk_memberN:
	chkordinal name
	dw IMAGE_FILE_MACHINE_I386,3+KEEP_ORIGINAL_THUNK-byordinal
	dd %t,dllname#name#.symbol_table-dllname#name#.lnk_memberN
	dd 9+KEEP_ORIGINAL_THUNK*2-byordinal*2+USE_COMPID
	dw 0,IMAGE_FILE_32BIT_MACHINE
	db '.text',0,0,0
	xx=6
	if cconv=CDECL & argcount>0
		xx=12+argcount*4
	end if
	if cconv=PBCALL & argcount>0
		xx=7
	end if
	dd 0,0,xx,dllname#name#.thunk-dllname#name#.lnk_memberN,dllname#name#.rel1-dllname#name#.lnk_memberN
	dd 0,1,IMAGE_CNT_CODE or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_EXECUTE
	db '.idata$5'
	dd 0,0,4,dllname#name#.rel2-dllname#name#.lnk_memberN
	if byordinal=0
		dd dllname#name#.rel2-dllname#name#.lnk_memberN,0,1
	else
		dd 0,0,0
	end if
	dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	if KEEP_ORIGINAL_THUNK
		db '.idata$4'
		dd 0,0,4,dllname#name#.rel2-dllname#name#.lnk_memberN
		if byordinal=0
			dd dllname#name#.rel2-dllname#name#.lnk_memberN,0,1
		else
			dd 0,0,0
		end if
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	end if
	xx=2
	if cconv=CDECL
		xx=2+argcount*4
	else if cconv=PBCALL & argcount>0
		xx=5
	end if
	if byordinal=0
		db '.idata$6'
		dd 0,0,dllname#name#.symbol_table-dllname#name#.data3
		dd dllname#name#.data3-dllname#name#.lnk_memberN,0,0,0
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		dllname#name#.thunk:
			if cconv=CDECL
				if argcount>0
					times argcount db 0FFh,74h,24h,argcount*4 ; push [esp+argcount*4]
					dw 15FFh,0,0           ; call [pubname]
					db 83h,0C4h,argcount*4 ; add esp,argcount*4
					db 0C2h,argcount*4     ; +00 retn argcount*4
				else
					dw 25FFh               ; +00000000 jmp [pubname]
				end if
			else
				if cconv=PBCALL & argcount>0
					db 5Ah,58h,52h ; pop edx / pop eax / push edx
				end if
				dw 25FFh ; +00000000 jmp [pubname]
			end if
		dllname#name#.rel2 dd 0,6+KEEP_ORIGINAL_THUNK*2+USE_COMPID ; --> .idata$6
			dw IMAGE_REL_I386_DIR32NB
		dllname#name#.rel1 dd xx,5+USE_COMPID ; --> public name
			db IMAGE_REL_I386_DIR32
		dllname#name#.data3 db 0,0,`name,0
			times ($-dllname#name#.data3) and 1 db 0
	else
		dllname#name#.thunk:
			if cconv=CDECL
				if argcount>0
					times argcount db 0FFh,74h,24h,argcount*4 ; push [esp+argcount*4]
					dw 15FFh,0,0           ; call [pubname]
					db 83h,0C4h,argcount*4 ; add esp,argcount*4
					db 0C2h,argcount*4,0   ; retn argcount*4
				else
					dw 25FFh,0,0           ; jmp [pubname]
				end if
			else
				if cconv=PBCALL & argcount>0
					db 5Ah,58h,52h ; pop edx / pop eax / push edx
				end if
				dw 25FFh,0,0 ; jmp [pubname]
			end if
		dllname#name#.rel1 dd xx,5+USE_COMPID ; --> public name
			dw IMAGE_REL_I386_DIR32
		dllname#name#.rel2 dd 80000000h+ordinal_value
	end if
dllname#name#.symbol_table:
	addcompid
	db '.text',0,0,0
	dd 0,1
	db IMAGE_SYM_CLASS_STATIC,1
	dd 6,1,0
	dw 0
	dd IMAGE_COMDAT_SELECT_NODUPLICATES
	dd 0,dllname#name#.thunkname-dllname#name#.strtbl,0
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
		dd dllname#name#.symbol_table-dllname#name#.data3,0,0
		dw 2
		dd IMAGE_COMDAT_SELECT_ASSOCIATIVE
	end if
	dd 0,dllname#name#.strtbl_2-dllname#name#.strtbl,0,0
	dw IMAGE_SYM_CLASS_EXTERNAL
dllname#name#.strtbl dd dllname#name#.strtbl_end-$
dllname#name#.publicname:
if pubname eqtype 0
	db `pubname,0
	dllname#name#.thunkname db '_PB_',`pb_name,0
else
	db '__imp_',`name,0
	dllname#name#.thunkname:
	if pb_name eqtype 0
		db '_PB_',`pb_name,0
	else
		db '_PB_',`name,0
	end if
end if
dllname#name#.strtbl_2 db '__IMPORT_DESCRIPTOR_'
	times namelen+1 db 0
	do_cpy dllname#.descr_dllname,dllname#name#.strtbl_2+20,namelen
dllname#name#.strtbl_end:
	add2dir dllname#name#.thunkname,dllname#name#.strtbl_2-dllname#name#.thunkname
	add2dir dllname#name#.publicname,dllname#name#.thunkname-dllname#name#.publicname
}

macro vbimplib module,dllname,cconv,argcount,name,vb_name,pubname{
	if RENAME_AR_MEMBERS
		RENAME_AR_MEMBERS equ 0
		display '-WNG: RENAME_AR_MEMBERS is ignored, it is not compatible with VB.',13,10
	end if
	if argcount>31 | argcount<0
		argcount=0
		display '-WNG: [argcount] should be in the range [0..31]. Defaulting to 0.',13,10
	end if
	if cconv>PBCALL | cconv<STDCALL
		display '-WNG: [cconv] has an invalid value. Defaulting to STDCALL.',13,10
	end if
	islongname dllname
	syms=syms+1
	longname=1
	if dllnamelen<16
		longname=0
	end if
	if ~defined dllname#.alreadydefined

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
		pack_sz (dllname#.descr_strtbl_end-dllname#.descr)
	dllname#.descr:
		dw IMAGE_FILE_MACHINE_I386,2
		dd %t,dllname#.descr_sym_tbl-dllname#.descr
		coffhdr
		dd dllname#.null_import_descr_data-dllname#.descr,dllname#.descr_rel-dllname#.descr
		dd 0,2+KEEP_ORIGINAL_THUNK,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		db '.idata$6'
		dd 0,0,(dllname#.null_import_descr_data-dllname#.descr_dllname+2) and -2,dllname#.descr_dllname-dllname#.descr,0
		dd 0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	dllname#.descr_dllname db `dllname
		do_cpy dllname#.descr_dllname,dllname_spot,dllnamelen
	dllname#.null_import_descr_data dq 0,0
		if KEEP_ORIGINAL_THUNK
		dllname#.descr_rel:
			dd 0,3+USE_COMPID ; Import lookup table RVA (characteristics) --> .idata$4
			dw IMAGE_REL_I386_DIR32NB
		else
			dd 0
		dllname#.descr_rel:
		end if
		dd 12,2+USE_COMPID ; DLL name RVA --> .idata$6
		dw IMAGE_REL_I386_DIR32NB
		dd 16,3+USE_COMPID+KEEP_ORIGINAL_THUNK ; Import address table RVA (thunk table) --> .idata$5
		dw IMAGE_REL_I386_DIR32NB
	dllname#.descr_sym_tbl:
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
		dd 0,dllname#.descr_strtbl_1-dllname#.descr_strtbl,0,0
		dw IMAGE_SYM_CLASS_EXTERNAL
	dllname#.descr_strtbl dd dllname#.descr_strtbl_end-$
		db '__NULL_IMPORT_DESCRIPTOR',0
	dllname#.descr_strtbl2 db '__IMPORT_DESCRIPTOR_'
		times namelen+1 db 0
		do_cpy dllname#.descr_dllname,dllname#.descr_strtbl2+20,namelen
		add2dir dllname#.descr_strtbl2,$-dllname#.descr_strtbl2
		dllname#.descr_strtbl_1 db 07Fh
		times namelen db 0
		do_cpy dllname#.descr_dllname,dllname#.descr_strtbl_1+1,namelen
		db '_NULL_THUNK_DATA',0
	dllname#.descr_strtbl_end:

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
		pack_sz (dllname#.descr_strtbl2_end-dllname#.descr2)
	dllname#.descr2:
		dw IMAGE_FILE_MACHINE_I386,1+KEEP_ORIGINAL_THUNK
		dd %t,dllname#.descr_sym_tbl2-dllname#.descr2,1+USE_COMPID
		dw 0,IMAGE_FILE_32BIT_MACHINE
		db '.idata$5'
		dd 0,0,4,48,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		if KEEP_ORIGINAL_THUNK
			db '.idata$4'
			dd 0,0,4,88,0,0,0,IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		end if
	dllname#.descr_sym_tbl2:
		addcompid
		dd 0,4,0,1
		dw IMAGE_SYM_CLASS_EXTERNAL
		dd dllname#.descr_strtbl2_end-$
		dllname#.descr_strtbl3 db 07Fh
		times namelen db 0
		do_cpy dllname#.descr_dllname,dllname#.descr_strtbl3+1,namelen
		db '_NULL_THUNK_DATA',0
	dllname#.descr_strtbl2_end:
		add2dir dllname#.descr_strtbl3,$-dllname#.descr_strtbl3
		define dllname#.alreadydefined 1
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
	pack_sz (dllname#name#.strtbl_end-dllname#name#.lnk_memberN)
dllname#name#.lnk_memberN:
	chkordinal name
	dw IMAGE_FILE_MACHINE_I386,3+KEEP_ORIGINAL_THUNK-byordinal
	dd %t,dllname#name#.symbol_table-dllname#name#.lnk_memberN
	dd 9+KEEP_ORIGINAL_THUNK*2-byordinal*2+USE_COMPID
	dw 0,IMAGE_FILE_32BIT_MACHINE
	db '.text',0,0,0
	xx=6
	if cconv=CDECL & argcount>0
		xx=12+argcount*4
	end if
	if cconv=PBCALL & argcount>0
		xx=7
	end if
	dd 0,0,xx,dllname#name#.thunk-dllname#name#.lnk_memberN,dllname#name#.rel1-dllname#name#.lnk_memberN
	dd 0,1,IMAGE_CNT_CODE or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_EXECUTE
	db '.idata$5'
	dd 0,0,4,dllname#name#.rel2-dllname#name#.lnk_memberN
	if byordinal=0
		dd dllname#name#.rel2-dllname#name#.lnk_memberN,0,1
	else
		dd 0,0,0
	end if
	dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	if KEEP_ORIGINAL_THUNK
		db '.idata$4'
		dd 0,0,4,dllname#name#.rel2-dllname#name#.lnk_memberN
		if byordinal=0
			dd dllname#name#.rel2-dllname#name#.lnk_memberN,0,1
		else
			dd 0,0,0
		end if
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	end if
	xx=2
	if cconv=CDECL
		xx=2+argcount*4
	else if cconv=PBCALL & argcount>0
		xx=5
	end if
	if byordinal=0
		db '.idata$6'
		dd 0,0,dllname#name#.symbol_table-dllname#name#.data3
		dd dllname#name#.data3-dllname#name#.lnk_memberN,0,0,0
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_LNK_COMDAT or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
		dllname#name#.thunk:
			if cconv=CDECL
				if argcount>0
					times argcount db 0FFh,74h,24h,argcount*4 ; push [esp+argcount*4]
					dw 15FFh,0,0           ; call [pubname]
					db 83h,0C4h,argcount*4 ; add esp,argcount*4
					db 0C2h,argcount*4     ; +00 retn argcount*4
				else
					dw 25FFh               ; +00000000 jmp [pubname]
				end if
			else
				if cconv=PBCALL & argcount>0
					db 5Ah,58h,52h         ; pop edx / pop eax / push edx
				end if
				dw 25FFh                       ; +00000000 jmp [pubname]
			end if
		dllname#name#.rel2 dd 0
			dd 6+KEEP_ORIGINAL_THUNK*2+USE_COMPID ; --> .idata$6
			dw IMAGE_REL_I386_DIR32NB
		dllname#name#.rel1 dd xx,5+USE_COMPID ; --> public name
			db IMAGE_REL_I386_DIR32
		dllname#name#.data3 db 0,0,`name,0
			times ($-dllname#name#.data3) and 1 db 0
	else
		dllname#name#.thunk:
			if cconv=CDECL
				if argcount>0
					times argcount db 0FFh,74h,24h,argcount*4 ; push [esp+argcount*4]
					dw 15FFh,0,0           ; call [pubname]
					db 83h,0C4h,argcount*4 ; add esp,argcount*4
					db 0C2h,argcount*4,0   ; retn argcount*4
				else
					dw 25FFh,0,0           ; jmp [pubname]
				end if
			else
				if cconv=PBCALL &  argcount>0
					db 5Ah,58h,52h         ; pop edx / pop eax / push edx
				end if
				dw 25FFh,0,0                   ; jmp [pubname]
			end if
		dllname#name#.rel1 dd xx
			dd 5+USE_COMPID ; --> public name
			dw IMAGE_REL_I386_DIR32
		dllname#name#.rel2 dd 80000000h+ordinal_value
	end if
dllname#name#.symbol_table:
	addcompid
	db '.text',0,0,0
	dd 0,1
	db IMAGE_SYM_CLASS_STATIC,1
	dd 6,1,0
	dw 0
	dd IMAGE_COMDAT_SELECT_NODUPLICATES
	dd 0,dllname#name#.thunkname-dllname#name#.strtbl,0
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
		dd dllname#name#.symbol_table-dllname#name#.data3,0,0
		dw 2
		dd IMAGE_COMDAT_SELECT_ASSOCIATIVE
	end if
	dd 0,dllname#name#.strtbl_2-dllname#name#.strtbl,0,0
	dw IMAGE_SYM_CLASS_EXTERNAL
dllname#name#.strtbl dd dllname#name#.strtbl_end-$
dllname#name#.publicname:
if pubname eqtype 0
	db `pubname,0
else
	db '__imp_',`name,0
end if
dllname#name#.thunkname:
if vb_name eqtype 0
	db '?',`vb_name
else
	db '?',`name
end if
	db '@',`module,'@@AAGXXZ',0
dllname#name#.strtbl_2 db '__IMPORT_DESCRIPTOR_'
	times namelen+1 db 0
	do_cpy dllname#.descr_dllname,dllname#name#.strtbl_2+20,namelen
dllname#name#.strtbl_end:
	add2dir dllname#name#.thunkname,dllname#name#.strtbl_2-dllname#name#.thunkname
	add2dir dllname#name#.publicname,dllname#name#.thunkname-dllname#name#.publicname
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
		dd IMAGE_CNT_INITIALIZED_DATA or IMAGE_ALIGN_2BYTES or IMAGE_MEM_READ or IMAGE_MEM_WRITE
	null_imp_descr_data dq 0,0
		if USE_COMPID
			dd 0
		end if
	null_imp_descr_sym_tbl:
		addcompid
		dd 0,4,0,1
		db IMAGE_SYM_CLASS_EXTERNAL,0
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
		display '-WNG: If using 32-bit MS linker, error LNK1102 may appear when loading this library due to its size.',13,10
	end if
}
