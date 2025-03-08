Attribute VB_Name = "openal32"
' This module represents the OpenAL (Open Audio Library) 32-bit API.
' The OpenAL constants and function prototypes are listed below.
' These constants and prototypes are based on the original OpenAL SDK v1.0/v1.1.

' At link time (when VB6 invokes the MS linker to generate the native executable), the VB6LINK tool included in
' the ImpLib SDK replaces this module with the OpenAL import library to link the executable to the openal32.dll.

' bad value
Const AL_INVALID As Long = -1
Const ALC_INVALID As Long = 0

Const AL_NONE As Long = 0

' Boolean False
Const AL_FALSE As Long = 0
Const ALC_FALSE As Long = 0

' Boolean True
Const AL_TRUE As Long = 1
Const ALC_TRUE As Long = 1

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
Const AL_NO_ERROR As Long = 0
Const ALC_NO_ERROR As Long = 0

' Invalid name paramater passed to AL call
Const AL_INVALID_NAME As Long = &HA001

' The specified device is not a valid output device
Const ALC_INVALID_DEVICE As Long = &HA001

' Invalid enum passed to AL call
Const AL_ILLEGAL_ENUM As Long = &HA002
Const AL_INVALID_ENUM As Long = &HA002
Const ALC_INVALID_ENUM As Long = &HA003

' The specified context is invalid
Const ALC_INVALID_CONTEXT As Long = &HA002

' Invalid value passed to AL call
Const AL_INVALID_VALUE As Long = &HA003
Const ALC_INVALID_VALUE As Long = &HA004

' Illegal call
Const AL_ILLEGAL_COMMAND As Long = &HA004
Const AL_INVALID_OPERATION As Long = &HA004

' Requested operation resulted in AL running out of memory
Const AL_OUT_OF_MEMORY As Long = &HA005
Const ALC_OUT_OF_MEMORY As Long = &HA005

' Context strings: Vendor Name
Const AL_VENDOR As Long = &HB001

Const AL_VERSION As Long = &HB002
Const AL_RENDERER As Long = &HB003
Const AL_EXTENSIONS As Long = &HB004

' *** Global tweakage

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

' Output frequency in Hz
Const ALC_FREQUENCY As Long = &H1007

' Rate of context processing
Const ALC_REFRESH As Long = &H1008

' Flag indicating a synchronous context
Const ALC_SYNC As Long = &H1009

' Num of requested mono (3D) sources
Const ALC_MONO_SOURCES As Long = &H1010

' Num of requested stereo sources
Const ALC_STEREO_SOURCES As Long = &H1011

' The name of the default output device
Const ALC_DEFAULT_DEVICE_SPECIFIER As Long = &H1004

' The name of the specified output device
Const ALC_DEVICE_SPECIFIER As Long = &H1005

' The available context extensions
Const ALC_EXTENSIONS As Long = &H1006

Const ALC_MAJOR_VERSION As Long = &H1000
Const ALC_MINOR_VERSION As Long = &H1001
Const ALC_ATTRIBUTES_SIZE As Long = &H1002
Const ALC_ALL_ATTRIBUTES As Long = &H1003

' Use with alcGetString with a NULL device ID to retrieve the name of the default device
Const ALC_DEFAULT_ALL_DEVICES_SPECIFIER As Long = &H1012

' Use with alcGetString and a NULL device pointer to retrieve the names of all devices and audio output paths
Const ALC_ALL_DEVICES_SPECIFIER As Long = &H1013

' Return the name of the specified capture device or a list of all available devices (if a NULL device pointer is supplied)
Const ALC_CAPTURE_DEVICE_SPECIFIER As Long = &H310

' Use with alcGetString with a NULL device ID to retrieve the name of the default capture device
Const ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER As Long = &H311

Const ALC_CAPTURE_SAMPLES As Long = &H312

' Context definitions to be used with alcCreateContext
Const ALC_EFX_MAJOR_VERSION As Long = &H20001
Const ALC_EFX_MINOR_VERSION As Long = &H20002
Const ALC_MAX_AUXILIARY_SENDS As Long = &H20003

' Listener definitions to be used with alListener functions
Const AL_METERS_PER_UNIT As Long = &H20004

' Source definitions to be used with alSource functions
Const AL_DIRECT_FILTER As Long = &H20005
Const AL_AUXILIARY_SEND_FILTER As Long = &H20006
Const AL_AIR_ABSORPTION_FACTOR As Long = &H20007
Const AL_ROOM_ROLLOFF_FACTOR As Long = &H20008
Const AL_CONE_OUTER_GAINHF As Long = &H20009
Const AL_DIRECT_FILTER_GAINHF_AUTO As Long = &H2000A
Const AL_AUXILIARY_SEND_FILTER_GAIN_AUTO As Long = &H2000B
Const AL_AUXILIARY_SEND_FILTER_GAINHF_AUTO As Long = &H2000C

' *** Effect object definitions to be used with alEffect functions

' Reverb parameters
Const AL_REVERB_DENSITY As Long = 1
Const AL_REVERB_DIFFUSION As Long = 2
Const AL_REVERB_GAIN As Long = 3
Const AL_REVERB_GAINHF As Long = 4
Const AL_REVERB_DECAY_TIME As Long = 5
Const AL_REVERB_DECAY_HFRATIO As Long = 6
Const AL_REVERB_REFLECTIONS_GAIN As Long = 7
Const AL_REVERB_REFLECTIONS_DELAY As Long = 8
Const AL_REVERB_LATE_REVERB_GAIN As Long = 9
Const AL_REVERB_LATE_REVERB_DELAY As Long = &HA
Const AL_REVERB_AIR_ABSORPTION_GAINHF As Long = &HB 
Const AL_REVERB_ROOM_ROLLOFF_FACTOR As Long = &HC
Const AL_REVERB_DECAY_HFLIMIT As Long = &HD

' Chorus parameters
Const AL_CHORUS_WAVEFORM As Long = 1
Const AL_CHORUS_PHASE As Long = 2
Const AL_CHORUS_RATE As Long = 3
Const AL_CHORUS_DEPTH As Long = 4
Const AL_CHORUS_FEEDBACK As Long = 5
Const AL_CHORUS_DELAY As Long = 6

' Distortion parameters
Const AL_DISTORTION_EDGE As Long = 1
Const AL_DISTORTION_GAIN As Long = 2
Const AL_DISTORTION_LOWPASS_CUTOFF As Long = 3
Const AL_DISTORTION_EQCENTER As Long = 4
Const AL_DISTORTION_EQBANDWIDTH As Long = 5

' Echo parameters
Const AL_ECHO_DELAY As Long = 1
Const AL_ECHO_LRDELAY As Long = 2
Const AL_ECHO_DAMPING As Long = 3
Const AL_ECHO_FEEDBACK As Long = 4
Const AL_ECHO_SPREAD As Long = 5

' Flanger parameters
Const AL_FLANGER_WAVEFORM As Long = 1
Const AL_FLANGER_PHASE As Long = 2
Const AL_FLANGER_RATE As Long = 3
Const AL_FLANGER_DEPTH As Long = 4
Const AL_FLANGER_FEEDBACK As Long = 5
Const AL_FLANGER_DELAY As Long = 6

' Frequencyshifter parameters
Const AL_FREQUENCY_SHIFTER_FREQUENCY As Long = 1
Const AL_FREQUENCY_SHIFTER_LEFT_DIRECTION As Long = 2
Const AL_FREQUENCY_SHIFTER_RIGHT_DIRECTION As Long = 3

' Vocalmorpher parameters
Const AL_VOCAL_MORPHER_PHONEMEA As Long = 1
Const AL_VOCAL_MORPHER_PHONEMEA_COARSE_TUNING As Long = 2
Const AL_VOCAL_MORPHER_PHONEMEB As Long = 3
Const AL_VOCAL_MORPHER_PHONEMEB_COARSE_TUNING As Long = 4
Const AL_VOCAL_MORPHER_WAVEFORM As Long = 5
Const AL_VOCAL_MORPHER_RATE As Long = 6

