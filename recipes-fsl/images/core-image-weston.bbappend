IMAGE_INSTALL_append = " docker docker-registry edgescale-eds eds-bootstrap eds-kubelet edgescale-eds-solution"
IMAGE_INSTALL_append = " ethtool dhcpcd curl e2fsprogs-mke2fs e2fsprogs"

IMAGE_ROOTFS_ALIGNMENT = "65536"
IMAGE_ROOTFS_EXTRA_SPACE = "5048000"

IMAGE_FSTYPES += " tar.gz"
IMAGE_FSTYPES_mx8mm = "tar.gz"
