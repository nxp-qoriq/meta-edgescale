SUMMARY = "EDGESCALE-EDS is a set of software agents running on device side which connects to cloud"
HOMEPAGE = "https://github.com/NXP/qoriq-edgescale-eds.git"
LICENSE = "NXP-EULA"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/EULA.txt;md5=ac5425aaed72fb427ef1113a88542f89"


SRC_URI = "\
        git://${GO_IMPORT}.git;protocol=ssh;nobranch=1 \
        git://github.com/golang/sys;nobranch=1;destsuffix=git/src/golang.org/x/sys;name=sys \
        git://github.com/golang/crypto;nobranch=1;destsuffix=git/src/golang.org/x/crypto;name=crypto \
        git://github.com/golang/net;nobranch=1;destsuffix=git/src/golang.org/x/net;name=net \
        git://github.com/sirupsen/logrus;nobranch=1;destsuffix=git/src/github.com/sirupsen/logrus;name=logrus \
        git://github.com/sigma/systemstat;nobranch=1;destsuffix=git/src/github.com/sigma/systemstat;name=systemstat \
        git://github.com/eclipse/paho.mqtt.golang;nobranch=1;destsuffix=git/src/github.com/eclipse/paho.mqtt.golang;name=mqtt \
        git://github.com/fullsailor/pkcs7.git;nobranch=1;destsuffix=git/src/github.com/fullsailor/pkcs7;name=pkcs7 \
        git://github.com/shirou/gopsutil.git;nobranch=1;destsuffix=git/src/github.com/shirou/gopsutil;name=disk \
        git://github.com/go-yaml/yaml.git;nobranch=1;destsuffix=git/src/gopkg.in/yaml.v2;name=yaml \
        git://github.com/joho/godotenv;nobranch=1;destsuffix=git/src/github.com/joho/godotenv;name=godotenv \
        git://github.com/edgeiot/est-client-go;nobranch=1;destsuffix=git/src/github.com/edgeiot/est-client-go;name=est-client-go \
"       
SRC_URI_append_imx = "  file://0001-imx-ota-support.patch \
"
SRC_URI_append_qoriq = "  file://0001-fix-solution.patch \
"
SRCREV = "72dc0afa0a7f90ddd091d43953634c6f94e8728f"
SRCREV_sys = "cb59ee3660675d463e86971646692ea3e470021c"
SRCREV_crypto = "ff983b9c42bc9fbf91556e191cc8efb585c16908"
SRCREV_net = "927f97764cc334a6575f4b7a1584a147864d5723"
SRCREV_logrus = "dae0fa8d5b0c810a8ab733fbd5510c7cae84eca4"
SRCREV_systemstat = "0eeff89b0690611fc32e21f0cd2e4434abf8fe53"
SRCREV_mqtt = "379fd9f99ba5b1f02c9fffb5e5952416ef9301dc"
SRCREV_pkcs7 = "8306686428a5fe132eac8cb7c4848af725098bd4"
SRCREV_disk = "eead265362a2c459593fc24d74aef92858d67835"
SRCREV_yaml = "51d6538a90f86fe93ac480b35f37b2be17fef232"
SRCREV_godotenv = "5c0e6c6ab1a0a9ef0a8822cba3a05d62f7dad941"
SRCREV_est-client-go = "a9d72263246dfcac6e90971c8ce51c2ef99295a6"

DEPENDS = "\
           openssl \
          "
RDEPENDS_${PN} += " \
          eds-bootstrap \
"
PACKAGECONFIG ??= " \
    ${@bb.utils.filter('DISTRO_FEATURES', 'secure', d)} \
    ${@bb.utils.filter('COMBINED_FEATURES', 'optee', d)} \
"
PACKAGECONFIG[secure] = ",,secure-obj,secure-obj-module"
PACKAGECONFIG[optee] = ",,optee-client-qoriq"

GO_IMPORT = "github.com/NXP/qoriq-edgescale-eds"

S = "${WORKDIR}/git"
inherit go
inherit goarch

# This disables seccomp and apparmor, which are on by default in the
# go package. 
WRAP_TARGET_PREFIX ?= "${TARGET_PREFIX}"
export GOBUILDTAGS = "${@bb.utils.contains('DISTRO_FEATURES', 'edgescale-optee', 'secure', 'default', d)}"
export CROSS_COMPILE="${WRAP_TARGET_PREFIX}"
export OPENSSL_PATH="${RECIPE_SYSROOT}/usr"
export SECURE_OBJ_PATH="${RECIPE_SYSROOT}/usr"
export OPTEE_CLIENT_EXPORT="${RECIPE_SYSROOT}/usr/"

EDS = "${@bb.utils.contains('DISTRO_FEATURES', 'edgescale', 'true', 'false', d)}"