' Pitchshifter parameters
Const AL_PITCH_SHIFTER_COARSE_TUNE As Long = 1
Const AL_PITCH_SHIFTER_FINE_TUNE As Long = 2

' Ringmodulator parameters
Const AL_RING_MODULATOR_FREQUENCY As Long = 1
Const AL_RING_MODULATOR_HIGHPASS_CUTOFF As Long = 2
Const AL_RING_MODULATOR_WAVEFORM As Long = 3

' Autowah parameters
Const AL_AUTOWAH_ATTACK_TIME As Long = 1
Const AL_AUTOWAH_RELEASE_TIME As Long = 2
Const AL_AUTOWAH_RESONANCE As Long = 3
Const AL_AUTOWAH_PEAK_GAIN As Long = 4

' Compressor parameters
Const AL_COMPRESSOR_ONOFF As Long = 1

' Equalizer parameters
Const AL_EQUALIZER_LOW_GAIN As Long = 1
Const AL_EQUALIZER_LOW_CUTOFF As Long = 2
Const AL_EQUALIZER_MID1_GAIN As Long = 3
Const AL_EQUALIZER_MID1_CENTER As Long = 4
Const AL_EQUALIZER_MID1_WIDTH As Long = 5
Const AL_EQUALIZER_MID2_GAIN As Long = 6
Const AL_EQUALIZER_MID2_CENTER As Long = 7
Const AL_EQUALIZER_MID2_WIDTH As Long = 8
Const AL_EQUALIZER_HIGH_GAIN As Long = 9
Const AL_EQUALIZER_HIGH_CUTOFF As Long = &HA

' Effect type
Const AL_EFFECT_FIRST_PARAMETER As Long = 0
Const AL_EFFECT_LAST_PARAMETER As Long = &H8000
Const AL_EFFECT_TYPE As Long = &H8001

' Effect type definitions to be used with AL_EFFECT_TYPE
Const AL_EFFECT_NULL As Long = 0 ' Can also be used as an Effect Object ID
Const AL_EFFECT_REVERB As Long = 1
Const AL_EFFECT_CHORUS As Long = 2
Const AL_EFFECT_DISTORTION As Long = 3
Const AL_EFFECT_ECHO As Long = 4
Const AL_EFFECT_FLANGER As Long = 5
Const AL_EFFECT_FREQUENCY_SHIFTER As Long = 6
Const AL_EFFECT_VOCAL_MORPHER As Long = 7
Const AL_EFFECT_PITCH_SHIFTER As Long = 8
Const AL_EFFECT_RING_MODULATOR As Long = 9
Const AL_EFFECT_AUTOWAH As Long = &HA
Const AL_EFFECT_COMPRESSOR As Long = &HB
Const AL_EFFECT_EQUALIZER As Long = &HC

' Auxiliary Slot object definitions to be used with alAuxiliaryEffectSlot functions
Const AL_EFFECTSLOT_EFFECT As Long = 1
Const AL_EFFECTSLOT_GAIN As Long = 2
Const AL_EFFECTSLOT_AUXILIARY_SEND_AUTO As Long = 3

' Value to be used as an Auxiliary Slot ID to disable a source send
Const AL_EFFECTSLOT_NULL As Long = 0

' *** Filter object definitions to be used with alFilter functions

' Lowpass parameters
Const AL_LOWPASS_GAIN As Long = 1
Const AL_LOWPASS_GAINHF As Long = 2

' Highpass parameters
Const AL_HIGHPASS_GAIN As Long = 1
Const AL_HIGHPASS_GAINLF As Long = 2

' Bandpass parameters
Const AL_BANDPASS_GAIN As Long = 1
Const AL_BANDPASS_GAINLF As Long = 2
Const AL_BANDPASS_GAINHF As Long = 3

' Filter type
Const AL_FILTER_FIRST_PARAMETER As Long = 0
Const AL_FILTER_LAST_PARAMETER As Long = &H8000
Const AL_FILTER_TYPE As Long = &H8001

' Filter type definitions to be used with AL_FILTER_TYPE
Const AL_FILTER_NULL As Long = 0 ' Can also be used as a Filter Object ID
Const AL_FILTER_LOWPASS As Long = 1
Const AL_FILTER_HIGHPASS As Long = 2
Const AL_FILTER_BANDPASS As Long = 3

' *** Filter ranges and defaults

' Lowpass filter
Const LOWPASS_MIN_GAIN As Single = 0.0
Const LOWPASS_MAX_GAIN As Single = 1.0
Const LOWPASS_DEFAULT_GAIN As Single = 1.0
Const LOWPASS_MIN_GAINHF As Single = 0.0
Const LOWPASS_MAX_GAINHF As Single = 1.0
Const LOWPASS_DEFAULT_GAINHF As Single = 1.0

' Highpass filter
Const HIGHPASS_MIN_GAIN As Single = 0.0
Const HIGHPASS_MAX_GAIN As Single = 1.0
Const HIGHPASS_DEFAULT_GAIN As Single = 1.0
Const HIGHPASS_MIN_GAINLF As Single = 0.0
Const HIGHPASS_MAX_GAINLF As Single = 1.0
Const HIGHPASS_DEFAULT_GAINLF As Single = 1.0

' Bandpass filter
Const BANDPASS_MIN_GAIN As Single = 0.0
Const BANDPASS_MAX_GAIN As Single = 1.0
Const BANDPASS_DEFAULT_GAIN As Single = 1.0
Const BANDPASS_MIN_GAINHF As Single = 0.0
Const BANDPASS_MAX_GAINHF As Single = 1.0
Const BANDPASS_DEFAULT_GAINHF As Single = 1.0
Const BANDPASS_MIN_GAINLF As Single = 0.0
Const BANDPASS_MAX_GAINLF As Single = 1.0
Const BANDPASS_DEFAULT_GAINLF As Single = 1.0

' *** Effect parameter structures, value definitions, ranges and defaults

' AL reverb effect parameter ranges and defaults
Const AL_REVERB_MIN_DENSITY As Single = 0.0
Const AL_REVERB_MAX_DENSITY As Single = 1.0
Const AL_REVERB_DEFAULT_DENSITY As Single = 1.0
Const AL_REVERB_MIN_DIFFUSION As Single = 0.0
Const AL_REVERB_MAX_DIFFUSION As Single = 1.0
Const AL_REVERB_DEFAULT_DIFFUSION As Single = 1.0
Const AL_REVERB_MIN_GAIN As Single = 0.0
Const AL_REVERB_MAX_GAIN As Single = 1.0
Const AL_REVERB_DEFAULT_GAIN As Single = 0.32
Const AL_REVERB_MIN_GAINHF As Single = 0.0
Const AL_REVERB_MAX_GAINHF As Single = 1.0
Const AL_REVERB_DEFAULT_GAINHF As Single = 0.89
Const AL_REVERB_MIN_DECAY_TIME As Single = 0.1
Const AL_REVERB_MAX_DECAY_TIME As Single = 20.0
Const AL_REVERB_DEFAULT_DECAY_TIME As Single = 1.49
Const AL_REVERB_MIN_DECAY_HFRATIO As Single = 0.1
Const AL_REVERB_MAX_DECAY_HFRATIO As Single = 2.0
Const AL_REVERB_DEFAULT_DECAY_HFRATIO As Single = 0.83
Const AL_REVERB_MIN_REFLECTIONS_GAIN As Single = 0.0
Const AL_REVERB_MAX_REFLECTIONS_GAIN As Single = 3.16
Const AL_REVERB_DEFAULT_REFLECTIONS_GAIN As Single = 0.05
Const AL_REVERB_MIN_REFLECTIONS_DELAY As Single = 0.0
Const AL_REVERB_MAX_REFLECTIONS_DELAY As Single = 0.3
Const AL_REVERB_DEFAULT_REFLECTIONS_DELAY As Single = 0.007
Const AL_REVERB_MIN_LATE_REVERB_GAIN As Single = 0.0
Const AL_REVERB_MAX_LATE_REVERB_GAIN As Single = 10.0
Const AL_REVERB_DEFAULT_LATE_REVERB_GAIN As Single = 1.26
Const AL_REVERB_MIN_LATE_REVERB_DELAY As Single = 0.0
Const AL_REVERB_MAX_LATE_REVERB_DELAY As Single = 0.1
Const AL_REVERB_DEFAULT_LATE_REVERB_DELAY As Single = 0.011
Const AL_REVERB_MIN_AIR_ABSORPTION_GAINHF As Single = 0.892
Const AL_REVERB_MAX_AIR_ABSORPTION_GAINHF As Single = 1.0
Const AL_REVERB_DEFAULT_AIR_ABSORPTION_GAINHF As Single = 0.994
Const AL_REVERB_MIN_ROOM_ROLLOFF_FACTOR As Single = 0.0
Const AL_REVERB_MAX_ROOM_ROLLOFF_FACTOR As Single = 10.0
Const AL_REVERB_DEFAULT_ROOM_ROLLOFF_FACTOR As Single = 0.0
Const AL_REVERB_MIN_DECAY_HFLIMIT As Long = 0
Const AL_REVERB_MAX_DECAY_HFLIMIT As Long = 1
Const AL_REVERB_DEFAULT_DECAY_HFLIMIT As Long = 1

