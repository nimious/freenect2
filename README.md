# io-myo

Nim bindings for libfreenect, the the cross-platform user library for Kinect for
Windows v2.

![io-freenect2 Logo](logo.png)


## About

io-freenect2 contains bindings to *libfreenect2* for the
[Nim](http://nim-lang.org) programming language. libfreenect2 is an open source
cross-platform driver for Kinect for Windows v2 devices that currently supports
transfer of RGB, IR and depth images.

Older Kinect devices are not supported. For Kinect for Windows v1 and Kinect for
Xbox 360 use [io-freenect](https://github.com/nimious/io-freenect) instead.


## Supported Platforms

io-freenect2 currently supports the following platforms:

- ~~Linux~~
- ~~MacOS X~~
- ~~Windows~~


## Prerequisites

### Linux

TODO

### MacOS X

TODO

### Windows

TODO


## Dependencies

io-freenect2 does not have any dependencies to other Nim packages at this time.


## Usage

Import the *libfreenect2* module from this package to make the bindings
available in your project:

```nimrod
import libfreenect2
```


## Support

Please [file an issue](https://github.com/nimious/io-freenect2/issues), submit a
[pull request](https://github.com/nimious/io-freenect2/pulls?q=is%3Aopen+is%3Apr)
or email us at info@nimio.us if this package is out of date or contains bugs.
For all other issues related to USB devices visit the libusb web site below.


## References

* [libfreenect2 on GitHub](https://github.com/OpenKinect/libfreenect2)
* [OpenKinect Wiki](http://openkinect.org/wiki/Main_Page)
* [Nim Programming Language](http://nim-lang.org/)
