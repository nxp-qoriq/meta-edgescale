# Copyright 2020 NXP
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Add packages for edgescale build"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "${PN}"

EDS_PKGS = " \
    docker docker-registry edgescale-eds eds-bootstrap eds-kubelet edgescale-eds-solution \
    ethtool dhcpcd curl \
    e2fsprogs-e2fsck e2fsprogs-mke2fs e2fsprogs \
"
RDEPENDS_${PN} = " \
    ${EDS_PKGS} \
"