' AL chorus effect parameter ranges and defaults
Const AL_CHORUS_MIN_WAVEFORM As Long = 0
Const AL_CHORUS_MAX_WAVEFORM As Long = 1
Const AL_CHORUS_DEFAULT_WAVEFORM As Long = 1
Const AL_CHORUS_WAVEFORM_SINUSOID As Long = 0
Const AL_CHORUS_WAVEFORM_TRIANGLE As Long = 1
Const AL_CHORUS_MIN_PHASE As Long = -180
Const AL_CHORUS_MAX_PHASE As Long = 180
Const AL_CHORUS_DEFAULT_PHASE As Long = 90
Const AL_CHORUS_MIN_RATE As Single = 0.0
Const AL_CHORUS_MAX_RATE As Single = 10.0
Const AL_CHORUS_DEFAULT_RATE As Single = 1.1
Const AL_CHORUS_MIN_DEPTH As Single = 0.0
Const AL_CHORUS_MAX_DEPTH As Single = 1.0
Const AL_CHORUS_DEFAULT_DEPTH As Single = 0.1
Const AL_CHORUS_MIN_FEEDBACK As Single = -1.0
Const AL_CHORUS_MAX_FEEDBACK As Single = 1.0
Const AL_CHORUS_DEFAULT_FEEDBACK As Single = 0.25
Const AL_CHORUS_MIN_DELAY As Single = 0.0
Const AL_CHORUS_MAX_DELAY As Single = 0.016
Const AL_CHORUS_DEFAULT_DELAY As Single = 0.016

' AL distortion effect parameter ranges and defaults
Const AL_DISTORTION_MIN_EDGE As Single = 0.0
Const AL_DISTORTION_MAX_EDGE As Single = 1.0
Const AL_DISTORTION_DEFAULT_EDGE As Single = 0.2
Const AL_DISTORTION_MIN_GAIN As Single = 0.01
Const AL_DISTORTION_MAX_GAIN As Single = 1.0
Const AL_DISTORTION_DEFAULT_GAIN As Single = 0.05
Const AL_DISTORTION_MIN_LOWPASS_CUTOFF As Single = 80.0
Const AL_DISTORTION_MAX_LOWPASS_CUTOFF As Single = 24000.0
Const AL_DISTORTION_DEFAULT_LOWPASS_CUTOFF As Single = 8000.0
Const AL_DISTORTION_MIN_EQCENTER As Single = 80.0
Const AL_DISTORTION_MAX_EQCENTER As Single = 24000.0
Const AL_DISTORTION_DEFAULT_EQCENTER As Single = 3600.0
Const AL_DISTORTION_MIN_EQBANDWIDTH As Single = 80.0
Const AL_DISTORTION_MAX_EQBANDWIDTH As Single = 24000.0
Const AL_DISTORTION_DEFAULT_EQBANDWIDTH As Single = 3600.0

' AL echo effect parameter ranges and defaults
Const AL_ECHO_MIN_DELAY As Single = 0.0
Const AL_ECHO_MAX_DELAY As Single = 0.207
Const AL_ECHO_DEFAULT_DELAY As Single = 0.1
Const AL_ECHO_MIN_LRDELAY As Single = 0.0
Const AL_ECHO_MAX_LRDELAY As Single = 0.404
Const AL_ECHO_DEFAULT_LRDELAY As Single = 0.1
Const AL_ECHO_MIN_DAMPING As Single = 0.0
Const AL_ECHO_MAX_DAMPING As Single = 0.99
Const AL_ECHO_DEFAULT_DAMPING As Single = 0.5
Const AL_ECHO_MIN_FEEDBACK As Single = 0.0
Const AL_ECHO_MAX_FEEDBACK As Single = 1.0
Const AL_ECHO_DEFAULT_FEEDBACK As Single = 0.5
Const AL_ECHO_MIN_SPREAD As Single = -1.0
Const AL_ECHO_MAX_SPREAD As Single = 1.0
Const AL_ECHO_DEFAULT_SPREAD As Single = -1.0

' AL flanger effect parameter ranges and defaults
Const AL_FLANGER_MIN_WAVEFORM As Long = 0
Const AL_FLANGER_MAX_WAVEFORM As Long = 1
Const AL_FLANGER_DEFAULT_WAVEFORM As Long = 1
Const AL_FLANGER_WAVEFORM_SINUSOID As Long = 0
Const AL_FLANGER_WAVEFORM_TRIANGLE As Long = 1
Const AL_FLANGER_MIN_PHASE As Long = -180
Const AL_FLANGER_MAX_PHASE As Long = 180
Const AL_FLANGER_DEFAULT_PHASE As Long = 0
Const AL_FLANGER_MIN_RATE As Single = 0.0
Const AL_FLANGER_MAX_RATE As Single = 10.0
Const AL_FLANGER_DEFAULT_RATE As Single = 0.27
Const AL_FLANGER_MIN_DEPTH As Single = 0.0
Const AL_FLANGER_MAX_DEPTH As Single = 1.0
Const AL_FLANGER_DEFAULT_DEPTH As Single = 1.0
Const AL_FLANGER_MIN_FEEDBACK As Single = -1.0
Const AL_FLANGER_MAX_FEEDBACK As Single = 1.0
Const AL_FLANGER_DEFAULT_FEEDBACK As Single = -0.5
Const AL_FLANGER_MIN_DELAY As Single = 0.0
Const AL_FLANGER_MAX_DELAY As Single = 0.004
Const AL_FLANGER_DEFAULT_DELAY As Single = 0.002

' AL frequency shifter effect parameter ranges and defaults
Const AL_FREQUENCY_SHIFTER_MIN_FREQUENCY As Single = 0.0
Const AL_FREQUENCY_SHIFTER_MAX_FREQUENCY As Single = 24000.0
Const AL_FREQUENCY_SHIFTER_DEFAULT_FREQUENCY As Single = 0.0
Const AL_FREQUENCY_SHIFTER_MIN_LEFT_DIRECTION As Long = 0
Const AL_FREQUENCY_SHIFTER_MAX_LEFT_DIRECTION As Long = 2
Const AL_FREQUENCY_SHIFTER_DEFAULT_LEFT_DIRECTION As Long = 0
Const AL_FREQUENCY_SHIFTER_MIN_RIGHT_DIRECTION As Long = 0
Const AL_FREQUENCY_SHIFTER_MAX_RIGHT_DIRECTION As Long = 2
Const AL_FREQUENCY_SHIFTER_DEFAULT_RIGHT_DIRECTION As Long = 0
Const AL_FREQUENCY_SHIFTER_DIRECTION_DOWN As Long = 0
Const AL_FREQUENCY_SHIFTER_DIRECTION_UP As Long = 1
Const AL_FREQUENCY_SHIFTER_DIRECTION_OFF As Long = 2

