## *freenect2* - Nim bindings for libfreenect2, the the cross-platform library
## for Kinect for Windows v2.
##
## This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
## See the file LICENSE included in this distribution for licensing details.
## GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.

{.deadCodeElim: on.}


when defined(linux):
  const dllname = "freenect2.so"
elif defined(macosx):
  const dllname = "freenect2.dylib"
elif defined(windows):
  const dllname = "freenect2.dll"
else:
  {.error: "freenect2 does not support this platform".}


type
  Freenect2DeviceAttributes* = object
    ## A struct used in enumeration to give access to serial numbers, so you can
    ## open a particular device by serial rather than depending on index. This
    ## is most useful if you have more than one Kinect.
    cameraSerial*: cstring ## Serial number of this device's camera subdevice.


type
  Freenect2Resolution* {.pure, size: sizeof(cint).} = enum ## \
    ## Enumeration of available resolutions.
    ##
    ## Not all available resolutions are actually supported for all video
    ## formats. Frame modes may not perfectly match resolutions.
    res512x424 = 0,
    res1920x1080 = 1


  Freenect2VideoFormat* {.pure, size: sizeof(cint).} = enum ## \
    ## Enumeration of video frame formats.
    rgb = 0  ## Decompressed RGB mode.


const
  Freenect2VideoFormatYuv* = Freenect2VideoFormat.rgb ## Decompressed YUV mode.
  Freenect2VideoFormatRaw* = Freenect2VideoFormat.rgb ## Raw JPEG data mode.


type
  Freenect2IrFormat* {.pure, size: sizeof(cint).} = enum ## \
    ## Enumeration of ir frame formats.
    raw = 5 ## Raw infrared data.


  Freenect2DepthFormat* {.pure, size: sizeof(cint).} = enum ## \
    ## Enumeration of depth frame formats
    mm = 5  ## depth to each pixel in mm, but left unaligned to RGB image.


  Freenect2Flag* {.pure, size: sizeof(cint).} = enum ## \
    ## Enumeration of flags to toggle features with freenect2SetFlag.
    mirrorDepth = 1 shl 16,
    mirrorVideo = 1 shl 17


  Freenect2FlagValue* {.pure, size: sizeof(cint).} = enum ## \
    ## Possible values for setting each `Freenect2Flag <#Freenect2Flag>`_.
    off = 0,
    on = 1


type
  Freenect2FrameModeFormat* = object {.union.}
    ## Format data for the `Freenect2FrameMode.format <#Freenect2FrameMode>`_
    ## field.
    dummy*: cint
    videoFormat*: Freenect2VideoFormat
    irFormat*: Freenect2IrFormat
    depthFormat*: Freenect2DepthFormat

  Freenect2FrameMode* = object
    ## Structure to give information about the width, height, bitrate,
    ## framerate, and buffer size of a frame in a particular mode, as
    ## well as the total number of bytes needed to hold a single frame.
    reserved*: cuint ## Unique ID used internally. The meaning of values may
      ## change without notice. Don't touch or depend on the contents of this
      ## field. We mean it.
    resolution*: Freenect2Resolution ## Resolution that this object describes,
      ## should you want to find it again with `freenect2Find*FrameMode()`.
    format*: Freenect2FrameModeFormat ## Format data.
    bytes*: cint ## Total buffer size in bytes to hold a single frame of data.
      ## Should be equivalent to:
      ## `width * height * (data_bits_per_pixel+padding_bits_per_pixel) / 8`
    width*: cshort ## Width of the frame, in pixels.
    height*: cshort ## Height of the frame, in pixels.
    dataBitsPerPixel*: cchar ## Number of bits of information needed for each
      ## pixel.
    paddingBitsPerPixel*: cchar ## Number of bits of padding for alignment used
      ## for each pixel.
    framerate*: cchar ## Approximate expected frame rate, in Hz.
    isValid*: cchar ## If 0, this Freenect2FrameMode is invalid and does not
      ## describe a supported mode.  Otherwise, the frame_mode is valid.


  Freenect2Context* = object
    ## Holds information about the usb context.


  Freenect2Device* = object
    ## Holds device information.


  Freenect2UsbContext* = ptr
    ## Holds libusb-1.0 context.


