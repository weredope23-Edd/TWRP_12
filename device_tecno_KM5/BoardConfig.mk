DEVICE_PATH := device/tecno/KM5

# Allow building without a full vendor tree
ALLOW_MISSING_DEPENDENCIES := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# ---------------------------------------------------------------- Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic

# 64-bit only; the stock build has an empty 32-bit abilist
TARGET_SUPPORTS_64_BIT_APPS := true
TARGET_IS_64_BIT := true

# ---------------------------------------------------------------- Platform
TARGET_BOARD_PLATFORM := mt6768
TARGET_BOOTLOADER_BOARD_NAME := TECNO-KM5
TARGET_NO_BOOTLOADER := true

# ---------------------------------------------------------------- Boot images
# boot.img / init_boot.img / vendor_boot.img are all header version 4 (verified).
# Recovery lives inside vendor_boot (there is no recovery partition).
BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_PAGESIZE := 4096
BOARD_FLASH_BLOCK_SIZE := 262144

# Addresses read from the stock vendor_boot v4 header:
#   kernel 0x40080000, ramdisk 0x47c80000, tags 0x4bc80000, dtb 0x4bc80000
BOARD_KERNEL_BASE := 0x40000000
BOARD_KERNEL_OFFSET := 0x00080000
BOARD_RAMDISK_OFFSET := 0x07c80000
BOARD_TAGS_OFFSET := 0x0bc80000
BOARD_DTB_OFFSET := 0x0bc80000

# Stock vendor_boot cmdline (boot.img carries an empty cmdline)
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2

BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE)
BOARD_MKBOOTIMG_ARGS += --base $(BOARD_KERNEL_BASE)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)

# Stock vendor_boot DTB is a dt-table wrapper (magic d7b7ab1e) around the
# single MT6768 DTB, so it is passed through untouched instead of being
# rebuilt via BOARD_PREBUILT_DTBIMAGE_DIR.
BOARD_MKBOOTIMG_ARGS += --dtb $(DEVICE_PATH)/prebuilt/dtb

# Stock ramdisks are legacy LZ4 (kernel has CONFIG_RD_LZ4=y)
BOARD_RAMDISK_USE_LZ4 := true

# Kernel: GKI 6.6.102 (android15-6.6), stays in boot.img. Only vendor_boot
# is rebuilt, so the kernel is kept as a reference prebuilt.
TARGET_NO_KERNEL := false
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true

# Recovery in vendor_boot
BOARD_USES_RECOVERY_AS_BOOT := false
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
BOARD_INCLUDE_DTB_IN_BOOTIMG := true

# ---------------------------------------------------------------- Kernel modules
# The stock vendor_boot platform ramdisk carries 189 modules and a
# 183-entry modules.load.recovery (display, touch, eMMC/UFS, USB, PMIC, charger...).
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(DEVICE_PATH)/prebuilt/modules/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/modules.load))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/modules.load.recovery))
TW_LOAD_VENDOR_BOOT_MODULES := true

# ---------------------------------------------------------------- Partitions
# Sizes match the partition layout (boot/vendor_boot 0x4000000, init_boot/dtbo 0x800000).
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_DTBOIMG_PARTITION_SIZE := 8388608

# Dynamic partitions (every logical partition in the stock fstab)
BOARD_SUPER_PARTITION_GROUPS := tecno_dynamic_partitions
BOARD_TECNO_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    system \
    system_ext \
    product \
    vendor \
    vendor_dlkm \
    odm_dlkm \
    system_dlkm \
    tr_mi \
    tr_theme \
    tr_region \
    tr_company \
    tr_carrier \
    tr_product \
    tr_preload \
    tr_overlayfs
# From the MediaTek partition layout you provided: super = 0x240000000 (9 GiB).
# The group size is super minus 4 MiB, the usual Virtual A/B convention; it is
# derived, not read from device metadata, and only matters for building images.
BOARD_SUPER_PARTITION_SIZE := 9663676416
BOARD_TECNO_DYNAMIC_PARTITIONS_SIZE := 9659482112

BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm
TARGET_COPY_OUT_ODM_DLKM := odm_dlkm
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_USES_METADATA_PARTITION := true

# ---------------------------------------------------------------- A/B + Virtual A/B
AB_OTA_UPDATER := true

# ---------------------------------------------------------------- Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888

# ---------------------------------------------------------------- Verified boot
# Stock vbmeta/vbmeta_vendor are unsigned (algorithm NONE, flags 0).
# Flash vbmeta with verification disabled after flashing a custom vendor_boot.
BOARD_AVB_ENABLE := false

# ---------------------------------------------------------------- Security patch
# Spoofed so TWRP's FBE decryption does not reject the stock keymaster version.
PLATFORM_VERSION := 16.1.0
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
BOOT_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

# ---------------------------------------------------------------- Crypto
# Stock userdata: fileencryption=aes-256-xts:aes-256-cts:v2 + metadata
# encryption at /metadata/vold/metadata_encryption, inlinecrypt.
# Gatekeeper / kmsetkey are "trustonic" per stock props, so decryption also
# needs the matching vendor services at runtime (see README).
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
TW_USE_FSCRYPT_POLICY := 2

# Trustonic stack read from your vendor.img: mcDriverDaemon ("mobicore"),
# tee-service, android.hardware.gatekeeper-service.trustonic ("vendor.gatekeeper-default")
# and android.hardware.security.keymint@3.0-service.trustonic ("vendor.keymint-trustonic").
# Mount /vendor so TWRP can start them from the real partition (all their
# libraries resolve from /vendor/lib64 or the recovery's /system/lib64).
TW_CRYPTO_SYSTEM_VOLD_MOUNT := vendor
TW_CRYPTO_USE_SYSTEM_VOLD := mobicore tee-service vendor.gatekeeper-default vendor.keymint-trustonic
TW_CRYPTO_SYSTEM_VOLD_DEBUG := true

# ---------------------------------------------------------------- TWRP
TW_DEVICE_VERSION := KM5-stock-A15
TW_THEME := portrait_hdpi
TW_FRAMERATE := 60
TW_EXTRA_LANGUAGES := true
TW_USE_TOOLBOX := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_REPACKTOOLS := true
TW_INCLUDE_FASTBOOTD := true
TW_NO_LEGACY_PROPS := true
RECOVERY_SDCARD_ON_DATA := true
TW_INTERNAL_STORAGE_PATH := "/data/media/0"
TW_INTERNAL_STORAGE_MOUNT_POINT := "data"
TW_EXTERNAL_STORAGE_PATH := "/external_sd"
TW_EXTERNAL_STORAGE_MOUNT_POINT := "external_sd"
TW_DEFAULT_EXTERNAL_STORAGE := true

# Backlight is mt6370 / leds-mtk-disp; confirm values on-device (README).
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 120

# Debug-friendly while bringing the device up
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true
