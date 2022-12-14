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

generate_qoriq_composite_firmware() {
    # generate machine-specific firmware to be programmed to NOR/SD media
    # $1: machine name
    # $2: boot type: sd, qspi, xspi, nor, nand
    # $3: bootloader type: uboot or uefi

    . $MACHINE.manifest
    . memorylayout.cfg
    fwimg=$DEPLOYDIR/firmware_${MACHINE}_uboot_${BOOTTYPE}boot
    fwimg2=$DEPLOYDIR/firmware_${MACHINE}_uboot_sdboot
    if [ -f $fwimg ]; then
        rm -f $fwimg
    fi
    if [ -f $fwimg2 ]; then
        rm -f $fwimg2
    fi
    #spl
    if [ "$spl" != "null" -a -n "$spl" ]; then
        dd if=$DEPLOYDIR/$spl of=$fwimg bs=1K seek=$sd_spl_offset
    fi
    # fbl
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
        if [ "$fbl" != "null" -a -n "$fbl" ]; then
            echo "fbl"
            dd if=$DEPLOYDIR/$fbl of=$fwimg bs=1K seek=$sd_fbl_offset
        fi
    fi
    if [ $BOOTTYPE = nor ]; then
        dd if=$DEPLOYDIR/$fbl of=$fwimg bs=1K seek=0 
    fi

    # u-boot_itb firmware
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
        if [ "$uboot_itb" != "null" -a -n "$uboot_itb" ]; then
            dd if=$DEPLOYDIR/$uboot_itb of=$fwimg bs=1K seek=$sd_uboot_itb_offset
        fi
    fi
    if [ $BOOTTYPE = nor ]; then
        val=`expr $(echo $(($nor_uboot_itb_offset))) / 1024`
        dd if=$DEPLOYDIR/$uboot_itb of=$fwimg bs=1K seek=$val
    fi

    # env
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
        if [ "$uboot_scr" != "null" -a -n "$uboot_scr" ]; then
            mkenvimage -s 0x1000 -o  $uboot_scr uboot-imx-env.txt
            cp $uboot_scr $DEPLOYDIR
            dd if=$DEPLOYDIR/$uboot_scr of=$fwimg bs=1K seek=$sd_bootloader_env_offset
        fi
        if [ "$uboot_dtb_scr2" != "null" -a -n "$uboot_dtb_scr2" ]; then
            mkenvimage -s 0x2000 -o  $uboot_dtb_scr2 uboot-imx-env2.txt
            cp $uboot_dtb_scr2  $DEPLOYDIR
            dd if=$DEPLOYDIR/$uboot_dtb_scr2 of=$fwimg bs=1K seek=$sd_uboot_dtb_env2_offset
        fi
    fi
    if [ $BOOTTYPE = nor ]; then
        val=`expr $(echo $(($nor_bootloader_env_offset))) / 1024`
        mkenvimage -s 0x1000 -o  $uboot_scr uboot-imx-env.txt
        cp $uboot_scr  $DEPLOYDIR
        dd if=$DEPLOYDIR/$uboot_scr of=$fwimg bs=1K seek=$val
    fi
    #  uboot dtb
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
        if [ "$uboot_dtb" != "null" -a -n "$uboot_dtb" ]; then
            dd if=$DEPLOYDIR/$uboot_dtb of=$fwimg bs=1K seek=$sd_uboot_dtb_offset
        fi
    fi

    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
        if [ "$uboot_scr2" != "null" -a -n "$uboot_scr2" ]; then
            mkenvimage -s 0x1000 -o  $uboot_scr2 uboot-imx-env2.txt
            cp $uboot_scr2  $DEPLOYDIR
            dd if=$DEPLOYDIR/$uboot_scr2 of=$fwimg bs=1K seek=$sd_bootloader_env2_offset
        fi
        if [ "$uboot_dtb_scr" != "null" -a -n "$uboot_dtb_scr" ]; then
            mkenvimage -s 0x2000 -o  $uboot_dtb_scr uboot-imx-env.txt
            cp $uboot_dtb_scr  $DEPLOYDIR
            dd if=$DEPLOYDIR/$uboot_dtb_scr of=$fwimg bs=1K seek=$sd_uboot_dtb_env_offset
        fi
    fi
    if [ $BOOTTYPE = nor ]; then
        val=`expr $(echo $(($nor_bootloader_env2_offset))) / 1024`
        mkenvimage -s 0x1000 -o  $uboot_scr2 uboot-imx-env2.txt
        cp $uboot_scr2  $DEPLOYDIR
        dd if=$DEPLOYDIR/$uboot_scr2 of=$fwimg bs=1K seek=$val
        dd if=$DEPLOYDIR/$uboot_scr2 of=$fwimg2 bs=1K seek=$sd_bootloader_env2_offset
    fi
    
     
    # dtb
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
        dd if=$DEPLOYDIR/$device_tree of=$fwimg bs=1K seek=$sd_dtb_offset
    fi
    if [ $BOOTTYPE = nor ]; then
        dd if=$DEPLOYDIR/$device_tree of=$fwimg2 bs=1K seek=$sd_dtb_offset
    fi
    # linux kernel image
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
        dd if=$DEPLOYDIR/${kernel_img} of=$fwimg bs=1K seek=$sd_kernel_offset
    fi
    if [ $BOOTTYPE = nor ]; then
        dd if=$DEPLOYDIR/${kernel_img} of=$fwimg2 bs=1K seek=$sd_kernel_offset
    fi

    # rootfs image
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
        dd if=$DEPLOYDIR/${rootfs} of=$fwimg bs=1K seek=$sd_rootfs_offset
    fi
    if [ $BOOTTYPE = nor ]; then
        dd if=$DEPLOYDIR/${rootfs} of=$fwimg2 bs=1K seek=$sd_rootfs_offset
    fi
   
    if [ $BOOTTYPE = sd -o $BOOTTYPE = emmc ]; then
        tail -c +0 $fwimg > $fwimg.img && rm $fwimg
    fi
    if [ $BOOTTYPE = nor ]; then
        tail -c +0 $fwimg2 > $fwimg2.img && rm $fwimg2
        mv $fwimg $fwimg.img
    fi     

    echo -e "${GREEN} $fwimg.img   [Done]\n${NC}"

}

generate_qoriq_composite_firmware $MACHINE $BOOTTYPE
