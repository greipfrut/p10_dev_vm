# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers
# 14/01/2020 - modified by Yahoo Mike @ xda-developers
# 11/06/2020 - modified by Timothy S. Phan @ autonomous healthcare

## AnyKernel setup
# begin properties
properties() { '
kernel.string=X705F_Kernel by Timothy S. Phan @ autonomous healthcare
do.devicecheck=1
do.modules=1
do.cleanup=1
do.cleanuponabort=0
device.name1=X705F
supported.versions=9
supported.patchlevels=- 2020-06
'; } # end properties

# shell variables
block=/dev/block/platform/soc/7824900.sdhci/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel install
dump_boot;

write_boot;
## end install

