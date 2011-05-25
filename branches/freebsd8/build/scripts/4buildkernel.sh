#!/usr/local/bin/bash

set -e

if [ -z "$MW_BUILDPATH" -o ! -d "$MW_BUILDPATH" ]; then
	echo "\$MW_BUILDPATH is not set"
	exit 1
fi

# patch kernel / sources
		cd /usr/src
		patch -p0 < $MW_BUILDPATH/freebsd8/build/patches/kernel/stf_6rd_20100923-1.diff
		patch < $MW_BUILDPATH/freebsd8/build/patches/kernel/ipfilter_kernel_update_to_4.1.34.patch
		patch < $MW_BUILDPATH/freebsd8/build/patches/kernel/Makefile.orig.patch
		patch < $MW_BUILDPATH/freebsd8/build/patches/kernel/options.orig.patch
		patch < $MW_BUILDPATH/freebsd8/build/patches/kernel/ip_ftp_pxy.c.orig.patch
		patch < $MW_BUILDPATH/freebsd8/build/patches/kernel/ip_nat.c.orig.patch
		patch < $MW_BUILDPATH/freebsd8/build/patches/kernel/fil.c.orig.patch
		patch < $MW_BUILDPATH/freebsd8/build/patches/kernel/ip_state.c.orig.patch
		patch < $MW_BUILDPATH/freebsd8/build/patches/kernel/mlfk_ipl.c.orig.patch
		patch < $MW_BUILDPATH/freebsd8/build/patches/kernel/pfil.c.orig.patch 
		patch < $MW_BUILDPATH/freebsd8/build/patches/kernel/g_part_bsd.c.orig.patch
		patch < $MW_BUILDPATH/freebsd8/build/patches/kernel/usbdevs.orig.patch
		patch < $MW_BUILDPATH/freebsd8/build/patches/kernel/u3g.c.orig.patch


# kernel compile
        cd /sys/$MW_ARCH/conf
        cp $MW_BUILDPATH/freebsd8/build/kernelconfigs/M0N0WALL_GENERIC.$MW_ARCH /sys/$MW_ARCH/conf/M0N0WALL_GENERIC
		cp $MW_BUILDPATH/freebsd8/build/kernelconfigs/M0N0WALL_GENERIC.hints /sys/$MW_ARCH/conf/
        config M0N0WALL_GENERIC
        cd /sys/$MW_ARCH/compile/M0N0WALL_GENERIC/
        make depend && make
        strip kernel
        strip --remove-section=.note --remove-section=.comment kernel
        gzip -9 kernel
        mv kernel.gz $MW_BUILDPATH/tmp/
        cd modules/usr/src/sys/modules
        cp aesni/aesni.ko glxsb/glxsb.ko padlock/padlock.ko if_tap/if_tap.ko if_vlan/if_vlan.ko dummynet/dummynet.ko ipfw/ipfw.ko $MW_BUILDPATH/m0n0fs/boot/kernel
		if [ $MW_ARCH = "i386" ]; then
                cp acpi/acpi/acpi.ko $MW_BUILDPATH/tmp
        fi


# make libs
		cd $MW_BUILDPATH/tmp
		perl $MW_BUILDPATH/freebsd8/build/minibsd/mklibs.pl $MW_BUILDPATH/m0n0fs > m0n0wall.libs
		perl $MW_BUILDPATH/freebsd8/build/minibsd/mkmini.pl m0n0wall.libs / $MW_BUILDPATH/m0n0fs