' AL vocal morpher effect parameter ranges and defaults
Const AL_VOCAL_MORPHER_MIN_PHONEMEA As Long = 0
Const AL_VOCAL_MORPHER_MAX_PHONEMEA As Long = 29
Const AL_VOCAL_MORPHER_DEFAULT_PHONEMEA As Long = 0
Const AL_VOCAL_MORPHER_MIN_PHONEMEA_COARSE_TUNING As Long = -24
Const AL_VOCAL_MORPHER_MAX_PHONEMEA_COARSE_TUNING As Long = 24
Const AL_VOCAL_MORPHER_DEFAULT_PHONEMEA_COARSE_TUNING As Long = 0
Const AL_VOCAL_MORPHER_MIN_PHONEMEB As Long = 0
Const AL_VOCAL_MORPHER_MAX_PHONEMEB As Long = 29
Const AL_VOCAL_MORPHER_DEFAULT_PHONEMEB As Long = 10
Const AL_VOCAL_MORPHER_PHONEME_A As Long = 0
Const AL_VOCAL_MORPHER_PHONEME_E As Long = 1
Const AL_VOCAL_MORPHER_PHONEME_I As Long = 2
Const AL_VOCAL_MORPHER_PHONEME_O As Long = 3
Const AL_VOCAL_MORPHER_PHONEME_U As Long = 4
Const AL_VOCAL_MORPHER_PHONEME_AA As Long = 5
Const AL_VOCAL_MORPHER_PHONEME_AE As Long = 6
Const AL_VOCAL_MORPHER_PHONEME_AH As Long = 7
Const AL_VOCAL_MORPHER_PHONEME_AO As Long = 8
Const AL_VOCAL_MORPHER_PHONEME_EH As Long = 9
Const AL_VOCAL_MORPHER_PHONEME_ER As Long = 10
Const AL_VOCAL_MORPHER_PHONEME_IH As Long = 11
Const AL_VOCAL_MORPHER_PHONEME_IY As Long = 12
Const AL_VOCAL_MORPHER_PHONEME_UH As Long = 13
Const AL_VOCAL_MORPHER_PHONEME_UW As Long = 14
Const AL_VOCAL_MORPHER_PHONEME_B As Long = 15
Const AL_VOCAL_MORPHER_PHONEME_D As Long = 16
Const AL_VOCAL_MORPHER_PHONEME_F As Long = 17
Const AL_VOCAL_MORPHER_PHONEME_G As Long = 18
Const AL_VOCAL_MORPHER_PHONEME_J As Long = 19
Const AL_VOCAL_MORPHER_PHONEME_K As Long = 20
Const AL_VOCAL_MORPHER_PHONEME_L As Long = 21
Const AL_VOCAL_MORPHER_PHONEME_M As Long = 22
Const AL_VOCAL_MORPHER_PHONEME_N As Long = 23
Const AL_VOCAL_MORPHER_PHONEME_P As Long = 24
Const AL_VOCAL_MORPHER_PHONEME_R As Long = 25
Const AL_VOCAL_MORPHER_PHONEME_S As Long = 26
Const AL_VOCAL_MORPHER_PHONEME_T As Long = 27
Const AL_VOCAL_MORPHER_PHONEME_V As Long = 28
Const AL_VOCAL_MORPHER_PHONEME_Z As Long = 29
Const AL_VOCAL_MORPHER_MIN_PHONEMEB_COARSE_TUNING As Long = -24
Const AL_VOCAL_MORPHER_MAX_PHONEMEB_COARSE_TUNING As Long = 24
Const AL_VOCAL_MORPHER_DEFAULT_PHONEMEB_COARSE_TUNING As Long = 0
Const AL_VOCAL_MORPHER_MIN_WAVEFORM As Long = 0
Const AL_VOCAL_MORPHER_MAX_WAVEFORM As Long = 2
Const AL_VOCAL_MORPHER_DEFAULT_WAVEFORM As Long = 0
Const AL_VOCAL_MORPHER_WAVEFORM_SINUSOID As Long = 0
Const AL_VOCAL_MORPHER_WAVEFORM_TRIANGLE As Long = 1
Const AL_VOCAL_MORPHER_WAVEFORM_SAWTOOTH As Long = 2
Const AL_VOCAL_MORPHER_MIN_RATE As Single = 0.0
Const AL_VOCAL_MORPHER_MAX_RATE As Single = 10.0
Const AL_VOCAL_MORPHER_DEFAULT_RATE As Single = 1.41

' AL pitch shifter effect parameter ranges and defaults
Const AL_PITCH_SHIFTER_MIN_COARSE_TUNE As Long = -12
Const AL_PITCH_SHIFTER_MAX_COARSE_TUNE As Long = 12
Const AL_PITCH_SHIFTER_DEFAULT_COARSE_TUNE As Long = 12
Const AL_PITCH_SHIFTER_MIN_FINE_TUNE As Long = -50
Const AL_PITCH_SHIFTER_MAX_FINE_TUNE As Long = 50
Const AL_PITCH_SHIFTER_DEFAULT_FINE_TUNE As Long = 0

' AL ring modulator effect parameter ranges and defaults
Const AL_RING_MODULATOR_MIN_FREQUENCY As Single = 0.0
Const AL_RING_MODULATOR_MAX_FREQUENCY As Single = 8000.0
Const AL_RING_MODULATOR_DEFAULT_FREQUENCY As Single = 440.0
Const AL_RING_MODULATOR_MIN_HIGHPASS_CUTOFF As Single = 0.0
Const AL_RING_MODULATOR_MAX_HIGHPASS_CUTOFF As Single = 24000.0
Const AL_RING_MODULATOR_DEFAULT_HIGHPASS_CUTOFF As Single = 800.0
Const AL_RING_MODULATOR_MIN_WAVEFORM As Long = 0
Const AL_RING_MODULATOR_MAX_WAVEFORM As Long = 2
Const AL_RING_MODULATOR_DEFAULT_WAVEFORM As Long = 0
Const AL_RING_MODULATOR_SINUSOID As Long = 0
Const AL_RING_MODULATOR_SAWTOOTH As Long = 1
Const AL_RING_MODULATOR_SQUARE As Long = 2

' AL autowah effect parameter ranges and defaults
Const AL_AUTOWAH_MIN_ATTACK_TIME As Single = 0.0001
Const AL_AUTOWAH_MAX_ATTACK_TIME As Single = 1.0
Const AL_AUTOWAH_DEFAULT_ATTACK_TIME As Single = 0.06
Const AL_AUTOWAH_MIN_RELEASE_TIME As Single = 0.0001
Const AL_AUTOWAH_MAX_RELEASE_TIME As Single = 1.0
Const AL_AUTOWAH_DEFAULT_RELEASE_TIME As Single = 0.06
Const AL_AUTOWAH_MIN_RESONANCE As Single = 2.0
Const AL_AUTOWAH_MAX_RESONANCE As Single = 1000.0
Const AL_AUTOWAH_DEFAULT_RESONANCE As Single = 1000.0
Const AL_AUTOWAH_MIN_PEAK_GAIN As Single = 0.00003
Const AL_AUTOWAH_MAX_PEAK_GAIN As Single = 31621.0
Const AL_AUTOWAH_DEFAULT_PEAK_GAIN As Single = 11.22

' AL compressor effect parameter ranges and defaults
Const AL_COMPRESSOR_MIN_ONOFF As Long = 0
Const AL_COMPRESSOR_MAX_ONOFF As Long = 1
Const AL_COMPRESSOR_DEFAULT_ONOFF As Long = 1

