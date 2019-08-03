okreader
========

Free/libre software stack for Kobo ebook readers. No proprietary software (except WiFi and EPD controller firmware), no spyware and no DRM. Based on [koreader](https://github.com/koreader/koreader) and [Debian](https://www.debian.org/).

WARNING: At this point, okreader has only been tested on a few different devices. Only install it if you know what you're doing. You could brick your ereader and in some countries you might void your warranty.


Features yet to be implemented
------------------------------

This project is at a very early stage. Lack of the following features could be a problem, especially for non-technical users:

* No GUI for enabling and disabling access to the data partition via USB. It is always enabled and it seems to work reliably, but data could get corrupted if both software on the ereader and another computer were to write at the same time. Maintain a backup copy of your data partition.
* No GUI for setting the time & date. The NTP option in koreader is supported, but there is no UI for setting the timezone.


Supported hardware
------------------

This project was tested on:

* Kobo Touch
* Kobo Mini
* Kobo Aura
* Kobo Glo
* Kobo Glo HD

okreader is also expected to work on other Kobo devices using the i.MX507 or i.MX6 SoCs, but some additional u-boot and/or kernel patches might be needed (see [this](https://github.com/kobolabs/Kobo-Reader/tree/master/hw) repository). okreader commit #1e7825eb has been confirmed by @dtamas to also work on Kobo Glo. Support for newer devices might be added at a later time. If anyone wants to test / lend or donate any of the untested or unsupported devices, please get in touch at okreader at linux-geek dot org. Also see [this thread](https://github.com/lgeek/okreader/issues/6) for a short description of the steps involved in getting okreader running on an unsupported Kobo device.

There seem to be multiple hardware revisions with different WiFi adapters. The *firmware-okreader* package only provides the firmware required for the WiFi adapters in the devices I am using for testing.

Comparison of Kobo ereaders:

Device           | eReader | Wi-Fi   | Touch      | Mini       | Glo         | Aura        | Aura HD        | Aura H2O       | Glo HD       | Touch 2.0   | Aura One       | Aura Edition 2 |
-----------------|---------|---------|------------|------------|-------------|-------------|----------------|----------------|--------------|-------------|----------------|----------------|
okreader support | no      | no      | yes        | yes        | yes        | yes         | kernel upg?    | kernel upg?    | yes          | no          | no             | no             |
touchscreen      | no      | no      | yes        | yes        | yes         | yes         | yes            | yes            | yes          | yes         | yes            | yes            |
frontlight       | no      | no      | no         | no         | yes         | yes         | yes            | yes            | yes          | no          | yes            | yes            |
WiFi             | no      | yes     | yes        | yes        | yes         | yes         | yes            | yes            | yes          | yes         | yes            | yes            |
screen           | 6"      | 6"      | 6" 800x600 | 5" 800x600 | 6" 1024x768 | 6" 1024x768 | 6.8" 1440×1080 | 6.8" 1440×1080 | 6" 1448x1072 | 6" 800x600  | 7.8" 1872x1404 | 6" 1024x768    |
SoC              | i.MX357 | i.MX357 | i.MX507    | i.MX507    | i.MX507     | i.MX507     | i.MX507        | i.MX507        | i.MX6 Solo   | i.MX6 Solo? | ?              | i.MX6 Solo Lite|
is current model | no      | no      | no         | no         | no          | no          | no             | yes            | yes          | yes         | yes            | yes            |

Apart from these specs, the contrast and the ghosting of the electronic ink display also tend to get better in newer models. However, even old models tend to be quite usable. I find a Kobo Touch perfectly readable in moderate to strong ambiental light and a Kobo Aura readable with the frontlight off in strong light or with the frontlight on in dark to moderately lit environments.

If you're looking to buy an ereader for use with okreader, I'd recommend getting a Kobo Touch (£10-£30 used on eBay) if you don't need a frontlight or a Kobo Glo (not tested at the moment) or Aura otherwise.


Build
-----

See BUILD.md


Install
-------

See INSTALL.md

Use
---

See USAGE.md


Notes for developers
--------------------

The first partition on the factory SD starts at the 15 MiB offset. The space before the first partition contains U-Boot, the Linux kernel image (in uImage format), the serial number of the device, a *hwconfig* block used both by U-Boot and Linux to detect the hardware configuration, a *waveform* block used by the electronic ink screen driver and one other unknown data blob.

    Address (in 512B blocks) | Size (in 512B blocks) | Data
    -------------------------------------------------------------------------
    0                        | 1                     | MBR
    1                        | 1                     | Serial no.
    2                        | Variable              | U-Boot
    1023                     | 1                     | Unknown
    1024                     | 1                     | HWCONFIG
    2048                     | Variable              | Linux
    14335                    | 1                     | Waveform header?
    14336                    | Variable?             | Waveform

