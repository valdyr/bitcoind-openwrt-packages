#
# Author: Jimmy Situ <web@jimmystone.cn>
# Address:1KHujLT4AzQwQKSLEUSbcergqv7fMnQNXA 
#
# This is free and unencumbered software released into the public domain.
# For details see the UNLICENSE file at the root of the source tree.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bitcoind

ifeq ($(CONFIG_BITCOIND),y)
	PKG_VERSION:=v0.9.2
	PKG_REV:=505681f234685f2e17f1ebdbd8ba96eb061f1794
endif

PKG_RELEASE:=1
PKG_INSTALL:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_REV).tar.bz2
ifeq ($(CONFIG_BITCOIND),y)
	PKG_SOURCE_URL:=git://github.com/bitcoin/bitcoin.git
endif

PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/bitcoind
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=bitcoind
	URL:=https://github.com/bitcoin/bitcoin
ifeq ($(CONFIG_TARGET_brcm2708_RaspberryPi),)
	DEPENDS:=+libcurl +libpthread +jansson +udev
else
	DEPENDS:=+libcurl +libpthread +jansson +udev +libncurses +libssp +boost-chrono +boost-filesystem +boost-program +boost-test 
endif
endef

define Package/bitcoind/description
Bitcoind is a bitcoin full node
endef

define Package/bitcoind/config
	menu "Configuration"
	depends on PACKAGE_bitcoind
	source "$(SOURCE)/Config.in"
	endmenu
endef

TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib

ifeq ($(CONFIG_BITCOIND),y)
	CONFIGURE_ARGS += --without-miniupnpc --disable-wallet 
	CONFIGURE_ARGS += --with-boost-libdir=$(STAGING_DIR)/usr/lib
endif

define Build/Compile
	$(call Build/Compile/Default)
endef

define Package/bitcoind/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/bitcoind  $(1)/usr/bin

ifeq ($(CONFIG_BITCOIND),y)
	$(INSTALL_BIN) $(FILES_DIR)/bitcoind-monitor        $(1)/usr/bin/bitcoind-monitor
	$(INSTALL_BIN) $(FILES_DIR)/bitcoind.init           $(1)/etc/init.d/bitcoind
	$(CP)          $(FILES_DIR)/bitcoind.config         $(1)/etc/config/bitcoind
endif

endef

$(eval $(call BuildPackage,bitcoind))