# makefile to build system tools

# -----------------------------------------------------------------------------

$(D)/openvpn: $(D)/lzo $(D)/openssl $(ARCHIVE)/openvpn-$(OPENVPN_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/openvpn-$(OPENVPN_VER)
	$(UNTAR)/openvpn-$(OPENVPN_VER).tar.xz
	$(CHDIR)/openvpn-$(OPENVPN_VER); \
		$(CONFIGURE) \
			IFCONFIG="/sbin/ifconfig" \
			NETSTAT="/bin/netstat" \
			ROUTE="/sbin/route" \
			IPROUTE="/sbin/ip" \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--infodir=/.remove \
			--enable-shared \
			--disable-static \
			--enable-small \
			--enable-management \
			--disable-debug \
			--disable-selinux \
			--disable-plugins \
			--disable-pkcs11 \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/openvpn-$(OPENVPN_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/openssh: $(D)/openssl $(D)/zlib $(ARCHIVE)/openssh-$(OPENSSH_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/openssh-$(OPENSSH_VER)
	$(UNTAR)/openssh-$(OPENSSH_VER).tar.gz
	$(CHDIR)/openssh-$(OPENSSH_VER); \
		export ac_cv_search_dlopen=no; \
		./configure \
			$(CONFIGURE_OPTS) \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--infodir=/.remove \
			--with-pid-dir=/tmp \
			--with-privsep-path=/var/empty \
			--with-cppflags="-pipe $(TARGET_O_CFLAGS) $(TARGET_MARCH_CFLAGS) -g -I$(TARGET_INCLUDE_DIR)" \
			--with-ldflags="-L$(TARGET_LIB_DIR)" \
			--libexecdir=/bin \
			--disable-strip \
			--disable-lastlog \
			--disable-utmp \
			--disable-utmpx \
			--disable-wtmp \
			--disable-wtmpx \
			--disable-pututline \
			--disable-pututxline \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/openssh-$(OPENSSH_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

ifeq ($(BOXSERIES), hd2)
  LOCALTIME = var/etc/localtime
else
  LOCALTIME = etc/localtime
endif

$(D)/timezone: $(ARCHIVE)/tzdata$(TZDATA_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/timezone
	$(MKDIR)/timezone
	$(CHDIR)/timezone; \
		tar -xf $(ARCHIVE)/tzdata$(TZDATA_VER).tar.gz; \
		unset ${!LC_*}; LANG=POSIX; LC_ALL=POSIX; export LANG LC_ALL; \
		zic -d zoneinfo.tmp \
			africa antarctica asia australasia \
			europe northamerica southamerica pacificnew \
			etcetera backward; \
		mkdir zoneinfo; \
		sed -n '/zone=/{s/.*zone="\(.*\)".*$$/\1/; p}' $(IMAGEFILES)/timezone/timezone.xml | sort -u | \
		while read x; do \
			find zoneinfo.tmp -type f -name $$x | sort | \
			while read y; do \
				cp -a $$y zoneinfo/$$x; \
			done; \
			test -e zoneinfo/$$x || echo "WARNING: timezone $$x not found."; \
		done; \
		install -d -m 0755 $(TARGET_DIR)/share/ $(TARGET_DIR)/etc; \
		mv zoneinfo/ $(TARGET_DIR)/share/
	install -m 0644 $(IMAGEFILES)/timezone/timezone.xml $(TARGET_DIR)/etc/
	cp $(TARGET_DIR)/share/zoneinfo/CET $(TARGET_DIR)/$(LOCALTIME)
	$(REMOVE)/timezone
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/mtd-utils: $(D)/zlib $(D)/lzo $(D)/e2fsprogs $(ARCHIVE)/mtd-utils-$(MTD-UTILS_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/mtd-utils-$(MTD-UTILS_VER)
	$(UNTAR)/mtd-utils-$(MTD-UTILS_VER).tar.bz2
	$(CHDIR)/mtd-utils-$(MTD-UTILS_VER); \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--mandir=/.remove \
			--enable-silent-rules \
			--disable-tests \
			--without-xattr \
			; \
		$(MAKE)
ifeq ($(BOXSERIES), hd2)
	install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/nanddump $(TARGET_DIR)/sbin
	install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/nandtest $(TARGET_DIR)/sbin
	install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/nandwrite $(TARGET_DIR)/sbin
	install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/mtd_debug $(TARGET_DIR)/sbin
	install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/mkfs.jffs2 $(TARGET_DIR)/sbin
endif
	install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/flash_erase $(TARGET_DIR)/sbin
	$(REMOVE)/mtd-utils-$(MTD-UTILS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

IPERF_PATCH  = iperf-disable-profiling.patch

$(D)/iperf: $(ARCHIVE)/iperf-$(IPERF_VER)-source.tar.gz | $(TARGET_DIR)
	$(REMOVE)/iperf-$(IPERF_VER)
	$(UNTAR)/iperf-$(IPERF_VER)-source.tar.gz
	$(CHDIR)/iperf-$(IPERF_VER); \
		$(call apply_patches, $(IPERF_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--mandir=/.remove \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/iperf-$(IPERF_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

PARTED_PATCH  = parted-3.2-devmapper-1.patch
PARTED_PATCH += parted-3.2-sysmacros.patch

$(D)/parted: $(D)/e2fsprogs $(ARCHIVE)/parted-$(PARTED_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/parted-$(PARTED_VER)
	$(UNTAR)/parted-$(PARTED_VER).tar.xz
	$(CHDIR)/parted-$(PARTED_VER); \
		$(call apply_patches, $(PARTED_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--mandir=/.remove \
			--infodir=/.remove \
			--enable-silent-rules \
			--enable-shared \
			--disable-static \
			--disable-debug \
			--disable-pc98 \
			--disable-nls \
			--disable-device-mapper \
			--without-readline \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libparted.la
	$(REWRITE_LIBTOOL)/libparted-fs-resize.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libparted.pc
	$(REMOVE)/parted-$(PARTED_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/hdparm: $(ARCHIVE)/hdparm-$(HDPARM_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/hdparm-$(HDPARM_VER)
	$(UNTAR)/hdparm-$(HDPARM_VER).tar.gz
	$(CHDIR)/hdparm-$(HDPARM_VER); \
		$(BUILDENV) \
		$(MAKE) CC=$(TARGET)-gcc STRIP=$(TARGET)-strip; \
		install -D -m755 hdparm $(TARGET_DIR)/sbin/hdparm
	$(REMOVE)/hdparm-$(HDPARM_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/hd-idle: $(ARCHIVE)/hd-idle-$(HD-IDLE_VER).tgz | $(TARGET_DIR)
	$(REMOVE)/hd-idle
	$(UNTAR)/hd-idle-$(HD-IDLE_VER).tgz
	$(CHDIR)/hd-idle; \
		$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -o hd-idle hd-idle.c; \
		install -m755 hd-idle $(BIN)/
	$(REMOVE)/hd-idle
	$(TOUCH)

# -----------------------------------------------------------------------------

COREUTILS_PATCH  = coreutils-fix-coolstream-build.patch

# only used for "touch"
$(D)/coreutils: $(ARCHIVE)/coreutils-$(COREUTILS_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/coreutils-$(COREUTILS_VER)
	$(UNTAR)/coreutils-$(COREUTILS_VER).tar.xz
	$(CHDIR)/coreutils-$(COREUTILS_VER); \
		$(call apply_patches, $(COREUTILS_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--enable-silent-rules \
			--disable-xattr \
			--disable-libcap \
			--disable-acl \
			--without-gmp \
			--without-selinux \
			; \
		$(MAKE)
	install -m755 $(BUILD_TMP)/coreutils-$(COREUTILS_VER)/src/touch $(BIN)/
	$(REMOVE)/coreutils-$(COREUTILS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/less: $(D)/libncurses $(ARCHIVE)/less-$(LESS_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/less-$(LESS_VER)
	$(UNTAR)/less-$(LESS_VER).tar.gz
	$(CHDIR)/less-$(LESS_VER); \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--mandir=/.remove \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/less-$(LESS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/ntp: $(ARCHIVE)/ntp-$(NTP_VER).tar.gz $(D)/openssl | $(TARGET_DIR)
	$(REMOVE)/ntp-$(NTP_VER)
	$(UNTAR)/ntp-$(NTP_VER).tar.gz
	$(CHDIR)/ntp-$(NTP_VER); \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--with-shared \
			--with-crypto \
			--with-yielding-select=yes \
			--without-ntpsnmpd \
			; \
		$(MAKE)
	mv -v $(BUILD_TMP)/ntp-$(NTP_VER)/ntpdate/ntpdate $(TARGET_DIR)/sbin/
	$(REMOVE)/ntp-$(NTP_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

DJMOUNT_PATCH  = djmount-fix-hang-with-asset-upnp.patch
DJMOUNT_PATCH += djmount-fix-incorrect-range-when-retrieving-content-via-HTTP.patch
DJMOUNT_PATCH += djmount-fix-new-autotools.diff
DJMOUNT_PATCH += djmount-fixed-crash-when-using-UTF-8-charset.patch
DJMOUNT_PATCH += djmount-fixed-crash.patch
DJMOUNT_PATCH += djmount-support-fstab-mounting.diff
DJMOUNT_PATCH += djmount-support-seeking-in-large-2gb-files.patch

$(D)/djmount: $(ARCHIVE)/djmount-$(DJMOUNT_VER).tar.gz $(D)/libfuse | $(TARGET_DIR)
	$(REMOVE)/djmount-$(DJMOUNT_VER)
	$(UNTAR)/djmount-$(DJMOUNT_VER).tar.gz
	$(CHDIR)/djmount-$(DJMOUNT_VER); \
		$(call apply_patches, $(DJMOUNT_PATCH)); \
		touch libupnp/config.aux/config.rpath; \
		autoreconf -fi; \
		$(CONFIGURE) -C \
			--prefix= \
			--disable-debug \
			; \
		make; \
		make install DESTDIR=$(TARGET_DIR)
	install -D -m 755 $(IMAGEFILES)/scripts/djmount.init $(TARGET_DIR)/etc/init.d/djmount
	ln -sf djmount $(TARGET_DIR)/etc/init.d/S99djmount
	ln -sf djmount $(TARGET_DIR)/etc/init.d/K01djmount
	$(REMOVE)/djmount-$(DJMOUNT_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

USHARE_PATCH  = ushare.diff
USHARE_PATCH += ushare-fix-building-with-gcc-5.x.patch

$(D)/ushare: $(ARCHIVE)/ushare-$(USHARE_VER).tar.bz2 $(D)/libupnp | $(TARGET_DIR)
	$(REMOVE)/ushare-$(USHARE_VER)
	$(UNTAR)/ushare-$(USHARE_VER).tar.bz2
	$(CHDIR)/ushare-$(USHARE_VER); \
		$(call apply_patches, $(USHARE_PATCH)); \
		$(BUILDENV) \
		./configure \
			--prefix=$(TARGET_DIR) \
			--disable-dlna \
			--disable-nls \
			--cross-compile \
			--cross-prefix=$(TARGET)- \
			; \
		sed -i config.h  -e 's@SYSCONFDIR.*@SYSCONFDIR "/etc"@'; \
		sed -i config.h  -e 's@LOCALEDIR.*@LOCALEDIR "/share"@'; \
		ln -sf ../config.h src/; \
		$(MAKE); \
		$(MAKE) install; \
		install -D -m 0644 $(IMAGEFILES)/scripts/ushare.conf $(TARGET_DIR)/etc/ushare.conf
		sed -i 's|%(BOXTYPE)|$(BOXTYPE)|; s|%(BOXMODEL)|$(BOXMODEL)|' $(TARGET_DIR)/etc/ushare.conf
		install -D -m 0755 $(IMAGEFILES)/scripts/ushare.init $(TARGET_DIR)/etc/init.d/ushare
		ln -sf ushare $(TARGET_DIR)/etc/init.d/S99ushare
		ln -sf ushare $(TARGET_DIR)/etc/init.d/K01ushare
	$(REMOVE)/ushare-$(USHARE_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/smartmontools: $(ARCHIVE)/smartmontools-$(SMARTMON_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/smartmontools-$(SMARTMON_VER)
	$(UNTAR)/smartmontools-$(SMARTMON_VER).tar.gz
	$(CHDIR)/smartmontools-$(SMARTMON_VER); \
		$(BUILDENV) \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			; \
		$(MAKE); \
		install -m755 smartctl $(TARGET_DIR)/sbin/smartctl
	$(REMOVE)/smartmontools-$(SMARTMON_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/inadyn: $(D)/openssl $(D)/confuse $(D)/libite $(ARCHIVE)/inadyn-$(INADYN_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/inadyn-$(INADYN_VER)
	$(UNTAR)/inadyn-$(INADYN_VER).tar.xz
	$(CHDIR)/inadyn-$(INADYN_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--libdir=$(TARGET_LIB_DIR) \
			--includedir=$(TARGET_INCLUDE_DIR) \
			--mandir=/.remove \
			--docdir=/.remove \
			--enable-openssl \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -D -m 644 $(IMAGEFILES)/scripts/inadyn.conf $(TARGET_DIR)/var/etc/inadyn.conf
	ln -sf /var/etc/inadyn.conf $(TARGET_DIR)/etc/inadyn.conf
	install -D -m 755 $(IMAGEFILES)/scripts/inadyn.init $(TARGET_DIR)/etc/init.d/inadyn
	ln -sf inadyn $(TARGET_DIR)/etc/init.d/S80inadyn
	ln -sf inadyn $(TARGET_DIR)/etc/init.d/K60inadyn
	$(REMOVE)/inadyn-$(INADYN_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

VSFTP_PATCH  = vsftpd-fix-CVE-2015-1419.patch
VSFTP_PATCH += vsftpd-disable-capabilities.patch

$(D)/vsftpd: $(D)/openssl $(ARCHIVE)/vsftpd-$(VSFTPD_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/vsftpd-$(VSFTPD_VER)
	$(UNTAR)/vsftpd-$(VSFTPD_VER).tar.gz
	$(CHDIR)/vsftpd-$(VSFTPD_VER); \
		$(call apply_patches, $(VSFTP_PATCH)); \
		sed -i -e 's/.*VSF_BUILD_PAM/#undef VSF_BUILD_PAM/' builddefs.h; \
		sed -i -e 's/.*VSF_BUILD_SSL/#define VSF_BUILD_SSL/' builddefs.h; \
		make clean; \
		TARGET_DIR=$(TARGET_DIR) make CC=$(TARGET)-gcc LIBS="-lcrypt -lcrypto -lssl" CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)"
	install -d $(TARGET_DIR)/share/empty
	install -D -m 755 $(BUILD_TMP)/vsftpd-$(VSFTPD_VER)/vsftpd $(TARGET_DIR)/sbin/vsftpd
	install -D -m 644 $(IMAGEFILES)/scripts/vsftpd.conf $(TARGET_DIR)/etc/vsftpd.conf
	install -D -m 644 $(IMAGEFILES)/scripts/vsftpd.chroot_list $(TARGET_DIR)/etc/vsftpd.chroot_list
	install -D -m 755 $(IMAGEFILES)/scripts/vsftpd.init $(TARGET_DIR)/etc/init.d/vsftpd
	ln -sf vsftpd $(TARGET_DIR)/etc/init.d/S53vsftpd
	ln -sf vsftpd $(TARGET_DIR)/etc/init.d/K80vsftpd
	$(REMOVE)/vsftpd-$(VSFTPD_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/procps-ng: $(D)/libncurses $(ARCHIVE)/procps-ng-$(PROCPS-NG_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/procps-ng-$(PROCPS-NG_VER)
	$(UNTAR)/procps-ng-$(PROCPS-NG_VER).tar.xz
	$(CHDIR)/procps-ng-$(PROCPS-NG_VER); \
		export ac_cv_func_malloc_0_nonnull=yes; \
		export ac_cv_func_realloc_0_nonnull=yes; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			; \
		$(MAKE); \
		rm -f $(TARGET_DIR)/bin/ps $(TARGET_DIR)/bin/top; \
		install -D -m 755 top/.libs/top $(TARGET_DIR)/bin/top; \
		install -D -m 755 ps/.libs/pscommand $(TARGET_DIR)/bin/ps; \
		cp -a proc/.libs/libprocps.so* $(TARGET_LIB_DIR)
	$(REMOVE)/procps-ng-$(PROCPS-NG_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/nano: $(D)/libncurses $(ARCHIVE)/nano-$(NANO_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/nano-$(NANO_VER)
	$(UNTAR)/nano-$(NANO_VER).tar.gz
	$(CHDIR)/nano-$(NANO_VER); \
		export ac_cv_prog_NCURSESW_CONFIG=false; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			; \
		$(MAKE) CURSES_LIB="-lncurses"; \
		install -m755 src/nano $(TARGET_DIR)/bin
	$(REMOVE)/nano-$(NANO_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

MINICOM_PATCH  = minicom-fix-h-v-return-value-is-not-0.patch

$(D)/minicom: $(D)/libncurses $(ARCHIVE)/minicom-$(MINICOM_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/minicom-$(MINICOM_VER)
	$(UNTAR)/minicom-$(MINICOM_VER).tar.gz
	$(CHDIR)/minicom-$(MINICOM_VER); \
		$(call apply_patches, $(MINICOM_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--disable-nls \
			; \
		$(MAKE); \
		install -m755 src/minicom $(TARGET_DIR)/bin
	$(REMOVE)/minicom-$(MINICOM_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

# Link against libtirpc so that we can leverage its RPC
# support for NFS mounting with BusyBox
BUSYBOX_CFLAGS = $(TARGET_CFLAGS)
BUSYBOX_CFLAGS += "`$(PKG_CONFIG) --cflags libtirpc`"
# Don't use LDFLAGS for -ltirpc, because LDFLAGS is used for
# the non-final link of modules as well.
BUSYBOX_CFLAGS_busybox = "`$(PKG_CONFIG) --libs libtirpc`"

# Allows the build system to tweak CFLAGS
BUSYBOX_MAKE_ENV = \
	CFLAGS="$(BUSYBOX_CFLAGS)" \
	CFLAGS_busybox="$(BUSYBOX_CFLAGS_busybox)"

BUSYBOX_MAKE_OPTS = \
	CC="$(TARGET)-gcc" \
	LD="$(TARGET)-ld" \
	AR="$(TARGET)-ar" \
	RANLIB="$(TARGET)-ranlib" \
	CROSS_COMPILE="$(TARGET)-" \
	CFLAGS_EXTRA="$(TARGET_CFLAGS)" \
	EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
	CONFIG_PREFIX="$(TARGET_DIR)"

BUSYBOX_PATCH  = busybox-fix-config-header.diff
BUSYBOX_PATCH += busybox-insmod-hack.patch
BUSYBOX_PATCH += busybox-mount-use-var-etc-fstab.patch
BUSYBOX_PATCH += busybox-fix-partition-size.patch

$(D)/busybox: $(D)/libtirpc $(ARCHIVE)/$(BUSYBOX_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/busybox-$(BUSYBOX_VER)
	$(UNTAR)/$(BUSYBOX_SOURCE)
	$(CHDIR)/busybox-$(BUSYBOX_VER); \
		$(call apply_patches, $(BUSYBOX_PATCH)); \
		cp $(CONFIGS)/busybox-$(BOXSERIES).config .config; \
		sed -i -e 's|^CONFIG_PREFIX=.*|CONFIG_PREFIX="$(TARGET_DIR)"|' .config; \
		$(BUSYBOX_MAKE_ENV) $(MAKE) busybox $(BUSYBOX_MAKE_OPTS); \
		$(BUSYBOX_MAKE_ENV) $(MAKE) install $(BUSYBOX_MAKE_OPTS)
	$(REMOVE)/busybox-$(BUSYBOX_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/bash: $(ARCHIVE)/bash-$(BASH_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/bash-$(BASH_VER)
	$(UNTAR)/bash-$(BASH_VER).tar.gz
	$(CHDIR)/bash-$(BASH_VER); \
		$(call apply_patches, $(PATCHES)/bash-$(BASH_MAJOR).$(BASH_MINOR), 0); \
		$(CONFIGURE); \
		$(MAKE); \
		install -m 755 bash $(TARGET_DIR)/bin
	$(REMOVE)/bash-$(BASH_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/e2fsprogs: $(ARCHIVE)/e2fsprogs-$(E2FSPROGS_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/e2fsprogs-$(E2FSPROGS_VER)
	$(UNTAR)/e2fsprogs-$(E2FSPROGS_VER).tar.gz
	$(CHDIR)/e2fsprogs-$(E2FSPROGS_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/ \
			--infodir=/.remove \
			--mandir=/.remove \
			--disable-nls \
			--disable-profile \
			--disable-e2initrd-helper \
			--disable-debugfs \
			--disable-imager \
			--disable-resizer \
			--disable-uuidd \
			--disable-testio-debug \
			--disable-defrag \
			--enable-elf-shlibs \
			--enable-fsck \
			--enable-symlink-install \
			--enable-symlink-build \
			--with-gnu-ld \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
		cd lib/uuid/; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/uuid.pc
	$(REMOVE)/e2fsprogs-$(E2FSPROGS_VER)
	cd $(TARGET_DIR) && rm sbin/dumpe2fs sbin/logsave sbin/e2undo \
		sbin/filefrag sbin/e2freefrag bin/chattr bin/lsattr bin/uuidgen
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/ntfs-3g: $(ARCHIVE)/ntfs-3g_ntfsprogs-$(NTFS3G_VER).tgz | $(TARGET_DIR)
	$(REMOVE)/ntfs-3g_ntfsprogs-$(NTFS3G_VER)
	$(UNTAR)/ntfs-3g_ntfsprogs-$(NTFS3G_VER).tgz
	$(CHDIR)/ntfs-3g_ntfsprogs-$(NTFS3G_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--disable-ntfsprogs \
			--disable-ldconfig \
			--disable-library \
			; \
		$(MAKE); \
	install -D -m 755 $(BUILD_TMP)/ntfs-3g_ntfsprogs-$(NTFS3G_VER)/src/ntfs-3g $(TARGET_DIR)/sbin/ntfs-3g
	ln -sf ntfs-3g $(TARGET_DIR)/sbin/mount.ntfs
	$(REMOVE)/ntfs-3g_ntfsprogs-$(NTFS3G_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

# cd $(PATCHES)\autofs-5.1.4
# wget -N https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.5/patch_order-5.1.4
# for p in $(cat patch_order-5.1.4); do test -f $p || wget https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.5/$p; done

AUTOFS_PATCH = $(addprefix autofs-$(AUTOFS5_VER)/, $(shell cat $(PATCHES)/autofs-$(AUTOFS5_VER)/patch_order-$(AUTOFS5_VER)))

$(D)/autofs5: $(D)/libtirpc $(ARCHIVE)/autofs-$(AUTOFS5_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/autofs-$(AUTOFS5_VER)
	$(UNTAR)/autofs-$(AUTOFS5_VER).tar.gz
	$(CHDIR)/autofs-$(AUTOFS5_VER); \
		$(call apply_patches, $(AUTOFS_PATCH)); \
		export ac_cv_linux_procfs=yes; \
		export ac_cv_path_KRB5_CONFIG=no; \
		export ac_cv_path_MODPROBE=/sbin/modprobe; \
		export ac_cv_path_RANLIB=$(TARGET)-ranlib; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--disable-mount-locking \
			--without-openldap \
			--without-sasl \
			--enable-ignore-busy \
			--with-path=$(PATH) \
			--with-libtirpc \
			--with-hesiod=no \
			--with-confdir=/etc \
			--with-mapdir=/etc \
			--with-fifodir=/var/run \
			--with-flagdir=/var/run \
			; \
		sed -i "s|nfs/nfs.h|linux/nfs.h|" include/rpc_subs.h; \
		$(MAKE) SUBDIRS="lib daemon modules" DONTSTRIP=1; \
		$(MAKE) SUBDIRS="lib daemon modules" install DESTDIR=$(TARGET_DIR)
	cp -a $(IMAGEFILES)/autofs/* $(TARGET_DIR)/
	ln -sf autofs $(TARGET_DIR)/etc/init.d/S60autofs
	ln -sf autofs $(TARGET_DIR)/etc/init.d/K40autofs
	$(REMOVE)/autofs-$(AUTOFS5_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

samba: samba-$(BOXSERIES)

# -----------------------------------------------------------------------------

SAMBA33_PATCH  = samba33-build-only-what-we-need.patch
SAMBA33_PATCH += samba33-configure.in-make-getgrouplist_ok-test-cross-compile.patch

$(D)/samba-hd1: $(D)/zlib $(ARCHIVE)/samba-$(SAMBA33_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/samba-$(SAMBA33_VER)
	$(UNTAR)/samba-$(SAMBA33_VER).tar.gz
	$(CHDIR)/samba-$(SAMBA33_VER); \
		$(call apply_patches, $(SAMBA33_PATCH)); \
	$(CHDIR)/samba-$(SAMBA33_VER)/source; \
		./autogen.sh; \
		export CONFIG_SITE=$(CONFIGS)/samba33-config.site; \
		$(CONFIGURE) \
			--prefix=/ \
			--datadir=/var/samba \
			--datarootdir=/.remove \
			--localstatedir=/var/samba \
			--sysconfdir=/etc/samba \
			--with-configdir=/etc/samba \
			--with-privatedir=/etc/samba \
			--with-modulesdir=/.remove \
			--with-sys-quotas=no \
			--with-piddir=/tmp \
			--enable-static \
			--disable-shared \
			--without-cifsmount \
			--without-acl-support \
			--without-ads \
			--without-cluster-support \
			--without-dnsupdate \
			--without-krb5 \
			--without-ldap \
			--without-libnetapi \
			--without-libtalloc \
			--without-libtdb \
			--without-libsmbsharemodes \
			--without-libsmbclient \
			--without-libaddns \
			--without-pam \
			--without-winbind \
			--disable-shared-libs \
			--disable-avahi \
			--disable-cups \
			--disable-iprint \
			--disable-pie \
			--disable-relro \
			--disable-swat \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/var/samba/locks
	install $(IMAGEFILES)/scripts/smb3.conf $(TARGET_DIR)/etc/samba/smb.conf
	install -m 755 $(IMAGEFILES)/scripts/samba3.init $(TARGET_DIR)/etc/init.d/samba
	ln -sf samba $(TARGET_DIR)/etc/init.d/S99samba
	ln -sf samba $(TARGET_DIR)/etc/init.d/K01samba
	rm -rf $(TARGET_DIR)/bin/testparm
	rm -rf $(TARGET_DIR)/bin/findsmb
	rm -rf $(TARGET_DIR)/bin/smbtar
	rm -rf $(TARGET_DIR)/bin/smbclient
	rm -rf $(TARGET_DIR)/bin/smbpasswd
	$(REMOVE)/samba-$(SAMBA33_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMBA36_PATCH1  = samba36-build-only-what-we-need.patch
SAMBA36_PATCH1 += samba36-remove_printer_support.patch
SAMBA36_PATCH1 += samba36-remove_ad_support.patch
SAMBA36_PATCH1 += samba36-remove_services.patch
SAMBA36_PATCH1 += samba36-remove_winreg_support.patch
SAMBA36_PATCH1 += samba36-remove_registry_backend.patch
SAMBA36_PATCH1 += samba36-strip_srvsvc.patch

SAMBA36_PATCH0  = samba36-CVE-2016-2112-v3-6.patch
SAMBA36_PATCH0 += samba36-CVE-2016-2115-v3-6.patch
SAMBA36_PATCH0 += samba36-CVE-2017-7494-v3-6.patch

$(D)/samba-hd51 \
$(D)/samba-hd2: $(D)/zlib $(ARCHIVE)/samba-$(SAMBA36_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/samba-$(SAMBA36_VER)
	$(UNTAR)/samba-$(SAMBA36_VER).tar.gz
	$(CHDIR)/samba-$(SAMBA36_VER); \
		$(call apply_patches, $(SAMBA36_PATCH1), 1); \
		$(call apply_patches, $(SAMBA36_PATCH0), 0); \
	$(CHDIR)/samba-$(SAMBA36_VER)/source3; \
		./autogen.sh; \
		export CONFIG_SITE=$(CONFIGS)/samba36-config.site; \
		$(CONFIGURE) \
			--prefix=/ \
			--datadir=/var/samba \
			--datarootdir=/.remove \
			--localstatedir=/var/samba \
			--sysconfdir=/etc/samba \
			--with-configdir=/etc/samba \
			--with-privatedir=/etc/samba \
			--with-modulesdir=/.remove \
			--with-piddir=/tmp \
			--with-sys-quotas=no \
			--enable-static \
			--disable-shared \
			--without-acl-support \
			--without-ads \
			--without-cluster-support \
			--without-dmapi \
			--without-dnsupdate \
			--without-krb5 \
			--without-ldap \
			--without-libnetapi \
			--without-libsmbsharemodes \
			--without-libsmbclient \
			--without-libaddns \
			--without-pam \
			--without-winbind \
			--disable-shared-libs \
			--disable-avahi \
			--disable-cups \
			--disable-iprint \
			--disable-pie \
			--disable-relro \
			--disable-swat \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/var/samba/locks
	install $(IMAGEFILES)/scripts/smb3.conf $(TARGET_DIR)/etc/samba/smb.conf
	install -m 755 $(IMAGEFILES)/scripts/samba3.init $(TARGET_DIR)/etc/init.d/samba
	ln -sf samba $(TARGET_DIR)/etc/init.d/S99samba
	ln -sf samba $(TARGET_DIR)/etc/init.d/K01samba
	rm -rf $(TARGET_DIR)/bin/testparm
	rm -rf $(TARGET_DIR)/bin/findsmb
	rm -rf $(TARGET_DIR)/bin/smbtar
	rm -rf $(TARGET_DIR)/bin/smbclient
	rm -rf $(TARGET_DIR)/bin/smbpasswd
	$(REMOVE)/samba-$(SAMBA36_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/dropbear: $(D)/zlib $(ARCHIVE)/dropbear-$(DROPBEAR_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/dropbear-$(DROPBEAR_VER)
	$(UNTAR)/dropbear-$(DROPBEAR_VER).tar.bz2
	$(CHDIR)/dropbear-$(DROPBEAR_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--disable-pututxline \
			--disable-wtmp \
			--disable-wtmpx \
			--disable-loginfunc \
			--disable-pam \
			--disable-zlib \
			--disable-harden \
			--enable-bundled-libtom \
			; \
		# Ensure that dropbear doesn't use crypt() when it's not available; \
		echo '#if !HAVE_CRYPT'                          >> localoptions.h; \
		echo '#define DROPBEAR_SVR_PASSWORD_AUTH 0'     >> localoptions.h; \
		echo '#endif'                                   >> localoptions.h; \
		# disable SMALL_CODE define; \
		sed -i 's|^\(#define DROPBEAR_SMALL_CODE\).*|\1 0|' default_options.h; \
		# fix PATH define; \
		sed -i 's|^\(#define DEFAULT_PATH\).*|\1 "/sbin:/bin:/var/bin"|' default_options.h; \
		# remove /usr prefix; \
		sed -i 's|/usr/|/|g' default_options.h; \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" SCPPROGRESS=1; \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" install DESTDIR=$(TARGET_DIR)
	install -D -m 0755 $(IMAGEFILES)/scripts/dropbear.init $(TARGET_DIR)/etc/init.d/dropbear
	install -d -m 0755 $(TARGET_DIR)/etc/dropbear
	ln -sf dropbear $(TARGET_DIR)/etc/init.d/S60dropbear
	ln -sf dropbear $(TARGET_DIR)/etc/init.d/K60dropbear
	$(REMOVE)/dropbear-$(DROPBEAR_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/sg3-utils: $(ARCHIVE)/sg3_utils-$(SG3-UTILS_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/sg3_utils-$(SG3-UTILS_VER)
	$(UNTAR)/sg3_utils-$(SG3-UTILS_VER).tar.xz
	$(CHDIR)/sg3_utils-$(SG3-UTILS_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			; \
		$(MAKE); \
		cp -a src/.libs/sg_start $(TARGET_DIR)/bin; \
		cp -a lib/.libs/libsgutils2.so.2.0.0 $(TARGET_LIB_DIR); \
		cp -a lib/.libs/libsgutils2.so.2 $(TARGET_LIB_DIR); \
		cp -a lib/.libs/libsgutils2.so $(TARGET_LIB_DIR)
	install -D -m 755 $(IMAGEFILES)/scripts/sdX.init $(TARGET_DIR)/etc/init.d/sdX
	ln -sf sdX $(TARGET_DIR)/etc/init.d/K97sdX
	$(REMOVE)/sg3_utils-$(SG3-UTILS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

FBSHOT_PATCH  = fbshot-32bit_cs_fb.diff
FBSHOT_PATCH += fbshot_cs_hd2.diff

$(D)/fbshot: $(D)/libpng $(ARCHIVE)/fbshot-$(FBSHOT_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/fbshot-$(FBSHOT_VER)
	$(UNTAR)/fbshot-$(FBSHOT_VER).tar.gz
	$(CHDIR)/fbshot-$(FBSHOT_VER); \
		$(call apply_patches, $(FBSHOT_PATCH)); \
		sed -i 's|	gcc |	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) |' Makefile; \
		sed -i '/strip fbshot/d' Makefile; \
		$(MAKE) all; \
		install -D -m 755 fbshot $(TARGET_DIR)/bin/fbshot
	$(REMOVE)/fbshot-$(FBSHOT_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/lcd4linux: $(D)/libncurses $(D)/libgd2 $(D)/libdpf | $(TARGET_DIR)
	$(REMOVE)/lcd4linux
	git clone https://github.com/TangoCash/lcd4linux.git $(BUILD_TMP)/lcd4linux
	$(CHDIR)/lcd4linux; \
		./bootstrap; \
		$(CONFIGURE) \
			--libdir=$(TARGET_LIB_DIR) \
			--includedir=$(TARGET_INCLUDE_DIR) \
			--bindir=$(TARGET_DIR)/bin \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--infodir=/.remove \
			--with-ncurses=$(TARGET_LIB_DIR) \
			--with-drivers='DPF, SamsungSPF' \
			--with-plugins='all,!dbus,!mpris_dbus,!asterisk,!isdn,!pop3,!ppp,!seti,!huawei,!imon,!kvv,!sample,!w1retap,!wireless,!xmms,!gps,!mpd,!mysql,!qnaplog,!iconv' \
			; \
		$(MAKE) vcs_version; \
		$(MAKE) all; \
		$(MAKE) install
	$(REMOVE)/lcd4linux
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/wpa_supplicant: $(D)/openssl $(ARCHIVE)/wpa_supplicant-$(WPA_SUPP_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/wpa_supplicant-$(WPA_SUPP_VER)
	$(UNTAR)/wpa_supplicant-$(WPA_SUPP_VER).tar.gz
	$(CHDIR)/wpa_supplicant-$(WPA_SUPP_VER)/wpa_supplicant; \
		cp $(CONFIGS)/wpa_supplicant.config .config; \
		CC=$(TARGET)-gcc CFLAGS="$(TARGET_CFLAGS)" CXXFLAGS="$(TARGET_CXXFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE)
	cp -f $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPP_VER)/wpa_supplicant/wpa_cli $(TARGET_DIR)/sbin/wpa_cli
	cp -f $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPP_VER)/wpa_supplicant/wpa_passphrase $(TARGET_DIR)/sbin/wpa_passphrase
	cp -f $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPP_VER)/wpa_supplicant/wpa_supplicant $(TARGET_DIR)/sbin/wpa_supplicant
	$(REMOVE)/wpa_supplicant-$(WPA_SUPP_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

XUPNPD_PATCH  = xupnpd-coolstream-dynamic-lua.patch
XUPNPD_PATCH += xupnpd-fix-memleak-on-coolstream-boxes-thanks-ng777.patch
XUPNPD_PATCH += xupnpd-fix-webif-backlinks.diff
XUPNPD_PATCH += xupnpd-change-XUPNPDROOTDIR.diff
XUPNPD_PATCH += xupnpd-add-configuration-files.diff

$(D)/xupnpd: $(D)/lua $(D)/openssl | $(TARGET_DIR)
	$(REMOVE)/xupnpd
	git clone https://github.com/clark15b/xupnpd.git $(BUILD_TMP)/xupnpd
	$(CHDIR)/xupnpd; \
		$(call apply_patches, $(XUPNPD_PATCH))
	$(CHDIR)/xupnpd/src; \
		$(BUILDENV) \
		$(MAKE) embedded TARGET=$(TARGET) CC=$(TARGET)-gcc STRIP=$(TARGET)-strip LUAFLAGS="$(TARGET_LDFLAGS) -I$(TARGET_INCLUDE_DIR)"; \
	install -D -m 0755 xupnpd $(BIN)/; \
	mkdir -p $(TARGET_DIR)/share/xupnpd/config; \
	for object in *.lua plugins/ profiles/ ui/ www/; do \
		cp -a $$object $(TARGET_DIR)/share/xupnpd/; \
	done;
	rm $(TARGET_DIR)/share/xupnpd/plugins/staff/xupnpd_18plus.lua
	install -D -m 644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_18plus.lua $(TARGET_DIR)/share/xupnpd/plugins/
	install -D -m 644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_youtube.lua $(TARGET_DIR)/share/xupnpd/plugins/
	install -D -m 644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_coolstream.lua $(TARGET_DIR)/share/xupnpd/plugins/
	install -D -m 644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_cczwei.lua $(TARGET_DIR)/share/xupnpd/plugins/
	mkdir -p $(TARGET_DIR)/etc/init.d/
		install -D -m 0755 $(IMAGEFILES)/scripts/xupnpd.init $(TARGET_DIR)/etc/init.d/xupnpd
		ln -sf xupnpd $(TARGET_DIR)/etc/init.d/S99xupnpd
		ln -sf xupnpd $(TARGET_DIR)/etc/init.d/K01xupnpd
	cp -a $(IMAGEFILES)/xupnpd/* $(TARGET_DIR)/
	$(REMOVE)/xupnpd
	$(TOUCH)

# -----------------------------------------------------------------------------

DOSFSTOOLS_CFLAGS = $(TARGET_CFLAGS) -D_GNU_SOURCE -fomit-frame-pointer -D_FILE_OFFSET_BITS=64

$(D)/dosfstools: $(DOSFSTOOLS_DEPS) $(ARCHIVE)/dosfstools-$(DOSFSTOOLS_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/dosfstools-$(DOSFSTOOLS_VER)
	$(UNTAR)/dosfstools-$(DOSFSTOOLS_VER).tar.xz
	$(CHDIR)/dosfstools-$(DOSFSTOOLS_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--without-udev \
			--enable-compat-symlinks \
			CFLAGS="$(DOSFSTOOLS_CFLAGS)" \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/dosfstools-$(DOSFSTOOLS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

NFS-UTILS_IPV6=--enable-ipv6
ifeq ($(BOXSERIES), hd1)
	NFS-UTILS_IPV6=--disable-ipv6
endif

NFS-UTILS_PATCH  = nfs-utils_01-Patch-taken-from-Gentoo.patch
NFS-UTILS_PATCH += nfs-utils_02-Switch-legacy-index-in-favour-of-strchr.patch
NFS-UTILS_PATCH += nfs-utils_03-Let-the-configure-script-find-getrpcbynumber-in-libt.patch
NFS-UTILS_PATCH += nfs-utils_04-mountd-Add-check-for-struct-file_handle.patch
NFS-UTILS_PATCH += nfs-utils_05-sm-notify-use-sbin-instead-of-usr-sbin.patch

$(D)/nfs-utils: $(D)/rpcbind $(ARCHIVE)/nfs-utils-$(NFS-UTILS_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/nfs-utils-$(NFS-UTILS_VER)
	$(UNTAR)/nfs-utils-$(NFS-UTILS_VER).tar.bz2
	$(CHDIR)/nfs-utils-$(NFS-UTILS_VER); \
		$(call apply_patches, $(NFS-UTILS_PATCH)); \
		export knfsd_cv_bsd_signals=no; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--enable-maintainer-mode \
			--docdir=/.remove \
			--mandir=/.remove \
			--disable-nfsv4 \
			--disable-nfsv41 \
			--disable-gss \
			--disable-uuid \
			$(NFS-UTILS_IPV6) \
			--without-tcp-wrappers \
			--with-statedir=/var/lib/nfs \
			--with-rpcgen=internal \
			--without-systemd \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	chmod 755 $(TARGET_DIR)/sbin/mount.nfs
	rm -rf $(TARGET_DIR)/sbin/mountstats
	rm -rf $(TARGET_DIR)/sbin/nfsiostat
	rm -rf $(TARGET_DIR)/sbin/osd_login
	rm -rf $(TARGET_DIR)/sbin/start-statd
	rm -rf $(TARGET_DIR)/sbin/mount.nfs*
	rm -rf $(TARGET_DIR)/sbin/umount.nfs*
	rm -rf $(TARGET_DIR)/sbin/showmount
	rm -rf $(TARGET_DIR)/sbin/rpcdebug
	install -m 755 -D $(IMAGEFILES)/scripts/nfsd.init $(TARGET_DIR)/etc/init.d/nfsd
	ln -s nfsd $(TARGET_DIR)/etc/init.d/S60nfsd
	ln -s nfsd $(TARGET_DIR)/etc/init.d/K01nfsd
	$(REMOVE)/nfs-utils-$(NFS-UTILS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

RPCBIND_PATCH  = rpcbind-0001-Remove-yellow-pages-support.patch

$(D)/rpcbind: $(D)/libtirpc $(ARCHIVE)/rpcbind-$(RPCBIND_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/rpcbind-$(RPCBIND_VER)
	$(UNTAR)/rpcbind-$(RPCBIND_VER).tar.bz2
	$(CHDIR)/rpcbind-$(RPCBIND_VER); \
		$(call apply_patches, $(RPCBIND_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--enable-silent-rules \
			--with-rpcuser=root \
			--with-systemdsystemunitdir=no \
			--mandir=/.remove \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
ifeq ($(BOXSERIES), hd1)
	sed -i -e '/^\(udp\|tcp\)6/ d' $(TARGET_DIR)/etc/netconfig
endif
	rm -rf $(TARGET_DIR)/bin/rpcgen
	$(REMOVE)/rpcbind-$(RPCBIND_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/fuse-exfat: $(ARCHIVE)/fuse-exfat-$(FUSE_EXFAT_VER).tar.gz $(D)/libfuse | $(TARGET_DIR)
	$(REMOVE)/fuse-exfat-$(FUSE_EXFAT_VER)
	$(UNTAR)/fuse-exfat-$(FUSE_EXFAT_VER).tar.gz
	$(CHDIR)/fuse-exfat-$(FUSE_EXFAT_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--docdir=/.remove \
			--mandir=/.remove \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/fuse-exfat-$(FUSE_EXFAT_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/exfat-utils: $(ARCHIVE)/exfat-utils-$(EXFAT_UTILS_VER).tar.gz $(D)/fuse-exfat | $(TARGET_DIR)
	$(REMOVE)/exfat-utils-$(EXFAT_UTILS_VER)
	$(UNTAR)/exfat-utils-$(EXFAT_UTILS_VER).tar.gz
	$(CHDIR)/exfat-utils-$(EXFAT_UTILS_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--docdir=/.remove \
			--mandir=/.remove \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/exfat-utils-$(EXFAT_UTILS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/streamripper: $(D)/libvorbisidec $(D)/libmad $(D)/libglib2 | $(TARGET_DIR)
	$(REMOVE)/$(NI_STREAMRIPPER)
	tar -C $(SOURCE_DIR) -cp $(NI_STREAMRIPPER) --exclude-vcs | tar -C $(BUILD_TMP) -x
	$(CHDIR)/$(NI_STREAMRIPPER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--includedir=$(TARGET_DIR)/include \
			--datarootdir=/.remove \
			--with-included-argv=yes \
			--with-included-libmad=no \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -m755 $(IMAGEFILES)/scripts/streamripper.sh $(TARGET_DIR)/bin/
	$(REMOVE)/$(NI_STREAMRIPPER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/gettext: $(ARCHIVE)/gettext-$(GETTEXT_VERSION).tar.xz | $(TARGET_DIR)
	$(REMOVE)/gettext-$(GETTEXT_VERSION)
	$(UNTAR)/gettext-$(GETTEXT_VERSION).tar.xz
	$(CHDIR)/gettext-$(GETTEXT_VERSION)/gettext-runtime; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--disable-libasprintf \
			--disable-acl \
			--disable-openmp \
			--disable-java \
			--disable-native-java \
			--disable-csharp \
			--disable-relocatable \
			--without-emacs \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/bin/envsubst
	rm -rf $(TARGET_DIR)/bin/gettext
	rm -rf $(TARGET_DIR)/bin/gettext.sh
	rm -rf $(TARGET_DIR)/bin/ngettext
	$(REWRITE_LIBTOOL)/libintl.la
	$(REMOVE)/gettext-$(GETTEXT_VERSION)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/mc: $(ARCHIVE)/mc-$(MC_VER).tar.xz $(D)/libglib2 $(D)/libncurses | $(TARGET_DIR)
	$(REMOVE)/mc-$(MC_VER)
	$(UNTAR)/mc-$(MC_VER).tar.xz
	$(CHDIR)/mc-$(MC_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--enable-maintainer-mode \
			--enable-silent-rules \
			\
			--disable-charset \
			--disable-nls \
			--disable-vfs-extfs \
			--disable-vfs-fish \
			--disable-vfs-sfs \
			--disable-vfs-sftp \
			--with-screen=ncurses \
			--without-diff-viewer \
			--without-x \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/share/mc/examples
	find $(TARGET_DIR)/share/mc/skins -type f ! -name default.ini | xargs --no-run-if-empty rm
	$(REMOVE)/mc-$(MC_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

WGET_PATCH  = wget-remove-hardcoded-engine-support-for-openss.patch
WGET_PATCH += wget-set-check_cert-false-by-default.patch
WGET_PATCH += wget-change_DEFAULT_LOGFILE.patch

$(D)/wget: $(D)/openssl $(ARCHIVE)/wget-$(WGET_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/wget-$(WGET_VER)
	$(UNTAR)/wget-$(WGET_VER).tar.gz
	$(CHDIR)/wget-$(WGET_VER); \
		$(call apply_patches, $(WGET_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--datarootdir=/.remove \
			--docdir=/.remove \
			--sysconfdir=/.remove \
			--mandir=/.remove \
			--with-gnu-ld \
			--with-ssl=openssl \
			--disable-debug \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/wget-$(WGET_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBICONV_PATCH  = iconv-disable_transliterations.patch
LIBICONV_PATCH += iconv-strip_charsets.patch

# builds only stripped down iconv binary
# used for smarthomeinfo plugin
$(D)/iconv: $(ARCHIVE)/libiconv-$(LIBICONV_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/libiconv-$(LIBICONV_VER)
	$(UNTAR)/libiconv-$(LIBICONV_VER).tar.gz
	$(CHDIR)/libiconv-$(LIBICONV_VER); \
		$(call apply_patches, $(LIBICONV_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--enable-static \
			--disable-shared \
			--enable-relocatable \
			--datarootdir=/.remove \
			; \
		$(MAKE); \
	$(MAKE) install DESTDIR=$(BUILD_TMP)/libiconv-$(LIBICONV_VER)/tmp
	cp -a $(BUILD_TMP)/libiconv-$(LIBICONV_VER)/tmp/bin/iconv $(TARGET_DIR)/bin
	$(REMOVE)/libiconv-$(LIBICONV_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/ofgwrite: $(SOURCE_DIR)/$(NI_OFGWRITE) | $(TARGET_DIR)
	$(REMOVE)/$(NI_OFGWRITE)
	tar -C $(SOURCE_DIR) -cp $(NI_OFGWRITE) --exclude-vcs | tar -C $(BUILD_TMP) -x
	$(CHDIR)/$(NI_OFGWRITE); \
		$(BUILDENV) \
		$(MAKE)
	install -m 755 $(BUILD_TMP)/$(NI_OFGWRITE)/ofgwrite_bin $(TARGET_DIR)/bin
	install -m 755 $(BUILD_TMP)/$(NI_OFGWRITE)/ofgwrite_tgz $(TARGET_DIR)/bin
	install -m 755 $(BUILD_TMP)/$(NI_OFGWRITE)/ofgwrite $(TARGET_DIR)/bin
	$(REMOVE)/$(NI_OFGWRITE)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/aio-grab: $(D)/zlib $(D)/libpng $(D)/libjpeg | $(TARGET_DIR)
	$(REMOVE)/aio-grab
	git clone git://github.com/oe-alliance/aio-grab.git $(BUILD_TMP)/aio-grab; \
	$(CHDIR)/aio-grab; \
		aclocal --force -I m4; \
		libtoolize --copy --ltdl --force; \
		autoconf --force; \
		automake --add-missing --copy --force-missing --foreign; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--enable-silent-rules \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/aio-grab
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/dvbsnoop: | $(TARGET_DIR)
	$(REMOVE)/dvbsnoop
	git clone https://github.com/Duckbox-Developers/dvbsnoop.git $(BUILD_TMP)/dvbsnoop; \
	$(CHDIR)/dvbsnoop; \
		$(CONFIGURE) \
			--enable-silent-rules \
			--prefix= \
			--mandir=/.remove \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/dvbsnoop
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/ethtool: $(ARCHIVE)/$(ETHTOOL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/ethtool-$(ETHTOOL_VER)
	$(UNTAR)/$(ETHTOOL_SOURCE)
	$(CHDIR)/ethtool-$(ETHTOOL_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--libdir=$(TARGET_LIB_DIR) \
			--disable-pretty-dump \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/ethtool-$(ETHTOOL_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/gptfdisk: $(D)/popt $(D)/e2fsprogs $(ARCHIVE)/$(GPTFDISK_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/gptfdisk-$(GPTFDISK_VER)
	$(UNTAR)/$(GPTFDISK_SOURCE)
	$(CHDIR)/gptfdisk-$(GPTFDISK_VER); \
		sed -i 's|^CC=.*|CC=$(TARGET)-gcc|' Makefile; \
		sed -i 's|^CXX=.*|CXX=$(TARGET)-g++|' Makefile; \
		$(BUILDENV) \
		$(MAKE) sgdisk; \
		install -m 755 -D sgdisk $(TARGET_DIR)/sbin/
	$(REMOVE)/gptfdisk-$(GPTFDISK_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/popt: $(ARCHIVE)/$(POPT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/popt-$(POPT_VER)
	$(UNTAR)/$(POPT_SOURCE)
	$(CHDIR)/popt-$(POPT_VER); \
		$(CONFIGURE) \
			--prefix= \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/popt-$(POPT_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/ca-bundle: $(ARCHIVE)/cacert.pem | $(TARGET_DIR)
	curl --remote-name --time-cond $(ARCHIVE)/cacert.pem https://curl.haxx.se/ca/cacert.pem
	install -D -m 644 $(ARCHIVE)/cacert.pem $(TARGET_DIR)/$(CA-BUNDLE_DIR)/$(CA-BUNDLE)
	$(TOUCH)
