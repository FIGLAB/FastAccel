#!/bin/bash -e
mkbootimg \
    --kernel ../arch/arm/boot/zImage-dtb \
    --ramdisk boot/boot.img-ramdisk.gz \
    --cmdline "`cat boot/boot.img-cmdline`" \
    --pagesize "`cat boot/boot.img-pagesize`" \
    --base "`cat boot/boot.img-base`" \
    $(cat boot/boot.img-offsets) \
    -o boot-new.img
