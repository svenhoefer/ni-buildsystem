#
# set up linux environment for other makefiles
#
# -----------------------------------------------------------------------------

ifeq ($(BOXMODEL), nevis)
  KERNEL_VER    = 2.6.34.13
  KERNEL_TMP    = linux-$(KERNEL_VER)
  KERNEL_SOURCE = git
  KERNEL_URL    = $(EMPTY)

  KERNEL_BRANCH = ni/linux-2.6.34.15
  KERNEL_DTB    = $(EMPTY)

else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), apollo shiner kronos kronos_v2))
  KERNEL_VER    = 3.10.93
  KERNEL_TMP    = linux-$(KERNEL_VER)
  KERNEL_SOURCE = git
  KERNEL_URL    = $(EMPTY)

  KERNEL_BRANCH = ni/linux-3.10.108
  ifeq ($(BOXMODEL), $(filter $(BOXMODEL), apollo shiner))
    KERNEL_DTB    = $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/kernel-dtb/hd849x.dtb
    KERNEL_CONFIG = $(CONFIGS)/kernel-apollo.config
  else
    KERNEL_DTB    = $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/kernel-dtb/en75x1.dtb
    KERNEL_CONFIG = $(CONFIGS)/kernel-kronos.config
  endif

else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), hd51 bre2ze4k h7))
  KERNEL_VER    = 4.10.12
  KERNEL_TMP    = linux-$(KERNEL_VER)
  KERNEL_SOURCE = linux-$(KERNEL_VER)-arm.tar.gz
  KERNEL_URL    = http://downloads.mutant-digital.net

  KERNEL_BRANCH = $(EMPTY)
  KERNEL_DTB    = $(BUILD_TMP)/$(KERNEL_OBJ)/arch/$(BOXARCH)/boot/dts/bcm7445-bcm97445svmb.dtb
  KERNEL_CONFIG = $(CONFIGS)/kernel-hd51.config

else ifeq ($(BOXMODEL), vusolo4k)
  KERNEL_VER    = 3.14.28-1.8
  KERNEL_TMP    = linux
  KERNEL_SOURCE = stblinux-3.14-1.8.tar.bz2
  KERNEL_URL    = http://archive.vuplus.com/download/kernel

  KERNEL_BRANCH = $(EMPTY)
  KERNEL_DTB    = $(EMPTY)

  VMLINUZ-INITRD_VER    = 20190911
  VMLINUZ-INITRD_SOURCE = vmlinuz-initrd_$(BOXMODEL)_$(VMLINUZ-INITRD_VER).tar.gz
  VMLINUZ-INITRD_URL    = https://bitbucket.org/max_10/vmlinuz-initrd-$(BOXMODEL)/downloads
  VMLINUZ-INITRD        = vmlinuz-initrd-7366c0

  BOOT_PARTITION = 1

else ifeq ($(BOXMODEL), vuduo4k)
  KERNEL_VER    = 4.1.45-1.17
  KERNEL_TMP    = linux
  KERNEL_SOURCE = stblinux-4.1-1.17.tar.bz2
  KERNEL_URL    = http://archive.vuplus.com/download/kernel

  KERNEL_BRANCH = $(EMPTY)
  KERNEL_DTB    = $(EMPTY)

  VMLINUZ-INITRD_VER    = 20190911
  VMLINUZ-INITRD_SOURCE = vmlinuz-initrd_$(BOXMODEL)_$(VMLINUZ-INITRD_VER).tar.gz
  VMLINUZ-INITRD_URL    = https://bitbucket.org/max_10/vmlinuz-initrd-$(BOXMODEL)/downloads
  VMLINUZ-INITRD        = vmlinuz-initrd-7278b1

  BOOT_PARTITION = 6

else ifeq ($(BOXMODEL), vuultimo4k)
  KERNEL_VER    = 3.14.28-1.12
  KERNEL_TMP    = linux
  KERNEL_SOURCE = stblinux-3.14-1.12.tar.bz2
  KERNEL_URL    = http://archive.vuplus.com/download/kernel

  KERNEL_BRANCH = $(EMPTY)
  KERNEL_DTB    = $(EMPTY)

  VMLINUZ-INITRD_VER    = 20190911
  VMLINUZ-INITRD_SOURCE = vmlinuz-initrd_$(BOXMODEL)_$(VMLINUZ-INITRD_VER).tar.gz
  VMLINUZ-INITRD_URL    = https://bitbucket.org/max_10/vmlinuz-initrd-$(BOXMODEL)/downloads
  VMLINUZ-INITRD        = vmlinuz-initrd-7445d0

  BOOT_PARTITION = 1

