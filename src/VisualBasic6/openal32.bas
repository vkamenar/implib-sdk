Attribute VB_Name = "openal32"
Const AL_NONE As Long = 0
Const AL_FALSE As Long = 0
Const AL_TRUE As Long = 1

' Indicate Source has relative coordinates
Const AL_SOURCE_RELATIVE As Long = &H202

' Directional source, inner cone angle, in degrees
' Range:   [0-360]
' Default: 360
Const AL_CONE_INNER_ANGLE As Long = &H1001

' Directional source, outer cone angle, in degrees
' Range:   [0-360]
' Default: 360
Const AL_CONE_OUTER_ANGLE As Long = &H1002

' Specify the pitch to be applied at source
' Range:   [0.5-2.0]
' Default: 1.0
Const AL_PITCH As Long = &H1003

' Specify the current location in 3D space
Const AL_POSITION As Long = &H1004

' Specify the current direction
Const AL_DIRECTION As Long = &H1005

' Specify the current velocity in 3D space
Const AL_VELOCITY As Long = &H1006

' Errors: No Error
Const AL_NO_ERROR As Long = 0

' Bad name paramater passed to AL call
Const AL_INVALID_NAME As Long = &HA001

' Invalid enum passed to AL call
Const AL_INVALID_ENUM As Long = &HA002

' Invalid value passed to AL call
Const AL_INVALID_VALUE As Long = &HA003

' Illegal call
Const AL_INVALID_OPERATION As Long = &HA004

' Requested operation resulted in AL running out of memory
Const AL_OUT_OF_MEMORY As Long = &HA005


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
