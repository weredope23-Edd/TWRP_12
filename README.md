# TWRP build for Tecno KM5 — gatekeeper AIDL decrypt fix

This repo is a self-contained GitHub Actions build: push it to GitHub, run
the workflow from the Actions tab, and it produces a TWRP image with the
PIN-decrypt fix built in. No local machine or AOSP tree needed on your end
-- GitHub's runner does the `repo sync` + build.

## Layout

- `device_tecno_KM5/` -- your device tree, unchanged.
- `patches/` -- the three files that fix PIN decrypt (HIDL gatekeeper ->
  AIDL gatekeeper). See `patches/README_PATCH.txt`-equivalent notes below;
  these are the same files already explained to you, just staged here so
  the workflow can copy them into place after `repo sync`.
- `.github/workflows/build-twrp.yml` -- the build. It:
  1. Frees disk space on the runner (Android builds need more than the
     ~14GB a stock runner starts with).
  2. Installs the standard AOSP host build dependencies.
  3. `repo init`s the TWRP minimal manifest at branch `twrp-14.1` (matches
     your device's Android 15 / GKI base) and `repo sync`s it -- this is
     where `bootable/recovery/crypto/Decrypt.cpp` actually comes from.
  4. Copies `device_tecno_KM5/` into the synced tree at
     `device/tecno/KM5`.
  5. Overwrites `bootable/recovery/crypto/Decrypt.cpp`,
     `bootable/recovery/crypto/Android.mk`, and
     `bootable/recovery/prebuilt/Android.mk` with the patched versions
     from `patches/`.
  6. `lunch twrp_KM5-eng` and `mka vendorbootimage`.
  7. Uploads whatever `.img` files land in `out/target/product/*/` as a
     downloadable workflow artifact.

## How to run it

1. Create a new **public** repo on GitHub (public = unlimited free Actions
   minutes on standard runners; private repos get a limited free minutes
   budget per month, which an Android build can burn through fast).
2. Push everything in this folder to that repo's default branch, keeping
   the paths exactly as they are here.
3. In the repo, go to **Actions -> Build TWRP (Tecno KM5, gatekeeper AIDL
   fix) -> Run workflow**. Leave `build_target` on `vendorbootimage`
   (matches your board: recovery lives inside vendor_boot, there's no
   separate recovery partition) unless you specifically need
   `recoveryimage` or `bootimage` instead.
4. Wait -- a TWRP build from a minimal manifest typically runs 30-90
   minutes on GitHub's runners; the job has a 5.5 hour ceiling before it's
   killed, which is generous headroom.
5. When it finishes, open the run and download the `twrp-KM5-gatekeeper-fix`
   artifact. That's your new vendor_boot.img.

## What to check if the build fails

- **"test -f bootable/recovery/crypto/Decrypt.cpp" fails at the patch
  step**: the TWRP manifest layout changed, or the sync didn't finish.
  Check the sync step's log for errors first.
- **Compile error on `rsp.statusCode` / `rsp.hardwareAuthToken` in
  Decrypt.cpp**: this is the one thing I couldn't verify without your
  tree's actual generated AIDL header (explained in our last message).
  Open the build log, find the exact compiler error (it'll quote the real
  field name), and tell me -- it's a one-line fix in
  `patches/Decrypt.cpp`.
- **`lunch twrp_KM5-eng` fails / combo not found**: your device tree's
  `AndroidProducts.mk` / `twrp_KM5.mk` may define a different product
  name than `twrp_KM5`. Check those two files; if the name differs, edit
  `LUNCH_COMBO` near the top of `.github/workflows/build-twrp.yml` to
  match.
- **Runs out of disk mid-build**: send me the log around where `df -h`
  prints low numbers; the cleanup step may need another large preinstalled
  tool removed, or the job may need a bigger (paid) runner.

Send me the failing step's log and I'll adjust the workflow or the patch.
