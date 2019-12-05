require recipes-core/images/core-image-minimal.bb

SUMMARY = "Edgescale image to be used for evaluating the NXP edgescale"
DESCRIPTION = "Edgescale image which includes some edgescale tools and \
NXP-specific packages."

LICENSE = "MIT"

IMA_EVM = "${@bb.utils.contains('DISTRO_FEATURES', 'ima-evm', 'ima-evm', '', d)}"

IMAGE_INSTALL_append = " \
    start-stop-daemon \
    dhcpcd \
    ota-overlay \
    edgescale-eds \
    bash \
    ca-certificates \
    coreutils \
    curl \
    net-tools \
    util-linux-fdisk \
    util-linux-lsblk \
    dosfstools \
    e2fsprogs \
    e2fsprogs-e2fsck \
    e2fsprogs-mke2fs \
    file \
    openssl \
    packagegroup-core-ssh-openssh \
    tar \
    inetutils-ping \
    keyutils \
    rng-tools \
    ${IMA_EVM} \
"

IMAGE_INSTALL_append_ls1012a = " \
    kernel-modules \
    ppfe-firmware \
"

PACKAGE_ARCH = "${MACHINE_ARCH}"
IMAGE_FSTYPES = "tar.gz ext2.gz ext2.gz.u-boot"

