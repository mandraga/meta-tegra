require tegra-binaries-${PV}.inc
require tegra-shared-binaries.inc

COMPATIBLE_MACHINE = "(tegra)"
PACKAGE_ARCH = "${SOC_FAMILY_PKGARCH}"

DEPENDS = "tegra-binaries-patches quilt-native"

do_configure() {
	rm -rf ${B}/usr/sbin ${B}/etc ${B}/patches ${B}/.pc
	tar -C ${B} -x -f ${S}/nv_tegra/nv_tools.tbz2 usr/sbin
        tar -C ${B} -x -f ${S}/nv_tegra/config.tbz2 etc
}

do_configure:append:tegra210() {
	quilt import ${STAGING_DATADIR}/l4t-patches-${PV}/Convert-l4t_payload_updater_t210-to-Python3.patch
        quilt push
}

do_compile() {
	:
}

do_install() {
	install -d ${D}${sbindir}
	install -m 0755 ${B}/usr/sbin/nvbootctrl ${D}${sbindir}
	install -m 0755 ${B}/usr/sbin/nv_bootloader_payload_updater ${D}${sbindir}
	install -m 0755 ${B}/usr/sbin/nv_update_engine ${D}${sbindir}
	install -d ${D}/opt/ota_package
}

do_install:tegra210() {
	install -d ${D}${sbindir}
	install -m 0755 ${B}/usr/sbin/l4t_payload_updater_t210 ${D}${sbindir}
	install -d ${D}/opt/ota_package
}

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_SYSROOT_STRIP = "1"
PACKAGES = "tegra-redundant-boot-nvbootctrl ${PN} ${PN}-dev"
FILES:tegra-redundant-boot-nvbootctrl = "${sbindir}/nvbootctrl"
FILES:${PN} += "/opt/ota_package"
RDEPENDS:${PN} = "tegra-redundant-boot-nvbootctrl setup-nv-boot-control-service"
RDEPENDS:${PN}:tegra210 = "setup-nv-boot-control-service python3-core"
INSANE_SKIP:${PN} = "ldflags"
RDEPENDS:tegra-redundant-boot-nvbootctrl = "setup-nv-boot-control"
RDEPENDS:tegra-redundant-boot-nvbootctrl:tegra210 = ""
ALLOW_EMPTY:tegra-redundant-boot-nvbootctrl:tegra210 = "1"
INSANE_SKIP:tegra-redundant-boot-nvbootctrl = "ldflags"
