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
Private Function OAerr(ByVal msg As String, Optional err As Long = -1) As String
   If err = -1 Then err = alGetError()
   OAerr = msg & vbCrLf & "Error: " & err
End Function

Public Sub Main()
   Dim err As Long, device As Long, context As Long, source As Long, buffer As Long, b() As Byte

   device = openal32.alcOpenDevice(0) ' Open a handle to the default audio device
   If device = 0 Then
      MsgBox OAerr("Failed to open the default device"), vbCritical
      Exit Sub
   End If
   context = openal32.alcCreateContext(device, 0) ' Create a context
   If context = 0 Then
      MsgBox OAerr("Failed to create the context"), vbCritical
      Exit Sub
   End If
   ' Make the context current
   If Not openal32.alcMakeContextCurrent(context) Then
      MsgBox OAerr("Failed to make context current"), vbCritical
   Else

      ' Test if XRAM is supported
      ' If alIsExtensionPresent(BSTR2LPSTR("EAX-RAM", b)) Then MsgBox "XRAM supported!"

      openal32.alGenSources 1, source ' Generate and initialize the source
      err = openal32.alGetError()
      If err <> AL_NO_ERROR Then
         MsgBox OAerr("Failed to generate the source", err), vbCritical
      Else

         ' Modify the source properties: pitch, gain, position, velocity and looping
         ' openal32.alSourcef source, AL_PITCH, 1
         ' openal32.alSourcef source, AL_GAIN, 1
         ' openal32.alSource3f source, AL_POSITION, 0, 0, 0
         ' openal32.alSource3f source, AL_VELOCITY, 0, 0, 0
         openal32.alSourcei source, AL_LOOPING, AL_TRUE ' Enable looping
         err = openal32.alGetError()
         If err <> AL_NO_ERROR Then MsgBox OAerr("Failed to configure the source", err)

         openal32.alGenBuffers 1, buffer ' Create the buffer to hold the raw audio stream
         err = openal32.alGetError()
         If err <> AL_NO_ERROR Then
            MsgBox OAerr("Failed to create the buffer", err), vbCritical
         Else

            ' Generate a 16-bit sive wave (PCM format)
            Dim wav(1000) As Integer, T As Long, L As Long, SR As Long, F As Double
            SR = 22000
            L = UBound(wav)
            F = (2 * 3.14159265358979 * 440) / SR
            For T = 0 To L
               wav(T) = 32700 * Sin(F * T)
            Next T

            ' Load the sine wave into the buffer
            openal32.alBufferData buffer, AL_FORMAT_MONO16, VarPtr(wav(0)), L, SR
            err = openal32.alGetError()
            If err <> AL_NO_ERROR Then
               MsgBox OAerr("Failed to load PCM data into the buffer", err), vbCritical
            Else
               openal32.alSourcei source, AL_BUFFER, buffer ' Bind the source with its buffer
               openal32.alSourcePlay source                 ' Start playing
               MsgBox "OpenAL test"
            End If
            alDeleteBuffers 1, buffer
         End If
         alDeleteSources 1, source
      End If
      openal32.alcMakeContextCurrent 0
   End If
   openal32.alcDestroyContext context
   openal32.alcCloseDevice device
End Sub
