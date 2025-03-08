Attribute VB_Name = "vb6_openal"

Private Declare Function lstrlen Lib "kernel32" Alias "lstrlenA" (ByVal lpString As Any) As Long
Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (hpvDest As Any, hpvSource As Any, ByVal cbCopy As Long)

' Convert a VB6 string to a null terminated ASCII string (LPSTR)
Private Function BSTR2LPSTR(ByVal vbstr As String, ByRef b() As Byte) As Long
   b() = StrConv(vbstr & vbNullChar, vbFromUnicode)
   BSTR2LPSTR = VarPtr(b(0))
End Function

' Convert a null terminated ASCII string (LPSTR) to VB6 string
Private Function LPSTR2BSTR(ByVal lpsz As Long) As String
   If lpsz = 0 Then
      LPSTR2BSTR = vbNullString
   Else
      Dim x As Long
      x = lstrlen(lpsz)
      LPSTR2BSTR = String$(x, 0)
      CopyMemory ByVal StrPtr(LPSTR2BSTR), ByVal lpsz, x
      LPSTR2BSTR = StrConv(LPSTR2BSTR, vbUnicode)
      x = InStr(LPSTR2BSTR, vbNullChar)
      If x > 0 Then LPSTR2BSTR = Left$(LPSTR2BSTR, x - 1)
   End If
End Function

' Append the OpeanAL error code
Private Function OAerr(ByVal msg As String) As String
   OAerr = msg & vbCrLf & "Error: " & alGetError()
End Function

Public Sub Main()
   Dim device, context, source As Long
   Dim b() As Byte

   ' Open a handle to the default audio device
   device = openal32.alcOpenDevice(0)
   If device = 0 Then
      MsgBox OAerr("Failed to open the default device"), vbCritical
      Exit Sub
   End If

   ' Create a context
   context = openal32.alcCreateContext(device, 0)
   If context = 0 Then
      MsgBox OAerr("Failed to create the context"), vbCritical
      Exit Sub
   End If

   ' Make the context current
   If Not openal32.alcMakeContextCurrent(context) Then
      MsgBox OAerr("Failed to make context current"), vbCritical
   Else

      ' Test if XRAM is supported
      If alIsExtensionPresent(BSTR2LPSTR("EAX-RAM", b)) Then MsgBox "XRAM supported!"

      ' Generate and initialize the source
      openal32.alGenSources 1, source
      If openal32.alGetError() <> AL_NO_ERROR Then
         MsgBox "Failed to generate the source", vbCritical
      End If

      openal32.alcMakeContextCurrent 0
   End If
   openal32.alcDestroyContext context
   openal32.alcCloseDevice device
End Sub

