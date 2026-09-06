# CubeFN
*The cube-from-nothing.*

An experimental demo that renders a true-3D spinning wireframe cube directly on bare x86 hardware. No OS, no third-party libraries.

![Demo](res/cubefn.gif)

## Build
This project is written in Assembly using [FASM](https://flatassembler.net/).
Test it in QEMU or Bochs.

This repo has some Windows cmd scripts which build and run the demo: `run_qemu.bat`, `run_bochs.bat`.

## P.S.
I initially wanted this demo to run directly from a bootsector,
but the resulting binary exceeded 512 bytes, so I had to divide it into bootloader and kernel.

For now I don't know how to compress the rendering algorithm and other data to fit in boot sector, if it's even possible.
But if you know any implementation variations that solve this problem, please feel free to share it in the issues section.