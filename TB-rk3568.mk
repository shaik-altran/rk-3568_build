################################################################################
# Following variables defines how the NS_USER (Non Secure User - Client
# Application), NS_KERNEL (Non Secure Kernel), S_KERNEL (Secure Kernel) and
# S_USER (Secure User - TA) are compiled
################################################################################
override COMPILE_NS_USER   := 32
override COMPILE_NS_KERNEL := 32
override COMPILE_S_USER    := 32
override COMPILE_S_KERNEL  := 32


OPTEE_OS_PLATFORM = rockchip

include common.mk

################################################################################
# Paths to git projects and various binaries
################################################################################

RKBIN_PATH              ?= $(ROOT)/rkbin
BINARIES_PATH           ?= $(ROOT)/out/bin
U-BOOT_PATH		?= $(ROOT)/u-boot
DEBUG = 0

################################################################################
# Targets
################################################################################
all: rkbin u-boot
clean: u-boot-clean

include toolchain.mk

################################################################################
# RKBIN
################################################################################
rkbin:
	cd $(RKBIN_PATH) && \
		git reset --hard 7be392f70cf6b87a0baac3bee649b5fbc151ce51 && \
		git clean -fdx

################################################################################
# U-boot
################################################################################
U-BOOT_EXPORTS ?= \
	CROSS_COMPILE="$(CCACHE)$(AARCH64_CROSS_COMPILE)"\
	ARCH=arm64

U-BOOT_DEFCONFIG_FILES := \
	$(U-BOOT_PATH)/configs/evb-rk3568_defconfig \
	$(ROOT)/rk3568_build/kconfig/TB-rk3568.config

U-BOOT_PATCHES := \
	$(ROOT)/rk3568_build/0001-2USB_working.patch \
	$(ROOT)/rk3568_build/0002-DFU_Patch.patch


.PHONY: u-boot
u-boot: rkbin
	cd $(U-BOOT_PATH) && \
		git reset --hard refs/tags/v2022.01 && \
		git clean -fdx
		
	cd $(U-BOOT_PATH) && \
		git apply $(U-BOOT_PATCHES)
	
	rm -rf $(BINARIES_PATH)/u-boot
	mkdir -p $(BINARIES_PATH)/u-boot
	cd $(U_BOOT_PATH) && \
		scripts/kconfig/merge_config.sh -O $(BINARIES_PATH)/u-boot $(U-BOOT_DEFCONFIG_FILES)
	$(U-BOOT_EXPORTS) $(MAKE) -C $(U-BOOT_PATH) O=$(BINARIES_PATH)/u-boot BL31=$(ROOT)/rkbin/bin/rk35/rk3568_bl31_v1.25.elf all


.PHONY: u-boot-clean
u-boot-clean:
	$(U-BOOT_EXPORTS) $(MAKE) -C $(U-BOOT_PATH) distclean

