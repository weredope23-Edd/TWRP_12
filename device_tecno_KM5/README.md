# TWRP device tree: TECNO KM5 (MediaTek MT6768)

Generated from your `Stock_Files.zip` (boot, init_boot, vendor_boot, vendor_dlkm,
dtbo, vbmeta, vbmeta_vendor). **This tree has not been compiled or booted.**
There is no AOSP/TWRP source tree in the environment it was written in, so
treat the first build as bring-up, not a finished port.

## What was read directly from your stock files

| Item | Value | Source |
|---|---|---|
| Device / codename | TECNO KM5 (`KM5-OP`, product `km5_xk67j`) | recovery ramdisk props |
| SoC / platform | MediaTek MT6768, `ro.board.platform=mt6768` | DTB, props |
| Android | 15, SDK 35, build `AP3A.240905.015.A2`, patch 2026-08-01 | props |
| ABI | arm64-v8a only (32-bit abilist empty) | props |
| Kernel | GKI `6.6.102-android15-8`, 4K pages, gzip Image in boot.img | boot.img |
| Boot headers | v4 for boot, init_boot, vendor_boot | headers |
| Recovery location | inside vendor_boot (ramdisk type 2); no recovery partition | vendor_boot table |
| Addresses | kernel `0x40080000`, ramdisk `0x47c80000`, tags/dtb `0x4bc80000` (base `0x40000000`) | vendor_boot header |
| Cmdline | `bootopt=64S3,32N2,64N2` | vendor_boot header |
| Ramdisk compression | legacy LZ4 | ramdisk magic |
| Partition sizes | boot 64 MiB, vendor_boot 64 MiB, init_boot 8 MiB, dtbo 8 MiB | image file sizes |
| Slotting | A/B (`slotselect`), Virtual A/B (snapuserd in init_boot) | fstab |
| Logical partitions | system, system_ext, product, vendor, vendor_dlkm, odm_dlkm, system_dlkm, tr_* | fstab |
| vendor_dlkm | EROFS | superblock |
| Userdata | f2fs, `fileencryption=aes-256-xts:aes-256-cts:v2`, metadata encryption at `/metadata/vold/metadata_encryption` | fstab |
| Storage | eMMC (`11230000.mmc`), SD on `11240000.mmc` | fstab, DTB |
| Display / touch modules | td4160 (HKC, BOE) and nt36528a panels, `novatek_nt36xxx`, `omnivision_td4160` | modules.load.recovery |
| TEE | MicroTrust uTOS + Trusty/GenieZone; gatekeeper and kmsetkey = `trustonic` | DTB, props |
| Super size | 0x240000000 (9 GiB) | partition layout |
| AVB | vbmeta and vbmeta_vendor are unsigned (algorithm NONE, flags 0) | vbmeta |

## Assumptions and TODOs: confirm these before trusting the build

1. **Super size now comes from your partition layout** (9663676416 bytes). The
   dynamic-group size is derived as super minus 4 MiB, not read from device metadata.
2. **Screen resolution is not confirmed.** The panel modules say "hdp" (HD+) but
   the timings are not recoverable from the files. `TW_THEME := portrait_hdpi`
   is a best guess.
3. **Backlight.** `TW_BRIGHTNESS_PATH`, `TW_MAX_BRIGHTNESS := 255` and the default
   are a typical MediaTek guess. Check `max_brightness` on the device.
4. **Filesystem types of logical partitions.** Only vendor_dlkm was confirmed as
   EROFS. The others are set to `erofs` because the stock fstab lists EROFS
   first. Check with `blkid` and adjust `recovery.fstab` if any are ext4.
5. **Decryption is still the riskiest part, but it is now grounded in your vendor.img.**
   It contains the full Trustonic stack: `mcDriverDaemon` (service `mobicore`),
   `tee-service`, the KeyMint 3.0 service (`vendor.keymint-trustonic`) and the
   gatekeeper service (`vendor.gatekeeper-default`). All of their libraries resolve
   from `/vendor/lib64` or the recovery's `/system/lib64`, so the tree does **not**
   copy vendor blobs; it mounts `/vendor` and starts those services
   (`TW_CRYPTO_SYSTEM_VOLD_MOUNT` / `TW_CRYPTO_USE_SYSTEM_VOLD`). The init script also
   mounts `persist` at `/mnt/vendor/persist` because `mcDriverDaemon` needs
   `mcRegistry` there. None of this has been run. If `/data` stays locked, send me
   `recovery.log` and `logcat`.
6. **Boot HAL.** The stock recovery uses MediaTek's AIDL boot HAL, which is copied
   in under `recovery/root`. `device.mk` also pulls in the AOSP `boot@1.2` impl.
   If slot switching fails or the two collide, remove one of them.
7. **Slotted firmware partitions** (lk, logo, tee, scp, sspm, gz, spmfw, modem, tkv) are
   listed in `recovery.fstab` as `slotselect` per your layout; flashing them from TWRP is
   optional and risky.
8. **Marketing name** is unknown; only the codename `KM5` is used.

## Layout

```
BoardConfig.mk / device.mk / twrp_KM5.mk / AndroidProducts.mk / Android.mk
recovery.fstab              TWRP-format fstab built from the stock one
modules.load(.recovery)     stock module load order (171 / 183 entries)
prebuilt/dtb                stock vendor_boot DTB (dt-table wrapper, MT6768)
prebuilt/dtbo.img           stock dtbo
prebuilt/kernel             stock gzip kernel (reference only; stays in boot.img)
prebuilt/modules/*.ko       189 stock modules from the vendor_boot platform ramdisk
recovery/root/              stock MTK boot HAL, libmtk_bsg, fastboot impl, USB init rc
docs/partition_layout.md    key partitions from your layout
docs/stock_kernel.config    kernel config extracted from boot.img (ikconfig)
```

## Build (needs a TWRP minimal manifest that supports vendor_boot recovery)

```
# place this folder at device/tecno/KM5
. build/envsetup.sh
lunch twrp_KM5-eng
mka vendorbootimage
```

Output is `vendor_boot.img`. The kernel stays in your stock `boot.img`, so only
vendor_boot is replaced.

## Flashing (bootloader must be unlocked)

Back up your stock `vendor_boot` first. Then:

```
fastboot flash vendor_boot vendor_boot.img
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
fastboot reboot recovery
```

If it fails to boot, restore the stock `vendor_boot.img` from your zip.