type
  Freenect2Loglevel* {.pure, size: sizeof(cint).} = enum ## \
    ## Enumeration of message logging levels.
    fatal = 0,  ## Log for crashing/non-recoverable errors.
    error, ## Log for major errors.
    warning, ## Log for warning messages.
    notice, ## Log for important messages.
    info, ## Log for normal messages.
    debug, ## Log for useful development messages.
    spew, ## Log for slightly less useful messages.
    flood ## Log EVERYTHING. May slow performance.


proc freenect2Init*(ctx: ptr ptr Freenect2Context;
  usbCtx: Freenect2UsbContext): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_init".}
  ## Initialize a freenect2 context and do any setup required for platform
  ## specific USB libraries.
  ##
  ## ctx
  ##   Address of pointer to freenect2 context struct to allocate and initialize
  ## usbCtx
  ##   USB context to initialize. Can be `nil` if not using multiple contexts.
  ## result
  ##   - `0` on success
  ##   - `< 0` on error


proc freenect2Shutdown*(ctx: ptr Freenect2Context): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_shutdown".}
  ## Close the device if it is open, and free the context.
  ##
  ## ctx
  ##   freenect2 context to close/free
  ## result
  ##   - `0` on success


type
  Freenect2LogCb* = proc (dev: ptr Freenect2Context; level: Freenect2Loglevel;
    msg: cstring)
    ## Typedef for logging callback functions.


proc freenect2SetLogLevel*(ctx: ptr Freenect2Context; level: Freenect2Loglevel)
  {.cdecl, dynlib: dllname, importc: "freenect2_set_log_level".}
  ## Set the log level for the specified freenect2 context.
  ##
  ## ctx
  ##   Context to set log level for
  ## level
  ##   Log level to use


proc freenect2SetLogCallback*(ctx: ptr Freenect2Context; cb: Freenect2LogCb)
  {.cdecl, dynlib: dllname, importc: "freenect2_set_log_callback".}
  ## Callback for log messages (i.e. for rerouting to a file instead of stdout).
  ##
  ## ctx
  ##   Context to set log callback for
  ## cb
  ##   callback function pointer


proc freenect2NumDevices*(ctx: ptr Freenect2Context): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_num_devices".}
  ## Scan for Kinect devices and return the number of Kinect devices currently
  ## connected to the system.
  ##
  ## ctx
  ##   Context to access device count through
  ## result
  ##   - Number of devices connected on success
  ##   - `< 0` on error


proc freenect2GetDeviceAttributes*(ctx: ptr Freenect2Context; index: cint):
  Freenect2DeviceAttributes
  {.cdecl, dynlib: dllname, importc: "freenect2_get_device_attributes".}
  ## Get the attributes of a kinect device at a given index.
  ##
  ## ctx
  ##   Context to access device attributes through
  ## index
  ##   Index of the kinect device
  ## result
  ##   - Number of devices connected on success
  ##   - `< 0` on error


proc freenect2OpenDevice*(ctx: ptr Freenect2Context;
  dev: ptr ptr Freenect2Device; index: cint): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_open_device".}
  ## Open a kinect device via a context.
  ##
  ## ctx
  ##   Context to open device through
  ## dev
  ##   Device structure to assign opened device to
  ## index
  ##   Index of the device on the bus
  ## result
  ##   - `0` on success
  ##   - `< 0` on error
  ##
  ## Index specifies the index of the device on the current state of the bus.
  ## Bus resets may cause indexes to shift.