do_compile() {
        export GOARCH="${TARGET_GOARCH}"
        export CGO_ENABLED="1"
        export CFLAGS=""
        export LDFLAGS=""
        export CGO_CFLAGS="${BUILDSDK_CFLAGS} -I${SECURE_OBJ_PATH}/include -I${OPENSSL_PATH}/include --sysroot=${STAGING_DIR_TARGET}"
        export CGO_LDFLAGS="${BUILDSDK_LDFLAGS} -L${SECURE_OBJ_PATH}/lib -L${OPENSSL_PATH}/lib -L${OPTEE_CLIENT_EXPORT} --sysroot=${STAGING_DIR_TARGET}"

        rm -rf ${S}/import/vendor/cert-agent
        mkdir -p ${S}/import/vendor/
        cp -rf ${S}/src/${GO_IMPORT}/cert-agent ${S}/import/vendor/
        cp -rf ${S}/src/${GO_IMPORT}/mq-agent  ${S}/import/vendor/
        cp -rf ${S}/src/${GO_IMPORT}/watchdog  ${S}/import/vendor/
        cd ${S}/import/vendor/cert-agent
        ${GO} build --ldflags="-w -s" --tags "${GOBUILDTAGS}"
        cd ${S}/import/vendor/mq-agent
        ${GO} build --ldflags="-w -s" --tags "${GOBUILDTAGS}" 
        cd ${S}/import/vendor/watchdog
        ${GO} build --ldflags="-w -s"  -o es-watchdog 
}

do_install() {
        install -d ${D}/${sysconfdir}
        install -d ${D}/${includedir}/cert-agent
        install -d ${D}/usr/local/edgescale/bin
        install -d ${D}/usr/local/edgescale/conf

        if [ -n "${ES_CERTIFICATE_PATH}" ]; then
          install -d ${D}/usr/local/share/ca-certificates
          cp -fr ${ES_CERTIFICATE_PATH}/* ${D}/usr/local/share/ca-certificates
        fi

        cp -r ${S}/import/vendor/cert-agent/cert-agent ${D}/usr/local/edgescale/bin
        cp -r ${S}/import/vendor/watchdog/es-watchdog  ${D}/usr/local/edgescale/bin
        cp -r ${S}/import/vendor/cert-agent/pkg ${D}/${includedir}/cert-agent/
        cp -r ${S}/src/${GO_IMPORT}/etc/edgescale-version ${D}/usr/local/edgescale/conf
        cp -r ${S}/src/${GO_IMPORT}/etc/config.yml ${D}/usr/local/edgescale/conf

        if [ -n "${ES_DOMAIN_SUFFIX}" ]; then
          sed -i "s,api.*,api: https://api.${ES_DOMAIN_SUFFIX}/v1," ${D}/usr/local/edgescale/conf/config.yml
        fi
}

do_install_append_qoriq() {
    if [ "${EDS}" = "true" ];then
        cp -r ${S}/import/vendor/mq-agent/mq-agent ${D}/usr/local/edgescale/bin
        cp -r ${S}/src/${GO_IMPORT}/startup/*.sh ${D}/usr/local/edgescale/bin
        cp -r ${S}/src/${GO_IMPORT}/startup/ota-* ${D}/usr/local/edgescale/bin
        sed -i "s:/bin/tee-supplicant:/usr/bin/tee-supplicant:" ${D}/usr/local/edgescale/bin/startup.sh
        sed -i -e '/es-watchdog/d' ${D}/usr/local/edgescale/bin/startup.sh
    fi
}

do_install_append_imx() {
    cp -r ${S}/import/vendor/mq-agent/mq-agent ${D}/usr/local/edgescale/bin
    cp -r ${S}/src/${GO_IMPORT}/startup/*.sh ${D}/usr/local/edgescale/bin
    cp -r ${S}/src/${GO_IMPORT}/startup/ota-* ${D}/usr/local/edgescale/bin
    sed -i "s:/bin/tee-supplicant:/usr/bin/tee-supplicant:" ${D}/usr/local/edgescale/bin/startup.sh
    sed -i -e '/es-watchdog/d' ${D}/usr/local/edgescale/bin/startup.sh
}

do_install_append_mx6() { 
   sed -i "s:/dev/mmcblk1:/dev/mmcblk2:" ${D}/usr/local/edgescale/bin/startup.sh  
   sed -i "s:./mmc-check.sh:#./mmc-check.sh:" ${D}/usr/local/edgescale/bin/startup.sh
   sed -i "s:/dev/mmcblk1:/dev/mmcblk2:" ${D}/usr/local/edgescale/bin/ota-statuscheck
   sed -i "s:/dev/mmcblk1:/dev/mmcblk2:" ${D}/usr/local/edgescale/bin/ota-updateSet
   sed -i "s:/run/media/mmcblk1p3:/run/media/mmcblk2p3:" ${D}/usr/local/edgescale/bin/ota-updateSet
   sed -i "s:/dev/mmcblk1p3:/dev/mmcblk2p3:" ${D}/usr/local/edgescale/bin/ota-updateSet
}

FILES_${PN} += "${includedir}/* /usr/local/*"
INSANE_SKIP_${PN} += "already-stripped dev-deps file-rdeps"
deltask compile_ptest_base
