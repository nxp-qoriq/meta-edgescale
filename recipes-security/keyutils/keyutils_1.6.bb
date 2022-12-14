SUMMARY = "Linux Key Management Utilities"
DESCRIPTION = "\
    Utilities to control the kernel key management facility and to provide \
    a mechanism by which the kernel call back to userspace to get a key \
    instantiated. \
    "
HOMEPAGE = "http://people.redhat.com/dhowells/keyutils"
SECTION = "base"

LICENSE = "LGPLv2.1+ & GPLv2.0+"

LIC_FILES_CHKSUM = "file://LICENCE.GPL;md5=5f6e72824f5da505c1f4a7197f004b45 \
                    file://LICENCE.LGPL;md5=7d1cacaa3ea752b72ea5e525df54a21f"


inherit siteinfo ptest

SRC_URI = "http://people.redhat.com/dhowells/keyutils/${BP}.tar.bz2 \
           file://keyutils-test-fix-output-format.patch \
           file://keyutils-fix-error-report-by-adding-default-message.patch \
           file://run-ptest \
           "

SRC_URI[md5sum] = "191987b0ab46bb5b50efd70a6e6ce808"
SRC_URI[sha256sum] = "d3aef20cec0005c0fa6b4be40079885567473185b1a57b629b030e67942c7115"

EXTRA_OEMAKE = "'CFLAGS=${CFLAGS} -Wall' \
    NO_ARLIB=1 \
    BINDIR=${base_bindir} \
    SBINDIR=${base_sbindir} \
    LIBDIR=${base_libdir} \
    USRLIBDIR=${base_libdir} \
    BUILDFOR=${SITEINFO_BITS}-bit \
    NO_GLIBC_KEYERR=1 \
    "

do_install () {
    install -d ${D}/${nonarch_base_libdir}/pkgconfig
    oe_runmake DESTDIR=${D} install
}

do_install_ptest () {
    cp -r ${S}/tests ${D}${PTEST_PATH}/
    sed -i -e 's/OSDIST=Unknown/OSDIST=${DISTRO}/' ${D}${PTEST_PATH}/tests/prepare.inc.sh
}

FILES_${PN}-dev += "${nonarch_base_libdir}/pkgconfig/libkeyutils.pc"
FILES_${PN} += "/lib/pkgconfig/*.pc"
RDEPENDS_${PN}-ptest += "lsb"
RDEPENDS_${PN}-ptest_append_libc-glibc = " glibc-utils"
RDEPENDS_${PN}-ptest_append_libc-musl = " musl-utils"