' AL equalizer effect parameter ranges and defaults
Const AL_EQUALIZER_MIN_LOW_GAIN As Single = 0.126
Const AL_EQUALIZER_MAX_LOW_GAIN As Single = 7.943
Const AL_EQUALIZER_DEFAULT_LOW_GAIN As Single = 1.0
Const AL_EQUALIZER_MIN_LOW_CUTOFF As Single = 50.0
Const AL_EQUALIZER_MAX_LOW_CUTOFF As Single = 800.0
Const AL_EQUALIZER_DEFAULT_LOW_CUTOFF As Single = 200.0
Const AL_EQUALIZER_MIN_MID1_GAIN As Single = 0.126
Const AL_EQUALIZER_MAX_MID1_GAIN As Single = 7.943
Const AL_EQUALIZER_DEFAULT_MID1_GAIN As Single = 1.0
Const AL_EQUALIZER_MIN_MID1_CENTER As Single = 200.0
Const AL_EQUALIZER_MAX_MID1_CENTER As Single = 3000.0
Const AL_EQUALIZER_DEFAULT_MID1_CENTER As Single = 500.0
Const AL_EQUALIZER_MIN_MID1_WIDTH As Single = 0.01
Const AL_EQUALIZER_MAX_MID1_WIDTH As Single = 1.0
Const AL_EQUALIZER_DEFAULT_MID1_WIDTH As Single = 1.0
Const AL_EQUALIZER_MIN_MID2_GAIN As Single = 0.126
Const AL_EQUALIZER_MAX_MID2_GAIN As Single = 7.943
Const AL_EQUALIZER_DEFAULT_MID2_GAIN As Single = 1.0
Const AL_EQUALIZER_MIN_MID2_CENTER As Single = 1000.0
Const AL_EQUALIZER_MAX_MID2_CENTER As Single = 8000.0
Const AL_EQUALIZER_DEFAULT_MID2_CENTER As Single = 3000.0
Const AL_EQUALIZER_MIN_MID2_WIDTH As Single = 0.01
Const AL_EQUALIZER_MAX_MID2_WIDTH As Single = 1.0
Const AL_EQUALIZER_DEFAULT_MID2_WIDTH As Single = 1.0
Const AL_EQUALIZER_MIN_HIGH_GAIN As Single = 0.126
Const AL_EQUALIZER_MAX_HIGH_GAIN As Single = 7.943
Const AL_EQUALIZER_DEFAULT_HIGH_GAIN As Single = 1.0
Const AL_EQUALIZER_MIN_HIGH_CUTOFF As Single = 4000.0
Const AL_EQUALIZER_MAX_HIGH_CUTOFF As Single = 16000.0
Const AL_EQUALIZER_DEFAULT_HIGH_CUTOFF As Single = 6000.0

' Source parameter value definitions, ranges and defaults
Const AL_MIN_AIR_ABSORPTION_FACTOR As Single = 0.0
Const AL_MAX_AIR_ABSORPTION_FACTOR As Single = 10.0
Const AL_DEFAULT_AIR_ABSORPTION_FACTOR As Single = 0.0
Const AL_MIN_ROOM_ROLLOFF_FACTOR As Single = 0.0
Const AL_MAX_ROOM_ROLLOFF_FACTOR As Single = 10.0
Const AL_DEFAULT_ROOM_ROLLOFF_FACTOR As Single = 0.0
Const AL_MIN_CONE_OUTER_GAINHF As Single = 0.0
Const AL_MAX_CONE_OUTER_GAINHF As Single = 1.0
Const AL_DEFAULT_CONE_OUTER_GAINHF As Single = 1.0
Const AL_MIN_DIRECT_FILTER_GAINHF_AUTO As Long = 0
Const AL_MAX_DIRECT_FILTER_GAINHF_AUTO As Long = 1
Const AL_DEFAULT_DIRECT_FILTER_GAINHF_AUTO As Long = 1
Const AL_MIN_AUXILIARY_SEND_FILTER_GAIN_AUTO As Long = 0
Const AL_MAX_AUXILIARY_SEND_FILTER_GAIN_AUTO As Long = 1
Const AL_DEFAULT_AUXILIARY_SEND_FILTER_GAIN_AUTO As Long = 1
Const AL_MIN_AUXILIARY_SEND_FILTER_GAINHF_AUTO As Long = 0
Const AL_MAX_AUXILIARY_SEND_FILTER_GAINHF_AUTO As Long = 1
Const AL_DEFAULT_AUXILIARY_SEND_FILTER_GAINHF_AUTO As Long = 1

' Listener parameter value definitions, ranges and defaults
Const AL_MIN_METERS_PER_UNIT As Single = 1.175494e-38
Const AL_MAX_METERS_PER_UNIT As Single = 3.402823e+38
Const AL_DEFAULT_METERS_PER_UNIT As Single = 1.0

' *** Effect object definitions to be used with alEffect functions (Creative)

' AL EAXReverb effect parameters
Const AL_EAXREVERB_DENSITY As Long = 1
Const AL_EAXREVERB_DIFFUSION As Long = 2
Const AL_EAXREVERB_GAIN As Long = 3
Const AL_EAXREVERB_GAINHF As Long = 4
Const AL_EAXREVERB_GAINLF As Long = 5
Const AL_EAXREVERB_DECAY_TIME As Long = 6
Const AL_EAXREVERB_DECAY_HFRATIO As Long = 7
Const AL_EAXREVERB_DECAY_LFRATIO As Long = 8
Const AL_EAXREVERB_REFLECTIONS_GAIN As Long = 9
Const AL_EAXREVERB_REFLECTIONS_DELAY As Long = &HA
Const AL_EAXREVERB_REFLECTIONS_PAN As Long = &HB
Const AL_EAXREVERB_LATE_REVERB_GAIN As Long = &HC
Const AL_EAXREVERB_LATE_REVERB_DELAY As Long = &HD
Const AL_EAXREVERB_LATE_REVERB_PAN As Long = &HE
Const AL_EAXREVERB_ECHO_TIME As Long = &HF
Const AL_EAXREVERB_ECHO_DEPTH As Long = &H10
Const AL_EAXREVERB_MODULATION_TIME As Long = &H11
Const AL_EAXREVERB_MODULATION_DEPTH As Long = &H12
Const AL_EAXREVERB_AIR_ABSORPTION_GAINHF As Long = &H13 
Const AL_EAXREVERB_HFREFERENCE As Long = &H14 
Const AL_EAXREVERB_LFREFERENCE As Long = &H15 
Const AL_EAXREVERB_ROOM_ROLLOFF_FACTOR As Long = &H16
Const AL_EAXREVERB_DECAY_HFLIMIT As Long = &H17

' Effect type definitions to be used with AL_EFFECT_TYPE
Const AL_EFFECT_EAXREVERB As Long = &H8000

' *** Effect parameter structures, value definitions, ranges and defaults (Creative)

