# High-Speed Accelerometer Sampling on a Commodity Smartwatch

This is the core kernel code underlying the project [ViBand: High-Fidelity Bio-Acoustic Sensing Using Commodity Smartwatch Accelerometers](https://www.robertxiao.ca/research/viband/).

See [prebuilt](prebuilt) for a plug-and-play kernel image to get started quickly, or [kernel](kernel) to see the full kernel source changes.

## About

The accelerometer on a typical smartwatch runs at around 100 Hz, which is sufficient for applications like step-counting and orientation detection (for e.g. raise-to-unlock). However, we found that it was possible to overclock the accelerometer to 4000 Hz on a commodity smartwatch using a software-only modification. At this point, it becomes possible to sense a lot more than just orientation - tiny micro-vibrations propagating through the body are visible in the data stream. Moreover, unlike a microphone, the accelerometer is largely insensitive to outside acoustic noise, making it an ideal vibro-acoustic sensor.

This repository contains the software necessary to run the accelerometer at this higher speed. It disables the existing accelerometer driver (`INV_MPU_IIO`) and substitutes a custom driver, `fastacc_mpu`, which buffers data at the higher rate and makes it available through a virtual file.

We have prepared this kernel image and source for an LG G Watch (W100) running Android 5.0.1 (LWX48P). However, the underlying code should be portable to any Android device with an InvenSense 6xxx or 9xxx Series MPU.

## Citing

If you use this code, we ask that you cite the following paper:

> Gierad Laput, Robert Xiao, and Chris Harrison. 2016. ViBand: High-Fidelity Bio-Acoustic Sensing Using Commodity Smartwatch Accelerometers. In Proceedings of the 29th Annual Symposium on User Interface Software and Technology (UIST '16). ACM, New York, NY, USA, 321-333. DOI: https://doi.org/10.1145/2984511.2984582

or in BibTeX format:

>     @inproceedings{Laput:2016:VHB:2984511.2984582,
>      author = {Laput, Gierad and Xiao, Robert and Harrison, Chris},
>      title = {ViBand: High-Fidelity Bio-Acoustic Sensing Using Commodity Smartwatch Accelerometers},
>      booktitle = {Proceedings of the 29th Annual Symposium on User Interface Software and Technology},
>      series = {UIST '16},
>      year = {2016},
>      isbn = {978-1-4503-4189-9},
>      location = {Tokyo, Japan},
>      pages = {321--333},
>      numpages = {13},
>      url = {http://doi.acm.org/10.1145/2984511.2984582},
>      doi = {10.1145/2984511.2984582},
>      acmid = {2984582},
>      publisher = {ACM},
>      address = {New York, NY, USA},
>      keywords = {gestures, object detection, vibro-tags, wearables},
>     }

## API
The `fastacc_mpu` driver exports a set of virtual files at `/sys/class/misc/fastacc_mpu/device`. These files are as follows:

- `pwr`
    - read: 0/1 depending on current power state
    - write: 0/1 to turn off/on the IMU chip respectively
- `accel_range`
    - read: 2/4/8/16 depending on current accelerometer sensitivity (in Gs)
    - write: 2/4/8/16 to set the accelerometer sensitivity
- `fifo_read_stat`
    - read: `<count> <time>`, two 64-bit numbers showing the number of bytes read to date and the amount of time elapsed in nanoseconds. Differencing two pairs of stat values will allow you to calculate the sample rate of the accelerometer, which may change gradually over time. The calculation is `sample_rate = (count2 - count1) / ((time2 - time1) / 1e9) / 6` as each sample consists of 3 2-byte values.
- `fifo`
    - read: a continuous stream of binary data. This is the raw data coming off of the sensor. You should continuously read this file (as if it were a pipe). The data is formatted into 6-byte samples, where each sample contains 3 big-endian 16-bit numbers (representing the X, Y and Z axis data respectively).

Note that writable files may require root to write, due to SELinux restrictions.

## Caveats

The new driver disables the existing IMU driver, which will disable any functionality that depends on the accelerometer or gyro (e.g. step counting, orientation detection, raise-to-unlock, etc.). It may also cause some watches to take a long time to start up, as the Android system may wait for a long period before deciding the IMU is unavailable.

`fastacc_mpu` will drain the battery faster than normal due to the constant buffering, so it is recommended that you power off the accelerometer (`echo 0 > pwr`) whenever you don't need the data stream.

This code is intended for *research purposes only* and should not be used for any commercial purpose. Do not deploy this kernel on a valuable device or one which contains valuable data. Although we have not observed any hardware issues from using this code, please be aware that any kernel modification (especially one that involves this sort of "overclocking") may cause unintended hardware behaviour, up to and including hardware failure. Use at your own risk.

## Fixing Sensors log spew

The patch might cause some watches to spew the following message to LogCat several times per second, forever:

    E/Sensors (  484): HAL:cannot open pedometer_steps

This is due to the existing sensor HAL driver being unable to find the matching kernel interface (since we replaced it). To fix, you'll need to root your device.

Open `adb shell`, and execute the following commands:

    $ su
    # mount -o rw,remount /system
    # cp hals.conf{,.bak}
    # cat > hals.conf
    /system/lib/hw/lis3dsh_tilt.so
    # reboot

This deletes the InvenSense HAL driver, removing the source of the error message.

## Disclaimer

THE PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT WITHOUT ANY WARRANTY. IT IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW THE AUTHOR WILL BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF THE AUTHOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
