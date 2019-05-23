#!/bin/bash

# BSD LICENSE
#
# Copyright 2019 NXP
#
#

Usage()
{
    echo "Usage: $0 -m MACHINE  -t BOOTTYPE -d TOPDIR -s DEPLOYDIR -e ENCAP -i IMA_EVM\

        -m        machine name
        -t        boottype
        -d        topdir
        -s        deploy dir
        -e        encap
        -i        ima-evm
"
    exit
}

# get command options
while getopts "m:t:d:s:e:i:" flag
do
        case $flag in
                m) MACHINE="$OPTARG";
                   echo "machine: $MACHINE";
                   ;;
                t) BOOTTYPE="$OPTARG";
                   echo "secure boot type: $BOOTTYPE";
                   ;;
                d) TOPDIR="$OPTARG";
                   echo "top dir : $TOPDIR";
                   ;;
                s) DEPLOYDIR="$OPTARG";
                   echo "deploy dir : $DEPLOYDIR";
                   ;;
                e) ENCAP="$OPTARG";
                   echo "encap : $ENCAP";
                   ;;
                i) IMA_EVM="$OPTARG";
                   echo "ima_evm : $IMA_EVM";
                   ;;
                ?) Usage;
                   exit 3
                   ;;
        esac
done

generate_distro_bootscr() {
    if [ "$ENCAP" = "true" ] ; then
        KEY_ID=0x12345678123456781234567812345678
        key_id_1=${KEY_ID:2:8}
        key_id_2=${KEY_ID:10:8}
        key_id_3=${KEY_ID:18:8}
        key_id_4=${KEY_ID:26:8}
    fi
    . $MACHINE.manifest
    if [ -n "$uboot_scr" -a "$uboot_scr" != "null" ] ; then
        if [ -n "$securevalidate" ]; then
            if [ "$ENCAP" = "true" ] ; then
                if [ $bootscript_dec != null ] ; then
                    echo $securevalidate_dec > $bootscript_dec.tmp
                    if [ $MACHINE = ls1043ardb -o $MACHINE = ls1046ardb ]; then
                        echo $distroboot | sed 's/vmlinuz/vmlinuz.v8/g' >> $bootscript_dec.tmp
                    else
                        echo $distroboot >> $bootscript_dec.tmp
                    fi
                mkimage -A arm64 -O linux -T script -C none -a 0 -e 0  -n "boot.scr" -d $bootscript_dec.tmp $bootscript_dec
                rm -f $bootscript_dec.tmp
                fi
                echo $securevalidate_enc > $uboot_scr.tmp
            elif [ "$IMA_EVM" = "true" ] ; then
                 if [ $bootscript_enforce != null ] ; then
                     echo $securevalidate_enforce > $bootscript_enforce.tmp
                     echo $distroboot_ima >> $bootscript_enforce.tmp
                     mkimage -A arm64 -O linux -T script -C none -a 0 -e 0  -n "boot.scr" \
                             -d $bootscript_enforce.tmp $bootscript_enforce
                     rm -f $FBDIR/$bootscript_enforce.tmp
                 fi
                 echo $securevalidate_fix > $uboot_scr.tmp
            else
                echo $securevalidate > $uboot_scr.tmp
            fi
        fi
        if [ "$IMA_EVM" = "true" ] ; then
                echo $distroboot_ima >> $uboot_scr.tmp
        else
                echo $distroboot >> $uboot_scr.tmp
        fi

        #mkimage -A arm64 -O linux -T script -C none -a 0 -e 0  -n "boot.scr" -d $uboot_scr.tmp $uboot_scr
        mkenvimage -s 0x1000 -o  $uboot_scr uboot-imx-env.txt
        mkenvimage -s 0x1000 -o  $uboot_scr2 uboot-imx-env2.txt
        rm -f $uboot_scr.tmp
        echo -e "$uboot_scr    [Done]\n"
    fi
}

generate_qoriq_composite_firmware() {
    # generate machine-specific firmware to be programmed to NOR/SD media
    # $1: machine name
    # $2: boot type: sd, qspi, xspi, nor, nand
    # $3: bootloader type: uboot or uefi

    . $MACHINE.manifest
    . memorylayout.cfg
    fwimg=$DEPLOYDIR/firmware_${MACHINE}_uboot_${BOOTTYPE}boot
    if [ -f $fwimg ]; then
        rm -f $fwimg
    fi
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
        dd if=$DEPLOYDIR/$fbl of=$fwimg bs=1K seek=$sd_fbl_offset
    fi

    # u-boot_itb firmware
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
            dd if=$DEPLOYDIR/$uboot_itb of=$fwimg bs=1K seek=$sd_uboot_itb_offset
    fi
    # env
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
            dd if=$DEPLOYDIR/$uboot_scr of=$fwimg bs=1K seek=$sd_bootloader_env_offset
    fi
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
            dd if=$DEPLOYDIR/$uboot_scr2 of=$fwimg bs=1K seek=$sd_bootloader_env2_offset
    fi
    # dtb
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
            dd if=$DEPLOYDIR/$device_tree of=$fwimg bs=1K seek=$sd_dtb_offset
    fi

    # linux kernel image
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
        dd if=$DEPLOYDIR/${kernel_img} of=$fwimg bs=1K seek=$sd_kernel_offset
    fi
    # rootfs image
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
        dd if=$DEPLOYDIR/${rootfs} of=$fwimg bs=1K seek=$sd_rootfs_offset
    fi

   
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
        tail -c +4097 $fwimg > $fwimg.img && rm $fwimg
    else
        mv $fwimg $fwimg.img
    fi
    echo -e "${GREEN} $fwimg.img   [Done]\n${NC}"

}

generate_distro_bootscr $MACHINE
generate_qoriq_composite_firmware $MACHINE $BOOTTYPE
