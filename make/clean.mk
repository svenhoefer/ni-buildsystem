#
# makefile for clean targets
#
# -----------------------------------------------------------------------------

cross-base-clean:
	-rm -rf $(CROSS_BASE)

cross-clean:
	-rm -rf $(CROSS_DIR)

deps-clean:
	-rm -rf $(DEPS_DIR)

host-clean:
	-rm -rf $(HOST_DIR)

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

rebuild-clean: target-clean deps-clean
	-rm -rf $(BUILD_TMP)

all-clean: rebuild-clean staging-clean host-clean static-base-clean
	@echo -e "\n$(TERM_RED_BOLD)Any other key then CTRL-C will now remove CROSS_BASE$(TERM_NORMAL)"
	@read
	make cross-base-clean

%-clean:
	-find $(D) -name $(subst -clean,,$@) -delete

clean: rebuild-clean bootstrap

clean-all:
	make update-all
	make staging-clean
	make clean

# -----------------------------------------------------------------------------

PHONY += cross-base-clean
PHONY += cross-clean
PHONY += deps-clean
PHONY += host-clean
PHONY += staging-clean
PHONY += static-base-clean
PHONY += static-clean
PHONY += target-clean
PHONY += ccache-clean
PHONY += rebuild-clean
PHONY += all-clean
PHONY += %-clean
PHONY += clean
PHONY += clean-all