proc freenect2OpenDeviceByCameraSerial*(ctx: ptr Freenect2Context;
  dev: ptr ptr Freenect2Device; cameraSerial: cstring): cint
  {.cdecl, dynlib: dllname, importc: "freenect2OpenDevice_by_camera_serial".}
  ## Open a kinect device (via a context) associated with a particular camera
  ## subdevice serial number.
  ##
  ## ctx
  ##   Context to open device through
  ## dev
  ##   Device structure to assign opened device to
  ## cameraSerial
  ##   Null-terminated ASCII string containing the serial number of the camera
  ##   subdevice in the device to open
  ## result
  ##   - `0` on success
  ##   - `< 0` on error
  ##
  ## This function will fail if no device with a matching serial number is found.


proc freenect2CloseDevice*(dev: ptr Freenect2Device): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_close_device".}
  ## Close a device that is currently open.
  ##
  ## dev
  ##   Device to close
  ## result
  ##   - `0` on success


type
  Freenect2DepthCb* = proc (dev: ptr Freenect2Device; timestamp: cuint;
    depth: pointer; user: pointer)
    ## Typedef for depth image received event callbacks.


  Freenect2IrCb* = proc (dev: ptr Freenect2Device; timestamp: cuint;
    ir: pointer; user: pointer)
    ## Typedef for ir image received event callbacks.


  Freenect2VideoCb* = proc (dev: ptr Freenect2Device; timestamp: cuint;
    video: pointer; user: pointer)
    ## Typedef for video image received event callbacks.


proc freenect2SetDepthCallback*(dev: ptr Freenect2Device;
  cb: Freenect2DepthCb; user: pointer)
  {.cdecl, dynlib: dllname, importc: "freenect2_set_depth_callback".}
  ## Set callback for depth information received event.
  ##
  ## dev
  ##   Device to set callback for
  ## cb
  ##   Function pointer for processing depth information
  ## user
  ##   Pointer to user data


proc freenect2SetIrCallback*(dev: ptr Freenect2Device; cb: Freenect2IrCb;
  user: pointer)
  {.cdecl, dynlib: dllname, importc: "freenect2_set_ir_callback".}
  ## Set callback for ir information received event.
  ##
  ## dev
  ##   Device to set callback for
  ## cb
  ##   Function pointer for processing depth information
  ## user
  ##   Pointer to user data


proc freenect2SetVideoCallback*(dev: ptr Freenect2Device;
                                   cb: Freenect2VideoCb; user: pointer)
  {.cdecl, dynlib: dllname, importc: "freenect2_set_video_callback".}
  ## Set callback for video information received event.
  ##
  ## dev
  ##   Device to set callback for
  ## cb
  ##   Function pointer for processing video information
  ## user
  ##   Pointer to user data


proc freenect2StartDepth*(dev: ptr Freenect2Device): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_start_depth".}
  ## Start the depth information stream for a device.
  ##
  ## dev
  ##   Device to start depth information stream for.
  ## result
  ##   - `0` on success
  ##   - `< 0` on error


proc freenect2StartIr*(dev: ptr Freenect2Device): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_start_ir".}
  ## Start the ir information stream for a device.
  ##
  ## dev
  ##   Device to start ir information stream for.
  ## result
  ##   - `0` on success
  ##   - `< 0` on error


proc freenect2StartVideo*(dev: ptr Freenect2Device): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_start_video".}
  ## Start the video information stream for a device.
  ##
  ## dev
  ##   Device to start video information stream for
  ## result
  ##   - `0` on success
  ##    - `< 0` on error


proc freenect2StopDepth*(dev: ptr Freenect2Device): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_stop_depth".}
  ## Stop the depth information stream for a device.
  ##
  ## dev
  ##   Device to stop depth information stream on
  ## result
  ##   `0` on success
  ##    `< 0` on error


proc freenect2StopIr*(dev: ptr Freenect2Device): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_stop_ir".}
  ## Stop the ir information stream for a device.
  ##
  ## dev
  ##   Device to stop ir information stream on
  ## result
  ##   - `0` on success
  ##   - `< 0` on error


