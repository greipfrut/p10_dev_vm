p10\_dev\_vm
============

This project automates the provisionsing of a Virtualbox VM with all batteries included to build the Android/Linux kernel v3.18.120 from source and create a flashable zip file for the Lenovo Smart Tab P10 tablet via TWRP Custom Recovery.

It also includes the standard Ubuntu desktop in case the developer wishes to have a GUI experience to make modifications to any source files.


## macOS/Linux Quick Start: First Time
1. Download the latest [release](https://github.com/greipfrut/p10_dev_vm/releases) (v0.1.0 as of June 16 2020) of this repo.
1. (Very first time only) Install Vagrant: https://www.vagrantup.com/downloads
1. Spin up the VM: `vagrant up --provider=virtualbox`
1. Once you see `Provisioning complete!` at the terminal, you will find the flashable zip (e.g. `update_P10_kernel_Tue_Jun_16_19-14-05_2020.zip`) in this same directory.
1. Power down the VM if you're done: `vagrant halt`
1. Destroy the VM to free up HD space if you no longer require it: `vagrant destroy`

### Flashing onto the P10
1. Place the flashable zip file (e.g. `update_P10_kernel_Tue_Jun_16_19-14-05_2020.zip`) onto a USB Flash Drive and power off the P10 tablet.
1. With the tablet powered off, hold down all 3 buttons (volume up, volume down, lock) until the blue TWRP Custom Recovery screen appears.
1. Click on `Install`, then `Select Storage` on the following screen to select the `USB-OTG` option.  You should now be able to select the zip file (e.g. `update_P10_kernel_Tue_Jun_16_19-14-05_2020.zip`).
1. Swipe to flash the file and once complete, click on `Reboot System`.
1. Done!

## macOS/Linux: Working on an already provisioned VM
1. On your local computer, open up a terminal and `cd` into this folder that contains `Vagrantfile`.
1. Spin the VM back up: `vagrant up`

## Windows Quick Start
1. Download the latest [release](https://github.com/greipfrut/p10_dev_vm/releases) (v0.1.0 as of June 16 2020) of this repo.
1. (Very first time only) Install Vagrant and Git for Windows: https://www.vagrantup.com/downloads and https://gitforwindows.org/
1. Now spin up the VM: `vagrant up --provider=virtualbox`
1. You should see a lot of automated outputs at the terminal and maybe after 30 minutes or so, you'll see `Provisioning complete!` at the terminal.  Then you will find a flashable zip (e.g. `update_P10_kernel_Tue_Jun_16_19-14-05_2020.zip`) in this same directory.
1. Power down the VM if you're done: `vagrant halt`
1. Destroy the VM to free up HD space if you no longer require it: `vagrant destroy`


## Troubleshooting

#### 1. It took a long time to find out that normalizing line endings so that this repo survives cross-platform (Linux, macOS, Windows) messes up the binaries that are included under the `AnyKernel3/tools` directory; git assumes the binaries are text files and attempts to convert CRLF to LF which wrecks the binaries leading to unflashable files.

- You can figure out if this is an issue by calling `file` on `busybox`.  If your output matches the first entry below with `missing section headers`, you're in trouble; go straight to the source of AnyKernel3: https://github.com/osm0sis/AnyKernel3, and replace your files with the ones contained in there since git may have attempted line ending conversions on the binaries.  If it matches the second, you're in good shape:

```bash
			$ file AnyKernel3/tools/busybox
			BAD:  AnyKernel3/tools/busybox: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, missing section headers

			$ file AnyKernel3/tools/busybox
			GOOD: AnyKernel3/tools/busybox: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, stripped
```

- Alternatively, calculate the md5 hashes of all the files under `AnyKernel3/tools` and `AnyKernel3/META-INF` and ensure they match the following hashes:

```bash
			$ find ./AnyKernel3/tools -type f -exec md5sum {} \;
			18e3cd547bd42bef48a45da2ec8b6243 *./AnyKernel3/tools/ak3-core.sh
			fb9d0953aa640a0fec88b508fcfd8bd9 *./AnyKernel3/tools/busybox
			dc389371a1d0bd110a47992d16f8a8d7 *./AnyKernel3/tools/magiskboot
			8d2b669cae142b76876ee388c9dab05a *./AnyKernel3/tools/magiskpolicy

			$ find ./AnyKernel3/META-INF -type f -exec md5sum {} \;
			9f531e1b38eb3654730b09372d4a4421 *./AnyKernel3/META-INF/com/google/android/update-binary
			7d4067c73b35b4960e64e2ee4169f863 *./AnyKernel3/META-INF/com/google/android/updater-script
```