#
# set up update environment for other makefiles
#
# -----------------------------------------------------------------------------

UPDATE_TEMP_DIR = $(BUILD_TMP)/temp_inst

UPDATE_INST_DIR	= $(UPDATE_TEMP_DIR)/inst
UPDATE_CTRL_DIR	= $(UPDATE_TEMP_DIR)/ctrl

POSTINSTALL_SH	= $(UPDATE_CTRL_DIR)/postinstall.sh
PREINSTALL_SH	= $(UPDATE_CTRL_DIR)/preinstall.sh

# defaults for Neutrino-Update
UPDATE_DATE	= $(shell date +%Y%m%d%H%M)
UPDATE_VER	= $(IMAGE_VER)
UPDATE_VERSION	= $(IMAGE_VERSION)

UPDATE_PREFIX	= $(IMAGE_PREFIX)
UPDATE_SUFFIX	= $(BOXTYPE_SC)-$(BOXSERIES)-update

UPDATE_NAME	= $(UPDATE_PREFIX)-$(UPDATE_SUFFIX)
UPDATE_DESC	= "Neutrino [$(BOXTYPE_SC)][$(BOXSERIES)] Update"
UPDATE_TYPE	= U
# Release	= 0
# Beta		= 1
# Nightly	= 2
# Selfmade	= 9
# Locale	= L
# Settings	= S
# Update	= U
# Addon		= A
# Text		= T

UPDATE_URL	= $(NI-SERVER)/$(NI-SUBDIR)
UPDATE_MD5FILE	= update.txt
UPDATE_MD5FILE-BOXSERIES= update-$(BOXTYPE_SC)-$(BOXSERIES).txt
UPDATE_MD5FILE-BOXMODEL	= update-$(BOXTYPE_SC)-$(BOXMODEL).txt