' AL reverb effect parameter ranges and defaults
Const AL_EAXREVERB_MIN_DENSITY As Single = 0.0
Const AL_EAXREVERB_MAX_DENSITY As Single = 1.0
Const AL_EAXREVERB_DEFAULT_DENSITY As Single = 1.0
Const AL_EAXREVERB_MIN_DIFFUSION As Single = 0.0
Const AL_EAXREVERB_MAX_DIFFUSION As Single = 1.0
Const AL_EAXREVERB_DEFAULT_DIFFUSION As Single = 1.0
Const AL_EAXREVERB_MIN_GAIN As Single = 0.0
Const AL_EAXREVERB_MAX_GAIN As Single = 1.0
Const AL_EAXREVERB_DEFAULT_GAIN As Single = 0.32
Const AL_EAXREVERB_MIN_GAINHF As Single = 0.0
Const AL_EAXREVERB_MAX_GAINHF As Single = 1.0
Const AL_EAXREVERB_DEFAULT_GAINHF As Single = 0.89
Const AL_EAXREVERB_MIN_GAINLF As Single = 0.0
Const AL_EAXREVERB_MAX_GAINLF As Single = 1.0
Const AL_EAXREVERB_DEFAULT_GAINLF As Single = 1.0
Const AL_EAXREVERB_MIN_DECAY_TIME As Single = 0.1
Const AL_EAXREVERB_MAX_DECAY_TIME As Single = 20.0
Const AL_EAXREVERB_DEFAULT_DECAY_TIME As Single = 1.49
Const AL_EAXREVERB_MIN_DECAY_HFRATIO As Single = 0.1
Const AL_EAXREVERB_MAX_DECAY_HFRATIO As Single = 2.0
Const AL_EAXREVERB_DEFAULT_DECAY_HFRATIO As Single = 0.83
Const AL_EAXREVERB_MIN_DECAY_LFRATIO As Single = 0.1
Const AL_EAXREVERB_MAX_DECAY_LFRATIO As Single = 2.0
Const AL_EAXREVERB_DEFAULT_DECAY_LFRATIO As Single = 1.0
Const AL_EAXREVERB_MIN_REFLECTIONS_GAIN As Single = 0.0
Const AL_EAXREVERB_MAX_REFLECTIONS_GAIN As Single = 3.16
Const AL_EAXREVERB_DEFAULT_REFLECTIONS_GAIN As Single = 0.05
Const AL_EAXREVERB_MIN_REFLECTIONS_DELAY As Single = 0.0
Const AL_EAXREVERB_MAX_REFLECTIONS_DELAY As Single = 0.3
Const AL_EAXREVERB_DEFAULT_REFLECTIONS_DELAY As Single = 0.007
Const AL_EAXREVERB_DEFAULT_REFLECTIONS_PAN_XYZ As Single = 0.0
Const AL_EAXREVERB_MIN_LATE_REVERB_GAIN As Single = 0.0
Const AL_EAXREVERB_MAX_LATE_REVERB_GAIN As Single = 10.0
Const AL_EAXREVERB_DEFAULT_LATE_REVERB_GAIN As Single = 1.26
Const AL_EAXREVERB_MIN_LATE_REVERB_DELAY As Single = 0.0
Const AL_EAXREVERB_MAX_LATE_REVERB_DELAY As Single = 0.1
Const AL_EAXREVERB_DEFAULT_LATE_REVERB_DELAY As Single = 0.011
Const AL_EAXREVERB_DEFAULT_LATE_REVERB_PAN_XYZ As Single = 0.0
Const AL_EAXREVERB_MIN_ECHO_TIME As Single = 0.075
Const AL_EAXREVERB_MAX_ECHO_TIME As Single = 0.25
Const AL_EAXREVERB_DEFAULT_ECHO_TIME As Single = 0.25
Const AL_EAXREVERB_MIN_ECHO_DEPTH As Single = 0.0
Const AL_EAXREVERB_MAX_ECHO_DEPTH As Single = 1.0
Const AL_EAXREVERB_DEFAULT_ECHO_DEPTH As Single = 0.0
Const AL_EAXREVERB_MIN_MODULATION_TIME As Single = 0.04
Const AL_EAXREVERB_MAX_MODULATION_TIME As Single = 4.0
Const AL_EAXREVERB_DEFAULT_MODULATION_TIME As Single = 0.25
Const AL_EAXREVERB_MIN_MODULATION_DEPTH As Single = 0.0
Const AL_EAXREVERB_MAX_MODULATION_DEPTH As Single = 1.0
Const AL_EAXREVERB_DEFAULT_MODULATION_DEPTH As Single = 0.0
Const AL_EAXREVERB_MIN_AIR_ABSORPTION_GAINHF As Single = 0.892
Const AL_EAXREVERB_MAX_AIR_ABSORPTION_GAINHF As Single = 1.0
Const AL_EAXREVERB_DEFAULT_AIR_ABSORPTION_GAINHF As Single = 0.994
Const AL_EAXREVERB_MIN_HFREFERENCE As Single = 1000.0
Const AL_EAXREVERB_MAX_HFREFERENCE As Single = 20000.0
Const AL_EAXREVERB_DEFAULT_HFREFERENCE As Single = 5000.0
Const AL_EAXREVERB_MIN_LFREFERENCE As Single = 20.0
Const AL_EAXREVERB_MAX_LFREFERENCE As Single = 1000.0
Const AL_EAXREVERB_DEFAULT_LFREFERENCE As Single = 250.0
Const AL_EAXREVERB_MIN_ROOM_ROLLOFF_FACTOR As Single = 0.0
Const AL_EAXREVERB_MAX_ROOM_ROLLOFF_FACTOR As Single = 10.0
Const AL_EAXREVERB_DEFAULT_ROOM_ROLLOFF_FACTOR As Single = 0.0
Const AL_EAXREVERB_MIN_DECAY_HFLIMIT As Long = 0
Const AL_EAXREVERB_MAX_DECAY_HFLIMIT As Long = 1
Const AL_EAXREVERB_DEFAULT_DECAY_HFLIMIT As Long = 1

' *** Renderer State management

' Enable a feature of the OpenAL driver
' Note: There are no capabilities in OpenAL 1.1 to be used with this function, but it may be used by an extension
Sub alEnable(ByVal capability As Long) : End Sub

' Disable a feature of the OpenAL driver
' Note: There are no capabilities in OpenAL 1.1 to be used with this function, but it may be used by an extension
Sub alDisable(ByVal capability As Long) : End Sub

' Return a boolean indicating if a specific feature is enabled in the OpenAL driver
' Note: There are no capabilities in OpenAL 1.1 to be used with this function, but it may be used by an extension
Function alIsEnabled(ByVal capability As Long) As Boolean : End Function

' *** State retrieval

' Retrieve an OpenAL string property
' Note: This function returns a null terminated ASCII string
'       (It can be converted to VB6 string using the LPSTR2BSTR function)
Function alGetString(ByVal param As Long) As Long : End Function

' Retrieve a boolean OpenAL state
Sub alGetBooleanv(ByVal param As Long, ByRef data As Boolean) : End Sub

' Retrieve an integer OpenAL state
Sub alGetIntegerv(ByVal param As Long, ByRef data As Long) : End Sub

' Retrieve a floating point OpenAL state
Sub alGetFloatv(ByVal param As Long, ByRef data As Single) : End Sub

' Retrieve a double precision floating point OpenAL state
Sub alGetDoublev(ByVal param As Long, ByRef data As Double) : End Sub

' Return a boolean OpenAL state
Function alGetBoolean(ByVal param As Long) As Boolean : End Function

' Return an integer OpenAL state
Function alGetInteger(ByVal param As Long) As Long : End Function

' Return a floating point OpenAL state
Function alGetFloat(ByVal param As Long) As Single : End Function

' Return a double precision floating point OpenAL state
Function alGetDouble(ByVal param As Long) As Double : End Function

' *** Error support

' Return the current error state and then clear the error state
Function alGetError() As Long : End Function

' *** Extension support
' Note: The names are specified as null terminated ASCII strings
'       (VB6 strings can be converted using the BSTR2LPSTR function)

' Test if a specific extension is available for the OpenAL driver
Function alIsExtensionPresent(ByVal extname As Long) As Boolean : End Function

' Return the address of an OpenAL extension function
Function alGetProcAddress(ByVal fname As Long) As Long : End Function

' Return the enumeration value of an OpenAL enum described by a string
Function alGetEnumValue(ByVal ename As Long) As Long : End Function

' *** Listener API
' Listener represents the location and orientation of the 'user' in 3D-space
' Properties: gain, position, velocity, orientation

' *** Set Listener parameters

' Set a floating point property for the listener (AL_GAIN)
Sub alListenerf(ByVal param As Long, ByVal value As Single) : End Sub

' Set three floating point values for a property of the listener (AL_POSITION, AL_VELOCITY)
Sub alListener3f(ByVal param As Long, ByVal v1 As Single, ByVal v2 As Single, ByVal v3 As Single) : End Sub

' Set a floating point-vector property of the listener (AL_POSITION, AL_VELOCITY, AL_ORIENTATION)
' Note: 'values' is a pointer to an array of 32-bit floating point values
Sub alListenerfv(ByVal param As Long, ByVal values As Long) : End Sub

