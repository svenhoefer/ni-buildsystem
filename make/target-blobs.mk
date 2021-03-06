#
# makefile to add binary large objects
#
# -----------------------------------------------------------------------------

#BLOBS_DEPS = kernel # because of depmod

blobs: $(BLOBS_DEPS)
	$(MAKE) firmware
	$(MAKE) $(BOXMODEL)-drivers
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), hd51 bre2ze4k h7 vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse))
	$(MAKE) $(BOXMODEL)-libgles
endif
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse))
	$(MAKE) vuplus-platform-util
endif

# -----------------------------------------------------------------------------

firmware: firmware-boxmodel firmware-wireless

firmware-boxmodel: $(SOURCE_DIR)/$(NI-DRIVERS-BIN) | $(TARGET_DIR)
	$(call INSTALL_EXIST,$(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/lib-firmware/.,$(TARGET_LIB_DIR)/firmware)
	$(call INSTALL_EXIST,$(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/lib-firmware-dvb/.,$(TARGET_LIB_DIR)/firmware)

ifeq ($(BOXMODEL), nevis)
  FIRMWARE-WIRELESS  = rt2870.bin
  FIRMWARE-WIRELESS += rt3070.bin
  FIRMWARE-WIRELESS += rt3071.bin
  FIRMWARE-WIRELESS += rtlwifi/rtl8192cufw.bin
  FIRMWARE-WIRELESS += rtlwifi/rtl8712u.bin
else
  FIRMWARE-WIRELESS  = $(shell cd $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/general/firmware-wireless; find * -type f)
endif

firmware-wireless: $(SOURCE_DIR)/$(NI-DRIVERS-BIN) | $(TARGET_DIR)
	for firmware in $(FIRMWARE-WIRELESS); do \
		$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/general/firmware-wireless/$$firmware $(TARGET_LIB_DIR)/firmware/$$firmware; \
	done

# -----------------------------------------------------------------------------

HD51-DRIVERS_VER    = 20191120
HD51-DRIVERS_SOURCE = hd51-drivers-$(KERNEL_VER)-$(HD51-DRIVERS_VER).zip
HD51-DRIVERS_URL    = http://source.mynonpublic.com/gfutures

BRE2ZE4K-DRIVERS_VER    = 20191120
BRE2ZE4K-DRIVERS_SOURCE = bre2ze4k-drivers-$(KERNEL_VER)-$(BRE2ZE4K-DRIVERS_VER).zip
BRE2ZE4K-DRIVERS_URL    = http://source.mynonpublic.com/gfutures

H7-DRIVERS_VER    = 20191123
H7-DRIVERS_SOURCE = h7-drivers-$(KERNEL_VER)-$(H7-DRIVERS_VER).zip
H7-DRIVERS_URL    = http://source.mynonpublic.com/zgemma

VUSOLO4K-DRIVERS_VER    = 20190424
VUSOLO4K-DRIVERS_SOURCE = vuplus-dvb-proxy-vusolo4k-3.14.28-$(VUSOLO4K-DRIVERS_VER).r0.tar.gz
VUSOLO4K-DRIVERS_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUDUO4K-DRIVERS_VER    = 20191125
VUDUO4K-DRIVERS_SOURCE = vuplus-dvb-proxy-vuduo4k-4.1.45-$(VUDUO4K-DRIVERS_VER).r0.tar.gz
VUDUO4K-DRIVERS_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUULTIMO4K-DRIVERS_VER    = 20190104
VUULTIMO4K-DRIVERS_SOURCE = vuplus-dvb-proxy-vuultimo4k-3.14.28-$(VUULTIMO4K-DRIVERS_VER).r0.tar.gz
VUULTIMO4K-DRIVERS_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUZERO4K-DRIVERS_VER    = 20190424
VUZERO4K-DRIVERS_SOURCE = vuplus-dvb-proxy-vuzero4k-4.1.20-$(VUZERO4K-DRIVERS_VER).r0.tar.gz
VUZERO4K-DRIVERS_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUUNO4K-DRIVERS_VER    = 20190104
VUUNO4K-DRIVERS_SOURCE = vuplus-dvb-proxy-vuuno4k-3.14.28-$(VUUNO4K-DRIVERS_VER).r0.tar.gz
VUUNO4K-DRIVERS_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUUNO4KSE-DRIVERS_VER    = 20190104
VUUNO4KSE-DRIVERS_SOURCE = vuplus-dvb-proxy-vuuno4kse-4.1.20-$(VUUNO4KSE-DRIVERS_VER).r0.tar.gz
VUUNO4KSE-DRIVERS_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUDUO-DRIVERS_VER    = 20151124
VUDUO-DRIVERS_SOURCE = vuplus-dvb-modules-bm750-3.9.6-$(VUDUO-DRIVERS_VER).tar.gz
VUDUO-DRIVERS_URL    = http://archive.vuplus.com/download/drivers

# -----------------------------------------------------------------------------

BOXMODEL-DRIVERS_VER    = $($(call UPPERCASE,$(BOXMODEL))-DRIVERS_VER)
BOXMODEL-DRIVERS_SOURCE = $($(call UPPERCASE,$(BOXMODEL))-DRIVERS_SOURCE)
BOXMODEL-DRIVERS_URL    = $($(call UPPERCASE,$(BOXMODEL))-DRIVERS_URL)

ifneq ($(BOXMODEL-DRIVERS_SOURCE),$(EMPTY))
$(ARCHIVE)/$(BOXMODEL-DRIVERS_SOURCE):
	$(DOWNLOAD) $(BOXMODEL-DRIVERS_URL)/$(BOXMODEL-DRIVERS_SOURCE)
endif

nevis-drivers \
apollo-drivers \
shiner-drivers \
kronos-drivers \
kronos_v2-drivers \
coolstream-drivers: $(SOURCE_DIR)/$(NI-DRIVERS-BIN) | $(TARGET_DIR)
	mkdir -p $(TARGET_LIB_DIR)
	$(INSTALL_COPY) $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/lib/. $(TARGET_LIB_DIR)
	$(INSTALL_COPY) $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/libcoolstream/$(shell echo -n $(NI-FFMPEG_BRANCH) | sed 's,/,-,g')/. $(TARGET_LIB_DIR)
ifeq ($(BOXMODEL), nevis)
	ln -sf libnxp.so $(TARGET_LIB_DIR)/libconexant.so
endif
	mkdir -p $(TARGET_MODULES_DIR)
	$(INSTALL_COPY) $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/lib-modules/$(KERNEL_VER)/. $(TARGET_MODULES_DIR)
ifeq ($(BOXMODEL), nevis)
	ln -sf $(KERNEL_VER) $(TARGET_MODULES_DIR)-$(BOXMODEL)
endif
	make depmod
	$(TOUCH)

hd51-drivers \
bre2ze4k-drivers \
h7-drivers: $(ARCHIVE)/$(BOXMODEL-DRIVERS_SOURCE) | $(TARGET_DIR)
	mkdir -p $(TARGET_MODULES_DIR)/extra
	unzip -o $(ARCHIVE)/$(BOXMODEL-DRIVERS_SOURCE) -d $(TARGET_MODULES_DIR)/extra
	make depmod
	$(TOUCH)

vusolo4k-drivers \
vuduo4k-drivers \
vuultimo4k-drivers \
vuzero4k-drivers \
vuuno4k-drivers \
vuuno4kse-drivers \
vuduo-drivers \
vuplus-drivers: $(ARCHIVE)/$(BOXMODEL-DRIVERS_SOURCE) | $(TARGET_DIR)
	mkdir -p $(TARGET_MODULES_DIR)/extra
	tar -xf $(ARCHIVE)/$(BOXMODEL-DRIVERS_SOURCE) -C $(TARGET_MODULES_DIR)/extra
	make depmod
	$(TOUCH)

# -----------------------------------------------------------------------------

HD51-LIBGLES_VER    = 20191101
HD51-LIBGLES_TMP    = $(EMPTY)
HD51-LIBGLES_SOURCE = hd51-v3ddriver-$(HD51-LIBGLES_VER).zip
HD51-LIBGLES_URL    = http://downloads.mutant-digital.net/v3ddriver

BRE2ZE4K-LIBGLES_VER    = 20191101
BRE2ZE4K-LIBGLES_TMP    = $(EMPTY)
BRE2ZE4K-LIBGLES_SOURCE = bre2ze4k-v3ddriver-$(BRE2ZE4K-LIBGLES_VER).zip
BRE2ZE4K-LIBGLES_URL    = http://downloads.mutant-digital.net/v3ddriver

H7-LIBGLES_VER    = 20191110
H7-LIBGLES_TMP    = $(EMPTY)
H7-LIBGLES_SOURCE = h7-v3ddriver-$(H7-LIBGLES_VER).zip
H7-LIBGLES_URL    = http://source.mynonpublic.com/zgemma

VUSOLO4K-LIBGLES_VER    = $(VUSOLO4K-DRIVERS_VER)
VUSOLO4K-LIBGLES_TMP    = libgles-vusolo4k
VUSOLO4K-LIBGLES_SOURCE = libgles-vusolo4k-17.1-$(VUSOLO4K-LIBGLES_VER).r0.tar.gz
VUSOLO4K-LIBGLES_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUDUO4K-LIBGLES_VER    = $(VUDUO4K-DRIVERS_VER)
VUDUO4K-LIBGLES_TMP    = libgles-vuduo4k
VUDUO4K-LIBGLES_SOURCE = libgles-vuduo4k-18.1-$(VUDUO4K-LIBGLES_VER).r0.tar.gz
VUDUO4K-LIBGLES_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUULTIMO4K-LIBGLES_VER    = $(VUULTIMO4K-DRIVERS_VER)
VUULTIMO4K-LIBGLES_TMP    = libgles-vuultimo4k
VUULTIMO4K-LIBGLES_SOURCE = libgles-vuultimo4k-17.1-$(VUULTIMO4K-LIBGLES_VER).r0.tar.gz
VUULTIMO4K-LIBGLES_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUZERO4K-LIBGLES_VER    = $(VUZERO4K-DRIVERS_VER)
VUZERO4K-LIBGLES_TMP    = libgles-vuzero4k
VUZERO4K-LIBGLES_SOURCE = libgles-vuzero4k-17.1-$(VUZERO4K-LIBGLES_VER).r0.tar.gz
VUZERO4K-LIBGLES_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUUNO4K-LIBGLES_VER    = $(VUUNO4K-DRIVERS_VER)
VUUNO4K-LIBGLES_TMP    = libgles-vuuno4k
VUUNO4K-LIBGLES_SOURCE = libgles-vuuno4k-17.1-$(VUUNO4K-LIBGLES_VER).r0.tar.gz
VUUNO4K-LIBGLES_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUUNO4KSE-LIBGLES_VER    = $(VUUNO4KSE-DRIVERS_VER)
VUUNO4KSE-LIBGLES_TMP    = libgles-vuuno4kse
VUUNO4KSE-LIBGLES_SOURCE = libgles-vuuno4kse-17.1-$(VUUNO4KSE-LIBGLES_VER).r0.tar.gz
VUUNO4KSE-LIBGLES_URL    = http://archive.vuplus.com/download/build_support/vuplus

# -----------------------------------------------------------------------------

BOXMODEL-LIBGLES_VER    = $($(call UPPERCASE,$(BOXMODEL))-LIBGLES_VER)
BOXMODEL-LIBGLES_TMP    = $($(call UPPERCASE,$(BOXMODEL))-LIBGLES_TMP)
BOXMODEL-LIBGLES_SOURCE = $($(call UPPERCASE,$(BOXMODEL))-LIBGLES_SOURCE)
BOXMODEL-LIBGLES_URL    = $($(call UPPERCASE,$(BOXMODEL))-LIBGLES_URL)

ifneq ($(BOXMODEL-LIBGLES_SOURCE),$(EMPTY))
$(ARCHIVE)/$(BOXMODEL-LIBGLES_SOURCE):
	$(DOWNLOAD) $(BOXMODEL-LIBGLES_URL)/$(BOXMODEL-LIBGLES_SOURCE)
endif

hd51-libgles \
bre2ze4k-libgles \
h7-libgles: $(ARCHIVE)/$(BOXMODEL-LIBGLES_SOURCE) | $(TARGET_DIR)
	unzip -o $(ARCHIVE)/$(BOXMODEL-LIBGLES_SOURCE) -d $(TARGET_LIB_DIR)
	ln -sf libv3ddriver.so $(TARGET_LIB_DIR)/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_LIB_DIR)/libGLESv2.so
	$(TOUCH)

vusolo4k-libgles \
vuduo4k-libgles \
vuultimo4k-libgles \
vuzero4k-libgles \
vuuno4k-libgles \
vuuno4kse-libgles \
vuplus-libgles: $(ARCHIVE)/$(BOXMODEL-LIBGLES_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BOXMODEL-LIBGLES_TMP)
	$(UNTAR)/$(BOXMODEL-LIBGLES_SOURCE)
	$(INSTALL_EXEC) $(BUILD_TMP)/$(BOXMODEL-LIBGLES_TMP)/lib/* $(TARGET_LIB_DIR)
	ln -sf libv3ddriver.so $(TARGET_LIB_DIR)/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_LIB_DIR)/libGLESv2.so
	$(INSTALL_COPY) $(BUILD_TMP)/$(BOXMODEL-LIBGLES_TMP)/include/* $(TARGET_INCLUDE_DIR)
	$(REMOVE)/$(BOXMODEL-LIBGLES_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

VUSOLO4K-PLATFORM-UTIL_VER    = $(VUSOLO4K-DRIVERS_VER)
VUSOLO4K-PLATFORM-UTIL_TMP    = platform-util-vusolo4k
VUSOLO4K-PLATFORM-UTIL_SOURCE = platform-util-vusolo4k-17.1-$(VUSOLO4K-PLATFORM-UTIL_VER).r0.tar.gz
VUSOLO4K-PLATFORM-UTIL_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUDUO4K-PLATFORM-UTIL_VER    = $(VUDUO4K-DRIVERS_VER)
VUDUO4K-PLATFORM-UTIL_TMP    = platform-util-vuduo4k
VUDUO4K-PLATFORM-UTIL_SOURCE = platform-util-vuduo4k-18.1-$(VUDUO4K-PLATFORM-UTIL_VER).r0.tar.gz
VUDUO4K-PLATFORM-UTIL_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUULTIMO4K-PLATFORM-UTIL_VER    = $(VUULTIMO4K-DRIVERS_VER)
VUULTIMO4K-PLATFORM-UTIL_TMP    = platform-util-vuultimo4k
VUULTIMO4K-PLATFORM-UTIL_SOURCE = platform-util-vuultimo4k-17.1-$(VUULTIMO4K-PLATFORM-UTIL_VER).r0.tar.gz
VUULTIMO4K-PLATFORM-UTIL_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUZERO4K-PLATFORM-UTIL_VER    = $(VUZERO4K-DRIVERS_VER)
VUZERO4K-PLATFORM-UTIL_TMP    = platform-util-vuzero4k
VUZERO4K-PLATFORM-UTIL_SOURCE = platform-util-vuzero4k-17.1-$(VUZERO4K-PLATFORM-UTIL_VER).r0.tar.gz
VUZERO4K-PLATFORM-UTIL_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUUNO4K-PLATFORM-UTIL_VER    = $(VUUNO4K-DRIVERS_VER)
VUUNO4K-PLATFORM-UTIL_TMP    = platform-util-vuuno4k
VUUNO4K-PLATFORM-UTIL_SOURCE = platform-util-vuuno4k-17.1-$(VUUNO4K-PLATFORM-UTIL_VER).r0.tar.gz
VUUNO4K-PLATFORM-UTIL_URL    = http://archive.vuplus.com/download/build_support/vuplus

VUUNO4KSE-PLATFORM-UTIL_VER    = $(VUUNO4KSE-DRIVERS_VER)
VUUNO4KSE-PLATFORM-UTIL_TMP    = platform-util-vuuno4kse
VUUNO4KSE-PLATFORM-UTIL_SOURCE = platform-util-vuuno4kse-17.1-$(VUUNO4KSE-PLATFORM-UTIL_VER).r0.tar.gz
VUUNO4KSE-PLATFORM-UTIL_URL    = http://archive.vuplus.com/download/build_support/vuplus

# -----------------------------------------------------------------------------

BOXMODEL-PLATFORM-UTIL_VER    = $($(call UPPERCASE,$(BOXMODEL))-PLATFORM-UTIL_VER)
BOXMODEL-PLATFORM-UTIL_TMP    = $($(call UPPERCASE,$(BOXMODEL))-PLATFORM-UTIL_TMP)
BOXMODEL-PLATFORM-UTIL_SOURCE = $($(call UPPERCASE,$(BOXMODEL))-PLATFORM-UTIL_SOURCE)
BOXMODEL-PLATFORM-UTIL_URL    = $($(call UPPERCASE,$(BOXMODEL))-PLATFORM-UTIL_URL)

ifneq ($(BOXMODEL-PLATFORM-UTIL_SOURCE),$(EMPTY))
$(ARCHIVE)/$(BOXMODEL-PLATFORM-UTIL_SOURCE):
	$(DOWNLOAD) $(BOXMODEL-PLATFORM-UTIL_URL)/$(BOXMODEL-PLATFORM-UTIL_SOURCE)
endif

vuplus-platform-util: $(ARCHIVE)/$(BOXMODEL-PLATFORM-UTIL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BOXMODEL-PLATFORM-UTIL_TMP)
	$(UNTAR)/$(BOXMODEL-PLATFORM-UTIL_SOURCE)
	$(INSTALL_EXEC) $(BUILD_TMP)/$(BOXMODEL-PLATFORM-UTIL_TMP)/* $(TARGET_BIN_DIR)
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/$(BOXMODEL)-platform-util.init $(TARGET_DIR)/etc/init.d/vuplus-platform-util
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vuduo4k))
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/bp3flash.sh $(TARGET_DIR)/bin/bp3flash.sh
endif
	$(REMOVE)/$(BOXMODEL-PLATFORM-UTIL_TMP)
	$(TOUCH)
