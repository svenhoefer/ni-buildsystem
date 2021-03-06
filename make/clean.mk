#
# makefile for clean targets
#
# -----------------------------------------------------------------------------

build-clean:
	-rm -rf $(BUILD_TMP)

cross-base-clean:
	-rm -rf $(CROSS_BASE)

cross-clean:
	-rm -rf $(CROSS_DIR)

deps-clean:
	-rm -rf $(DEPS_DIR)

host-clean:
	-rm -rf $(HOST_DIR)

host-bin-config-clean:
	-find $(HOST_DIR)/bin -name *-config ! -name pkg-config -delete

staging-clean:
	-rm -rf $(STAGING_DIR)

static-base-clean:
	-rm -rf $(STATIC_BASE)

static-clean:
	-rm -rf $(STATIC_DIR)

target-clean:
	-rm -rf $(TARGET_DIR)

ccache-clean:
	@echo "Clearing $$CCACHE_DIR"
	@$(CCACHE) -C

rebuild-clean: host-bin-config-clean target-clean deps-clean build-clean

all-clean: rebuild-clean staging-clean host-clean static-base-clean
	@echo -e "\n$(TERM_RED_BOLD)Any other key then CTRL-C will now remove CROSS_BASE$(TERM_NORMAL)"
	@read
	make cross-base-clean

clean: rebuild-clean bootstrap

clean-all: update-all staging-clean clean

%-clean:
	-find $(DEPS_DIR) -name $(subst -clean,,$(@)) -delete

# -----------------------------------------------------------------------------

PHONY += build-clean
PHONY += cross-base-clean
PHONY += cross-clean
PHONY += deps-clean
PHONY += host-clean
PHONY += host-bin-config-clean
PHONY += staging-clean
PHONY += static-base-clean
PHONY += static-clean
PHONY += target-clean
PHONY += ccache-clean
PHONY += rebuild-clean
PHONY += all-clean
PHONY += clean
PHONY += clean-all
PHONY += %-clean