' Set an integer property of the listener (AL_GAIN)
Sub alListeneri(ByVal param As Long, ByVal value As Long) : End Sub

' Set three integer values for a property of the listener (AL_POSITION, AL_VELOCITY)
Sub alListener3i(ByVal param As Long, ByVal v1 As Long, ByVal v2 As Long, ByVal v3 As Long) : End Sub

' Set an integer property of the listener (AL_POSITION, AL_VELOCITY, AL_ORIENTATION)
' Note: 'values' is a pointer to an array of 32-bit integer values
Sub alListeneriv(ByVal param As Long, ByVal values As Long) : End Sub

' *** Get Listener parameters

' Retrieve a floating point property of the listener (AL_GAIN)
Sub alGetListenerf(ByVal param As Long, ByRef value As Single) : End Sub

' Retrieve three floating point values from a property of the listener (AL_POSITION, AL_VELOCITY)
Sub alGetListener3f(ByVal param As Long, ByRef v1 As Single, ByRef v2 As Single, ByRef v3 As Single) : End Sub

' Retrieve a floating point-vector property of the listener (AL_POSITION, AL_VELOCITY, AL_ORIENTATION)
' Note: 'values' is a pointer to an array of 32-bit floating point values
Sub alGetListenerfv(ByVal param As Long, ByVal values As Long) : End Sub

' Retrieve an integer property of the listener (AL_GAIN)
Sub alGetListeneri(ByVal param As Long, ByRef value As Long) : End Sub

' Retrieve three integer values from a property of the listener (AL_POSITION, AL_VELOCITY)
Sub alGetListener3i(ByVal param As Long, ByRef v1 As Long, ByRef v2 As Long, ByRef v3 As Long) : End Sub

' Retrieve an integer-vector property of the listener (AL_POSITION, AL_VELOCITY, AL_ORIENTATION)
' Note: 'values' is a pointer to an array of 32-bit integer values
Sub alGetListeneriv(ByVal param As Long, ByVal values As Long) : End Sub

' *** Source API
' Sources represent individual sound objects in 3D-space. Sources take the PCM data provided in the buffer,
' apply source-specific modifications, and then submit them to be mixed according to spatial arrangement etc.
' Properties: gain, min gain, max gain, position, velocity, direction, head relative mode,
'             reference distance, max distance, rolloff factor, inner angle, outer angle,
'             cone outer gain, pitch, looping, ms offset, byte offset, sample offset, attached
'             buffer, state (query only), buffers queued (query only), buffers processed (query only)

' *** Create Source objects
' Note: When specifying multiple sources, 'sources' must be a pointer to the first value in the array

' Generate one or more sources
Sub alGenSources(ByVal n As Long, ByRef sources As Long) : End Sub

' Delete source objects
Sub alDeleteSources(ByVal n As Long, ByRef sources As Long) : End Sub

' Verify a handle is a valid source
Function alIsSource(ByVal sid As Long) As Boolean : End Function

' *** Set Source parameters

' Set a floating point property of a source (AL_PITCH, AL_GAIN, AL_MIN_GAIN, AL_MAX_GAIN, AL_MAX_DISTANCE,
' AL_ROLLOFF_FACTOR, AL_CONE_OUTER_GAIN, AL_CONE_INNER_ANGLE, AL_CONE_OUTER_ANGLE, AL_REFERENCE_DISTANCE)
Sub alSourcef(ByVal sid As Long, ByVal param As Long, ByVal value As Single) : End Sub

' Set a source property requiring three floating point values (AL_POSITION, AL_VELOCITY, AL_DIRECTION)
Sub alSource3f(ByVal sid As Long, ByVal param As Long, ByVal v1 As Single, ByVal v2 As Single, ByVal v3 As Single) : End Sub

' Set a floating point-vector property of a source (AL_POSITION, AL_VELOCITY, AL_DIRECTION)
' Note: 'values' is a pointer to an array of 32-bit floating point values
Sub alSourcefv(ByVal sid As Long, ByVal param As Long, ByVal values As Long) : End Sub

' Set an integer property of a source (AL_SOURCE_RELATIVE, AL_CONE_INNER_ANGLE, AL_CONE_OUTER_ANGLE,
' AL_LOOPING, AL_BUFFER, AL_SOURCE_STATE)
Sub alSourcei(ByVal sid As Long, ByVal param As Long, ByVal value As Long) : End Sub

' Set three integer values for a property of the source (AL_POSITION, AL_VELOCITY, AL_DIRECTION)
Sub alSource3i(ByVal sid As Long, ByVal param As Long, ByVal v1 As Long, ByVal v2 As Long, ByVal v3 As Long) : End Sub

' Set an integer property of the source (AL_POSITION, AL_VELOCITY, AL_DIRECTION)
' Note: 'values' is a pointer to an array of 32-bit integer values
Sub alSourceiv(ByVal sid As Long, ByVal param As Long, ByVal values As Long) : End Sub

' *** Get Source parameters

' Retrieve a floating point property of a source (AL_PITCH, AL_GAIN, AL_MIN_GAIN, AL_MAX_GAIN, AL_MAX_DISTANCE,
' AL_ROLLOFF_FACTOR, AL_CONE_OUTER_GAIN, AL_CONE_INNER_ANGLE, AL_CONE_OUTER_ANGLE, AL_REFERENCE_DISTANCE)
Sub alGetSourcef(ByVal sid As Long, ByVal param As Long, ByRef value As Single) : End Sub

' Retrieve three floating point values representing a property of a source (AL_POSITION, AL_VELOCITY, AL_DIRECTION)
Sub alGetSource3f(ByVal sid As Long, ByVal param As Long, ByRef v1 As Single, ByRef v2 As Single, ByRef v3 As Single) : End Sub

' Retrieve a floating point-vector property of a source (AL_POSITION, AL_VELOCITY, AL_DIRECTION)
' Note: 'values' is a pointer to an array of 32-bit floating point values
Sub alGetSourcefv(ByVal sid As Long, ByVal param As Long, ByVal values As Long) : End Sub

' Retrieve an integer property of a source (AL_SOURCE_RELATIVE, AL_BUFFER, AL_SOURCE_STATE, AL_BUFFERS_QUEUED,
' AL_BUFFERS_PROCESSED)
Sub alGetSourcei(ByVal sid As Long, ByVal param As Long, ByRef value As Long) : End Sub

' Retrieve three integer values for a property of the source (AL_POSITION, AL_VELOCITY, AL_DIRECTION)
Sub alGetSource3i(ByVal sid As Long, ByVal param As Long, ByRef v1 As Long, ByRef v2 As Long, ByRef v3 As Long) : End Sub

' Retrieve an integer property of the source (AL_POSITION, AL_VELOCITY, AL_DIRECTION)
' Note: 'values' is a pointer to an array of 32-bit integer values
Sub alGetSourceiv(ByVal sid As Long, ByVal param As Long, ByVal values As Long) : End Sub

' *** Source vector based playback calls
' Note: When specifying multiple sources, 'sids' must be a pointer to the first value in the array

' Play, replay, or resume (if paused) a list of Sources
Sub alSourcePlayv(ByVal ns As Long, ByRef sids As Long) : End Sub

' Stop a list of Sources
Sub alSourceStopv(ByVal ns As Long, ByRef sids As Long) : End Sub

' Rewind a list of Sources
Sub alSourceRewindv(ByVal ns As Long, ByRef sids As Long) : End Sub

' Pause a list of Sources
Sub alSourcePausev(ByVal ns As Long, ByRef sids As Long) : End Sub

' *** Source based playback calls

' Play, replay, or resume a Source
Sub alSourcePlay(ByVal sid As Long) : End Sub

' Stop a Source
Sub alSourceStop(ByVal sid As Long) : End Sub

' Rewind a Source (set playback postiton to beginning)
Sub alSourceRewind(ByVal sid As Long) : End Sub

' Pause a Source
Sub alSourcePause(ByVal sid As Long) : End Sub

' *** Source Queuing
' Note: When specifying multiple buffers, 'buffers' must be a pointer to the first value in the array