proc freenect2StopVideo*(dev: ptr Freenect2Device): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_stop_video".}
  ## Stop the video information stream for a device.
  ##
  ## dev
  ##   Device to stop video information stream on.
  ## result
  ##   - `0` on success
  ##   - `< 0` on error


proc freenect2GetVideoModeCount*(): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_get_video_mode_count".}
  ## Get the number of video camera modes supported by the driver.
  ##
  ## result
  ##   - Number of video modes supported by the driver


proc freenect2GetVideoMode*(modeNum: cint): Freenect2FrameMode
  {.cdecl, dynlib: dllname, importc: "freenect2_get_video_mode".}
  ## Get the frame descriptor of the nth supported video mode for the video
  ## camera.
  ##
  ## modeNum
  ##   Which of the supported modes to return information about
  ## result
  ##   - A Freenect2FrameMode describing the nth video mode


proc freenect2GetCurrentVideoMode*(dev: ptr Freenect2Device): Freenect2FrameMode
  {.cdecl, dynlib: dllname, importc: "freenect2_get_current_video_mode".}
  ## Get the frame descriptor of the current video mode for the specified
  ## freenect device.
  ##
  ## dev
  ##   Which device to return the currently-set video mode for
  ## result
  ##   - A Freenect2FrameMode describing the current video mode of the specified
  ##     device


proc freenect2FindVideoMode*(res: Freenect2Resolution;
  fmt: Freenect2VideoFormat): Freenect2FrameMode
  {.cdecl, dynlib: dllname, importc: "freenect2_find_video_mode".}
  ## Convenience function to return a mode descriptor matching the specified
  ## resolution and video camera pixel format, if one exists.
  ##
  ## res
  ##   Resolution desired
  ## fmt
  ##   Pixel format desired
  ## result
  ##   - A Freenect2FrameMode that matches the arguments specified, if such a
  ##     valid mode exists
  ##   - An invalid Freenect2FrameMode otherwise


proc freenect2SetVideoMode*(dev: ptr Freenect2Device; mode: Freenect2FrameMode):
  cint {.cdecl, dynlib: dllname, importc: "freenect2_set_video_mode".}
  ## Set the current video mode for the specified device.
  ##
  ## dev
  ##   Device for which to set the video mode
  ## mode
  ##   Frame mode to set
  ## result
  ##   - `0` on success
  ##   - `< 0` if error
  ##
  ## If the Freenect2FrameMode specified is not one provided by the driver
  ##  e.g. from `freenect2GetVideoMode <#freenect2GetVideoMode>`_ or
  ##  `freenect2FindVideoMode <#freenect2FindVideoMode>`_ then behavior is
  ## undefined.  The current video mode cannot be changed while streaming is
  ## active.


proc freenect2GetIrModeCount*(): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_get_ir_mode_count".}
  ## Get the number of ir camera modes supported by the driver.
  ##
  ## result
  ##   - Number of IR modes supported by the driver


proc freenect2GetIrMode*(modeNum: cint): Freenect2FrameMode
  {.cdecl, dynlib: dllname, importc: "freenect2_get_ir_mode".}
  ## Get the frame descriptor of the nth supported ir mode for the IR camera.
  ##
  ## modeNum
  ##   Which of the supported modes to return information about
  ## result
  ##   - A Freenect2FrameMode describing the nth IR mode


proc freenect2GetCurrentIrMode*(dev: ptr Freenect2Device): Freenect2FrameMode
  {.cdecl, dynlib: dllname, importc: "freenect2_get_current_ir_mode".}
  ## Get the frame descriptor of the current ir mode for the specified
  ## freenect device.
  ##
  ## dev
  ##   Which device to return the currently-set ir mode for
  ## result
  ##   - A Freenect2FrameMode describing the ir video mode of the specified
  ##     device


