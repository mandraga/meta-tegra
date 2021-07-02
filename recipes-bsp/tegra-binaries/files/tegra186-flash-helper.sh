#!/bin/sh
flash_in="$1"
dtb_file="$2"
sdramcfg_file="$3"
odmdata="$4"

BPFDTB_FILE="tegra186-a02-bpmp-quill-p3310-1000-@BPFDTBREV@-00-te770d-ucm2.dtb"
PINMUX_CONFIG="tegra186-mb1-bct-pinmux-quill-p3310-1000-@BOARDREV@.cfg"
PMIC_CONFIG="tegra186-mb1-bct-pmic-quill-p3310-1000-@PMICREV@.cfg"
PMC_CONFIG="tegra186-mb1-bct-pad-quill-p3310-1000-@BOARDREV@.cfg"
PROD_CONFIG="tegra186-mb1-bct-prod-quill-p3310-1000-@BOARDREV@.cfg"
BOOTROM_CONFIG="tegra186-mb1-bct-bootrom-quill-p3310-1000-@BOARDREV@.cfg"
MISC_CONFIG=tegra186-mb1-bct-misc-si-l4t.cfg
SCR_CONFIG=minimal_scr.cfg
SCR_COLD_BOOT_CONFIG=mobile_scr.cfg
DEV_PARAMS=emmc.cfg

# The following defaults are for the B00 revision SOM
# which shipped with at least some Jetson TX2 dev kits.
# BOARDREV is used for all substitutions, except for
# BPFDTB and PMIC revisions, which differe between B00
# and B01 revisions.  See p2771-0000.conf.common in
# the L4T kit.
TOREV="c03"
BPFDTBREV="c01"
PMICREV="c03"

if tegraflash.py --chip 0x18 --applet mb1_recovery_prod.bin --cmd "dump eeprom boardinfo cvm.bin"; then
    boardrev=`chkbdinfo -f cvm.bin`
    boardrev=`echo $boardrev | tr [a-z] [A-Z]`
    case $boardrev in
	B0[1-9]|[C-Z]??)
	    BPFDTBREV="c04"
	    PMICREV="c04"
	    ;;
	B00)
	    ;;
	*)
	    echo "ERR: unsupported board revision: $boardrev" >&2
	    exit 1
	    ;;
    esac
else
    echo "ERR: could not retrieve EEPROM board information" >&2
    exit 1
fi

BPFDTB_FILE=`echo $BPFDTB_FILE | sed -e"s,@BPFDTBREV@,$BPFDTBREV,"`
sed -e"s,BPFDTB-FILE,$BPFDTB_FILE," \
    "$flash_in" > flash.xml

PINMUX_CONFIG=`echo $PINMUX_CONFIG | sed -e"s,@BOARDREV@,$TOREV,"`
PMIC_CONFIG=`echo $PMIC_CONFIG | sed -e"s,@PMICREV@,$PMICREV,"`
PMC_CONFIG=`echo $PMC_CONFIG | sed -e"s,@BOARDREV@,$TOREV,"`
PROD_CONFIG=`echo $PROD_CONFIG | sed -e"s,@BOARDREV@,$TOREV,"`
BOOTROM_CONFIG=`echo $BOOTROM_CONFIG | sed -e"s,@BOARDREV@,$TOREV,"`

BINS="mb2_bootloader nvtboot_recovery.bin; \
mts_preboot preboot_d15_prod_cr.bin; \
mts_bootpack mce_mts_d15_prod_cr.bin; \
bpmp_fw bpmp.bin; \
bpmp_fw_dtb $BPFDTB_FILE; \
tlk tos.img; \
eks eks.img; \
bootloader_dtb $dtb_file"

tegraflash.py --chip 0x18 --bl nvtboot_recovery_cpu.bin \
	      --sdram_config $sdramcfg_file \
	      --odmdata $odmdata \
	      --applet mb1_recovery_prod.bin \
	      --cmd "flash;reboot" \
	      --cfg flash.xml \
	      --misc_config $MISC_CONFIG \
	      --pinmux_config $PINMUX_CONFIG \
	      --pmic_config $PMIC_CONFIG \
	      --pmc_config $PMC_CONFIG \
	      --prod_config $PROD_CONFIG \
	      --scr_config $SCR_CONFIG \
	      --scr_cold_boot_config $SCR_COLD_BOOT_CONFIG \
	      --br_cmd_config $BOOTROM_CONFIG \
	      --dev_params $DEV_PARAMS \
	      --bins "$BINS" || exit 1