' Queue a set of buffers on a source. All buffers attached to a source will be played in sequence, and
' the number of processed buffers can be detected using an alSourcei call to retrieve AL_BUFFERS_PROCESSED
Sub alSourceQueueBuffers(ByVal sid As Long, ByVal n As Long, ByRef buffers As Long) : End Sub

' Unqueue a set of buffers attached to a source. The number of processed buffers can be detected using an
' alSourcei call to retrieve AL_BUFFERS_PROCESSED, which is the maximum number of buffers that can be unqueued
Sub alSourceUnqueueBuffers(ByVal sid As Long, ByVal n As Long, ByRef buffers As Long) : End Sub

' *** Buffer API
' Buffer are storage space for sample data. Buffers are referred to by Sources.
' One Buffer can be used by multiple Sources.
' Properties (query only): frequency, size, bits, channels
' Note: When specifying multiple buffers, 'buffers' must be a pointer to the first value in the array

' Create Buffer objects
Sub alGenBuffers(ByVal n As Long, ByRef buffers As Long) : End Sub

' Delete Buffer objects
Sub alDeleteBuffers(ByVal n As Long, ByRef buffers As Long) : End Sub

' Verify a handle is a valid Buffer
Function alIsBuffer(ByVal bid As Long) As Boolean : End Function

' Specify the data to be copied into a buffer
' Note: 'data' is a pointer to a byte array containing the sample data
Sub alBufferData(ByVal bid As Long, ByVal format As Long, ByVal data As Long, ByVal size As Long, ByVal freq As Long) : End Sub

' *** Set Buffer parameters

' Set a floating point property of a buffer
Sub alBufferf(ByVal bid As Long, ByVal param As Long, ByVal value As Single) : End Sub

' Set three floating point values for a property of the buffer
Sub alBuffer3f(ByVal bid As Long, ByVal param As Long, ByVal v1 As Single, ByVal v2 As Single, ByVal v3 As Single) : End Sub

' Set a floating point property of the buffer
' Note: 'values' is a pointer to an array of 32-bit floating point values
Sub alBufferfv(ByVal bid As Long, ByVal param As Long, ByVal values As Long) : End Sub

' Set an integer property of a buffer
Sub alBufferi(ByVal bid As Long, ByVal param As Long, ByVal value As Long) : End Sub

' Set three integer values for a property of the buffer
Sub alBuffer3i(ByVal bid As Long, ByVal param As Long, ByVal v1 As Long, ByVal v2 As Long, ByVal v3 As Long) : End Sub

' Set an integer property of the buffer
' Note: 'values' is a pointer to an array of 32-bit integer values
Sub alBufferiv(ByVal bid As Long, ByVal param As Long, ByVal values As Long) : End Sub

' *** Get Buffer parameters

' Retrieve a floating point property of a buffer
Sub alGetBufferf(ByVal bid As Long, ByVal param As Long, ByRef value As Single) : End Sub

' Retrieve three floating point values for a property of the buffer
Sub alGetBuffer3f(ByVal bid As Long, ByVal param As Long, ByRef v1 As Single, ByRef v2 As Single, ByRef v3 As Single) : End Sub

' Retrieve a floating point-vector property of a buffer
' Note: 'values' is a pointer to an array of 32-bit floating point values
Sub alGetBufferfv(ByVal bid As Long, ByVal param As Long, ByVal values As Long) : End Sub

' Retrieve an integer property of a buffer
Sub alGetBufferi(ByVal bid As Long, ByVal param As Long, ByRef value As Long) : End Sub

' Retrieve three integer values for a property of the buffer
Sub alGetBuffer3i(ByVal bid As Long, ByVal param As Long, ByRef v1 As Long, ByRef v2 As Long, ByRef v3 As Long) : End Sub

' Retrieve an integer-vector property of a buffer
' Note: 'values' is a pointer to an array of 32-bit integer values
Sub alGetBufferiv(ByVal bid As Long, ByVal param As Long, ByVal values As Long) : End Sub

' *** Global Parameters

' Select the OpenAL Doppler factor value
Sub alDopplerFactor(ByVal value As Single) : End Sub

' Select the OpenAL Doppler velocity value
Sub alDopplerVelocity(ByVal value As Single) : End Sub

' Select the speed of sound for use in Doppler calculations
Sub alSpeedOfSound(ByVal value As Single) : End Sub

' Select the OpenAL distance model: AL_INVERSE_DISTANCE, AL_INVERSE_DISTANCE_CLAMPED, AL_LINEAR_DISTANCE,
' AL_LINEAR_DISTANCE_CLAMPED, AL_EXPONENT_DISTANCE, AL_EXPONENT_DISTANCE_CLAMPED, or AL_NONE
Sub alDistanceModel(ByVal distanceModel As Long) : End Sub

' *** Context Management

' Create a context using a specified device
Function alcCreateContext(ByVal device As Long, ByVal sttrlist As Long) As Long : End Function

' Make a specified context the current context
Function alcMakeContextCurrent(ByVal context As Long) As Boolean : End Function

' Tell a context to begin processing
Sub alcProcessContext(ByVal context As Long) : End Sub

' Suspend processing on a specified context
Sub alcSuspendContext(ByVal context As Long) : End Sub

' Destroy a context
Sub alcDestroyContext(ByVal context As Long) : End Sub

' Retrieve the current context
Function alcGetCurrentContext() As Long : End Function

' Retrieve a context's device pointer
Function alcGetContextsDevice(ByVal context As Long) As Long : End Function

' *** Device Management

' Open a device by name
' Note: 'devicename' is specified as a null terminated ASCII string
'       (VB6 strings can be converted using the BSTR2LPSTR function)
'       A null value is used to specify the default device
Function alcOpenDevice(ByVal devicename As Long) As Long : End Function

' Close a device by name
Function alcCloseDevice(ByVal device As Long) As Boolean : End Function

' *** Error support

' Obtain the most recent Context error
Function alcGetError(ByVal device As Long) As Long : End Function

' *** Extension support
' Query for the presence of an extension, and obtain any appropriate function pointers and enum values
' Note: 'name' is specified as a null terminated ASCII string
'       (VB6 strings can be converted using the BSTR2LPSTR function)

' Query if a specified context extension is available
Function alcIsExtensionPresent(ByVal device As Long, ByVal name As Long) As Boolean : End Function

' Retrieve the address of a specified context extension function
Function alcGetProcAddress(ByVal device As Long, ByVal name As Long) As Long : End Function

' Retrieve the enum value for a specified enumeration name
Function alcGetEnumValue(ByVal device As Long, ByVal name As Long) As Long : End Function

' *** Query functions

' Return a string (or strings) related to the context
' Note: This function returns a null terminated ASCII string
'       (It can be converted to VB6 string using the LPSTR2BSTR function)
Function alcGetString(ByVal device As Long, ByVal param As Long) As Long : End Function

' Return integers related to the context
' Note: 'data' is a pointer to an array of integers large enough to receive the requested 'size' values
Sub alcGetIntegerv(ByVal device As Long, ByVal param As Long, ByVal size As Long, ByVal data As Long) : End Sub

' *** Capture functions

' Open a capture device by name
' Note: 'name' is specified as a null terminated ASCII string
'       (VB6 strings can be converted using the BSTR2LPSTR function)
Function alcCaptureOpenDevice(ByVal name As Long, ByVal frequency As Long, ByVal format As Long, ByVal buffersize As Long) As Long : End Function

' Close the specified capture device
Function alcCaptureCloseDevice(ByVal device As Long) As Boolean : End Function

' Begin a capture operation
Sub alcCaptureStart(ByVal device As Long) : End Sub

' Stop a capture operation
Sub alcCaptureStop(ByVal device As Long) : End Sub

' Complete a capture operation, without blocking
' Note: 'buffer' is a pointer to a byte array large enough to receive the requested number of samples
Sub alcCaptureSamples(ByVal device As Long, ByVal buffer As Long, ByVal samples As Long) : End Sub
