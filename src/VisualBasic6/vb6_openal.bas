Attribute VB_Name = "vb6_openal"
Public Sub Main()
   Dim device, context, source As Long

   ' Open a handle to the default audio device
   device = openal32.alcOpenDevice(vbNullString)
   If device = 0 Then
      MsgBox "Failed to open the default device", vbCritical
      Exit Sub
   End If

   ' Create and initialize a context
   context = openal32.alcCreateContext(device, 0)
   If Not openal32.alcMakeContextCurrent(context) Then
      MsgBox "Failed to make context current", vbCritical
   Else

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