else ifeq ($(BOXMODEL), vuzero4k)
  KERNEL_VER    = 4.1.20-1.9
  KERNEL_TMP    = linux
  KERNEL_SOURCE = stblinux-4.1-1.9.tar.bz2
  KERNEL_URL    = http://archive.vuplus.com/download/kernel

  KERNEL_BRANCH = $(EMPTY)
  KERNEL_DTB    = $(EMPTY)

  VMLINUZ-INITRD_VER    = 20190911
  VMLINUZ-INITRD_SOURCE = vmlinuz-initrd_$(BOXMODEL)_$(VMLINUZ-INITRD_VER).tar.gz
  VMLINUZ-INITRD_URL    = https://bitbucket.org/max_10/vmlinuz-initrd-$(BOXMODEL)/downloads
  VMLINUZ-INITRD        = vmlinuz-initrd-7260a0

  BOOT_PARTITION = 4

else ifeq ($(BOXMODEL), vuuno4k)
  KERNEL_VER    = 3.14.28-1.12
  KERNEL_TMP    = linux
  KERNEL_SOURCE = stblinux-3.14-1.12.tar.bz2
  KERNEL_URL    = http://archive.vuplus.com/download/kernel

  KERNEL_BRANCH = $(EMPTY)
  KERNEL_DTB    = $(EMPTY)

  VMLINUZ-INITRD_VER    = 20191010
  VMLINUZ-INITRD_SOURCE = vmlinuz-initrd_$(BOXMODEL)_$(VMLINUZ-INITRD_VER).tar.gz
  VMLINUZ-INITRD_URL    = https://bitbucket.org/max_10/vmlinuz-initrd-$(BOXMODEL)/downloads
  VMLINUZ-INITRD        = vmlinuz-initrd-7439b0

  BOOT_PARTITION = 1

else ifeq ($(BOXMODEL), vuuno4kse)
  KERNEL_VER    = 4.1.20-1.9
  KERNEL_TMP    = linux
  KERNEL_SOURCE = stblinux-4.1-1.9.tar.bz2
  KERNEL_URL    = http://archive.vuplus.com/download/kernel

  KERNEL_BRANCH = $(EMPTY)
  KERNEL_DTB    = $(EMPTY)

  VMLINUZ-INITRD_VER    = 20191010
  VMLINUZ-INITRD_SOURCE = vmlinuz-initrd_$(BOXMODEL)_$(VMLINUZ-INITRD_VER).tar.gz
  VMLINUZ-INITRD_URL    = https://bitbucket.org/max_10/vmlinuz-initrd-$(BOXMODEL)/downloads
  VMLINUZ-INITRD        = vmlinuz-initrd-7439b0

  BOOT_PARTITION = 1

else ifeq ($(BOXMODEL), vuduo)
  KERNEL_VER    = 3.9.6
  KERNEL_TMP    = linux
  KERNEL_SOURCE = stblinux-$(KERNEL_VER).tar.bz2
  KERNEL_URL    = http://archive.vuplus.com/download/kernel

  KERNEL_BRANCH = $(EMPTY)
  KERNEL_DTB    = $(EMPTY)

endif

KERNEL_PATCH    = $($(call UPPERCASE,$(BOXMODEL))_PATCH)

KERNEL_OBJ      = linux-$(KERNEL_VER)-obj
KERNEL_MODULES  = linux-$(KERNEL_VER)-modules

KERNEL_CONFIG  ?= $(CONFIGS)/kernel-$(BOXMODEL).config
KERNEL_NAME     = NI $(shell echo $(BOXFAMILY) | sed 's/.*/\u&/') Kernel

# -----------------------------------------------------------------------------

KERNEL_MODULES_DIR  = $(BUILD_TMP)/$(KERNEL_MODULES)/lib/modules/$(KERNEL_VER)

KERNEL_UIMAGE       = $(BUILD_TMP)/$(KERNEL_OBJ)/arch/$(BOXARCH)/boot/Image
KERNEL_ZIMAGE       = $(BUILD_TMP)/$(KERNEL_OBJ)/arch/$(BOXARCH)/boot/zImage
KERNEL_ZIMAGE_DTB   = $(BUILD_TMP)/$(KERNEL_OBJ)/arch/$(BOXARCH)/boot/zImage_dtb
KERNEL_VMLINUX      = $(BUILD_TMP)/$(KERNEL_OBJ)/vmlinux

# -----------------------------------------------------------------------------

KERNEL_MAKEVARS = \
	ARCH=$(BOXARCH) \
	CROSS_COMPILE=$(TARGET_CROSS) \
	INSTALL_MOD_PATH=$(BUILD_TMP)/$(KERNEL_MODULES) \
	LOCALVERSION= \
	O=$(BUILD_TMP)/$(KERNEL_OBJ)

# Compatibility variables
KERNEL_MAKEVARS += \
	KVER=$(KERNEL_VER) \
	KSRC=$(BUILD_TMP)/$(KERNEL_TMP)

ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vuduo))
  KERNEL_IMAGE = vmlinux
else
  KERNEL_IMAGE = zImage
endif

KERNEL_MAKEOPTS = $(KERNEL_IMAGE) modules

# build also the kernel-dtb for arm-hd51
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), hd51 bre2ze4k h7))
  KERNEL_MAKEOPTS += $(notdir $(KERNEL_DTB))
endif
