##############################################################

GT9XX_DIR := ./gt9xx
LSM6DS3_DIR := ./lsm6ds3
QUECTEL_CM_DIR := ./quectel-CM
RTL8723BU_DIR := ./rtl8723bu
PRECONFIG_DIR := ./preconfig
TOPDIR := $(shell pwd)
KVER  := $(shell uname -r)
TP=$(TOPDIR)/_tp
VERSION :=$(shell echo $$(/bin/bash $(TOPDIR)/tools/setlocalversion --save-scmversion))
export TP

help:
	@echo 'Cleaning targets'
	@echo '  uninstall		- Clean all installed modules and config files'
	@echo '  cleanpackage		- Clean generated package'
	@echo '  clean			- Same make cleanpackage && make uninstall'
	@echo 'Generate targets'
	@echo '  install		- Install all modules and config files'
	@echo '  package		- Generate single package to use shell install them'
	@echo 'Help'
	@echo '  help			- Print this manual'

##############################################################
install:
	@dpkg -i $(TOPDIR)/tools/raspberrypi-kernel-headers_1.20190401-1_armhf.deb
	@make -C $(GT9XX_DIR)
	@echo "Install GT9XX success!!"
	@make -C $(LSM6DS3_DIR)
	@echo "Install lsm6ds3 success!!"
	@make -C $(QUECTEL_CM_DIR)
	@echo "Install quectel-cm success!!"
	@make -C $(RTL8723BU_DIR)
	@echo "Install rtl8723bu success!!"
	@make -C $(PRECONFIG_DIR)
	@echo "Install preconfig success!!"
	@sync
	@echo ""
	@echo "######Install rbcspkg success!!######"
##############################################################
uninstall:
	@make clean -C $(GT9XX_DIR)
	@echo "Uninstall GT9XX success!!"
	@make clean -C $(LSM6DS3_DIR)
	@echo "Uninstall lsm6ds3 success!!"
	@make clean -C $(QUECTEL_CM_DIR)
	@echo "Uninstall quectel-cm success!!"
	@make clean -C $(RTL8723BU_DIR)
	@echo "Uninstall rtl8723bu success!!"
	@make clean -C $(PRECONFIG_DIR)
	@echo "Uninstall preconfig success!!"
	@sync
	@echo ""
	@echo "######Uninstall rbcspkg success!!######"
##############################################################
package: install
	@echo "Prepare package ..."
	@cd $(TP) && tar zcvf $(KVER).tar.gz *
	install -p -m 644 -D $(TP)/$(KVER).tar.gz $(TOPDIR)/rbcspkg$(VERSION)/$(KVER).tar.gz
	install -p -m 777 -D $(TOPDIR)/tools/install.sh $(TOPDIR)/rbcspkg$(VERSION)/install.sh
	@tar zcvf rbcspkg$(VERSION).tar.gz rbcspkg$(VERSION)
	@sync
	@echo "######Generate package rbcspkg$(VERSION).tar.gz success!!######"
##############################################################
cleanpackage:
	@rm $(TP) rbcspkg* -rf
	@sync
	@echo "######Clean package success!!######"
##############################################################
clean: cleanpackage uninstall
	@echo "######Clean success!!######"
##############################################################
