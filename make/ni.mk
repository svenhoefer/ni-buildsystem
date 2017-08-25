# custom ni-makefile - just a collection of targets

ni-init \
init: preqs crosstools bootstrap

BOXSERIES_UPDATE = hd2
ifneq ($(DEBUG), yes)
	BOXSERIES_UPDATE += hd1
endif
ni-neutrino-updates:
	for boxseries in $(BOXSERIES_UPDATE); do \
		$(MAKE) BOXSERIES=$${boxseries} clean ni-neutrino-update || exit; \
	done;
	make clean

ni-neutrino-update:
	@echo "starting 'make $@' build with "$(NUM_CPUS)" threads!"
	make u-neutrino
	@make done

BOXMODEL_IMAGE = apollo kronos kronos_v2
ifneq ($(DEBUG), yes)
	BOXMODEL_IMAGE += nevis
endif
ni-images:
	for boxmodel in $(BOXMODEL_IMAGE); do \
		$(MAKE) BOXMODEL=$${boxmodel} clean ni-image || exit; \
	done;
	make clean

personalized-image:
	make ni-image PERSONALIZE=yes

ni-image:
	@echo "starting 'make $@' build with "$(NUM_CPUS)" threads!"
	make -j$(NUM_CPUS) neutrino
	make plugins-all
	make fbshot
	make -j$(NUM_CPUS) luacurl
	make -j$(NUM_CPUS) timezone
	make -j$(NUM_CPUS) smartmontools
	make -j$(NUM_CPUS) sg3-utils
	make -j$(NUM_CPUS) nfs-utils
	make -j$(NUM_CPUS) procps-ng
	make -j$(NUM_CPUS) nano
	make hd-idle
	make -j$(NUM_CPUS) e2fsprogs
	make -j$(NUM_CPUS) ntfs-3g
	make -j$(NUM_CPUS) exfat-utils
	make -j$(NUM_CPUS) vsftpd
	make -j$(NUM_CPUS) djmount
	make -j$(NUM_CPUS) ushare
	make -j$(NUM_CPUS) xupnpd
	make inadyn
	make -j$(NUM_CPUS) samba
	make dropbear
	make -j$(NUM_CPUS) hdparm
	make -j$(NUM_CPUS) busybox
	make -j$(NUM_CPUS) bc
	make -j$(NUM_CPUS) coreutils
	make -j$(NUM_CPUS) dosfstools
	make -j$(NUM_CPUS) wpa_supplicant
	make -j$(NUM_CPUS) mtd-utils
	make -j$(NUM_CPUS) wget
ifeq ($(BOXSERIES), hd2)
	make plugins-hd2
	make -j$(NUM_CPUS) less
	make -j$(NUM_CPUS) parted
	make -j$(NUM_CPUS) openvpn
	make -j$(NUM_CPUS) openssh
	make -j$(NUM_CPUS) streamripper
  ifneq ($(BOXMODEL), kronos_v2)
	make -j$(NUM_CPUS) bash
	make -j$(NUM_CPUS) iperf
	make -j$(NUM_CPUS) minicom
	make -j$(NUM_CPUS) usbutils
	make -j$(NUM_CPUS) mc
  endif
  ifeq ($(DEBUG), yes)
	make -j$(NUM_CPUS) strace
	make -j$(NUM_CPUS) valgrind
	make -j$(NUM_CPUS) gdb
  endif
endif
	make -j$(NUM_CPUS) kernel-cst-modules
	make autofs5
ifeq ($(PERSONALIZE), yes)
	make personalize
endif
	make rootfs
	make images
	@make done