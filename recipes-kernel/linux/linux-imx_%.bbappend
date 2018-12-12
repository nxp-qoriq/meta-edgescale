FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://docker.cfg \
            file://eds.cfg \
	"

DELTA_KERNEL_DEFCONFIG ?= ""
DELTA_KERNEL_DEFCONFIG_prepend_mx6 = "eds.cfg docker.cfg"
DELTA_KERNEL_DEFCONFIG_prepend_mx7 = "eds.cfg docker.cfg"

do_merge_delta_config[dirs] = "${B}"

do_merge_delta_config() {
    config="${B}/.config"

    # Merge config fragments
    for deltacfg in ${DELTA_KERNEL_DEFCONFIG}; do
        if [ -f ${S}/arch/${ARCH}/configs/${deltacfg} ]; then
            oe_runmake  -C ${S} O=${B} ${deltacfg}
        elif [ -f "${WORKDIR}/${deltacfg}" ]; then
            ${S}/scripts/kconfig/merge_config.sh -r -m $config ${WORKDIR}/${deltacfg}
        elif [ -f "${deltacfg}" ]; then
            ${S}/scripts/kconfig/merge_config.sh -m $config ${deltacfg}
        fi
    done
    cp $config ${WORKDIR}/defconfig
}
addtask merge_delta_config before do_preconfigure after do_copy_defconfig
