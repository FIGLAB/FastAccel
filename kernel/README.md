## Building a custom fastaccel kernel

The kernel code lives at https://github.com/nneonneo/ViBand-kernel.

It is based off of the kernel for Android version 5.0.1 (LWX48P) for the LG G Watch, codename "dory".

## Detailed build steps

These steps should be followed on a Linux machine for best results.

0. Install the `gcc-arm-none-eabi` Ubuntu package or equivalent to get the cross-compilation toolchain
1. Download and install [unpack-mkbootimg](https://github.com/nneonneo/unpack-mkbootimg)
2. `git clone https://github.com/nneonneo/ViBand-kernel --depth 1`
3. `export ARCH=arm CROSS_COMPILE=arm-none-eabi-`
4. `make dory_defconfig`
5. `make -j7`
6. Copy the `build` directory from this directory into the kernel tree
7. `cd build ; ./build-image.sh`

If all goes well, you will have a flashable `boot-new.img` in the `build` directory. Grab that and follow the instructions from the `prebuilt` directory.
