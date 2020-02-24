BUILD_SIG = "${@bb.utils.contains('DISTRO_FEATURES', 'singleboot', 'true', 'false', d)}"
#BUILD_OTA = "${@bb.utils.contains('DISTRO_FEATURES', 'edgescale', 'true', 'false', d)}"
do_compile_prepend() {
    if [ "${BUILD_SIG}" = "true" ]; then
        otaopt="POLICY_OTA=1"
        btype="${OTABOOTTYPE}"
    fi
}
