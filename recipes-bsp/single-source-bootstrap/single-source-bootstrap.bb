DESCRIPTION = "NXP secure bootloader for qoriq devices"
SECTION = "bootloaders"
LICENSE = "GPLv2"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://create_single_boot_image.sh \
    file://memorylayout.cfg \
    file://flash_images.sh \
    file://${MACHINE}.manifest \
    file://${MACHINE}/env_bootstrap.img \
    file://mft-environment/env_bootstrap.img \
"
SRC_URI_append_ls1021atwr = "file://gen_flash_image.pl \
    file://${MACHINE}/flashmap_nor.cfg \
    file://${MACHINE}/uboot_env_nor.txt \
"

inherit deploy  perlnative

#set ROOTFS_IMAGE = "fsl-image-edgescale" in local.conf
#set KERNEL_ITS = "kernel-all.its" in local.conf
ITB_IMAGE = "fsl-image-kernelitb"
ITB_IMAGE_ls1021atwr = "fsl-image-edgescale"
DEPENDS = "u-boot-mkimage-native cst-native"
DEPENDS_append_qoriq-arm64 = " atf"
DEPENDS_append_ls1021atwr = " u-boot perl-native libstring-crc32-perl-native"
do_deploy[depends] += "virtual/kernel:do_deploy ${ITB_IMAGE}:do_build"

BOOT_TYPE ??= ""
BOOT_TYPE_ls1043ardb ?= "nor"
BOOT_TYPE_ls1046ardb ?= "qspi"
BOOT_TYPE_ls1046afrwy ?= "qspi"
BOOT_TYPE_ls1088a ?= "qspi"
BOOT_TYPE_ls2088ardb ?= "nor"
BOOT_TYPE_lx2160ardb ?= "xspi"
BOOT_TYPE_ls1028ardb ?= "xspi"
BOOT_TYPE_ls1012ardb ?= "qspi"
BOOT_TYPE_ls1012afrwy ?= "qspi"
BOOT_TYPE_ls1021atwr ?= "qspi nor"

IMA_EVM = "${@bb.utils.contains('DISTRO_FEATURES', 'ima-evm', 'true', 'false', d)}"
ENCAP = "${@bb.utils.contains('DISTRO_FEATURES', 'encap', 'true', 'false', d)}"
SECURE = "${@bb.utils.contains('DISTRO_FEATURES', 'secure', 'true', 'false', d)}"
MFT = "${@bb.utils.contains('DISTRO_FEATURES', 'mft', 'true', 'false', d)}"

S = "${WORKDIR}"

do_deploy[nostamp] = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_deploy () {
    rm -rf ${DEPLOY_DIR_IMAGE}/single-bootstrap
    install -d ${DEPLOY_DIR_IMAGE}/single-source-bootstrap
    cd ${RECIPE_SYSROOT_NATIVE}/usr/bin/cst
    cp ${S}/*.sh ./
    cp ${S}/${MACHINE}.manifest ./
    if [ ${MFT} != "true" ]; then
        cp ${S}/${MACHINE}/env_bootstrap.img ./
    else
        cp ${S}/mft-environment/env_bootstrap.img ./
    fi
    cp ${S}/memorylayout.cfg ./
    if [ ${SECURE} = "true" ]; then
        if [ ! -f ${RECIPE_SYSROOT_NATIVE}/usr/bin/cst/srk.pri ]; then
            ./gen_keys 1024
        fi
    fi
 
    for d in ${BOOT_TYPE}; do
        ./create_single_boot_image.sh -m ${MACHINE} -t ${d} -d . -s ${DEPLOY_DIR_IMAGE} -e ${ENCAP} -i ${IMA_EVM} -o ${SECURE} -f ${MFT}
        cp ${DEPLOY_DIR_IMAGE}/firmware*.img ${DEPLOY_DIR_IMAGE}/single-source-bootstrap/
        cp ${DEPLOY_DIR_IMAGE}/bl2*.pbl ${DEPLOY_DIR_IMAGE}/single-source-bootstrap/
    done
    if [ -e ${RECIPE_SYSROOT_NATIVE}/usr/bin/cst/${MACHINE}_boot.scr ]; then
    	cp ${RECIPE_SYSROOT_NATIVE}/usr/bin/cst/${MACHINE}_boot.scr ${DEPLOY_DIR_IMAGE}
    fi
}

do_deploy_ls1021atwr () {
    rm -rf ${DEPLOY_DIR_IMAGE}/single-source-bootstrap
    mkdir ${DEPLOY_DIR_IMAGE}/single-source-bootstrap
    ./gen_flash_image.pl -c ${MACHINE}/flashmap_nor.cfg -e ${MACHINE}/uboot_env_nor.txt -d ${DEPLOY_DIR_IMAGE} -o  ${MACHINE}-nor.img
    cp ${MACHINE}-nor.img ${DEPLOY_DIR_IMAGE}/single-source-bootstrap/firmware_${MACHINE}_uboot_norboot.img
}

addtask deploy before do_build after do_compile
PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(qoriq)"
