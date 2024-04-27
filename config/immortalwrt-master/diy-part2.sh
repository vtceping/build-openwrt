#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: master
#========================================================================================================================

# ------------------------------- Main source started -------------------------------

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt'" >>package/base-files/files/etc/openwrt_release

# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------

# Add luci-app-amlogic
# svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# Apply patch
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci

# 最大连接数修改为524288
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=524288' package/base-files/files/etc/sysctl.conf

# 替换Passwall为smartdns版
rm -rf feeds/luci/applications/luci-app-passwall
# rm -rf package/feeds/luci/luci-app-passwall
git clone  --depth=1 https://github.com/xiaorouji/openwrt-passwall.git package/passwall_luci
git clone  --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages.git package/passwall_packages

# 替换immortalwrt 软件仓库smartdns版本为官方最新版
# rm -rf feeds/packages/net/smartdns
# cp -rf ${GITHUB_WORKSPACE}/patch/smartdns feeds/packages/net
# git clone --depth=1 https://github.com/pymumu/luci-app-smartdns.git package/smartdns_luci

# golang 1.22
# rm -rf feeds/packages/lang/golang
# git clone --depth=1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# pushd package/emortal/
# rm -rf luci-app-omcproxy
# git clone -b 18.06 https://github.com/lwb1978/luci-app-omcproxy.git
# popd

# 修正部分从第三方仓库拉取的软件 Makefile 路径问题
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

# 替换udpxy为修改版
# rm -rf feeds/packages/net/udpxy/Makefile
# cp -rf ${GITHUB_WORKSPACE}/patch/udpxy/Makefile feeds/packages/net/udpxy/

# 卸载酸酸乳
# ./scripts/feeds uninstall luci-app-ssr-plus

# ------------------------------- Other ends -------------------------------
