# Device tree for TECNO KM5 (MediaTek MT6768), TWRP build
#
# Generated from stock firmware image analysis. See README.md for what was
# verified from the stock files and what still needs confirming on-device.

# 64-bit only (stock ro.system.product.cpu.abilist32 is empty)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)

# Virtual A/B (snapuserd is present in init_boot and the stock recovery)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)

# Device configuration
$(call inherit-product, $(LOCAL_PATH)/device.mk)

# TWRP common configuration
$(call inherit-product, vendor/twrp/config/common.mk)

PRODUCT_DEVICE       := KM5
PRODUCT_NAME         := twrp_KM5
PRODUCT_BRAND        := TECNO
PRODUCT_MODEL        := TECNO KM5
PRODUCT_MANUFACTURER := TECNO
PRODUCT_RELEASE_NAME := TECNO KM5
