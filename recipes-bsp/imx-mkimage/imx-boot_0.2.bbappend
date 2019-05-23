IMXBOOT_TARGETS_append = " first_boot_loader"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

#SRC_URI_append = " file://0001-imx8mq-Generate-fbl.bin-as-first-boot-loader.patch"
SRC_URI_append = " file://0001-fix.patch"

do_deploy_append () {
    install -m 0644 ${S}/${SOC_DIR}/u-boot.itb ${DEPLOYDIR}/${DEPLOYDIR_IMXBOOT} 
    install -m 0644 ${S}/${SOC_DIR}/fbl.bin ${DEPLOYDIR}/${DEPLOYDIR_IMXBOOT}
}
