#
# makefile for image updates
#
# -----------------------------------------------------------------------------

u-neutrino: neutrino-clean
	$(MAKE) u-init
	echo "killall start_neutrino neutrino; sleep 5"	>> $(PREINSTALL_SH)
	echo "sync; /bin/busybox reboot"		>> $(POSTINSTALL_SH)
	$(MAKE) neutrino
	install -D -m 0644 $(TARGET_DIR)/.version $(UPDATE_INST_DIR)/.version
	install -D -m 0755 $(TARGET_DIR)/etc/init.d/start_neutrino $(UPDATE_INST_DIR)/etc/init.d/start_neutrino
	install -D -m 0755 $(TARGET_DIR)/bin/neutrino $(UPDATE_INST_DIR)/bin/neutrino
	install -D -m 0644 $(TARGET_DIR)/share/tuxbox/neutrino/locale/deutsch.locale $(UPDATE_INST_DIR)/share/tuxbox/neutrino/locale/deutsch.locale
	install -D -m 0644 $(TARGET_DIR)/share/tuxbox/neutrino/locale/english.locale $(UPDATE_INST_DIR)/share/tuxbox/neutrino/locale/english.locale
ifneq ($(DEBUG), yes)
	find $(UPDATE_INST_DIR)/bin -type f ! -name *.sh -print0 | xargs -0 $(TARGET)-strip || true
endif
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=$(UPDATE_MD5FILE-BOXSERIES)

# -----------------------------------------------------------------------------

u-neutrino-full: neutrino-clean
	$(MAKE) u-init
	echo "killall start_neutrino neutrino; sleep 5"	>> $(PREINSTALL_SH)
	echo "sync; /bin/busybox reboot"		>> $(POSTINSTALL_SH)
	$(MAKE) neutrino NEUTRINO_INST_DIR=$(UPDATE_INST_DIR)
	install -D -m 0644 $(TARGET_DIR)/.version $(UPDATE_INST_DIR)/.version
	install -D -m 0755 $(TARGET_DIR)/etc/init.d/start_neutrino $(UPDATE_INST_DIR)/etc/init.d/start_neutrino
ifneq ($(DEBUG), yes)
	find $(UPDATE_INST_DIR)/bin -type f ! -name *.sh -print0 | xargs -0 $(TARGET)-strip || true
endif
ifeq ($(BOXSERIES), hd2)
	# avoid overrides in user's var-partition
	mv $(UPDATE_INST_DIR)/var $(UPDATE_INST_DIR)/var_init
endif
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=$(UPDATE_MD5FILE-BOXSERIES)

# -----------------------------------------------------------------------------

u-update.urls: update.urls
	$(MAKE) u-init
	echo "wget -q "http://localhost/control/message?popup=update.urls%20installed." -O /dev/null"	>> $(POSTINSTALL_SH)
	mkdir -pv $(UPDATE_INST_DIR)/var/etc
	cp -f $(TARGET_DIR)/var/etc/update.urls $(UPDATE_INST_DIR)/var/etc/
	$(MAKE) u-update-bin \
			UPDATE_NAME=update.urls \
			UPDATE_DESC=update.urls

# -----------------------------------------------------------------------------

