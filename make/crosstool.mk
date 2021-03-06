#
# makefile to build crosstools
#
# -----------------------------------------------------------------------------

crosstool: $(CROSS_DIR)

crosstools:
	for boxseries in hd1 hd2 hd51 vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo; do \
		echo "make crosstool-ng for $${boxseries}"; \
		make BOXSERIES=$${boxseries} crosstool || exit; \
	done;

# -----------------------------------------------------------------------------

CROSSTOOL_BACKUP = $(ARCHIVE)/crosstool-ng-$(BOXARCH)-linux-$(KERNEL_VER)-backup.tar.gz

$(CROSSTOOL_BACKUP):
	$(call draw_line);
	@echo "CROSSTOOL_BACKUP does not exist. You probably need to run 'make crosstool-backup' first."
	$(call draw_line);
	@false

crosstool-backup:
	$(CD) $(CROSS_DIR); \
		tar -czvf $(CROSSTOOL_BACKUP) *

crosstool-restore: $(CROSSTOOL_BACKUP)
	make cross-clean
	mkdir -p $(CROSS_DIR)
	tar -xzvf $(CROSSTOOL_BACKUP) -C $(CROSS_DIR)

# -----------------------------------------------------------------------------

crosstools-renew:
	for boxseries in hd1 hd2 hd51 vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo; do \
		make BOXSERIES=$${boxseries} ccache-clean || exit; \
	done;
	make host-clean
	make static-base-clean
	make cross-base-clean
	make crosstools
	make clean

# -----------------------------------------------------------------------------

# wrapper for manually call
kernel-tarball: $(BUILD_TMP)/linux-$(KERNEL_VER).tar

# create kernel-tarball
$(BUILD_TMP)/linux-$(KERNEL_VER).tar: | $(BUILD_TMP)
	$(MAKE) kernel.do_prepare.$(if $(filter $(KERNEL_SOURCE),git),git,tar)
	tar cf $(@) --exclude-vcs -C $(BUILD_TMP)/$(KERNEL_TMP) .

# -----------------------------------------------------------------------------

CROSSTOOL-NG_VER    = git
CROSSTOOL-NG_TMP    = crosstool-ng.$(CROSSTOOL-NG_VER)
CROSSTOOL-NG_SOURCE = crosstool-ng.$(CROSSTOOL-NG_VER)
CROSSTOOL-NG_URL    = https://github.com/MaxWiesel

CROSSTOOL-NG_PATCH  = crosstool-ng-bash-version.patch

CROSSTOOL-NG_CONFIG = $(CONFIGS)/ct-ng-$(BOXTYPE).config
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd1 hd2))
  CROSSTOOL-NG_CONFIG = $(CONFIGS)/ct-ng-$(BOXTYPE)-$(BOXSERIES).config
endif

# crosstool for hd2 depends on gcc-linaro
GCC-LINARO_VER    = 4.9-2017.01
GCC-LINARO_SOURCE = gcc-linaro-$(GCC-LINARO_VER).tar.xz
GCC-LINARO_URL    = https://releases.linaro.org/components/toolchain/gcc-linaro/$(GCC-LINARO_VER)

$(ARCHIVE)/$(GCC-LINARO_SOURCE):
	$(DOWNLOAD) $(GCC-LINARO_URL)/$(GCC-LINARO_SOURCE)

UCLIBC_VER = 1.0.24

# -----------------------------------------------------------------------------

# crosstool for arm-hd2 depends on gcc-linaro
$(CROSS_BASE)/arm/hd2: $(ARCHIVE)/$(GCC-LINARO_SOURCE)

$(CROSS_DIR): | $(BUILD_TMP)
	make $(BUILD_TMP)/linux-$(KERNEL_VER).tar
	#
	$(REMOVE)/$(CROSSTOOL-NG_TMP)
	$(GET-GIT-SOURCE) $(CROSSTOOL-NG_URL)/$(CROSSTOOL-NG_SOURCE) $(ARCHIVE)/$(CROSSTOOL-NG_SOURCE)
	$(CPDIR)/$(CROSSTOOL-NG_SOURCE)
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd1 hd2))
	$(CHDIR)/$(CROSSTOOL-NG_TMP); \
		git checkout 1dbb06f2; \
		$(call apply_patches, $(CROSSTOOL-NG_PATCH))
  ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2))
	$(CHDIR)/$(CROSSTOOL-NG_TMP); \
		$(INSTALL_COPY) $(PATCHES)/crosstool-ng/gcc/* patches/gcc/linaro-6.3-2017.02
  endif
endif
	$(CHDIR)/$(CROSSTOOL-NG_TMP); \
		unset CONFIG_SITE LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE; \
		$(INSTALL_DATA) $(CROSSTOOL-NG_CONFIG) .config; \
		sed -i "s|^CT_PARALLEL_JOBS=.*|CT_PARALLEL_JOBS=$(PARALLEL_JOBS)|" .config; \
		export NI_LOCAL_TARBALLS_DIR=$(ARCHIVE); \
		export NI_PREFIX_DIR=$(@); \
		export NI_KERNEL_VERSION=$(KERNEL_VER); \
		export NI_KERNEL_LOCATION=$(BUILD_TMP)/linux-$(KERNEL_VER).tar; \
		export NI_LIBC_UCLIBC_CONFIG_FILE=$(CONFIGS)/ct-ng-uClibc-$(UCLIBC_VER).config; \
		export LD_LIBRARY_PATH=; \
		test -f ./configure || ./bootstrap; \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd1 hd2))
	test -e $(CROSS_DIR)/$(TARGET)/lib && mv $(CROSS_DIR)/$(TARGET)/lib $(CROSS_DIR)/$(TARGET)/lib.x
endif
	test -e $(CROSS_DIR)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/
	rm -f $(CROSS_DIR)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.*-gdb.py
	$(REMOVE)/$(CROSSTOOL-NG_TMP)

# -----------------------------------------------------------------------------

get-gccversion:
	@echo ""
	@$(TARGET_CC) --version

# -----------------------------------------------------------------------------

PHONY += crosstool
PHONY += crosstools
PHONY += crosstools-renew

PHONY += get-gccversion
