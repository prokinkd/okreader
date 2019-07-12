CFLAGS=-O2 -Wall

CROSS_COMPILE ?=

AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
CC = $(CROSS_COMPILE)gcc
CPP = $(CC) -E
AR = $(CROSS_COMPILE)ar
NM = $(CROSS_COMPILE)nm
STRIP = $(CROSS_COMPILE)strip
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

kobo_hwconfig:

pkg: kobo_hwconfig
	mkdir -p pkg/usr/bin
	cp kobo_hwconfig pkg/usr/bin
	dpkg-deb -b pkg/ .

clean:
	rm kobo_hwconfig pkg/usr/bin/kobo_hwconfig *.deb
