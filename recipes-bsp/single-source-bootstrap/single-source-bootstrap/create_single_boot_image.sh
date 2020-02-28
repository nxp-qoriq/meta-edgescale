#!/bin/bash

# BSD LICENSE
#
# Copyright 2017~2019 NXP
#
#

Usage()
{
    echo "Usage: $0 -m MACHINE  -t BOOTTYPE -d TOPDIR -s DEPLOYDIR -e ENCAP -i IMA_EVM -o SECURE -f MFT\

        -m        machine name
        -t        boottype
        -d        topdir
        -s        deploy dir
        -e        encap
        -i        ima-evm
        -o        secure
        -f        mft
"
    exit
}

# get command options
while getopts "m:t:d:s:e:i:o:f:" flag
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
                o) SECURE="$OPTARG";
                   echo "secure : $SECURE";
                   ;;
                f) MFT="$OPTARG";
                   echo "mft : $MFT";
                   ;;
                ?) Usage;
                   exit 3
                   ;;
        esac
done

secure_sign_image() {
    
    echo "Signing $2boot images for $1 ..."
    if [ "$ENCAP" = "true" ]; then
        cp $TOPDIR/$bootscript_dec $TOPDIR/bootscript_dec && echo "Copying bootscript_decap"
    fi

    cp $TOPDIR/$uboot_scr $TOPDIR/bootscript && echo "Copying bootscript"
    cp $DEPLOYDIR/$device_tree $TOPDIR/uImage.dtb && echo "Copying dtb"
    cp $DEPLOYDIR/$kernel_img $TOPDIR/uImage.bin && echo "Copying kernel"
    cp $DEPLOYDIR/$kernel_itb $TOPDIR/kernel.itb && echo "Copying kernel_itb"
    rcwimg_sec=`eval echo '${'"rcw_""$BOOTTYPE"'_sec}'`
    rcwimg_nonsec=`eval echo '${'"rcw_""$BOOTTYPE"'}'`


    if [ -f $DEPLOYDIR/$pfe_fw ] ; then
        cp $DEPLOYDIR/$pfe_fw $TOPDIR/pfe.itb && echo "Copying PFE"
    fi
     
    if [ -f $DEPLOYDIR/$dpaa2_mc_fw ] ; then
        cp $DEPLOYDIR/$dpaa2_mc_fw $TOPDIR/mc.itb
    fi

    if [ -f $DEPLOYDIR/$dpaa2_mc_dpc ] ; then
        cp $DEPLOYDIR/$dpaa2_mc_dpc $TOPDIR/dpc.dtb
    fi

    if [ -f $DEPLOYDIR/$dpaa2_mc_dpl ] ; then
        cp $DEPLOYDIR/$dpaa2_mc_dpl $TOPDIR/dpl.dtb
    fi

    if [ ! -d  $DEPLOYDIR/secboot_hdrs/ ] ; then
        mkdir -p  $DEPLOYDIR/secboot_hdrs/
    fi
    if [ "$BOOTTYPE" = "nand" ] ; then
        . $nand_script
    elif [ "$BOOTTYPE" = "sd" ] ; then
        . $sd_script
    elif [ "$BOOTTYPE" = "nor" ] ; then
        . $nor_script
    elif [ "$BOOTTYPE" = "qspi" ] ; then
        . $qspi_script
    elif [ "$BOOTTYPE" = "xspi" ] ; then
        . $xspi_script
    fi


    #cp $TOPDIR/secboot_hdrs_${BOOTTYPE}boot.bin $DEPLOYDIR/secboot_hdrs/
    if [  "$MACHINE"  = "ls1028ardb" ] ; then
          cp $TOPDIR/secboot_hdrs.bin $DEPLOYDIR/secboot_hdrs/secboot_hdrs_${BOOTTYPE}boot.bin
    else
          cp $TOPDIR/secboot_hdrs_${BOOTTYPE}boot.bin $DEPLOYDIR/secboot_hdrs/
    fi
    cp $TOPDIR/hdr_dtb.out $DEPLOYDIR/secboot_hdrs/
    cp $TOPDIR/hdr_linux.out $DEPLOYDIR/secboot_hdrs/
    if [  "$MACHINE"  = "ls1012afrwy" ] ; then
        cp $TOPDIR/hdr_kernel.out $DEPLOYDIR/secboot_hdrs/
    fi
    cp $TOPDIR/hdr_bs.out $DEPLOYDIR/secboot_hdrs/hdr_${1}_bs.out
    cp $TOPDIR/srk_hash.txt $DEPLOYDIR/
    cp $TOPDIR/srk.pri $DEPLOYDIR/
    cp $TOPDIR/srk.pub $DEPLOYDIR/
    if [ "$ENCAP" = "true" ]; then
        cp $TOPDIR/hdr_bs_dec.out $DEPLOYDIR/secboot_hdrs/hdr_${1}_bs_dec.out
    fi
}


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
                if [ "$bootscript_dec" != "null" ] ; then
                    echo $securevalidate_dec > $bootscript_dec.tmp
                    if [ "$MACHINE" = "ls1043ardb" -o "$MACHINE" = "ls1046ardb" ]; then
                        echo $distroboot | sed 's/vmlinuz/vmlinuz.v8/g' >> $bootscript_dec.tmp
                    else
                        echo $distroboot >> $bootscript_dec.tmp
                    fi
                mkimage -A arm64 -O linux -T script -C none -a 0 -e 0  -n "boot.scr" -d $bootscript_dec.tmp $bootscript_dec
                rm -f $bootscript_dec.tmp
                fi
                echo $securevalidate_enc > $uboot_scr.tmp
            elif [ "$IMA_EVM" = "true" ] ; then
                 if [ "$bootscript_enforce" != "null" ] ; then
                     echo $securevalidate_enforce > $bootscript_enforce.tmp
                     echo $distroboot_ima >> $bootscript_enforce.tmp
                     mkimage -A arm64 -O linux -T script -C none -a 0 -e 0  -n "boot.scr" \
                             -d $bootscript_enforce.tmp $bootscript_enforce
                     rm -f $DEPLOYDIR/$bootscript_enforce.tmp
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

        mkimage -A arm64 -O linux -T script -C none -a 0 -e 0  -n "boot.scr" -d $uboot_scr.tmp $uboot_scr
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
    if [ "$SECURE" = "true" ]; then
      fwimg=$DEPLOYDIR/firmware_${MACHINE}_uboot_${BOOTTYPE}boot_secure
      rcwimg=`eval echo '${'"rcw_""$BOOTTYPE"'_sec}'`
      bootloaderimg=`eval echo '${'"uboot"'_'"$BOOTTYPE"'boot_sec}'`
      bl2img=`eval echo '${'"atf_bl2_""$BOOTTYPE"'_sec}'`
      fipimg=`eval echo '${'"atf_fip_""uboot"'_sec}'`
    elif [ "$MFT" = "true" ]; then
      fwimg=$DEPLOYDIR/firmware_${MACHINE}_uboot_${BOOTTYPE}boot_mft
      rcwimg=`eval echo '${'"rcw_""$BOOTTYPE"'}'`
      bootloaderimg=`eval echo '${'"uboot"'_'"$BOOTTYPE"'boot}'`
      bl2img=`eval echo '${'"atf_bl2_""$BOOTTYPE"'}'`
      fipimg=`eval echo '${'"atf_fip_""uboot"'}'`
    else
      fwimg=$DEPLOYDIR/firmware_${MACHINE}_uboot_${BOOTTYPE}boot
      rcwimg=`eval echo '${'"rcw_""$BOOTTYPE"'}'`
      bootloaderimg=`eval echo '${'"uboot"'_'"$BOOTTYPE"'boot}'`
      bl2img=`eval echo '${'"atf_bl2_""$BOOTTYPE"'}'`
      fipimg=`eval echo '${'"atf_fip_""uboot"'}'`
    fi
    if [ -f $fwimg ]; then
        rm -f $fwimg
    fi
    secureboot_headers=`eval echo '${'"secureboot_headers_""$BOOTTYPE"'}'`
    # ATF BL2 image
    if [ "$MACHINE" = "ls1012afrwy" ]; then
	    if [ "$2" = "sd" -o "$2" = "emmc" ]; then
		    dd if=$DEPLOYDIR/$bl2img of=$fwimg bs=512 seek=$sd2_rcw_offset
	    else
		    dd if=$DEPLOYDIR/$bl2img of=$fwimg bs=1K seek=0
		    cp -r $DEPLOYDIR/$bl2img $DEPLOYDIR/bl2_${BOOTTYPE}_${MACHINE}.pbl
	    fi
    else
	    if [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
		    dd if=$DEPLOYDIR/$bl2img of=$fwimg bs=512 seek=$sd_rcw_bootloader_offset
	    else
		    dd if=$DEPLOYDIR/$bl2img of=$fwimg bs=1K seek=0
		    echo $DEPLOYDIR/$bl2img
		    cp -r $DEPLOYDIR/$bl2img $DEPLOYDIR/bl2_${BOOTTYPE}_${MACHINE}.pbl
	    fi
    fi
	
    # Program Ethernet firmware,  e.g. PFE on LS1012A-FRWY
    if [ "$MACHINE" = "ls1012afrwy" ]; then
	    if [ "$pfe_fw" != "null" -a -n "$pfe_fw" ]; then
		    if [ "$2" = "nor" -o "$2" = "qspi" -o "$2" = "xspi" -o "$2" = "nand" ]; then
			    val=`expr $(echo $(($nor2_eth_firmware_offset))) / 1024`
			    dd if=$DEPLOYDIR/$pfe_fw of=$fwimg bs=1K seek=$val
		    elif [ "$2" = "sd" -o "$2" = "emmc" ]; then
			    dd if=$DEPLOYDIR/$pfe_fw of=$fwimg bs=512 seek=$sd2_eth_firmware_offset
		    fi
	    fi
    fi
    # ATF FIP image
    if [ "$MACHINE" = "ls1012afrwy" ]; then
	    dd if=$DEPLOYDIR/$fipimg of=$fwimg bs=1k seek=384
    else
	    if [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
		    dd if=$DEPLOYDIR/$fipimg of=$fwimg bs=512 seek=$sd_bootloader_offset
	    else
		    val=`expr $(echo $(($nor_bootloader_offset))) / 1024`
		    dd if=$DEPLOYDIR/$fipimg of=$fwimg bs=1K seek=$val
	    fi
    fi
    if [ "$SECURE" != "true" ]; then
	    uboot_env=env_bootstrap.img
	    # Bootloader environment
	    if [ "$MACHINE" = "ls1012afrwy" ]; then
		    dd if=$uboot_env of=$fwimg bs=1k seek=1856
	    else
		    if [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
			    dd if=$uboot_env of=$fwimg bs=512 seek=$sd_bootloader_env_offset
		    else
			    val=`expr $(echo $(($nor_bootloader_env_offset))) / 1024`
			    dd if=$uboot_env of=$fwimg bs=1K seek=$val
		    fi
	    fi
    fi
    # secure boot headers
    if [ "$secureboot_headers" != null -a -n "$secureboot_headers" ] && [ "$SECURE" = "true" ] ; then
        if [ "$BOOTTYPE" = "nor" -o "$BOOTTYPE" = "qspi" -o "$BOOTTYPE" = "xspi" -o "$BOOTTYPE" = "nand" ]; then
            val=`expr $(echo $(($nor_secureboot_headers_offset))) / 1024`
            dd if=$DEPLOYDIR/$secureboot_headers of=$fwimg bs=1K seek=$val
        elif [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
            dd if=$DEPLOYDIR/$secureboot_headers of=$fwimg bs=512 seek=$sd_secureboot_headers_offset
        fi
    fi

    # DDR PHY firmware
    if [ "$MACHINE" = "lx2160ardb" ]; then
        if [ "$SECURE" = "true" ]; then
	    ddrphyfw=$ddr_phy_fw_sec
	else
	    ddrphyfw=$ddr_phy_fw
        fi
        if [ "$BOOTTYPE" = "nor" -o "$BOOTTYPE" = "qspi" -o "$BOOTTYPE" = "xspi" -o "$BOOTTYPE" = "nand" ]; then
            val=`expr $(echo $(($nor_ddr_phy_fw_offset))) / 1024`
            dd if=$DEPLOYDIR/$ddrphyfw of=$fwimg bs=1K seek=$val
        elif [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
            dd if=$DEPLOYDIR/$ddrphyfw of=$fwimg bs=512 seek=$sd_ddr_phy_fw_offset
        fi
    fi
     # fuse provisioning in case CONFIG_FUSE_PROVISIONING is enabled
    if [ "$CONFIG_FUSE_PROVISIONING" = "y" ]; then
        if [ "$SECURE" = "true" ]; then
            fuse_header=build/firmware/atf/$1/fuse_fip_sec.bin
        else
            fuse_header=build/firmware/atf/$1/fuse_fip.bin
        fi
        if [ "$2" = "nor" -o "$2" = "qspi" -o "$2" = "xspi" -o "$2" = "nand" ]; then
            val=`expr $(echo $(($nor_fuse_headers_offset))) / 1024`
            dd if=$DEPLOYDIR/$fuse_header of=$fwimg bs=1K seek=$val
        elif [ "$2" = "sd" -o "$2" = "emmc" ]; then
            dd if=$DEPLOYDIR/$fuse_header of=$fwimg bs=512 seek=$sd_fuse_headers_offset
        fi
    fi

    # DPAA1 FMan ucode firmware
    if [ "$fman_ucode" != "null" -a -n "$fman_ucode" ]; then
        if [ "$BOOTTYPE" = "nor" -o "$BOOTTYPE" = "qspi" -o "$BOOTTYPE" = "xspi" -o "$BOOTTYPE" = "nand" ]; then
            val=`expr $(echo $(($nor_fman_ucode_offset))) / 1024`
            dd if=$DEPLOYDIR/$fman_ucode of=$fwimg bs=1K seek=$val
        elif [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
            dd if=$DEPLOYDIR/$fman_ucode of=$fwimg bs=512 seek=$sd_fman_ucode_offset
        fi
    fi
    # QE/uQE firmware
    if [ "$qe_firmware" != "null" -a -n "$qe_firmware" ] ; then
        if [ "$BOOTTYPE" = "nor" -o "$BOOTTYPE" = "qspi" -o "$BOOTTYPE" = "xspi" -o "$BOOTTYPE" = "nand" ]; then
            val=`expr $(echo $(($nor_qe_firmware_offset))) / 1024`
            dd if=$DEPLOYDIR/$qe_firmware of=$fwimg bs=1K seek=$val
        elif [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
            dd if=$DEPLOYDIR/$qe_firmware of=$fwimg bs=512 seek=$sd_qe_firmware_offset
        fi
    fi

    # ethernet phy firmware
    if [ "$phy_firmware" != "null" -a -n "$phy_firmware" ] ; then
        if [ "$BOOTTYPE" = "nor" -o "$BOOTTYPE" = "qspi" -o "$BOOTTYPE" = "xspi" -o "$BOOTTYPE" = "nand" ]; then
            val=`expr $(echo $(($nor_phy_firmware_offset))) / 1024`
            dd if=$DEPLOYDIR/$phy_firmware of=$fwimg bs=1K seek=$val
        elif [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
            dd if=$DEPLOYDIR/$phy_firmware of=$fwimg bs=512 seek=$sd_phy_firmware_offset
        fi
    fi
    # flashing image script
    if [ ! -f $DEPLOYDIR/flash_images.scr ] ; then
        mkimage -T script -C none -d flash_images.sh $DEPLOYDIR/flash_images.scr
    fi
    if [ "$BOOTTYPE" = "nor" -o "$BOOTTYPE" = "qspi" -o "$BOOTTYPE" = "xspi" -o "$BOOTTYPE" = "nand" ]; then
        val=`expr $(echo $(($nor_uboot_scr_offset))) / 1024`
        dd if=$DEPLOYDIR/flash_images.scr of=$fwimg bs=1K seek=$val
    elif [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
        dd if=$DEPLOYDIR/flash_images.scr of=$fwimg bs=512 seek=$sd_uboot_scr_offset
    fi

    # DPAA2-MC or PFE firmware
    if [ "$dpaa2_mc_fw" != "null" -a -n "$dpaa2_mc_fw" ] ; then
        fwbin=`ls $DEPLOYDIR/$dpaa2_mc_fw`
    elif [ "$pfe_fw" != "null" -a -n "$pfe_fw" ] ; then
        fwbin=$DEPLOYDIR/$pfe_fw
    fi
    if [ -n "$fwbin" ]; then
        if [ "$BOOTTYPE" = "nor" -o "$BOOTTYPE" = "qspi" -o "$BOOTTYPE" = "xspi" -o "$BOOTTYPE" = "nand" ]; then
            	val=`expr $(echo $(($nor_dpaa2_mc_fw_offset))) / 1024`
            	dd if=$fwbin of=$fwimg bs=1K seek=$val
        elif [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
            	dd if=$fwbin of=$fwimg bs=512 seek=$sd_dpaa2_mc_fw_offset
        fi
    fi

    # DPAA2 DPL firmware
    if [ "$dpaa2_mc_dpl" != "null" -a -n "$dpaa2_mc_dpl" ] ; then
        if [ "$BOOTTYPE" = "nor" -o "$BOOTTYPE" = "qspi" -o "$BOOTTYPE" = "xspi" -o "$BOOTTYPE" = "nand" ]; then
            val=`expr $(echo $(($nor_dpaa2_mc_dpl_offset))) / 1024`
            dd if=$DEPLOYDIR/$dpaa2_mc_dpl of=$fwimg bs=1K seek=$val
        elif [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
            dd if=$DEPLOYDIR/$dpaa2_mc_dpl of=$fwimg bs=512 seek=$sd_dpaa2_mc_dpl_offset
        fi
    fi
    # DPAA2 DPC firmware
    if [ "$dpaa2_mc_dpc" != "null" -a -n "$dpaa2_mc_dpc" ] ; then
        if [ "$BOOTTYPE" = "nor" -o "$BOOTTYPE" = "qspi" -o "$BOOTTYPE" = "xspi" -o "$BOOTTYPE" = "nand" ]; then
            val=`expr $(echo $(($nor_dpaa2_mc_dpc_offset))) / 1024`
            dd if=$DEPLOYDIR/$dpaa2_mc_dpc of=$fwimg bs=1K seek=$val
        elif [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
            dd if=$DEPLOYDIR/$dpaa2_mc_dpc of=$fwimg bs=512 seek=$sd_dpaa2_mc_dpc_offset
        fi
    fi
    if [ "$MFT" != "true" ]; then
	    # linux kernel image
	    if [ "$BOOTTYPE" = "nor" -o "$BOOTTYPE" = "qspi" -o "$BOOTTYPE" = "xspi" -o "$BOOTTYPE" = "nand" ]; then
	        val=`expr $(echo $(($nor_kernel_offset))) / 1024`
	        dd if=$DEPLOYDIR/${kernel_itb} of=$fwimg bs=1K seek=$val
	    elif [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
	        dd if=$DEPLOYDIR/${kernel_itb} of=$fwimg bs=512 seek=$sd_kernel_offset
	    fi
    fi
    if [ "$BOOTTYPE" = "sd" -o "$BOOTTYPE" = "emmc" ]; then
        tail -c +4097 $fwimg > $fwimg.img && rm $fwimg
    else
        mv $fwimg $fwimg.img
    fi
    echo -e "${GREEN} $fwimg.img   [Done]\n${NC}"

}

generate_distro_bootscr $MACHINE
secure_sign_image $MACHINE $BOOTTYPE
generate_qoriq_composite_firmware $MACHINE $BOOTTYPE
