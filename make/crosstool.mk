# makefile to build crosstools

crosstool: crosstool-$(BOXARCH)-$(BOXSERIES)

crosstools:
	make crosstool-arm-hd1 BOXSERIES=hd1
	make crosstool-arm-hd2 BOXSERIES=hd2

crosstools-renew:
	ccache -cCz
	rm -rf $(BASE_DIR)/cross/$(BOXARCH)/hd1
	rm -rf $(BASE_DIR)/cross/$(BOXARCH)/hd2
	rm -rf $(HOSTPREFIX)/bin/arm-*
	rm -rf $(HOSTPREFIX)/bin/pkg-config
	rm -rf $(BASE_DIR)/static
	make crosstools
	make bootstrap
	make clean

crosstool-arm-hd1: $(SOURCE_DIR)/$(NI_LINUX-KERNEL)
	make $(BUILD_TMP)
	$(REMOVE)/crosstool-ng
	cd $(BUILD_TMP) && \
	git clone https://github.com/crosstool-ng/crosstool-ng && \
	cd crosstool-ng && \
	git checkout 1dbb06f2 && \
	unset CONFIG_SITE LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE && \
	cd $(BUILD_TMP)/crosstool-ng && \
		mkdir -p $(BUILD_TMP)/crosstool-ng/targets/src/ && \
			pushd $(SOURCE_DIR)/$(NI_LINUX-KERNEL) && \
				git checkout $(KBRANCH) && \
			popd && \
		tar cf linux-$(KVERSION).tar --exclude-vcs -C $(SOURCE_DIR)/$(NI_LINUX-KERNEL) . && \
		mv linux-$(KVERSION).tar $(BUILD_TMP)/crosstool-ng/targets/src/ && \
		cp -a $(CONFIGS)/ct-ng-coolstream_hd1.config .config && \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$(NUM_CPUS)@" .config && \
		export NI_BASE_DIR=$(BASE_DIR) && \
		export NI_CUSTOM_KERNEL=$(BUILD_TMP)/crosstool-ng/targets/src/linux-$(KVERSION).tar && \
		export NI_CUSTOM_KERNEL_VER=$(KVERSION) && \
		export LD_LIBRARY_PATH= && \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng && \
		./ct-ng oldconfig && \
		./ct-ng build
	chmod -R +w $(CROSS_DIR)
	test -e $(CROSS_DIR)/$(TARGET)/lib && mv $(CROSS_DIR)/$(TARGET)/lib $(CROSS_DIR)/$(TARGET)/lib.x
	test -e $(CROSS_DIR)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/
	rm -f $(CROSS_DIR)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.20-gdb.py
	$(REMOVE)/crosstool-ng

UCLIBC_VER=1.0.24
crosstool-arm-hd2: $(ARCHIVE)/gcc-linaro-$(GCC_VER).tar.xz $(SOURCE_DIR)/$(NI_LINUX-KERNEL)
	make $(BUILD_TMP)
	$(REMOVE)/crosstool-ng
	cd $(BUILD_TMP) && \
	git clone https://github.com/crosstool-ng/crosstool-ng && \
	cd crosstool-ng && \
	git checkout 1dbb06f2 && \
	cp -a $(PATCHES)/crosstool-ng/gcc/* $(BUILD_TMP)/crosstool-ng/patches/gcc/linaro-4.9-2017.01 && \
	unset CONFIG_SITE LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE && \
	cd $(BUILD_TMP)/crosstool-ng && \
		mkdir -p $(BUILD_TMP)/crosstool-ng/targets/src/ && \
			pushd $(SOURCE_DIR)/$(NI_LINUX-KERNEL) && \
				git checkout $(KBRANCH) && \
			popd && \
		tar cf linux-$(KVERSION).tar --exclude-vcs -C $(SOURCE_DIR)/$(NI_LINUX-KERNEL) . && \
		mv linux-$(KVERSION).tar $(BUILD_TMP)/crosstool-ng/targets/src/ && \
		cp -a $(CONFIGS)/ct-ng-coolstream_hd2.config .config && \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$(NUM_CPUS)@" .config && \
		export NI_BASE_DIR=$(BASE_DIR) && \
		export NI_CUSTOM_KERNEL=$(BUILD_TMP)/crosstool-ng/targets/src/linux-$(KVERSION).tar && \
		export NI_CUSTOM_KERNEL_VER=$(KVERSION) && \
		export NI_UCLIBC_CONFIG=$(CONFIGS)/ct-ng-uClibc-$(UCLIBC_VER).config && \
		export LD_LIBRARY_PATH= && \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng && \
		./ct-ng oldconfig && \
		./ct-ng build
	chmod -R +w $(CROSS_DIR)
	test -e $(CROSS_DIR)/$(TARGET)/lib && mv $(CROSS_DIR)/$(TARGET)/lib $(CROSS_DIR)/$(TARGET)/lib.x
	test -e $(CROSS_DIR)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/
	rm -f $(CROSS_DIR)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.20-gdb.py
	$(REMOVE)/crosstool-ng

PHONY += crosstool $(CROSS_DIR)
