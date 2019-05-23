DESCRIPTION = "Merge prebuilt/extra files into rootfs"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit systemd

SRC_URI = "file://merge"
SRC_URI_append = " file://eds-init.service"
S = "${WORKDIR}"

SYSTEMD_SERVICE_${PN} = "eds-init.service"

MERGED_DST ?= "${bindir}"
do_install () {
    install -d ${D}/${MERGED_DST}
    install -D -p -m0644 ${WORKDIR}/eds-init.service ${D}${systemd_system_unitdir}/eds-init.service
    install -m 0755    ${WORKDIR}/merge/eds-init  ${D}/usr/bin    
    find ${WORKDIR}/merge/ -maxdepth 1 -mindepth 1 -not -name README \
    -exec install -m 0755  '{}' ${D}/${MERGED_DST}/ \;
    find ${WORKDIR}/merge/ -maxdepth 1 -mindepth 1 -exec rm -fr '{}' \;
}
do_unpack[nostamp] = "1"
do_install[nostamp] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

FILES_${PN} = "/*"
ALLOW_EMPTY_${PN} = "1"
INSANE_SKIP_${PN} = "debug-files dev-so already-stripped file-rdeps"
