#!/bin/bash

export PATH="/home/vagrant/aarch64-linux-android-4.9/bin:$PATH"
export PROJECT=msm8953_64

# Allow normal user vagrant to access the virtualbox shared folder owned by vboxsf
sudo usermod -aG vboxsf vagrant

get_build_tools() {
    # Guidance of dependencies from https://nathanpfry.com/how-to-setup-ubuntu-18-04-lts-bionic-beaver-to-compile-android-roms/#comment-37929
    # Also https://back2basics.io/2020/05/creating-a-android-aosp-build-machine-on-ubuntu-20-04/
    sudo apt-get install openssh-server screen python openjdk-8-jdk android-tools-adb bc bison \
    build-essential curl flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses-dev \
    lib32readline-dev lib32z1-dev  liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev \
    libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc yasm zip zlib1g-dev \
    libtinfo5 libncurses5 ccache bzip2 libbz2-dev libghc-bzlib-dev lib32ncurses5-dev \
    x11proto-core-dev libx11-dev unzip python-dev libffi-dev libxml2-dev libxslt1-dev libjpeg8-dev python2 -y
}

get_linux_android_toolchain() {
    sudo apt-get update
    sudo apt-get install git -y

    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"
    if [ -d "/home/vagrant/aarch64-linux-android-4.9/bin" ] 
    then
        echo "Already have the cross compilation toolchain..." 
    else
        git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b pie-gsi
    fi

    # Append to PATH
    echo "PATH=/home/vagrant/aarch64-linux-android-4.9/bin:$PATH" >> ~/.bashrc
}

get_kernel_sources() {
    # Download sources
    ssh-keygen -F github.com || ssh-keyscan github.com >> /home/vagrant/.ssh/known_hosts
    echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> /home/vagrant/.ssh/config
    if [ -d "/home/vagrant/p10_kernel_source/arch/arm64/configs" ] 
    then
        echo "Already have the kernel source..." 
    else
        git clone git@github.com:greipfrut/android_kernel_lenovo_X705F.git
    fi
}

do_also_build_wifi() {
    # Let's build the wifi kernel module
    make O=../out/target/product/$PROJECT/obj/KERNEL_OBJ ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- KCFLAGS=-mno-android  WLAN_ROOT=/home/vagrant/p10_kernel_source/drivers/staging/prima MODNAME=pronto_wlan CONFIG_PRONTO_WLAN=m -C . M=/home/vagrant/p10_kernel_source/drivers/staging/prima modules
    make O=../out/target/product/$PROJECT/obj/KERNEL_OBJ ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- KCFLAGS=-mno-android  WLAN_ROOT=/home/vagrant/p10_kernel_source/drivers/staging/prima MODNAME=pronto_wlan CONFIG_PRONTO_WLAN=m -C . M=/home/vagrant/p10_kernel_source/drivers/staging/prima INSTALL_MOD_PATH=../system INSTALL_MOD_STRIP=1 modules_install
}

do_build_kernel() {
    # Source any updates to environment
    source ~/.bashrc
    
    # Copy the SyncronE kernel config into the kernel src
    SYNCRONE_DEFCONFIG="/home/vagrant/p10_kernel_source/arch/arm64/configs/syncronep10_defconfig"
    if [ -f "$SYNCRONE_DEFCONFIG" ];
    then
       echo "$SYNCRONE_DEFCONFIG already exists! Removing potentially stale config and copying over new one..."
    else
       echo "$SYNCRONE_DEFCONFIG does not exist...copying over a new one..." >&2
    fi
    cp /vagrant/syncronep10_defconfig $SYNCRONE_DEFCONFIG
    
    cd /home/vagrant/p10_kernel_source

    # Use mrproper to make sure src directory is in good shape and is clean from previous builds
    make -C . O=../out/target/product/$PROJECT/obj/KERNEL_OBJ ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- KCFLAGS=-mno-android mrproper

    # Use our SyncronE kernel config file as a starting point
    make -C . O=../out/target/product/$PROJECT/obj/KERNEL_OBJ ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- KCFLAGS=-mno-android syncronep10_defconfig

    # This is useful to run in another SSH connection to access a menu interface for configuring the kernel
    #make -C . O=../out/target/product/$PROJECT/obj/KERNEL_OBJ ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- KCFLAGS=-mno-android menuconfig

    # Prepare for the build
    make -C . O=../out/target/product/$PROJECT/obj/KERNEL_OBJ ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- KCFLAGS=-mno-android oldconfig
    make -C . O=../out/target/product/$PROJECT/obj/KERNEL_OBJ ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- KCFLAGS=-mno-android prepare
    make -C . O=../out/target/product/$PROJECT/obj/KERNEL_OBJ ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- KCFLAGS=-mno-android modules_prepare

    # Finally, this build here takes around 12 minutes to finish
    make -j8 -C . O=../out/target/product/$PROJECT/obj/KERNEL_OBJ ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- KCFLAGS=-mno-android
    
    # Comment this out if we don't care for the wifi modules
    do_also_build_wifi;

    do_build_modules;

}

do_build_modules() {
    # Now let's build any other modules selected (e.g. via menuconfig) and install
    make -C . O=../out/target/product/$PROJECT/obj/KERNEL_OBJ ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- KCFLAGS=-mno-android INSTALL_MOD_PATH=system modules
    make -C . O=../out/target/product/$PROJECT/obj/KERNEL_OBJ ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- KCFLAGS=-mno-android INSTALL_MOD_PATH=../system INSTALL_MOD_STRIP=1 modules_install
}

do_extra_goodies() {
    ### Get Sublime Text 3
    curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add - && sudo add-apt-repository "deb https://download.sublimetext.com/ apt/stable/" && sudo apt-get update && sudo apt-get install sublime-text -y

}

get_linux_android_toolchain;
get_kernel_sources;
get_build_tools;
do_extra_goodies;

do_build_kernel;
/vagrant/create_p10_flash.py;

printf "****************************************************************** \n"
printf "****************************************************************** \n"
printf "****************************************************************** \n"
printf "$(date): Provisioning complete! \n"
