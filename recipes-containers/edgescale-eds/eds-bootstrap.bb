SUMMARY = "Edgescale eds bootstrap enroll Application"
HOMEPAGE = "https://github.com/nxp/qoriq-eds-bootstrap.git"
LICENSE = "NXP-EULA"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/EULA.txt;md5=ac5425aaed72fb427ef1113a88542f89"

GO_IMPORT = "github.com/NXP/qoriq-eds-bootstrap"
SRC_URI = "\
        git://${GO_IMPORT}.git;protocol=ssh;nobranch=1 \
        git://github.com/fullsailor/pkcs7.git;nobranch=1;destsuffix=git/src/github.com/fullsailor/pkcs7;name=pkcs7 \
        git://github.com/go-yaml/yaml.git;nobranch=1;destsuffix=git/src/gopkg.in/yaml.v2;name=yaml \
        git://github.com/laurentluce/est-client-go;nobranch=1;destsuffix=git/src/github.com/laurentluce/est-client-go;name=est-client-go \
        "
SRCREV = "57b5c1c3ac6d0b943d9a920c39684550518080e9"
SRCREV_pkcs7 = "8306686428a5fe132eac8cb7c4848af725098bd4"
SRCREV_yaml = "51d6538a90f86fe93ac480b35f37b2be17fef232"
SRCREV_est-client-go = "14471c0ce01a9b67577ff1eeb0241bced09d387f"

S = "${WORKDIR}/git"
inherit go
inherit goarch

do_compile() {
        export GOOS="${TARGET_GOOS}"
        export CGO_ENABLED="1"
        export CFLAGS=""
        export LDFLAGS=""
        export CGO_CFLAGS="${BUILDSDK_CFLAGS} --sysroot=${STAGING_DIR_TARGET}"
        export CGO_LDFLAGS="${BUILDSDK_LDFLAGS} --sysroot=${STAGING_DIR_TARGET}"

        export GOPATH="${S}"
        export GOROOT="${STAGING_LIBDIR_NATIVE}/${TARGET_SYS}/go"

        mkdir -p ${S}/import/vendor
        cp -rf ${S}/src/${GO_IMPORT}/* ${S}/import/vendor/

        cd ${S}/import/vendor
        if [ -n "${ES_DOMAIN_SUFFIX}" ]; then
            sed -i "s/edgescale.org/${ES_DOMAIN_SUFFIX}/g" config.yml
            sed -i "s#cmd :=.*#cmd := \"curl -f https://image.${ES_DOMAIN_SUFFIX}/CA/int.b-est.${ES_DOMAIN_SUFFIX}.rootCA.pem -o /tmp/rootCA.pem\"#" bootstrap-enroll.go
        fi

        export GOARCH="${BUILD_GOARCH}"
        go run parse_config.go

        export GOARCH="${TARGET_GOARCH}"
        go build --ldflags="-w -s" -buildmode=pie -o ${GOARCH}/bootstrap-enroll bootstrap-enroll.go config_tmp.go
}

do_install() {
        install -d ${D}/usr/local/edgescale/bin
        cp -r  ${S}/import/vendor/${TARGET_GOARCH}/* ${D}/usr/local/edgescale/bin
        chown -R root:root ${D}
}

INSANE_SKIP_${PN} += "already-stripped"
FILES_${PN} += "/usr/local/edgescale/bin/*"
