#!/bin/bash

# Copyright (c) 2015, Cosmin Gorgovan <cosmin at linux-geek dot org>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

print_usage() {
  echo "Usage: build_rootfs.sh [OPTIONS]"
  echo "Valid options: "
  echo "  --skip-deps-check    don't check if dependencies are installed"
  echo "  --help               prints this message"
}

check_dependencies() {
  dpkg -s debian-archive-keyring debootstrap qemu-user-static coreutils xz-utils > /dev/null
  if [ $? -ne 0 ] ; then
    echo
    echo "Error: Some dependencies appear to be missing. Aborting."
    exit 1
  fi
}

parse_args() {
  for arg in "$@"; do
    case $arg in
      --skip-deps-check)
        dep_check=false
        ;;
      --help)
        print_usage
        exit 0
        ;;
      *)
        echo "Unrecognized option $arg"
        echo
        print_usage
        exit 1
        ;;
    esac
  done
}

config_rootfs() {
  echo
  echo "Configuring the newly built rootfs..."
  
  echo "okreader" > ./rootfs/etc/hostname
  echo -e "127.0.0.1 localhost okreader\n" > ./rootfs/etc/hosts
  echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4\n" > ./rootfs/etc/resolv.conf

  # replace the framebuffer terminals with an uart terminal
  mv ./rootfs/etc/inittab ./rootfs/etc/inittab.default
  sed -r 's/^[0-9]+:[0-9]+:respawn/# &/' ./rootfs/etc/inittab.default > rootfs/etc/inittab
  echo -e "\nT0:23:respawn:/sbin/getty -L ttymxc0 115200 vt100\n" >> ./rootfs/etc/inittab

  mkdir ./rootfs/mnt/onboard
  mkdir ./rootfs/mnt/external
  cp files/fstab rootfs/etc/
  cp files/rc.local rootfs/etc/

  chown root:root rootfs/etc/fstab rootfs/etc/rc.local
  chmod 644 rootfs/etc/fstab
  chmod 755 rootfs/etc/rc.local
  
  echo "Configuration done."
}

install_packages() {
  cp src/linux-okreader-modules-imx5_2.6.35.3-1_armhf.deb rootfs/
  cp src/linux-okreader-modules-imx6_3.0.35-1_armhf.deb rootfs/
  cp src/firmware-okreader_1.0-2_armhf.deb rootfs/
  cp src/koreader_2019.02_armhf.deb rootfs/
  cp src/kobo_hwconfig/kobo-hwconfig_1.0-1_armhf.deb rootfs/

  chroot rootfs/ bash -c "dpkg -i /*.deb"

  rm rootfs/*.deb
}

clean_up_rootfs() {
  echo "Cleaning up..."

  # SSH keys must be unique for each device. Run dpkg-reconfigure openssh-server on the device.
  rm ./rootfs/etc/ssh/ssh_host*key*

  # Remove cached packages and documentation to reduce the size of the FS
  rm ./rootfs/var/cache/apt/archives/*.deb
  rm -R ./rootfs/usr/share/man/*
  rm -R ./rootfs/usr/share/info/*
  rm -R ./rootfs/usr/share/doc/*
  rm -R ./rootfs/var/log/*

  echo "Cleanup done."
}

build_rootfs() {
  if [ -f rootfs-fresh-backup.tar.xz ]; then
    echo "Found fresh rootfs backup. Unpacking."
    xzcat rootfs-fresh-backup.tar.xz | tar x rootfs/
  else
    qemu-debootstrap --arch=armhf --variant=minbase \
    --include=net-tools,wireless-tools,wpasupplicant,kmod,udev,openssh-server,iputils-ping,ifupdown,vim-tiny,dhcpcd,ntpdate,libglib2.0-0 \
    wheezy ./rootfs http://archive.debian.org/debian/

    if [ $? -ne 0 ] ; then
      echo
      echo "Error: Debootstrap seems to have failed. Aborting."
      exit 1
    fi

    tar --create rootfs/* | xz > rootfs-fresh-backup.tar.xz
  fi
  
  config_rootfs
  install_packages
  clean_up_rootfs

  # uncomment to also create release tarball
  #tar --create rootfs/* | xz > okreader-rootfs-release-$(date --iso-8601=seconds).tar.xz
}

dep_check=true

parse_args $@

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root. Aborting."
   exit 1
fi

if $dep_check ; then
  check_dependencies
fi

build_rootfs