u-pr-auto-timer:
	$(MAKE) u-init
	install -m755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/update-ctrl/preinstall.sh $(PREINSTALL_SH)
	install -m755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/update-ctrl/postinstall.sh $(POSTINSTALL_SH)
	mkdir -pv $(UPDATE_INST_DIR)/lib/tuxbox/plugins
	install -m755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.sh $(UPDATE_INST_DIR)/lib/tuxbox/plugins/
	install -m644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.cfg $(UPDATE_INST_DIR)/lib/tuxbox/plugins/
	install -m755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer $(UPDATE_INST_DIR)/lib/tuxbox/plugins/
	install -m755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer_hint.png $(UPDATE_INST_DIR)/lib/tuxbox/plugins/
	install -m755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/auto-record-cleaner $(UPDATE_INST_DIR)/lib/tuxbox/plugins/
	mkdir -pv $(UPDATE_INST_DIR)/var/tuxbox/config
	install -m644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.conf.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	install -m644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.rules.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	install -m644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/auto-record-cleaner.conf.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	install -m644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/auto-record-cleaner.rules.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	VERSION_STRING=`cat $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer | grep '^VERSION' | cut -d= -f2`; \
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=pr-auto-timer.txt \
			UPDATE_URL=$(NI-SERVER)/plugins/pr-auto-timer \
			UPDATE_NAME=pr-auto-timer_$${VERSION_STRING//./} \
			UPDATE_DESC=Auto-Timer \
			UPDATE_VERSION_STRING=$$VERSION_STRING

# -----------------------------------------------------------------------------

CHANNELLISTS_URL = $(NI-SERVER)/channellists
CHANNELLISTS_MD5FILE = lists.txt

channellists: matze-19 matze-19-13 pathauf_HD-19

matze-19 \
matze-19-13 \
pathauf_HD-19:
	$(MAKE) u-init
	install -m755 $(IMAGEFILES)/channellists/update-ctrl/preinstall.sh $(PREINSTALL_SH)
	install -m755 $(IMAGEFILES)/channellists/update-ctrl/postinstall.sh $(POSTINSTALL_SH)
	mkdir -pv $(UPDATE_INST_DIR)/var/tuxbox/config/zapit && \
	cp -f $(IMAGEFILES)/channellists/$@/* $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/
	# remove non-printable chars and re-format xml-files
	cd $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/; \
	for file in *.xml; do \
		sed -i 's/[^[:print:]]//g' $$file; \
		XMLLINT_INDENT="	" \
		xmllint --format $$file > _$$file; \
		mv _$$file $$file; \
	done
	# sync sat-names with current satellites.xml
	# Astra 19.2
	A192=`grep 'position=\"192\"' $(SOURCE_DIR)/$(NI_NEUTRINO)/data/satellites.xml`; \
	A192=`echo $$A192`; \
	sed -i "/position=\"192\"/c\	$$A192" $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/services.xml
	# Hotbird 13.0
	H130=`grep 'position=\"130\"' $(SOURCE_DIR)/$(NI_NEUTRINO)/data/satellites.xml`; \
	H130=`echo $$H130`; \
	sed -i "/position=\"130\"/c\	$$H130" $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/services.xml
	#
	# we should try to keep this array table up-to-date ;-)
	#
	DIR[0]="#directory"	&& DESC[0]="#description"			&& DATE[0]="#date"	 ; \
	DIR[1]="matze-19"	&& DESC[1]="Matze-Settings 19.2"		&& DATE[1]="21.10.2018"	 ; \
	DIR[2]="matze-19-13"	&& DESC[2]="Matze-Settings 19.2, 13.0"		&& DATE[2]="21.10.2018"	 ; \
	DIR[3]="pathauf_HD-19"	&& DESC[3]="pathAuf-HD+-Settings 19.2"		&& DATE[3]="29.06.2018"	 ; \
	#; \
	i=0; \
	for dir in $${DIR[*]}; do \
		if [ $$dir = $@ ]; \
		then \
			desc=$${DESC[$$i]}; \
			date=$${DATE[$$i]}; \
			break; \
		else \
			i=$$((i+1)); \
		fi; \
	done && \
	$(MAKE) u-update-bin \
			UPDATE_TYPE=S \
			UPDATE_URL=$(CHANNELLISTS_URL) \
			UPDATE_MD5FILE=$(CHANNELLISTS_MD5FILE) \
			UPDATE_NAME=$@ \
			UPDATE_DESC="$$desc - " \
			UPDATE_VERSION_STRING="$$date" \

# -----------------------------------------------------------------------------

u-custom:
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=custom_bin.txt \
			UPDATE_NAME=custom_bin \
			UPDATE_DESC="Custom Package" \
			UPDATE_VERSION_STRING="0.00"

# -----------------------------------------------------------------------------

u-init: u-clean | $(UPDATE_DIR)
	mkdir -p $(UPDATE_INST_DIR)
	mkdir -p $(UPDATE_CTRL_DIR)
	echo -e "#!/bin/sh\n#"	> $(PREINSTALL_SH)
	chmod 0755 $(PREINSTALL_SH)
	echo -e "#!/bin/sh\n#"	> $(POSTINSTALL_SH)
	chmod 0755 $(POSTINSTALL_SH)

u-clean:
	rm -rf $(UPDATE_TEMP_DIR)

u-clean-all: u-clean
	rm -rf $(UPDATE_DIR)

u-update-bin:
	set -e; cd $(BUILD_TMP); \
		tar -czvf $(UPDATE_DIR)/$(UPDATE_NAME).bin temp_inst
	echo $(UPDATE_URL)/$(UPDATE_NAME).bin $(UPDATE_TYPE)$(UPDATE_VERSION)$(UPDATE_DATE) `md5sum $(UPDATE_DIR)/$(UPDATE_NAME).bin | cut -c1-32` $(UPDATE_DESC) $(UPDATE_VERSION_STRING) >> $(UPDATE_DIR)/$(UPDATE_MD5FILE)
	$(MAKE) u-clean

# -----------------------------------------------------------------------------

PHONY += u-neutrino
PHONY += u-neutrino-full
PHONY += u-update.urls
PHONY += u-pr-auto-timer
PHONY += channellists
PHONY += matze-19
PHONY += matze-19-13
PHONY += pathauf_HD-19
PHONY += u-custom
PHONY += u-init
PHONY += u-clean
PHONY += u-clean-all
PHONY += u-update-bin
