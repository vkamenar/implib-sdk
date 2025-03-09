Attribute VB_Name = "openal32"
' This module represents the OpenAL (Open Audio Library) 32-bit API.
' The OpenAL constants and function prototypes are listed below.
' These constants and prototypes are based on the original OpenAL SDK v1.0/v1.1.

' At link time (when VB6 invokes the MS linker to generate the native executable), the VB6LINK tool included in
' the ImpLib SDK replaces this module with the OpenAL import library to link the executable to the openal32.dll.

Public Enum OAL

   AL_INVALID = -1 ' bad value
   ALC_INVALID = 0
   AL_NONE = 0
   AL_FALSE = 0    ' Boolean False
   ALC_FALSE = 0
   AL_TRUE = 1     ' Boolean True
   ALC_TRUE = 1

   AL_NO_ERROR = 0              ' No Error
   ALC_NO_ERROR = 0
   AL_INVALID_NAME = &HA001     ' Invalid name paramater passed to AL call
   ALC_INVALID_DEVICE = &HA001  ' The specified device is not a valid output device
   AL_ILLEGAL_ENUM = &HA002     ' Invalid enum passed to AL call
   AL_INVALID_ENUM = &HA002
   ALC_INVALID_ENUM = &HA003
   ALC_INVALID_CONTEXT = &HA002 ' The specified context is invalid
   AL_INVALID_VALUE = &HA003    ' Invalid value passed to AL call
   ALC_INVALID_VALUE = &HA004
   AL_ILLEGAL_COMMAND = &HA004  ' Illegal call
   AL_INVALID_OPERATION = &HA004
   AL_OUT_OF_MEMORY = &HA005    ' Requested operation resulted in AL running out of memory
   ALC_OUT_OF_MEMORY = &HA005

   AL_SOURCE_RELATIVE = &H202   ' Indicate Source has relative coordinates
   AL_CONE_INNER_ANGLE = &H1001 ' Directional source, inner cone angle, in degrees
   AL_CONE_OUTER_ANGLE = &H1002 ' Directional source, outer cone angle, in degrees
   AL_PITCH = &H1003            ' Specify the pitch to be applied at source
   AL_POSITION = &H1004         ' Specify the current location in 3D space
   AL_DIRECTION = &H1005        ' Specify the current direction
   AL_VELOCITY = &H1006         ' Specify the current velocity in 3D space
   AL_LOOPING = &H1007          ' Indicate whether source is looping
   AL_BUFFER = &H1009           ' Indicate the buffer to provide sound samples
   AL_GAIN = &H100A             ' Indicate the gain (volume amplification) applied
   AL_MIN_GAIN = &H100D         ' Indicate minimum source attenuation
   AL_MAX_GAIN = &H100E         ' Indicate maximum source attenuation
   AL_ORIENTATION = &H100F      ' Indicate listener orientation
   AL_CHANNEL_MASK = &H3000     ' Specify the channel mask (Creative)

   ' Source state information
   AL_SOURCE_STATE = &H1010
   AL_INITIAL
   AL_PLAYING
   AL_PAUSED
   AL_STOPPED

   ' Buffer queue params
   AL_BUFFERS_QUEUED = &H1015
   AL_BUFFERS_PROCESSED = &H1016

   ' Source buffer position information
   AL_SEC_OFFSET = &H1024
   AL_SAMPLE_OFFSET
   AL_BYTE_OFFSET

   ' Source type: static, streaming or undetermined
   AL_SOURCE_TYPE = &H1027
   AL_STATIC = &H1028       ' Source is static if a buffer has been attached using AL_BUFFER
   AL_STREAMING = &H1029    ' Source is streaming if one or more buffers have been attached using alSourceQueueBuffers
   AL_UNDETERMINED = &H1030 ' Source is undetermined when it has the NULL buffer attached

   ' Sound samples: format specifier
   AL_FORMAT_MONO8 = &H1100
   AL_FORMAT_MONO16
   AL_FORMAT_STEREO8
   AL_FORMAT_STEREO16

   AL_REFERENCE_DISTANCE = &H1020 ' Source specific reference distance
   AL_ROLLOFF_FACTOR              ' Source specific rolloff factor
   AL_CONE_OUTER_GAIN             ' Directional source, outer cone gain
   AL_MAX_DISTANCE                ' Indicate distance above which sources are not attenuated using the inverse clamped distance model

   ' Sound samples per second: frequency, in units of Hertz [Hz]
   ' Half of the sample frequency marks the maximum significant frequency component
   AL_FREQUENCY = &H2001

   AL_BITS = &H2002
   AL_CHANNELS = &H2003
   AL_SIZE = &H2004

   ' Buffer state
   AL_UNUSED = &H2010
   AL_PENDING = &H2011
   AL_PROCESSED = &H2012

   AL_VENDOR = &HB001 ' Context strings: Vendor Name
   AL_VERSION = &HB002
   AL_RENDERER = &HB003
   AL_EXTENSIONS = &HB004

   ' *** Global tweakage

   AL_DOPPLER_FACTOR = &HC000   ' Doppler scale
   AL_DOPPLER_VELOCITY = &HC001 ' Tweaks speed of propagation
   AL_SPEED_OF_SOUND = &HC003   ' Speed of sound in units per second

   ' Distance models
   AL_DISTANCE_MODEL = &HD000
   AL_INVERSE_DISTANCE
   AL_INVERSE_DISTANCE_CLAMPED
   AL_LINEAR_DISTANCE
   AL_LINEAR_DISTANCE_CLAMPED
   AL_EXPONENT_DISTANCE
   AL_EXPONENT_DISTANCE_CLAMPED

   ALC_FREQUENCY = &H1007                ' Output frequency in Hz
   ALC_REFRESH = &H1008                  ' Rate of context processing
   ALC_SYNC = &H1009                     ' Flag indicating a synchronous context
   ALC_MONO_SOURCES = &H1010             ' Num of requested mono (3D) sources
   ALC_STEREO_SOURCES = &H1011           ' Num of requested stereo sources
   ALC_DEFAULT_DEVICE_SPECIFIER = &H1004 ' The name of the default output device
   ALC_DEVICE_SPECIFIER = &H1005         ' The name of the specified output device
   ALC_EXTENSIONS = &H1006               ' The available context extensions

   ALC_MAJOR_VERSION = &H1000
   ALC_MINOR_VERSION = &H1001
   ALC_ATTRIBUTES_SIZE = &H1002
   ALC_ALL_ATTRIBUTES = &H1003

   ALC_DEFAULT_ALL_DEVICES_SPECIFIER = &H1012   ' Use with alcGetString with a NULL device ID to retrieve the name of the default device
   ALC_ALL_DEVICES_SPECIFIER = &H1013           ' Use with alcGetString and a NULL device pointer to retrieve the names of all devices and audio output paths
   ALC_CAPTURE_DEVICE_SPECIFIER = &H310         ' Return the name of the specified capture device or a list of all available devices (if a NULL device pointer is supplied)
   ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER = &H311 ' Use with alcGetString with a NULL device ID to retrieve the name of the default capture device
   ALC_CAPTURE_SAMPLES = &H312

   ' Context definitions to be used with alcCreateContext
   ALC_EFX_MAJOR_VERSION = &H20001
   ALC_EFX_MINOR_VERSION = &H20002
   ALC_MAX_AUXILIARY_SENDS = &H20003

   ' Listener definitions to be used with alListener functions
   AL_METERS_PER_UNIT = &H20004

   ' Source definitions to be used with alSource functions
   AL_DIRECT_FILTER = &H20005
   AL_AUXILIARY_SEND_FILTER = &H20006
   AL_AIR_ABSORPTION_FACTOR = &H20007
   AL_ROOM_ROLLOFF_FACTOR = &H20008
   AL_CONE_OUTER_GAINHF = &H20009
   AL_DIRECT_FILTER_GAINHF_AUTO = &H2000A
   AL_AUXILIARY_SEND_FILTER_GAIN_AUTO = &H2000B
   AL_AUXILIARY_SEND_FILTER_GAINHF_AUTO = &H2000C

   ' *** Effect object definitions to be used with alEffect functions

   ' Reverb parameters
   AL_REVERB_DENSITY = 1
   AL_REVERB_DIFFUSION
   AL_REVERB_GAIN
   AL_REVERB_GAINHF
   AL_REVERB_DECAY_TIME
   AL_REVERB_DECAY_HFRATIO
   AL_REVERB_REFLECTIONS_GAIN
   AL_REVERB_REFLECTIONS_DELAY
   AL_REVERB_LATE_REVERB_GAIN
   AL_REVERB_LATE_REVERB_DELAY
   AL_REVERB_AIR_ABSORPTION_GAINHF
   AL_REVERB_ROOM_ROLLOFF_FACTOR
   AL_REVERB_DECAY_HFLIMIT

   ' Chorus parameters
   AL_CHORUS_WAVEFORM = 1
   AL_CHORUS_PHASE
   AL_CHORUS_RATE
   AL_CHORUS_DEPTH
   AL_CHORUS_FEEDBACK
   AL_CHORUS_DELAY

   ' Distortion parameters
   AL_DISTORTION_EDGE = 1
   AL_DISTORTION_GAIN
   AL_DISTORTION_LOWPASS_CUTOFF
   AL_DISTORTION_EQCENTER
   AL_DISTORTION_EQBANDWIDTH

   ' Echo parameters
   AL_ECHO_DELAY = 1
   AL_ECHO_LRDELAY
   AL_ECHO_DAMPING
   AL_ECHO_FEEDBACK
   AL_ECHO_SPREAD

   ' Flanger parameters
   AL_FLANGER_WAVEFORM = 1
   AL_FLANGER_PHASE
   AL_FLANGER_RATE
   AL_FLANGER_DEPTH
   AL_FLANGER_FEEDBACK
   AL_FLANGER_DELAY

   ' Frequencyshifter parameters
   AL_FREQUENCY_SHIFTER_FREQUENCY = 1
   AL_FREQUENCY_SHIFTER_LEFT_DIRECTION
   AL_FREQUENCY_SHIFTER_RIGHT_DIRECTION

   ' Vocalmorpher parameters
   AL_VOCAL_MORPHER_PHONEMEA = 1
   AL_VOCAL_MORPHER_PHONEMEA_COARSE_TUNING
   AL_VOCAL_MORPHER_PHONEMEB
   AL_VOCAL_MORPHER_PHONEMEB_COARSE_TUNING
   AL_VOCAL_MORPHER_WAVEFORM
   AL_VOCAL_MORPHER_RATE

   ' Pitchshifter parameters
   AL_PITCH_SHIFTER_COARSE_TUNE = 1
   AL_PITCH_SHIFTER_FINE_TUNE

   ' Ringmodulator parameters
   AL_RING_MODULATOR_FREQUENCY = 1
   AL_RING_MODULATOR_HIGHPASS_CUTOFF
   AL_RING_MODULATOR_WAVEFORM

   ' Autowah parameters
   AL_AUTOWAH_ATTACK_TIME = 1
   AL_AUTOWAH_RELEASE_TIME
   AL_AUTOWAH_RESONANCE
   AL_AUTOWAH_PEAK_GAIN

   ' Compressor parameters
   AL_COMPRESSOR_ONOFF = 1

   ' Equalizer parameters
   AL_EQUALIZER_LOW_GAIN = 1
   AL_EQUALIZER_LOW_CUTOFF
   AL_EQUALIZER_MID1_GAIN
   AL_EQUALIZER_MID1_CENTER
   AL_EQUALIZER_MID1_WIDTH
   AL_EQUALIZER_MID2_GAIN
   AL_EQUALIZER_MID2_CENTER
   AL_EQUALIZER_MID2_WIDTH
   AL_EQUALIZER_HIGH_GAIN
   AL_EQUALIZER_HIGH_CUTOFF

   ' Effect type
   AL_EFFECT_FIRST_PARAMETER = 0
   AL_EFFECT_LAST_PARAMETER = &H8000
   AL_EFFECT_TYPE = &H8001

   ' Effect type definitions to be used with AL_EFFECT_TYPE
   AL_EFFECT_NULL = 0 ' Can also be used as an Effect Object ID
   AL_EFFECT_REVERB
   AL_EFFECT_CHORUS
   AL_EFFECT_DISTORTION
   AL_EFFECT_ECHO
   AL_EFFECT_FLANGER
   AL_EFFECT_FREQUENCY_SHIFTER
   AL_EFFECT_VOCAL_MORPHER
   AL_EFFECT_PITCH_SHIFTER
   AL_EFFECT_RING_MODULATOR
   AL_EFFECT_AUTOWAH
   AL_EFFECT_COMPRESSOR
   AL_EFFECT_EQUALIZER

   ' Auxiliary Slot object definitions to be used with alAuxiliaryEffectSlot functions
   AL_EFFECTSLOT_EFFECT = 1
   AL_EFFECTSLOT_GAIN
   AL_EFFECTSLOT_AUXILIARY_SEND_AUTO

   ' Value to be used as an Auxiliary Slot ID to disable a source send
   AL_EFFECTSLOT_NULL = 0

   ' *** Filter object definitions to be used with alFilter functions

   ' Lowpass parameters
   AL_LOWPASS_GAIN = 1
   AL_LOWPASS_GAINHF

   ' Highpass parameters
   AL_HIGHPASS_GAIN = 1
   AL_HIGHPASS_GAINLF

   ' Bandpass parameters
   AL_BANDPASS_GAIN = 1
   AL_BANDPASS_GAINLF
   AL_BANDPASS_GAINHF

   ' Filter type
   AL_FILTER_FIRST_PARAMETER = 0
   AL_FILTER_LAST_PARAMETER = &H8000
   AL_FILTER_TYPE = &H8001

   ' Filter type definitions to be used with AL_FILTER_TYPE
   AL_FILTER_NULL = 0 ' Can also be used as a Filter Object ID
   AL_FILTER_LOWPASS
   AL_FILTER_HIGHPASS
   AL_FILTER_BANDPASS

   ' *** Filter ranges and defaults

   ' Lowpass filter
   LOWPASS_MIN_GAIN = 0.0
   LOWPASS_MAX_GAIN = 1.0
   LOWPASS_DEFAULT_GAIN = 1.0
   LOWPASS_MIN_GAINHF = 0.0
   LOWPASS_MAX_GAINHF = 1.0
   LOWPASS_DEFAULT_GAINHF = 1.0

   ' Highpass filter
   HIGHPASS_MIN_GAIN = 0.0
   HIGHPASS_MAX_GAIN = 1.0
   HIGHPASS_DEFAULT_GAIN = 1.0
   HIGHPASS_MIN_GAINLF = 0.0
   HIGHPASS_MAX_GAINLF = 1.0
   HIGHPASS_DEFAULT_GAINLF = 1.0

   ' Bandpass filter
   BANDPASS_MIN_GAIN = 0.0
   BANDPASS_MAX_GAIN = 1.0
   BANDPASS_DEFAULT_GAIN = 1.0
   BANDPASS_MIN_GAINHF = 0.0
   BANDPASS_MAX_GAINHF = 1.0
   BANDPASS_DEFAULT_GAINHF = 1.0
   BANDPASS_MIN_GAINLF = 0.0
   BANDPASS_MAX_GAINLF = 1.0
   BANDPASS_DEFAULT_GAINLF = 1.0

   ' *** Effect parameter structures, value definitions, ranges and defaults

   ' AL reverb effect parameter ranges and defaults
   AL_REVERB_MIN_DENSITY = 0.0
   AL_REVERB_MAX_DENSITY = 1.0
   AL_REVERB_DEFAULT_DENSITY = 1.0
   AL_REVERB_MIN_DIFFUSION = 0.0
   AL_REVERB_MAX_DIFFUSION = 1.0
   AL_REVERB_DEFAULT_DIFFUSION = 1.0
   AL_REVERB_MIN_GAIN = 0.0
   AL_REVERB_MAX_GAIN = 1.0
   AL_REVERB_DEFAULT_GAIN = 0.32
   AL_REVERB_MIN_GAINHF = 0.0
   AL_REVERB_MAX_GAINHF = 1.0
   AL_REVERB_DEFAULT_GAINHF = 0.89
   AL_REVERB_MIN_DECAY_TIME = 0.1
   AL_REVERB_MAX_DECAY_TIME = 20.0
   AL_REVERB_DEFAULT_DECAY_TIME = 1.49
   AL_REVERB_MIN_DECAY_HFRATIO = 0.1
   AL_REVERB_MAX_DECAY_HFRATIO = 2.0
   AL_REVERB_DEFAULT_DECAY_HFRATIO = 0.83
   AL_REVERB_MIN_REFLECTIONS_GAIN = 0.0
   AL_REVERB_MAX_REFLECTIONS_GAIN = 3.16
   AL_REVERB_DEFAULT_REFLECTIONS_GAIN = 0.05
   AL_REVERB_MIN_REFLECTIONS_DELAY = 0.0
   AL_REVERB_MAX_REFLECTIONS_DELAY = 0.3
   AL_REVERB_DEFAULT_REFLECTIONS_DELAY = 0.007
   AL_REVERB_MIN_LATE_REVERB_GAIN = 0.0
   AL_REVERB_MAX_LATE_REVERB_GAIN = 10.0
   AL_REVERB_DEFAULT_LATE_REVERB_GAIN = 1.26
   AL_REVERB_MIN_LATE_REVERB_DELAY = 0.0
   AL_REVERB_MAX_LATE_REVERB_DELAY = 0.1
   AL_REVERB_DEFAULT_LATE_REVERB_DELAY = 0.011
   AL_REVERB_MIN_AIR_ABSORPTION_GAINHF = 0.892
   AL_REVERB_MAX_AIR_ABSORPTION_GAINHF = 1.0
   AL_REVERB_DEFAULT_AIR_ABSORPTION_GAINHF = 0.994
   AL_REVERB_MIN_ROOM_ROLLOFF_FACTOR = 0.0
   AL_REVERB_MAX_ROOM_ROLLOFF_FACTOR = 10.0
   AL_REVERB_DEFAULT_ROOM_ROLLOFF_FACTOR = 0.0
   AL_REVERB_MIN_DECAY_HFLIMIT = 0
   AL_REVERB_MAX_DECAY_HFLIMIT = 1
   AL_REVERB_DEFAULT_DECAY_HFLIMIT = 1

   ' AL chorus effect parameter ranges and defaults
   AL_CHORUS_MIN_WAVEFORM = 0
   AL_CHORUS_MAX_WAVEFORM = 1
   AL_CHORUS_DEFAULT_WAVEFORM = 1
   AL_CHORUS_WAVEFORM_SINUSOID = 0
   AL_CHORUS_WAVEFORM_TRIANGLE = 1
   AL_CHORUS_MIN_PHASE = -180
   AL_CHORUS_MAX_PHASE = 180
   AL_CHORUS_DEFAULT_PHASE = 90
   AL_CHORUS_MIN_RATE = 0.0
   AL_CHORUS_MAX_RATE = 10.0
   AL_CHORUS_DEFAULT_RATE = 1.1
   AL_CHORUS_MIN_DEPTH = 0.0
   AL_CHORUS_MAX_DEPTH = 1.0
   AL_CHORUS_DEFAULT_DEPTH = 0.1
   AL_CHORUS_MIN_FEEDBACK = -1.0
   AL_CHORUS_MAX_FEEDBACK = 1.0
   AL_CHORUS_DEFAULT_FEEDBACK = 0.25
   AL_CHORUS_MIN_DELAY = 0.0
   AL_CHORUS_MAX_DELAY = 0.016
   AL_CHORUS_DEFAULT_DELAY = 0.016

   ' AL distortion effect parameter ranges and defaults
   AL_DISTORTION_MIN_EDGE = 0.0
   AL_DISTORTION_MAX_EDGE = 1.0
   AL_DISTORTION_DEFAULT_EDGE = 0.2
   AL_DISTORTION_MIN_GAIN = 0.01
   AL_DISTORTION_MAX_GAIN = 1.0
   AL_DISTORTION_DEFAULT_GAIN = 0.05
   AL_DISTORTION_MIN_LOWPASS_CUTOFF = 80.0
   AL_DISTORTION_MAX_LOWPASS_CUTOFF = 24000.0
   AL_DISTORTION_DEFAULT_LOWPASS_CUTOFF = 8000.0
   AL_DISTORTION_MIN_EQCENTER = 80.0
   AL_DISTORTION_MAX_EQCENTER = 24000.0
   AL_DISTORTION_DEFAULT_EQCENTER = 3600.0
   AL_DISTORTION_MIN_EQBANDWIDTH = 80.0
   AL_DISTORTION_MAX_EQBANDWIDTH = 24000.0
   AL_DISTORTION_DEFAULT_EQBANDWIDTH = 3600.0

   ' AL echo effect parameter ranges and defaults
   AL_ECHO_MIN_DELAY = 0.0
   AL_ECHO_MAX_DELAY = 0.207
   AL_ECHO_DEFAULT_DELAY = 0.1
   AL_ECHO_MIN_LRDELAY = 0.0
   AL_ECHO_MAX_LRDELAY = 0.404
   AL_ECHO_DEFAULT_LRDELAY = 0.1
   AL_ECHO_MIN_DAMPING = 0.0
   AL_ECHO_MAX_DAMPING = 0.99
   AL_ECHO_DEFAULT_DAMPING = 0.5
   AL_ECHO_MIN_FEEDBACK = 0.0
   AL_ECHO_MAX_FEEDBACK = 1.0
   AL_ECHO_DEFAULT_FEEDBACK = 0.5
   AL_ECHO_MIN_SPREAD = -1.0
   AL_ECHO_MAX_SPREAD = 1.0
   AL_ECHO_DEFAULT_SPREAD = -1.0

   ' AL flanger effect parameter ranges and defaults
   AL_FLANGER_MIN_WAVEFORM = 0
   AL_FLANGER_MAX_WAVEFORM = 1
   AL_FLANGER_DEFAULT_WAVEFORM = 1
   AL_FLANGER_WAVEFORM_SINUSOID = 0
   AL_FLANGER_WAVEFORM_TRIANGLE = 1
   AL_FLANGER_MIN_PHASE = -180
   AL_FLANGER_MAX_PHASE = 180
   AL_FLANGER_DEFAULT_PHASE = 0
   AL_FLANGER_MIN_RATE = 0.0
   AL_FLANGER_MAX_RATE = 10.0
   AL_FLANGER_DEFAULT_RATE = 0.27
   AL_FLANGER_MIN_DEPTH = 0.0
   AL_FLANGER_MAX_DEPTH = 1.0
   AL_FLANGER_DEFAULT_DEPTH = 1.0
   AL_FLANGER_MIN_FEEDBACK = -1.0
   AL_FLANGER_MAX_FEEDBACK = 1.0
   AL_FLANGER_DEFAULT_FEEDBACK = -0.5
   AL_FLANGER_MIN_DELAY = 0.0
   AL_FLANGER_MAX_DELAY = 0.004
   AL_FLANGER_DEFAULT_DELAY = 0.002

   ' AL frequency shifter effect parameter ranges and defaults
   AL_FREQUENCY_SHIFTER_MIN_FREQUENCY = 0.0
   AL_FREQUENCY_SHIFTER_MAX_FREQUENCY = 24000.0
   AL_FREQUENCY_SHIFTER_DEFAULT_FREQUENCY = 0.0
   AL_FREQUENCY_SHIFTER_MIN_LEFT_DIRECTION = 0
   AL_FREQUENCY_SHIFTER_MAX_LEFT_DIRECTION = 2
   AL_FREQUENCY_SHIFTER_DEFAULT_LEFT_DIRECTION = 0
   AL_FREQUENCY_SHIFTER_MIN_RIGHT_DIRECTION = 0
   AL_FREQUENCY_SHIFTER_MAX_RIGHT_DIRECTION = 2
   AL_FREQUENCY_SHIFTER_DEFAULT_RIGHT_DIRECTION = 0
   AL_FREQUENCY_SHIFTER_DIRECTION_DOWN = 0
   AL_FREQUENCY_SHIFTER_DIRECTION_UP = 1
   AL_FREQUENCY_SHIFTER_DIRECTION_OFF = 2

   ' AL vocal morpher effect parameter ranges and defaults
   AL_VOCAL_MORPHER_MIN_PHONEMEA = 0
   AL_VOCAL_MORPHER_MAX_PHONEMEA = 29
   AL_VOCAL_MORPHER_DEFAULT_PHONEMEA = 0
   AL_VOCAL_MORPHER_MIN_PHONEMEA_COARSE_TUNING = -24
   AL_VOCAL_MORPHER_MAX_PHONEMEA_COARSE_TUNING = 24
   AL_VOCAL_MORPHER_DEFAULT_PHONEMEA_COARSE_TUNING = 0
   AL_VOCAL_MORPHER_MIN_PHONEMEB = 0
   AL_VOCAL_MORPHER_MAX_PHONEMEB = 29
   AL_VOCAL_MORPHER_DEFAULT_PHONEMEB = 10
   AL_VOCAL_MORPHER_PHONEME_A = 0
   AL_VOCAL_MORPHER_PHONEME_E
   AL_VOCAL_MORPHER_PHONEME_I
   AL_VOCAL_MORPHER_PHONEME_O
   AL_VOCAL_MORPHER_PHONEME_U
   AL_VOCAL_MORPHER_PHONEME_AA
   AL_VOCAL_MORPHER_PHONEME_AE
   AL_VOCAL_MORPHER_PHONEME_AH
   AL_VOCAL_MORPHER_PHONEME_AO
   AL_VOCAL_MORPHER_PHONEME_EH
   AL_VOCAL_MORPHER_PHONEME_ER
   AL_VOCAL_MORPHER_PHONEME_IH
   AL_VOCAL_MORPHER_PHONEME_IY
   AL_VOCAL_MORPHER_PHONEME_UH
   AL_VOCAL_MORPHER_PHONEME_UW
   AL_VOCAL_MORPHER_PHONEME_B
   AL_VOCAL_MORPHER_PHONEME_D
   AL_VOCAL_MORPHER_PHONEME_F
   AL_VOCAL_MORPHER_PHONEME_G
   AL_VOCAL_MORPHER_PHONEME_J
   AL_VOCAL_MORPHER_PHONEME_K
   AL_VOCAL_MORPHER_PHONEME_L
   AL_VOCAL_MORPHER_PHONEME_M
   AL_VOCAL_MORPHER_PHONEME_N
   AL_VOCAL_MORPHER_PHONEME_P
   AL_VOCAL_MORPHER_PHONEME_R
   AL_VOCAL_MORPHER_PHONEME_S
   AL_VOCAL_MORPHER_PHONEME_T
   AL_VOCAL_MORPHER_PHONEME_V
   AL_VOCAL_MORPHER_PHONEME_Z
   AL_VOCAL_MORPHER_MIN_PHONEMEB_COARSE_TUNING = -24
   AL_VOCAL_MORPHER_MAX_PHONEMEB_COARSE_TUNING = 24
   AL_VOCAL_MORPHER_DEFAULT_PHONEMEB_COARSE_TUNING = 0
   AL_VOCAL_MORPHER_MIN_WAVEFORM = 0
   AL_VOCAL_MORPHER_MAX_WAVEFORM = 2
   AL_VOCAL_MORPHER_DEFAULT_WAVEFORM = 0
   AL_VOCAL_MORPHER_WAVEFORM_SINUSOID = 0
   AL_VOCAL_MORPHER_WAVEFORM_TRIANGLE
   AL_VOCAL_MORPHER_WAVEFORM_SAWTOOTH
   AL_VOCAL_MORPHER_MIN_RATE = 0.0
   AL_VOCAL_MORPHER_MAX_RATE = 10.0
   AL_VOCAL_MORPHER_DEFAULT_RATE = 1.41

   ' AL pitch shifter effect parameter ranges and defaults
   AL_PITCH_SHIFTER_MIN_COARSE_TUNE = -12
   AL_PITCH_SHIFTER_MAX_COARSE_TUNE = 12
   AL_PITCH_SHIFTER_DEFAULT_COARSE_TUNE = 12
   AL_PITCH_SHIFTER_MIN_FINE_TUNE = -50
   AL_PITCH_SHIFTER_MAX_FINE_TUNE = 50
   AL_PITCH_SHIFTER_DEFAULT_FINE_TUNE = 0

   ' AL ring modulator effect parameter ranges and defaults
   AL_RING_MODULATOR_MIN_FREQUENCY = 0.0
   AL_RING_MODULATOR_MAX_FREQUENCY = 8000.0
   AL_RING_MODULATOR_DEFAULT_FREQUENCY = 440.0
   AL_RING_MODULATOR_MIN_HIGHPASS_CUTOFF = 0.0
   AL_RING_MODULATOR_MAX_HIGHPASS_CUTOFF = 24000.0
   AL_RING_MODULATOR_DEFAULT_HIGHPASS_CUTOFF = 800.0
   AL_RING_MODULATOR_MIN_WAVEFORM = 0
   AL_RING_MODULATOR_MAX_WAVEFORM = 2
   AL_RING_MODULATOR_DEFAULT_WAVEFORM = 0
   AL_RING_MODULATOR_SINUSOID = 0
   AL_RING_MODULATOR_SAWTOOTH
   AL_RING_MODULATOR_SQUARE

   ' AL autowah effect parameter ranges and defaults
   AL_AUTOWAH_MIN_ATTACK_TIME = 0.0001
   AL_AUTOWAH_MAX_ATTACK_TIME = 1.0
   AL_AUTOWAH_DEFAULT_ATTACK_TIME = 0.06
   AL_AUTOWAH_MIN_RELEASE_TIME = 0.0001
   AL_AUTOWAH_MAX_RELEASE_TIME = 1.0
   AL_AUTOWAH_DEFAULT_RELEASE_TIME = 0.06
   AL_AUTOWAH_MIN_RESONANCE = 2.0
   AL_AUTOWAH_MAX_RESONANCE = 1000.0
   AL_AUTOWAH_DEFAULT_RESONANCE = 1000.0
   AL_AUTOWAH_MIN_PEAK_GAIN = 0.00003
   AL_AUTOWAH_MAX_PEAK_GAIN = 31621.0
   AL_AUTOWAH_DEFAULT_PEAK_GAIN = 11.22

   ' AL compressor effect parameter ranges and defaults
   AL_COMPRESSOR_MIN_ONOFF = 0
   AL_COMPRESSOR_MAX_ONOFF = 1
   AL_COMPRESSOR_DEFAULT_ONOFF = 1

   ' AL equalizer effect parameter ranges and defaults
   AL_EQUALIZER_MIN_LOW_GAIN = 0.126
   AL_EQUALIZER_MAX_LOW_GAIN = 7.943
   AL_EQUALIZER_DEFAULT_LOW_GAIN = 1.0
   AL_EQUALIZER_MIN_LOW_CUTOFF = 50.0
   AL_EQUALIZER_MAX_LOW_CUTOFF = 800.0
   AL_EQUALIZER_DEFAULT_LOW_CUTOFF = 200.0
   AL_EQUALIZER_MIN_MID1_GAIN = 0.126
   AL_EQUALIZER_MAX_MID1_GAIN = 7.943
   AL_EQUALIZER_DEFAULT_MID1_GAIN = 1.0
   AL_EQUALIZER_MIN_MID1_CENTER = 200.0
   AL_EQUALIZER_MAX_MID1_CENTER = 3000.0
   AL_EQUALIZER_DEFAULT_MID1_CENTER = 500.0
   AL_EQUALIZER_MIN_MID1_WIDTH = 0.01
   AL_EQUALIZER_MAX_MID1_WIDTH = 1.0
   AL_EQUALIZER_DEFAULT_MID1_WIDTH = 1.0
   AL_EQUALIZER_MIN_MID2_GAIN = 0.126
   AL_EQUALIZER_MAX_MID2_GAIN = 7.943
   AL_EQUALIZER_DEFAULT_MID2_GAIN = 1.0
   AL_EQUALIZER_MIN_MID2_CENTER = 1000.0
   AL_EQUALIZER_MAX_MID2_CENTER = 8000.0
   AL_EQUALIZER_DEFAULT_MID2_CENTER = 3000.0
   AL_EQUALIZER_MIN_MID2_WIDTH = 0.01
   AL_EQUALIZER_MAX_MID2_WIDTH = 1.0
   AL_EQUALIZER_DEFAULT_MID2_WIDTH = 1.0
   AL_EQUALIZER_MIN_HIGH_GAIN = 0.126
   AL_EQUALIZER_MAX_HIGH_GAIN = 7.943
   AL_EQUALIZER_DEFAULT_HIGH_GAIN = 1.0
   AL_EQUALIZER_MIN_HIGH_CUTOFF = 4000.0
   AL_EQUALIZER_MAX_HIGH_CUTOFF = 16000.0
   AL_EQUALIZER_DEFAULT_HIGH_CUTOFF = 6000.0

   ' Source parameter value definitions, ranges and defaults
   AL_MIN_AIR_ABSORPTION_FACTOR = 0.0
   AL_MAX_AIR_ABSORPTION_FACTOR = 10.0
   AL_DEFAULT_AIR_ABSORPTION_FACTOR = 0.0
   AL_MIN_ROOM_ROLLOFF_FACTOR = 0.0
   AL_MAX_ROOM_ROLLOFF_FACTOR = 10.0
   AL_DEFAULT_ROOM_ROLLOFF_FACTOR = 0.0
   AL_MIN_CONE_OUTER_GAINHF = 0.0
   AL_MAX_CONE_OUTER_GAINHF = 1.0
   AL_DEFAULT_CONE_OUTER_GAINHF = 1.0
   AL_MIN_DIRECT_FILTER_GAINHF_AUTO = 0
   AL_MAX_DIRECT_FILTER_GAINHF_AUTO
   AL_DEFAULT_DIRECT_FILTER_GAINHF_AUTO = 1
   AL_MIN_AUXILIARY_SEND_FILTER_GAIN_AUTO = 0
   AL_MAX_AUXILIARY_SEND_FILTER_GAIN_AUTO
   AL_DEFAULT_AUXILIARY_SEND_FILTER_GAIN_AUTO = 1
   AL_MIN_AUXILIARY_SEND_FILTER_GAINHF_AUTO = 0
   AL_MAX_AUXILIARY_SEND_FILTER_GAINHF_AUTO
   AL_DEFAULT_AUXILIARY_SEND_FILTER_GAINHF_AUTO = 1

   ' Listener parameter value definitions, ranges and defaults
   AL_MIN_METERS_PER_UNIT = 1.175494e-38
   AL_MAX_METERS_PER_UNIT = 999999999.9
   AL_DEFAULT_METERS_PER_UNIT = 1.0

   ' *** Effect object definitions to be used with alEffect functions (Creative)

   ' AL EAXReverb effect parameters
   AL_EAXREVERB_DENSITY = 1
   AL_EAXREVERB_DIFFUSION
   AL_EAXREVERB_GAIN
   AL_EAXREVERB_GAINHF
   AL_EAXREVERB_GAINLF
   AL_EAXREVERB_DECAY_TIME
   AL_EAXREVERB_DECAY_HFRATIO
   AL_EAXREVERB_DECAY_LFRATIO
   AL_EAXREVERB_REFLECTIONS_GAIN
   AL_EAXREVERB_REFLECTIONS_DELAY
   AL_EAXREVERB_REFLECTIONS_PAN
   AL_EAXREVERB_LATE_REVERB_GAIN
   AL_EAXREVERB_LATE_REVERB_DELAY
   AL_EAXREVERB_LATE_REVERB_PAN
   AL_EAXREVERB_ECHO_TIME
   AL_EAXREVERB_ECHO_DEPTH
   AL_EAXREVERB_MODULATION_TIME
   AL_EAXREVERB_MODULATION_DEPTH
   AL_EAXREVERB_AIR_ABSORPTION_GAINHF
   AL_EAXREVERB_HFREFERENCE
   AL_EAXREVERB_LFREFERENCE
   AL_EAXREVERB_ROOM_ROLLOFF_FACTOR
   AL_EAXREVERB_DECAY_HFLIMIT

   ' Effect type definitions to be used with AL_EFFECT_TYPE
   AL_EFFECT_EAXREVERB = &H8000

   ' *** Effect parameter structures, value definitions, ranges and defaults (Creative)

   ' AL reverb effect parameter ranges and defaults
   AL_EAXREVERB_MIN_DENSITY = 0.0
   AL_EAXREVERB_MAX_DENSITY = 1.0
   AL_EAXREVERB_DEFAULT_DENSITY = 1.0
   AL_EAXREVERB_MIN_DIFFUSION = 0.0
   AL_EAXREVERB_MAX_DIFFUSION = 1.0
   AL_EAXREVERB_DEFAULT_DIFFUSION = 1.0
   AL_EAXREVERB_MIN_GAIN = 0.0
   AL_EAXREVERB_MAX_GAIN = 1.0
   AL_EAXREVERB_DEFAULT_GAIN = 0.32
   AL_EAXREVERB_MIN_GAINHF = 0.0
   AL_EAXREVERB_MAX_GAINHF = 1.0
   AL_EAXREVERB_DEFAULT_GAINHF = 0.89
   AL_EAXREVERB_MIN_GAINLF = 0.0
   AL_EAXREVERB_MAX_GAINLF = 1.0
   AL_EAXREVERB_DEFAULT_GAINLF = 1.0
   AL_EAXREVERB_MIN_DECAY_TIME = 0.1
   AL_EAXREVERB_MAX_DECAY_TIME = 20.0
   AL_EAXREVERB_DEFAULT_DECAY_TIME = 1.49
   AL_EAXREVERB_MIN_DECAY_HFRATIO = 0.1
   AL_EAXREVERB_MAX_DECAY_HFRATIO = 2.0
   AL_EAXREVERB_DEFAULT_DECAY_HFRATIO = 0.83
   AL_EAXREVERB_MIN_DECAY_LFRATIO = 0.1
   AL_EAXREVERB_MAX_DECAY_LFRATIO = 2.0
   AL_EAXREVERB_DEFAULT_DECAY_LFRATIO = 1.0
   AL_EAXREVERB_MIN_REFLECTIONS_GAIN = 0.0
   AL_EAXREVERB_MAX_REFLECTIONS_GAIN = 3.16
   AL_EAXREVERB_DEFAULT_REFLECTIONS_GAIN = 0.05
   AL_EAXREVERB_MIN_REFLECTIONS_DELAY = 0.0
   AL_EAXREVERB_MAX_REFLECTIONS_DELAY = 0.3
   AL_EAXREVERB_DEFAULT_REFLECTIONS_DELAY = 0.007
   AL_EAXREVERB_DEFAULT_REFLECTIONS_PAN_XYZ = 0.0
   AL_EAXREVERB_MIN_LATE_REVERB_GAIN = 0.0
   AL_EAXREVERB_MAX_LATE_REVERB_GAIN = 10.0
   AL_EAXREVERB_DEFAULT_LATE_REVERB_GAIN = 1.26
   AL_EAXREVERB_MIN_LATE_REVERB_DELAY = 0.0
   AL_EAXREVERB_MAX_LATE_REVERB_DELAY = 0.1
   AL_EAXREVERB_DEFAULT_LATE_REVERB_DELAY = 0.011
   AL_EAXREVERB_DEFAULT_LATE_REVERB_PAN_XYZ = 0.0
   AL_EAXREVERB_MIN_ECHO_TIME = 0.075
   AL_EAXREVERB_MAX_ECHO_TIME = 0.25
   AL_EAXREVERB_DEFAULT_ECHO_TIME = 0.25
   AL_EAXREVERB_MIN_ECHO_DEPTH = 0.0
   AL_EAXREVERB_MAX_ECHO_DEPTH = 1.0
   AL_EAXREVERB_DEFAULT_ECHO_DEPTH = 0.0
   AL_EAXREVERB_MIN_MODULATION_TIME = 0.04
   AL_EAXREVERB_MAX_MODULATION_TIME = 4.0
   AL_EAXREVERB_DEFAULT_MODULATION_TIME = 0.25
   AL_EAXREVERB_MIN_MODULATION_DEPTH = 0.0
   AL_EAXREVERB_MAX_MODULATION_DEPTH = 1.0
   AL_EAXREVERB_DEFAULT_MODULATION_DEPTH = 0.0
   AL_EAXREVERB_MIN_AIR_ABSORPTION_GAINHF = 0.892
   AL_EAXREVERB_MAX_AIR_ABSORPTION_GAINHF = 1.0
   AL_EAXREVERB_DEFAULT_AIR_ABSORPTION_GAINHF = 0.994
   AL_EAXREVERB_MIN_HFREFERENCE = 1000.0
   AL_EAXREVERB_MAX_HFREFERENCE = 20000.0
   AL_EAXREVERB_DEFAULT_HFREFERENCE = 5000.0
   AL_EAXREVERB_MIN_LFREFERENCE = 20.0
   AL_EAXREVERB_MAX_LFREFERENCE = 1000.0
   AL_EAXREVERB_DEFAULT_LFREFERENCE = 250.0
   AL_EAXREVERB_MIN_ROOM_ROLLOFF_FACTOR = 0.0
   AL_EAXREVERB_MAX_ROOM_ROLLOFF_FACTOR = 10.0
   AL_EAXREVERB_DEFAULT_ROOM_ROLLOFF_FACTOR = 0.0
   AL_EAXREVERB_MIN_DECAY_HFLIMIT = 0
   AL_EAXREVERB_MAX_DECAY_HFLIMIT
   AL_EAXREVERB_DEFAULT_DECAY_HFLIMIT = 1

End Enum

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
