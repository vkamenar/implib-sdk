Attribute VB_Name = "openal32"
' This module represents the OpenAL (Open Audio Library) 32-bit API.
' The OpenAL constants and function prototypes are listed below.
' These constants and prototypes were ported from the original OpenAL SDK.

' At link time (when VB6 invokes the MS linker to generate the native executable), the VB6LINK tool included in
' the ImpLib SDK replaces this module with the OpenAL import library to link the executable to the openal32.dll.

' bad value
Const AL_INVALID As Long = -1

Const AL_NONE As Long = 0

' Boolean False
Const AL_FALSE As Long = 0

' Boolean True
Const AL_TRUE As Long = 1

' Indicate Source has relative coordinates
Const AL_SOURCE_RELATIVE As Long = &H202

' Directional source, inner cone angle, in degrees
Const AL_CONE_INNER_ANGLE As Long = &H1001

' Directional source, outer cone angle, in degrees
Const AL_CONE_OUTER_ANGLE As Long = &H1002

' Specify the pitch to be applied at source
Const AL_PITCH As Long = &H1003

' Specify the current location in 3D space
Const AL_POSITION As Long = &H1004

' Specify the current direction
Const AL_DIRECTION As Long = &H1005

' Specify the current velocity in 3D space
Const AL_VELOCITY As Long = &H1006

' Indicate whether source is looping
Const AL_LOOPING As Long = &H1007

' Indicate the buffer to provide sound samples
Const AL_BUFFER As Long = &H1009

' Indicate the gain (volume amplification) applied
Const AL_GAIN As Long = &H100A

' Indicate minimum source attenuation
Const AL_MIN_GAIN As Long = &H100D

' Indicate maximum source attenuation
Const AL_MAX_GAIN As Long = &H100E

' Indicate listener orientation
Const AL_ORIENTATION As Long = &H100F

' Specify the channel mask (Creative)
Const AL_CHANNEL_MASK As Long = &H3000

' Source state information
Const AL_SOURCE_STATE As Long = &H1010
Const AL_INITIAL As Long = &H1011
Const AL_PLAYING As Long = &H1012
Const AL_PAUSED As Long = &H1013
Const AL_STOPPED As Long = &H1014

' Buffer queue params
Const AL_BUFFERS_QUEUED As Long = &H1015
Const AL_BUFFERS_PROCESSED As Long = &H1016

' Source buffer position information
Const AL_SEC_OFFSET As Long = &H1024
Const AL_SAMPLE_OFFSET As Long = &H1025
Const AL_BYTE_OFFSET As Long = &H1026

' Source type: static, streaming or undetermined
' Source is static if a buffer has been attached using AL_BUFFER
' Source is streaming if one or more buffers have been attached using alSourceQueueBuffers
' Source is undetermined when it has the NULL buffer attached
Const AL_SOURCE_TYPE As Long = &H1027
Const AL_STATIC As Long = &H1028
Const AL_STREAMING As Long = &H1029
Const AL_UNDETERMINED As Long = &H1030

' Sound samples: format specifier
Const AL_FORMAT_MONO8 As Long = &H1100
Const AL_FORMAT_MONO16 As Long = &H1101
Const AL_FORMAT_STEREO8 As Long = &H1102
Const AL_FORMAT_STEREO16 As Long = &H1103

' Source specific reference distance
Const AL_REFERENCE_DISTANCE As Long = &H1020

' Source specific rolloff factor
Const AL_ROLLOFF_FACTOR As Long = &H1021

' Directional source, outer cone gain
Const AL_CONE_OUTER_GAIN As Long = &H1022

' Indicate distance above which sources are not attenuated using the inverse clamped distance model
Const AL_MAX_DISTANCE As Long = &H1023

' Sound samples per second: frequency, in units of Hertz [Hz]
' Half of the sample frequency marks the maximum significant frequency component
Const AL_FREQUENCY As Long = &H2001

