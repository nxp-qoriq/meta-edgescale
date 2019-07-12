# Copyright (C) 2013-2016 Freescale Semiconductor
# Copyright 2017-2018 NXP

DESCRIPTION = "i.MX U-Boot suppporting i.MX reference boards."
require recipes-bsp/u-boot/u-boot.inc
inherit pythonnative

DEPENDS_append = " python dtc-native"

PROVIDES += "u-boot"
UBOOT_CONFIG_mx6 = "sdmx6"
UBOOT_CONFIG[sdmx6] = "mx6sabresd_defconfig,sdcard"
UBOOT_MAKE_TARGET_mx6 = ""

UBOOT_BINARY = "u-boot-dtb.img"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRC_URI = "git://git.denx.de/u-boot.git"
SRCREV =  "7c7919cd07b34a784ab321ab7578106c9e9bd753"

MX6_PATCHES = "file://0001-mx6sabresd-Remove-CONFIG_SPL_DM-to-decrease-the-SPL-.patch \
               file://0002-MLK-19219-1-spl-Add-function-to-get-u-boot-raw-secto.patch \
               file://0003-imx6qsabre-spl-Add-OTA-status-check.patch \
               file://0004-imx6qsabre-spl-Add-mmc-write-support.patch \
               file://0005-imx6qsabre-Change-ENV-offset-to-avoid-overlap.patch \
               file://0006-imx6qsabre-Enable-watchdog-and-set-timeout-value.patch \
"

SRC_URI_append_mx6 =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', '${MX6_PATCHES}', '', d)}"

do_deploy_append () {
    install -m 0777 ${B}/${config}/SPL  ${DEPLOYDIR}
    install -m 0777 ${B}/${config}/u-boot-dtb.img  ${DEPLOYDIR}
}

S = "${WORKDIR}/git"

inherit fsl-u-boot-localversion

LOCALVERSION ?= "-${SRCBRANCH}"

COMPATIBLE_MACHINE = "(mx6|mx7|mx8)"

UBOOT_NAME_mx6 = "u-boot-${MACHINE}.bin-${UBOOT_CONFIG}"
UBOOT_NAME_mx7 = "u-boot-${MACHINE}.bin-${UBOOT_CONFIG}"
UBOOT_NAME_mx8 = "u-boot-${MACHINE}.bin-${UBOOT_CONFIG}"
