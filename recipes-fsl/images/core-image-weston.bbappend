IMAGE_INSTALL_append = " docker docker-registry edgescale-eds eds-bootstrap eds-kubelet"
IMAGE_INSTALL_append = " ethtool dhcp-client curl"

IMAGE_ROOTFS_ALIGNMENT = "65536"
IMAGE_ROOTFS_EXTRA_SPACE = "5048000"

IMAGE_FSTYPES += "tar.gz"