Const AL_BITS As Long = &H2002
Const AL_CHANNELS As Long = &H2003
Const AL_SIZE As Long = &H2004

' Buffer state
Const AL_UNUSED As Long = &H2010
Const AL_PENDING As Long = &H2011
Const AL_PROCESSED As Long = &H2012

' Errors: No Error
Const AL_NO_ERROR As Long = AL_FALSE

' Invalid name paramater passed to AL call
Const AL_INVALID_NAME As Long = &HA001

' Invalid enum passed to AL call
Const AL_ILLEGAL_ENUM As Long = &HA002
Const AL_INVALID_ENUM As Long = &HA002

' Invalid value passed to AL call
Const AL_INVALID_VALUE As Long = &HA003

' Illegal call
Const AL_ILLEGAL_COMMAND As Long = &HA004
Const AL_INVALID_OPERATION As Long = &HA004

' Requested operation resulted in AL running out of memory
Const AL_OUT_OF_MEMORY As Long = &HA005

' Context strings: Vendor Name
Const AL_VENDOR As Long = &HB001

Const AL_VERSION As Long = &HB002
Const AL_RENDERER As Long = &HB003
Const AL_EXTENSIONS As Long = &HB004

' Global tweakage

' Doppler scale
Const AL_DOPPLER_FACTOR As Long = &HC000

' Tweaks speed of propagation
Const AL_DOPPLER_VELOCITY As Long = &HC001

' Speed of sound in units per second
Const AL_SPEED_OF_SOUND As Long = &HC003

' Distance models
Const AL_DISTANCE_MODEL As Long = &HD000
Const AL_INVERSE_DISTANCE As Long = &HD001
Const AL_INVERSE_DISTANCE_CLAMPED As Long = &HD002
Const AL_LINEAR_DISTANCE As Long = &HD003
Const AL_LINEAR_DISTANCE_CLAMPED As Long = &HD004
Const AL_EXPONENT_DISTANCE As Long = &HD005
Const AL_EXPONENT_DISTANCE_CLAMPED As Long = &HD006

' Enable a feature of the OpenAL driver
' Note: There are no capabilities in OpenAL 1.1 to be used with this function, but it may be used by an extension
Sub alEnable(ByVal capability As Long)
End Sub

' Disable a feature of the OpenAL driver
' Note: There are no capabilities in OpenAL 1.1 to be used with this function, but it may be used by an extension
Sub alDisable(ByVal capability As Long)
End Sub

' Return a boolean indicating if a specific feature is enabled in the OpenAL driver
' Note: There are no capabilities in OpenAL 1.1 to be used with this function, but it may be used by an extension
Function alIsEnabled(ByVal capability As Long) As Boolean
End Function

Sub alGenBuffers(ByVal n As Long, ByRef bufferNames As Integer)
End Sub

Sub alDeleteBuffers(ByVal n As Long, ByRef bufferNames As Integer)
End Sub

Function alIsBuffer(ByVal bufferName As Integer) As Boolean
End Function

Function alcGetString(ByRef deviceHandle As Integer, ByVal token As Long) As String
End Function

' Open a device by name
Function alcOpenDevice(ByVal devicename As String) As Long
End Function

' Close a device by name
Function alcCloseDevice(ByVal device As Long) As Boolean
End Function

' Query if a specified context extension is available
Function alcIsExtensionPresent(ByVal device As Long, ByVal extName As String) As Boolean
End Function

' Return the current error state and then clear the error state
Function alGetError() As Long
End Function

' Create a context using a specified device
Function alcCreateContext(ByVal device As Long, ByVal sttrlist As Long) As Long
End Function

' Destroy a context
Sub alcDestroyContext(ByVal context As Long)
End Sub

' Make a specified context the current context
Function alcMakeContextCurrent(ByVal context As Long) As Boolean
End Function

' Generate one or more sources
Sub alGenSources(ByVal n As Long, ByRef sources As Long)
End Sub
