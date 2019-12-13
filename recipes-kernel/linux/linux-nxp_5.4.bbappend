FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " file://ima-evm.config"
SRC_URI_append = " file://edgescale_demo_kernel.config"
SRC_URI_append = " file://0001-lsdk.config-fix-issue-for-unset-ramdisk-size-in-LSDK.patch \
"

DELTA_KERNEL_DEFCONFIG = "${@bb.utils.contains('DISTRO_FEATURES', 'ima-evm', 'ima-evm.config', '', d)}"
#DELTA_KERNEL_DEFCONFIG = "${@bb.utils.contains('DISTRO_FEATURES', 'singleboot', 'edgescale_demo_kernel.config', '', d)}"
