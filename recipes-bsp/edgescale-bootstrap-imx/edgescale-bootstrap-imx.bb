DESCRIPTION = "NXP bootstrap for imx devices"
SECTION = "bootloader"
LICENSE = "GPLv2"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://create_imx_boot_image.sh \
    file://memorylayout.cfg \
    file://${MACHINE}/${MACHINE}.manifest \
    file://${MACHINE}/uboot-imx-env.txt \
    file://${MACHINE}/uboot-imx-env2.txt \
"

inherit deploy

DEPENDS = "u-boot-mkimage-native"
ITB_IMAGE ?= "fsl-image-edgescale"
UBOOT_IMAGE ?= "imx-boot"
UBOOT_IMAGE_mx6 = "uboot-ota"
do_deploy[depends] += "${UBOOT_IMAGE}:do_deploy ${ITB_IMAGE}:do_build"

BOOT_TYPE ?= "sd"
BOOT_TYPE_mx8mm = "nor"

S = "${WORKDIR}"

do_deploy[nostamp] = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_deploy () {
    cp ${MACHINE}/* ./
    for d in ${BOOT_TYPE}; do
        ./create_imx_boot_image.sh -m ${MACHINE} -t ${d} -d . -s ${DEPLOY_DIR_IMAGE}
    done
}

addtask deploy before do_build after do_compile

PACKAGE_ARCH = "${MACHINE_ARCH}"
