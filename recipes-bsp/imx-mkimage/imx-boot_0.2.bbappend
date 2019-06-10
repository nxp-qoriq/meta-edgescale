FILESEXTRAPATHS_prepend := "${THISDIR}/files:"


IMXBOOT_TARGETS_append_mx8mq = " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'first_boot_loader', '', d)}"
IMXBOOT_TARGETS_append_mx8mm = " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'first_boot_loader_flexspi', '', d)}"
IMXBOOT_TARGETS_mx8mm = "flash_evk_flexspi"

UBOOT_CONFIG_mx8mm = "fspi"

SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0001-imx8mq-Generate-fbl.bin-as-first-boot-loader.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0003-imx8mm-Generate-fbl.bin-for-QSPI-NOR-Flash-Boot.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0004-Add-the-script-to-generate-F-Q-SPI-FBL-Image.patch', '', d)}"
SRC_URI_append =  " ${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'file://0005-fspi_packer_fbl.sh-change-mod.patch', '', d)}"

OTA = "${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'true', 'false', d)}"
DEPLOY_OPTEE = "${@bb.utils.contains('DISTRO_FEATURES', 'ota', 'false', 'true', d)}"

do_compile_append () {
    if [ "${OTA}" = "true" ] && [ "${SOC_TARGET}" = "iMX8MM" ];then
        cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/bl31-imx8mm.bin ${S}/${SOC_DIR}/bl31.bin
         # mkimage for i.MX8
        for target in ${IMXBOOT_TARGETS}; do
            echo "building ${SOC_TARGET} - ${target}"
            make SOC=${SOC_TARGET} ${target}
            if [ -e "${S}/${SOC_DIR}/flash.bin" ]; then
                cp ${S}/${SOC_DIR}/flash.bin ${S}/${BOOT_CONFIG_MACHINE}-${target}
            fi
        done
    fi
}

do_deploy_append () {
    install -m 0644 ${S}/${SOC_DIR}/u-boot.itb ${DEPLOYDIR}/${DEPLOYDIR_IMXBOOT}
    if [ "${OTA}" = "true" ];then 
        install -m 0644 ${S}/${SOC_DIR}/fbl.bin ${DEPLOYDIR}/${DEPLOYDIR_IMXBOOT}
    fi
}
