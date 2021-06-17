#SRC_URI = "https://developer.nvidia.com/embedded/L4T/r28_Release_v4.0/t186ref_release_aarch64/${@d.getVar('SOC_FAMILY').title()}_Linux_R${PV}_aarch64.tbz2"
SRC_URI = "http://172.17.0.1/${@d.getVar('SOC_FAMILY').title()}_Linux_R${PV}_aarch64.tbz2"
#"https://developer.nvidia.com/assets/embedded/secure/tools/files/jetpack-sdks/jetpack-3.3.3/JETPACK_333_b8/P3310/Tegra186_Linux_R28.4.0_aarch64.tbz2"
#https://developer.nvidia.com/embedded/L4T/r28_Release_v4.0/t186ref_release_aarch64/Tegra186_Linux_R28.4.0_aarch64.tbz2
SRC_URI[md5sum] = "6171412d91167b889fab0af3549374fc"
SRC_URI[sha256sum] = "41381c2abc32c3a91d27a66203ccdebc222be92e00f429ea73231372173a8bec"
