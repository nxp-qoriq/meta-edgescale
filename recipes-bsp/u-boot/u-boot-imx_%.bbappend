FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# To uboot support ota
#please set DISTRO_FEATURES_append = " ota" in local.config

SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0001-imx8mq-spl-Add-OTA-status-check.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0002-imx8mq-spl-Add-mmc-write-support.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0003-imx8mq-Change-ENV-offset-to-avoid-overlap.patch ', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0004-imx8mq-spl-Enable-watchdog-and-set-timeout-value.patch', '', d)}"
