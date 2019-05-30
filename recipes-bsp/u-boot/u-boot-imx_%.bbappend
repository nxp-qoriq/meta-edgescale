FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# To uboot support ota
#please set DISTRO_FEATURES_append = " ota" in local.config

SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0001-imx8mq-spl-Add-OTA-status-check.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0002-imx8mq-spl-Add-mmc-write-support.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0003-imx8mq-Change-ENV-offset-to-avoid-overlap.patch ', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0004-imx8mq-spl-Enable-watchdog-and-set-timeout-value.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0005-imx8m-spl-Add-common-OTA-status-check.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0006-imx8m-spl_mmc-Move-OTA-status-check-from-spl_mmc.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0007-imx8mm-spl-Add-mmc-write-and-read-support.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0008-imx8mm-Change-ENV-offset-to-avoid-overlap.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0009-imx8mm-spl-Enable-watchdog-and-set-timeout-value.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0010-imx8mm-spl-Move-OTA-status-check-to-get_boot_device.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0011-imx8m-spl-Update-timeout-value-for-Watchdog.patch', '', d)}"

