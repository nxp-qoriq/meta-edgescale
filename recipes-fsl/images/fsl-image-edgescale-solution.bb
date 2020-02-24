require recipes-core/images/core-image-minimal.bb

SUMMARY = "Edgescale image to be used for evaluating the NXP edgescale"
DESCRIPTION = "Edgescale image which includes some edgescale tools and \
NXP-specific packages."

LICENSE = "MIT"

#set DISTRO_FEATURES_append = " edgescale" in local.config

EDS = "${@bb.utils.contains('DISTRO_FEATURES', 'edgescale', 'packagegroup-edgescale', '', d)}"
IMA_EVM = "${@bb.utils.contains('DISTRO_FEATURES', 'ima-evm', 'ima-evm', '', d)}"

IMAGE_INSTALL_append = " \
    start-stop-daemon \
    bash \
    coreutils \
    mosquitto \
    net-tools \
    util-linux-fdisk \
    util-linux-lsblk \
    dosfstools \
    file \
    packagegroup-core-ssh-openssh \
    tar \
    inetutils-ping \
    keyutils \
    kmod \
    kernel-modules \
    openssl-qoriq-bin \
    rng-tools \
    dhcp-client \
    curl \
    ${IMA_EVM} \
    ${EDS} \
"

IMAGE_INSTALL_append_ls1012a = " \
    kernel-modules \
    ppfe-firmware \
"

EXTRA_IMAGEDEPENDS_qoriq += " secure-boot-qoriq"

PACKAGE_ARCH = "${MACHINE_ARCH}"
IMAGE_FSTYPES_qoriq = "tar.gz ext2.gz ext2.gz.u-boot"

inherit remove-files
ROOTFS_POSTPROCESS_COMMAND_append_ls1012a = "rootfs_delete_files;"
ROOTFS_POSTPROCESS_COMMAND_append_ls1043a = "rootfs_delete_files;"
ROOTFS_POSTPROCESS_COMMAND_append_ls1046a = "rootfs_delete_files;"
ROOTFS_POSTPROCESS_COMMAND_append_ls1088a = "rootfs_delete_files;"
ROOTFS_POSTPROCESS_COMMAND_append_ls2088a = "rootfs_delete_files;"
ROOTFS_POSTPROCESS_COMMAND_append_lx2160a = "rootfs_delete_files;"