proc freenect2FindIrMode*(res: Freenect2Resolution; fmt: Freenect2IrFormat):
  Freenect2FrameMode
  {.cdecl, dynlib: dllname, importc: "freenect2_find_ir_mode".}
  ## Convenience function to return a mode descriptor matching the specified
  ## resolution and ir camera pixel format, if one exists.
  ##
  ## res
  ##   Resolution desired
  ## fmt
  ##   Pixel format desired
  ## result
  ##   - A Freenect2FrameMode that matches the arguments specified, if such a
  ##     valid mode exists
  ##   - An invalid Freenect2FrameMode otherwise


proc freenect2SetIrMode*(dev: ptr Freenect2Device;
                            mode: Freenect2FrameMode): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_set_ir_mode".}
  ## Sets the current ir mode for the specified device.
  ##
  ## dev
  ##   Device for which to set the ir mode
  ## mode
  ##   Frame mode to set
  ## result
  ##   - `0` on success
  ##   - `< 0` if error
  ##
  ## If the Freenect2FrameMode specified is not one provided by the driver
  ##  e.g. from `freenect2GetIrMode <#freenect2GetIrMode>`_ or
  ## `freenect2FindIrMode <#freenect2FindIrMode>`_ then behavior is undefined.
  ## The current ir mode cannot be changed while streaming is active.


proc freenect2GetDepthModeCount*(): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_get_depth_mode_count".}
  ## Get the number of depth camera modes supported by the driver.
  ##
  ## result
  ##   Number of depth modes supported by the driver


proc freenect2GetDepthMode*(modeNum: cint): Freenect2FrameMode
  {.cdecl, dynlib: dllname, importc: "freenect2_get_depth_mode".}
  ## Get the frame descriptor of the nth supported depth mode for the depth
  ## camera.
  ##
  ## modeNum
  ##   Which of the supported modes to return information about
  ## result
  ##   - A Freenect2FrameMode describing the nth depth mode


proc freenect2GetCurrentDepthMode*(dev: ptr Freenect2Device): Freenect2FrameMode
  {.cdecl, dynlib: dllname, importc: "freenect2_get_current_depth_mode".}
  ## Get the frame descriptor of the current depth mode for the specified
  ## freenect2 device.
  ##
  ## dev
  ##   Which device to return the currently-set depth mode for
  ## result
  ##   A Freenect2FrameMode describing the current depth mode of the specified
  ##   device


proc freenect2FindDepthMode*(res: Freenect2Resolution;
  fmt: Freenect2DepthFormat): Freenect2FrameMode
  {.cdecl, dynlib: dllname, importc: "freenect2_find_depth_mode".}
  ## Convenience function to return a mode descriptor matching the specified
  ## resolution and depth camera pixel format, if one exists.
  ##
  ## res
  ##   Resolution desired
  ## fmt
  ##   Pixel format desired
  ## result
  ##   - A Freenect2FrameMode that matches the arguments specified, if such a
  ##     valid mode exists
  ##   - An invalid Freenect2FrameMode otherwise


proc freenect2SetDepthMode*(dev: ptr Freenect2Device;
  mode: Freenect2FrameMode): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_set_depth_mode".}
  ## Set the current depth mode for the specified device.
  ##
  ## dev
  ##   Device for which to set the depth mode
  ## mode
  ##   Frame mode to set
  ## result
  ##   - `0` on success
  ##   - `< 0` if error
  ##
  ## The mode cannot be changed while streaming is active.


proc freenect2SetFlag*(dev: ptr Freenect2Device; flag: Freenect2Flag;
  value: Freenect2FlagValue): cint
  {.cdecl, dynlib: dllname, importc: "freenect2_set_flag".}
  ## Enable or disable the specified flag.
  ##
  ## flag
  ##   Feature to set
  ## value
  ##   `off` or `on`
  ## result
  ##   - `0` on success
  ##   - `< 0` if error
