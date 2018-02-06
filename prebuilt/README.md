## Installing a prebuilt kernel

1. Install Android 5.0.1 (LWX48P) on your LG G Watch. Pair it with a phone.
2. Enable developer mode
    1. Go to Settings ➔ About and tap on "Build Number" about 10 times. You should see a toast message pop up telling you that you are now a developer.
    2. Go back to Settings. A new "Developer options" menu should appear below About. Enter that and enable "ADB debugging".
    3. Plug your watch into your computer (using the dock). *On the phone*, a dialog should appear confirming whether you want to trust your computer for debugging. Check the "remember this device" box and press OK.
3. Use `adb reboot bootloader` to enter the bootloader
4. Use `fastboot oem unlock` to unlock the bootloader (only needs to be done once) - this will wipe the device
5. Use `fastboot flash boot boot-new.img` to flash the new boot image.

Rooting the device is not required. If you ever want to go back to the stock image, flash `boot-orig.img`.
