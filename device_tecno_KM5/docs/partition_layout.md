# Partition layout (from the MediaTek layout you supplied)

Storage: eMMC (MSDC_0), block size 0x20000. Platform MT6768, project km5_xk67j.

| Partition | Size | Notes |
|---|---|---|
| boot_a / boot_b | 0x4000000 (64 MiB) | |
| vendor_boot_a / _b | 0x4000000 (64 MiB) | recovery lives here |
| init_boot_a / _b | 0x800000 (8 MiB) | |
| dtbo_a / _b | 0x800000 (8 MiB) | |
| vbmeta, vbmeta_system, vbmeta_vendor (_a/_b) | 0x800000 each | |
| super | 0x240000000 (9663676416 B, 9 GiB) | dynamic partitions |
| metadata | 0x4000000 | f2fs at runtime |
| persist | 0x3000000 | ext4, Trustonic registry |
| nvram / nvdata / nvcfg | 0x4100000 / 0x4000000 / 0x2000000 | IMEI and calibration |
| protect1 / protect2 | 0x800000 / 0xf5e000 | |
| proinfo | 0x300000 | |
| tranfs | 0x12c00000 | Transsion, ext4 |
| userdata | (image size placeholder 0xc0000000) | real size is the remainder; NEEDRESIZE |

Slotted firmware: lk, logo, tee, scp, sspm, gz, spmfw, modem, tkv (each _a/_b).
Preloader is in eMMC boot1/boot2.
