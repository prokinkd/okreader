Installation on the device
--------------------------

WARNING: This project may contain bugs and other serious issues. Only install it if you know what you're doing. You could brick your ereader and in some countries you might void your warranty.

Important: The internal micro SD / eMMC stores configuration information unique to each hardware unit and firmware files which might not be available elsewhere. Therefore, it is essential to backup the first 15 MiB of the internal storage at the very least. I strongly recommend backing up the entire internal storage.

Some Kobo ereaders (as far as I know, Touch, Glo and some Aura revisions) store their firmware and data on internal removable microSD cards. On these devices, it is recommended to replace the internal microSD card with one containing okreader. Other ereaders store their firmware on an eMMC chip soldered to the PCB. On these devices, it is recommended to boot okreader from the external microSD slot, leaving the official firmware on the internal storage unmodified.

WARNING: You will need to create a new directory, located at `mnt/external/dict` on your device for dictionaries to work. It is required because dictionary storage location on rootfs is linked here.

Booting from the external microSD card
--------------------------------------

This is recommended way, since it does not requires disassembly of the device and works if internal memory is non-removable.

1) Prepare a sufficiently sized (check your ereader's internal memory capacity) microSD card formatted in `ext4` or `vfat`.

2) Insert the external microSD card in the ereader and boot it up.

3) Get a shell on the device, either via Telnet, SSH or some sort of terminal emulator.

You can use, for example, https://github.com/S-trace/kobo-aura-remote to gain SSH access.
Note that you'll need to pass `-oKexAlgorithms=+diffie-hellman-group1-sha1` option to `ssh` when connecting to the device from recent distros, because, apparently, `kobo-aura-remote` provides dated binaries with weak algoritms by default.

4) On the ereader shell, remount the rootfs as read only:

    umount /mnt/onboard
    mount -o remount,ro /

5) Mount external card:

    mkdir /mnt/external
    mount /dev/mmcblk1p1 /mnt/external

6) Clone the internal memory to the external microSD card as file:

    cp if=/dev/mmcblk0 of=/mnt/external/internal-backup.bin
    sync

Note: Device might disconnect from Wi-Fi regardless of timeout settings. It will cause SSH shell to freeze and not respond, but will not affect the copy progress. Reconnecting to Wi-Fi, or switching Wi-Fi on/off will restore SSH connecton.

7) Remount the filesystems with their default options:

    mount -o remount,rw /
    mount -t vfat -o noatime,nodiratime,shortname=mixed,utf8 /dev/mmcblk0p3 /mnt/onboard

8) Power off your ereader, remove the microSD card from the ereader and insert it into a computer with a microSD card reader.

9) Copy your `internal-backup.bin` somewhere safe. You might compress it to save space.

* describe how to create sdcard with old partition
* create data partition
* solve dictionary partition

9) Extract the hardware configuration block from the microSD card. For example, on a GNU/Linux computer, assuming the SD card is at /dev/mmcblk0 (replace as needed):

    dd bs=512 skip=1024 count=1 if=/dev/mmcblk0 of=ereader.hwconfig

10) Use a hex editor to change the byte at offset 0x3F (63) from 0 to 1:

    printf '\x01' | dd of=ereader.hwconfig bs=1 seek=63 count=1 conv=notrunc

11) Write it back to the microSD card

    dd if=ereader.hwconfig bs=512 seek=1024 of=/dev/mmcblk0

12) 

12) Proceed with the installation as documented in **Installation on the internal microSD**.

13) Hold down the power and backlight buttons while booting until the LED is blinking to boot from the external microSD card.

Installation on the internal microSD
-----------------------------------

This way will not work if you have soldered memory inside.

1) Fully power off your device.

2) Find a guide on how to open up the case of your particular ereader and follow it. Most are simply retained by plastic clips, so they're easy to open up using a spudger, a plastic card or a guitar pick.

3) Locate the internal microSD card and remove it.

4) Using a computer with an SD card reader, fully backup the factory SD. For example, on a GNU/Linux computer, assuming the SD card is at /dev/mmcblk0 (replace as needed):


    dd if=/dev/mmcblk0 of=<PATH_TO_BACKUP_FILE>


5) Delete the recovery partition (partition 2) and extended (using cfdisk, fdisk, parted, etc) the main system partition (partition 1) in the free space between partitions 1 and 3. It is essential to leave the first 15 MiB free before the first partition, which are used for U-Boot, the kernel, configuration information and display firmware. The system partition should have id 1 and the data partition should have id 3.

6) Write U-Boot and the Linux image to the disk (assuming the SD card is at */dev/mmcblk0*:

```
sudo dd if=src/u-boot/u-boot.bin of=/dev/mmcblk0 bs=1024 skip=1 seek=1
sudo dd if=src/linux/arch/arm/boot/uImage of=/dev/mmcblk0 bs=1024 seek=1024
```

7) Format the system partition:

```
sudo mkfs.ext4 /dev/mmcblk0p1
```

8) Copy okreader's rootfs to the SD card:

```
sudo mount /dev/mmcblk0p1 /mnt/
sudo cp -Rp rootfs/* /mnt/
sudo umount /dev/mmcblk0p1
sync
```

9) Move the SD card to the ereader and boot it up.