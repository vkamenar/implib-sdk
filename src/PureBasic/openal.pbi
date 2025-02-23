; The following constants were ported from the original OpenAL (Open Audio Library) SDK.

; bad value
#AL_INVALID = -1
#ALC_INVALID = 0

#AL_NONE = 0

; Boolean False
#AL_FALSE = 0
#ALC_FALSE = 0

; Boolean True
#AL_TRUE = 1
#ALC_TRUE = 1

; Indicate Source has relative coordinates
#AL_SOURCE_RELATIVE = $202

; Directional source, inner cone angle, in degrees
#AL_CONE_INNER_ANGLE = $1001

; Directional source, outer cone angle, in degrees
#AL_CONE_OUTER_ANGLE = $1002

; Specify the pitch to be applied at source
#AL_PITCH = $1003

; Specify the current location in 3D space
#AL_POSITION = $1004

; Specify the current direction
#AL_DIRECTION = $1005

; Specify the current velocity in 3D space
#AL_VELOCITY = $1006

; Indicate whether source is looping
#AL_LOOPING = $1007

; Indicate the buffer to provide sound samples
#AL_BUFFER = $1009

; Indicate the gain (volume amplification) applied
#AL_GAIN = $100A

; Indicate minimum source attenuation
#AL_MIN_GAIN = $100D

; Indicate maximum source attenuation
#AL_MAX_GAIN = $100E

; Indicate listener orientation
#AL_ORIENTATION = $100F

; Specify the channel mask (Creative)
#AL_CHANNEL_MASK = $3000

; Source state information
#AL_SOURCE_STATE = $1010
#AL_INITIAL = $1011
#AL_PLAYING = $1012
#AL_PAUSED = $1013
#AL_STOPPED = $1014

; Buffer queue params
#AL_BUFFERS_QUEUED = $1015
#AL_BUFFERS_PROCESSED = $1016

; Source buffer position information
#AL_SEC_OFFSET = $1024
#AL_SAMPLE_OFFSET = $1025
#AL_BYTE_OFFSET = $1026

; Source type: static, streaming or undetermined
; Source is static if a buffer has been attached using AL_BUFFER
; Source is streaming if one or more buffers have been attached using alSourceQueueBuffers
; Source is undetermined when it has the NULL buffer attached
#AL_SOURCE_TYPE = $1027
#AL_STATIC = $1028
#AL_STREAMING = $1029
#AL_UNDETERMINED = $1030

; Sound samples: format specifier
#AL_FORMAT_MONO8 = $1100
#AL_FORMAT_MONO16 = $1101
#AL_FORMAT_STEREO8 = $1102
#AL_FORMAT_STEREO16 = $1103

; Source specific reference distance
#AL_REFERENCE_DISTANCE = $1020

; Source specific rolloff factor
#AL_ROLLOFF_FACTOR = $1021

; Directional source, outer cone gain
#AL_CONE_OUTER_GAIN = $1022

; Indicate distance above which sources are not attenuated using the inverse clamped distance model
#AL_MAX_DISTANCE = $1023

; Sound samples per second: frequency, in units of Hertz [Hz]
; Half of the sample frequency marks the maximum significant frequency component
#AL_FREQUENCY = $2001

#AL_BITS = $2002
#AL_CHANNELS = $2003
#AL_SIZE = $2004

; Buffer state
#AL_UNUSED = $2010
#AL_PENDING = $2011
#AL_PROCESSED = $2012

; Errors: No Error
#AL_NO_ERROR = 0
#ALC_NO_ERROR = 0

; Invalid name paramater passed to AL call
#AL_INVALID_NAME = $A001

; The specified device is not a valid output device
#ALC_INVALID_DEVICE = $A001

; Invalid enum passed to AL call
#AL_ILLEGAL_ENUM = $A002
#AL_INVALID_ENUM = $A002
#ALC_INVALID_ENUM = $A003

; The specified context is invalid
#ALC_INVALID_CONTEXT = $A002

; Invalid value passed to AL call
#AL_INVALID_VALUE = $A003
#ALC_INVALID_VALUE = $A004

; Illegal call
#AL_ILLEGAL_COMMAND = $A004
#AL_INVALID_OPERATION = $A004

; Requested operation resulted in AL running out of memory
#AL_OUT_OF_MEMORY = $A005
#ALC_OUT_OF_MEMORY = $A005

; Context strings: Vendor Name
#AL_VENDOR = $B001

#AL_VERSION = $B002
#AL_RENDERER = $B003
#AL_EXTENSIONS = $B004

; Global tweakage

; Doppler scale
#AL_DOPPLER_FACTOR = $C000

; Tweaks speed of propagation
#AL_DOPPLER_VELOCITY = $C001

; Speed of sound in units per second
#AL_SPEED_OF_SOUND = $C003

; Distance models
#AL_DISTANCE_MODEL = $D000
#AL_INVERSE_DISTANCE = $D001
#AL_INVERSE_DISTANCE_CLAMPED = $D002
#AL_LINEAR_DISTANCE = $D003
#AL_LINEAR_DISTANCE_CLAMPED = $D004
#AL_EXPONENT_DISTANCE = $D005
#AL_EXPONENT_DISTANCE_CLAMPED = $D006

; Output frequency in Hz
#ALC_FREQUENCY = $1007

; Rate of context processing
#ALC_REFRESH = $1008

; Flag indicating a synchronous context
#ALC_SYNC = $1009

; Num of requested mono (3D) sources
#ALC_MONO_SOURCES = $1010

; Num of requested stereo sources
#ALC_STEREO_SOURCES = $1011

; The name of the default output device
#ALC_DEFAULT_DEVICE_SPECIFIER = $1004

; The name of the specified output device
#ALC_DEVICE_SPECIFIER = $1005

; The available context extensions
#ALC_EXTENSIONS = $1006

#ALC_MAJOR_VERSION = $1000
#ALC_MINOR_VERSION = $1001
#ALC_ATTRIBUTES_SIZE = $1002
#ALC_ALL_ATTRIBUTES = $1003

; Use with alcGetString with a NULL device ID to retrieve the name of the default device
#ALC_DEFAULT_ALL_DEVICES_SPECIFIER = $1012

; Use with alcGetString and a NULL device pointer to retrieve the names of all devices and audio output paths
#ALC_ALL_DEVICES_SPECIFIER = $1013

; Return the name of the specified capture device or a list of all available devices (if a NULL device pointer is supplied)
#ALC_CAPTURE_DEVICE_SPECIFIER = $310

; Use with alcGetString with a NULL device ID to retrieve the name of the default capture device
#ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER = $311

#ALC_CAPTURE_SAMPLES = $312
