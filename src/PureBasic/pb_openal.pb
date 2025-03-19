; This sample project shows how to use the OpenAL (Open Audio Library) API
; with PureBasic (32 and 64-bit). The ImpLib SDK compiles the import libraries
; for the OpenAL32 and OpenAL64 DLL. Then, the import libraries are converted
; to the User-Lib format using the PureBasic SDK.

; This project uses the device enumeration extension to locate all of the
; OpenAL devices on the user's system. The code also shows how to determine
; the capabilities of each device, including what version of OpenAL each
; device supports.

; Launch the batch file build.bat to build/rebuild the sample applications.

; Make sure you have OpenAL properly installed before running the program.
; You can download the redistributable OpenAL installer from the official
; OpenAL website:
;   https://www.openal.org/downloads/

; This example is also compatible with OpenAL Soft, an LGPL-licensed
; implementation of the OpenAL 3D API. The OpenAL Soft can be downloaded
; from the official website:
;   https://openal-soft.org/
; Note: When using OpenAL Soft, rename soft_oal.dll to either
;       openal32.dll (x86) or openal64.dll (x64).

; For more advanced samples refer to the PureBasic OpenAL SDK:
;   https://implib.sourceforge.io/PBOpenAL.htm

IncludeFile "openal.pbi"

OpenConsole()
PrintN("Hello!")

; Convert a PB string into ASCIIz
Procedure OALF_2ASCIIz(s$)
	*s = AllocateMemory(Len(s$) + 1)
	If *s : PokeS(*s, s$, -1, #PB_Ascii) : EndIf
	ProcedureReturn *s
EndProcedure

; Opens the specified OpenAL device
Procedure OALF_alcOpenDevice(devicename$)
	*DeviceName = OALF_2ASCIIz(devicename$)
	r = 0
	If *DeviceName
		r = alcOpenDevice(*DeviceName)
		FreeMemory(*DeviceName)
	EndIf
	ProcedureReturn r
EndProcedure

; Queries if a specified extension is available
Procedure OALF_alIsExtensionPresent(ext$)
	*Ext = OALF_2ASCIIz(ext$)
	r = #ALC_FALSE
	If *Ext
		r = alIsExtensionPresent(*Ext)
		FreeMemory(*Ext)
	EndIf
	ProcedureReturn r
EndProcedure

; Queries if a specified context extension is available
Procedure OALF_alcIsExtensionPresent(device, ext$)
	*Ext = OALF_2ASCIIz(ext$)
	r = #ALC_FALSE
	If *Ext
		r = alcIsExtensionPresent(device, *Ext)
		FreeMemory(*Ext)
	EndIf
	ProcedureReturn r
EndProcedure

; Fill a linked list with the available OpenAL devices names
NewList OALF_devices.s()
; Get a pointer to an array containing all the OpenAL available devices
; names, separated by single NULL characters and terminated with a bouble NULL
OALF_devices = alcGetString(0, #ALC_DEVICE_SPECIFIER)
; Does it support enumerating the available devices?
If OALF_alcIsExtensionPresent(0, "ALC_ENUMERATION_EXT") <> #ALC_FALSE And OALF_devices <> 0
	; Go through the array and add all its entries to our linked list.
	Repeat
		OALF_devices$ = PeekS(OALF_devices, -1, #PB_Ascii)
		OALF_i = Len(OALF_devices$)
		If OALF_i = 0 : Break : EndIf
		AddElement(OALF_devices())
		OALF_devices() = OALF_devices$
		OALF_devices + OALF_i + 1
	ForEver
EndIf
ResetList(OALF_devices())

; See if we have any available OpenAL devices
If ListSize(OALF_devices()) <> 0

	; List all the available OpenAL devices
	PrintN("All Available OpenAL Devices:")
	While NextElement(OALF_devices())
		list_item$ = " " + OALF_devices()
		xram_available = 0
		; Open the device and select a context to check the version info
		OAL_device = OALF_alcOpenDevice(OALF_devices())
		If OAL_device <> 0
			OAL_context = alcCreateContext(OAL_device, 0)
			If OAL_context <> 0
				alcMakeContextCurrent(OAL_context)
				iMajorVer.l = 0 : alcGetIntegerv(OAL_device, #ALC_MAJOR_VERSION, 4, @iMajorVer)
				iMinorVer.l = 0 : alcGetIntegerv(OAL_device, #ALC_MINOR_VERSION, 4, @iMinorVer)
				list_item$ + ", Spec Version " + Str(iMajorVer) + "." + Str(iMinorVer)
				; Check for XRAM support.
				If OALF_alIsExtensionPresent("EAX-RAM") <> #AL_FALSE : xram_available = 1 : EndIf
				alcMakeContextCurrent(0)
				alcDestroyContext(OAL_context)
			EndIf
			alcCloseDevice(OAL_device)
		EndIf
		PrintN(list_item$)
		If xram_available = 0 : DeleteElement(OALF_devices()) : EndIf
	Wend

	; Print the default device name
	defDev$ = ""
	PrintN("")
	defDevName = alcGetString(0, #ALC_DEFAULT_DEVICE_SPECIFIER)
	If defDevName <> 0
		defDev$ = PeekS(defDevName, -1, #PB_Ascii)
	EndIf
	PrintN("Default device: " + defDev$)

	; List the devices supporting XRAM
	PrintN("")
	PrintN("Devices with XRAM support:")
	If ListSize(OALF_devices()) = 0
		PrintN(" None")
	Else
		FirstElement(OALF_devices())
		Repeat
			PrintN(" " + OALF_devices())
		Until NextElement(OALF_devices()) = 0
	EndIf

Else
	; An empty device list means some kind of OpenAL error
	PrintN("-ERR: Could not initialize OpenAL")
EndIf

PrintN("")
Print("Press any key to exit")
Repeat
	If Inkey() <> ""
		Break
	Else
		Delay(50)
	EndIf
ForEver
CloseConsole()
End
