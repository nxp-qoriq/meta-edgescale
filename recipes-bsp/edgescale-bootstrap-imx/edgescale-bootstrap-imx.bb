DESCRIPTION = "NXP bootstrap for imx devices"
SECTION = "bootloader"
LICENSE = "GPLv2"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://create_imx_boot_image.sh \
    file://memorylayout.cfg \
    file://imx8mqevk.manifest \
    file://uboot-imx-env.txt \
    file://uboot-imx-env2.txt \
"

inherit deploy

DEPENDS = "u-boot-mkimage-native"
ITB_IMAGE ?= "fsl-image-edgescale"
do_deploy[depends] += "imx-boot:do_deploy ${ITB_IMAGE}:do_build"

BOOT_TYPE ??= "sd"

S = "${WORKDIR}"

do_deploy[nostamp] = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_deploy () {
    for d in ${BOOT_TYPE}; do
        ./create_imx_boot_image.sh -m ${MACHINE} -t ${d} -d . -s ${DEPLOY_DIR_IMAGE}
    done
    cp uboot-imx-env*.bin ${DEPLOY_DIR_IMAGE}
}

addtask deploy before do_build after do_compile

PACKAGE_ARCH = "${MACHINE_ARCH}"
