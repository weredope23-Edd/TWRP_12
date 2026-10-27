LOCAL_PATH := $(call my-dir)

# A/B
AB_OTA_UPDATER := true

AB_OTA_PARTITIONS += \
    boot \
    init_boot \
    vendor_boot \
    dtbo \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    system \
    system_ext \
    product \
    vendor \
    vendor_dlkm \
    odm_dlkm \
    system_dlkm

PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier \
    checkpoint_gc

# Boot control: AOSP default impl for TWRP's slot handling.
# NOTE: the stock recovery ships MediaTek's own AIDL boot HAL
# (android.hardware.boot-service.mtk_recovery); it is copied in below from
# recovery/root. If both register IBootControl/default, drop the AOSP one.
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl \
    android.hardware.boot@1.2-impl.recovery

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION := false

# Fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.1-impl-mock \
    fastbootd

# Health (charger/battery status in recovery)
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# Stock MediaTek recovery pieces (see recovery/root)
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/recovery/root/system/bin/hw,recovery/root/system/bin/hw) \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/recovery/root/system/lib64,recovery/root/system/lib64) \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/recovery/root/system/etc/init,recovery/root/system/etc/init)

# Stock-derived init script (USB controller / configfs)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/init.recovery.mt6768.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.mt6768.rc
