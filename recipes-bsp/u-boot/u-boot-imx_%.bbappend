FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# To uboot support ota
#please set DISTRO_FEATURES_append = " ota" in local.config

UBOOT_CONFIG_mx8mm = "fspi"
UBOOT_CONFIG_mx6 = "sd"
DEPENDS_append = " u-boot-mkimage-native"
UBOOT_MAKE_TARGET_mx6 = ""
UBOOT_BINARY_mx6 = "u-boot-dtb.bin"

SRC_URI_append_mx8m =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0001-imx8mq-spl-Add-OTA-status-check.patch', '', d)}"
SRC_URI_append_mx8m =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0002-imx8mq-spl-Add-mmc-write-support.patch', '', d)}"
SRC_URI_append_mx8m =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0003-imx8mq-Change-ENV-offset-to-avoid-overlap.patch ', '', d)}"
SRC_URI_append_mx8m =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0004-imx8mq-spl-Enable-watchdog-and-set-timeout-value.patch', '', d)}"
SRC_URI_append_mx8m =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0005-imx8m-spl-Add-common-OTA-status-check.patch', '', d)}"
SRC_URI_append_mx8m =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0006-imx8m-spl_mmc-Move-OTA-status-check-from-spl_mmc.patch', '', d)}"
SRC_URI_append_mx8m =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0007-imx8mm-spl-Add-mmc-write-and-read-support.patch', '', d)}"
SRC_URI_append_mx8m =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0008-imx8mm-Change-ENV-offset-to-avoid-overlap.patch', '', d)}"
SRC_URI_append_mx8m =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0009-imx8mm-spl-Enable-watchdog-and-set-timeout-value.patch', '', d)}"
SRC_URI_append_mx8m =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0010-imx8mm-spl-Move-OTA-status-check-to-get_boot_device.patch', '', d)}"
SRC_URI_append_mx8m =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0011-imx8m-spl-Update-timeout-value-for-Watchdog.patch', '', d)}"

do_deploy_append_mx6 () {
    uboot-mkimage -A ARM -T firmware -C none -O u-boot -a 0x17800000 -e 0x17800000 -d ${B}/${config}/u-boot-dtb.bin  ${B}/${config}/u-boot-dtb.img 
    install -m 0777 ${B}/${config}/u-boot-dtb.img  ${DEPLOYDIR}
}


