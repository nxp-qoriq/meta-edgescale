FILESEXTRAPATHS_prepend := "${THISDIR}/files:"


IMXBOOT_TARGETS_append = " " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'first_boot_loader"', '', d)}""
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0001-imx8mq-Generate-fbl.bin-as-first-boot-loader.patch', '', d)}"

OTA = "${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'true', 'false', d)}"

do_deploy_append () {
    if [ "${OTA}" = "true" ];then
        install -m 0644 ${S}/${SOC_DIR}/u-boot.itb ${DEPLOYDIR}/${DEPLOYDIR_IMXBOOT} 
        install -m 0644 ${S}/${SOC_DIR}/fbl.bin ${DEPLOYDIR}/${DEPLOYDIR_IMXBOOT}
    fi
}
