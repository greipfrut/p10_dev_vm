#!/usr/bin/env python3
import os
import shutil
import datetime
import time
import subprocess
import errno

anykernel_path = '/vagrant/AnyKernel3'

# Clear the anykernel path of any lingering files from the last build
for root, dirs, files in os.walk(anykernel_path):
    for file in files:
        if file.endswith('.ko') or file.endswith('.gz-dtb'):
            os.remove(os.path.join(root, file))

# Copy the kernel modules into the AnyKernel3 directory structure to create a flashable zip
pronto_wifi_modules_found = False
pronto_wifi_module_name = 'pronto_wlan.ko'
for root, dirs, files in os.walk("/home/vagrant/out/target/product/msm8953_64/obj/system/lib/modules"):
    for file in files:
        if file.endswith('.ko'):
            path_to_ko = os.path.join(root, file)
            if pronto_wifi_module_name in path_to_ko:
                pronto_wifi_modules_found = True
                print(f'wifi: {path_to_ko}')
                shutil.copyfile(path_to_ko, os.path.join(anykernel_path, 'modules/vendor/lib/modules/pronto', pronto_wifi_module_name))
                shutil.copyfile(path_to_ko, os.path.join(anykernel_path, 'modules/vendor/lib/modules', 'wlan.ko'))
            else:
                print(f'non-wifi: {path_to_ko}')
                shutil.copyfile(path_to_ko, os.path.join(anykernel_path, 'modules/system/lib/modules', file))

if not pronto_wifi_modules_found:
    """
    if no wifi modules were built, it is assumed they should not be present since flashing replaces files,
        merely not having the pronto_wlan.ko and wlan.ko files in the image does not remove them if they
        already exist. therefore, we will use mknod to create empty files that will replace the real files
        upon a flash, effectively disabling wifi at the kernel level.
    """ 
    open(os.path.join(anykernel_path, 'modules/vendor/lib/modules/pronto', pronto_wifi_module_name), 'w').close()
    open(os.path.join(anykernel_path, 'modules/vendor/lib/modules', 'wlan.ko'), 'w').close()

# Copy the kernel image
kernel_dtb_image_path = '/home/vagrant/out/target/product/msm8953_64/obj/KERNEL_OBJ/arch/arm64/boot/Image.gz-dtb'
if os.path.isfile(kernel_dtb_image_path):
    shutil.copyfile(kernel_dtb_image_path, os.path.join(anykernel_path, 'Image.gz-dtb'))
else:
    raise FileNotFoundError(
    errno.ENOENT, os.strerror(errno.ENOENT), kernel_dtb_image_path)

# Insert some goodies into the version file for documentation
with open(os.path.join(anykernel_path, 'version'), 'w+') as vfile:
    vfile.write('**************************************************\n')
    vfile.write('custom kernel for Lenovo Smart Tab P10 (TB-X705F)\n')
    vfile.write('  author:  greipfrut \n')
    vfile.write(' version:  3.18.120-greipfrut\n')
    vfile.write(f'compiled:  {time.ctime(os.path.getmtime(kernel_dtb_image_path))}\n')
    vfile.write(f'  zipped:  {datetime.datetime.now().ctime()}\n')
    vfile.write('**************************************************\n')

# Create the flashable zip
subprocess.run(f"zip -r9 ../update_P10_kernel_{datetime.datetime.now().ctime().replace(' ', '_').replace(':', '-')}.zip * -x .git README.md *placeholder create_zip.sh", shell=True, check=True, cwd=anykernel_path)
