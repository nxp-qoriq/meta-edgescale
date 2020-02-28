BUILD_SIG = "${@bb.utils.contains('DISTRO_FEATURES', 'singleboot', 'true', 'false', d)}"
#BUILD_OTA = "${@bb.utils.contains('DISTRO_FEATURES', 'edgescale', 'true', 'false', d)}"
BOOTTYPE = "${@bb.utils.contains('DISTRO_FEATURES', 'singleboot', 'nor qspi flexspi_nor', 'nor nand qspi flexspi_nor sd emmc', d)}"
do_compile_prepend() {
    if [ "${BUILD_SIG}" = "true" ]; then
        otaopt="POLICY_OTA=1"
        btype="${BOOTTYPE}"
    fi
}
