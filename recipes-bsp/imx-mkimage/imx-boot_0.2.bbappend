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

do_compile () {
    if [ "${SOC_TARGET}" = "iMX8M" -o "${SOC_TARGET}" = "iMX8MM" ]; then
        echo 8MQ/8MM boot binary build
        SOC_DIR="iMX8M"
        for ddr_firmware in ${DDR_FIRMWARE_NAME}; do
            echo "Copy ddr_firmware: ${ddr_firmware} from ${DEPLOY_DIR_IMAGE} -> ${S}/${SOC_DIR} "
            cp ${DEPLOY_DIR_IMAGE}/${ddr_firmware}               ${S}/${SOC_DIR}/
        done
        cp ${DEPLOY_DIR_IMAGE}/signed_*_imx8m.bin             ${S}/${SOC_DIR}/
        cp ${DEPLOY_DIR_IMAGE}/u-boot-spl.bin-${MACHINE}-${UBOOT_CONFIG} ${S}/${SOC_DIR}/u-boot-spl.bin
        cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/${UBOOT_DTB_NAME}   ${S}/${SOC_DIR}/
        cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/u-boot-nodtb.bin-${MACHINE}-${UBOOT_CONFIG}    ${S}/${SOC_DIR}/u-boot-nodtb.bin
        cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/mkimage_uboot       ${S}/${SOC_DIR}/
        
        if [ "${OTA}" = "true" ] && [ "${SOC_TARGET}" = "iMX8MM" ]; then
            cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/bl31-imx8mm.bin ${S}/${SOC_DIR}/bl31.bin
        else
            cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/${ATF_MACHINE_NAME} ${S}/${SOC_DIR}/bl31.bin
        fi
        cp ${DEPLOY_DIR_IMAGE}/${UBOOT_NAME}                     ${S}/${SOC_DIR}/u-boot.bin

    elif [ "${SOC_TARGET}" = "iMX8QM" ]; then
        echo 8QM boot binary build
        cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/${SC_FIRMWARE_NAME} ${S}/${SOC_DIR}/scfw_tcm.bin
        cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/${ATF_MACHINE_NAME} ${S}/${SOC_DIR}/bl31.bin
        cp ${DEPLOY_DIR_IMAGE}/${UBOOT_NAME}                     ${S}/${SOC_DIR}/u-boot.bin

        cp ${DEPLOY_DIR_IMAGE}/imx8qm_m4_0_TCM_rpmsg_lite_pingpong_rtos_linux_remote_m40.bin ${S}/${SOC_DIR}/m40_tcm.bin
        cp ${DEPLOY_DIR_IMAGE}/imx8qm_m4_1_TCM_rpmsg_lite_pingpong_rtos_linux_remote_m41.bin ${S}/${SOC_DIR}/m41_tcm.bin
        cp ${DEPLOY_DIR_IMAGE}/mx8qm-ahab-container.img ${S}/${SOC_DIR}/
    
    else
        echo 8QX boot binary build
        cp ${DEPLOY_DIR_IMAGE}/imx8qx_m4_TCM_srtm_demo.bin ${S}/${SOC_DIR}/m40_tcm.bin
        cp ${DEPLOY_DIR_IMAGE}/imx8qx_m4_TCM_srtm_demo.bin ${S}/${SOC_DIR}/CM4.bin
        cp ${DEPLOY_DIR_IMAGE}/mx8qx-ahab-container.img ${S}/${SOC_DIR}/
        cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/${SC_FIRMWARE_NAME} ${S}/${SOC_DIR}/scfw_tcm.bin
        cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/${ATF_MACHINE_NAME} ${S}/${SOC_DIR}/bl31.bin
        cp ${DEPLOY_DIR_IMAGE}/${UBOOT_NAME}                     ${S}/${SOC_DIR}/u-boot.bin
    fi

    # Copy TEE binary to SoC target folder to mkimage
    if ${DEPLOY_OPTEE}; then
        cp ${DEPLOY_DIR_IMAGE}/tee.bin             ${S}/${SOC_DIR}/
    fi

    # mkimage for i.MX8
    for target in ${IMXBOOT_TARGETS}; do
        echo "building ${SOC_TARGET} - ${target}"
        make SOC=${SOC_TARGET} ${target}
        if [ -e "${S}/${SOC_DIR}/flash.bin" ]; then
            cp ${S}/${SOC_DIR}/flash.bin ${S}/${BOOT_CONFIG_MACHINE}-${target}
        fi
    done
}



do_deploy_append () {
    install -m 0644 ${S}/${SOC_DIR}/u-boot.itb ${DEPLOYDIR}/${DEPLOYDIR_IMXBOOT}
    if [ "${OTA}" = "true" ];then 
        install -m 0644 ${S}/${SOC_DIR}/fbl.bin ${DEPLOYDIR}/${DEPLOYDIR_IMXBOOT}
    fi
}
