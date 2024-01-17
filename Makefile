##############################################################

LSM6DS3_DIR := ./lsm6ds3
QUECTEL_CM_DIR := ./quectel-CM
WM8960_DIR := ./wm8960
PWMBL_DIR := ./pwmbl
PRECONFIG_DIR := ./preconfig
TOPDIR := $(shell pwd)
KVER  := $(shell uname -r)
TP=$(TOPDIR)/_tp
LARCH := $(shell uname -m)
VERSION :=$(shell echo $$(/bin/bash $(TOPDIR)/tools/setlocalversion --save-scmversion))
export TP
export LARCH

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
	@apt-get update
	@dpkg -i $(TOPDIR)/tools/*$(LARCH).deb
	@make -C $(LSM6DS3_DIR)
	@echo "Install lsm6ds3 success!!"
	@make -C $(QUECTEL_CM_DIR)
	@echo "Install quectel-cm success!!"
	@make -C $(WM8960_DIR)
	@echo "Install wm8960 success!!"
	@make -C $(PWMBL_DIR)
	@echo "Install pwmbl success!!"
	@make -C $(PRECONFIG_DIR)
	@echo "Install preconfig success!!"
	@sync
	@echo ""
	@echo "######Install industrial-pi drivers success!!######"
##############################################################
uninstall:
	@make clean -C $(LSM6DS3_DIR)
	@echo "Uninstall lsm6ds3 success!!"
	@make clean -C $(QUECTEL_CM_DIR)
	@echo "Uninstall quectel-cm success!!"
	@make clean -C $(WM8960_DIR)
	@echo "Uninstall wm8960 success!!"
	@make clean -C $(PWMBL_DIR)
	@echo "Uninstall pwmbl success!!"
	@make clean -C $(PRECONFIG_DIR)
	@echo "Uninstall preconfig success!!"
	@sync
	@echo ""
	@echo "######Uninstall industrial-pi drivers success!!######"
##############################################################
package: install
	@echo "Prepare package ..."
	@cd $(TP) && tar zcvf $(KVER).tar.gz *
	install -p -m 644 -D $(TP)/$(KVER).tar.gz $(TOPDIR)/industrial-pi$(VERSION)/$(KVER).tar.gz
	install -p -m 777 -D $(TOPDIR)/tools/install.sh $(TOPDIR)/industrial-pi$(VERSION)/install.sh
	@tar zcvf industrial-pi$(VERSION).tar.gz industrial-pi$(VERSION)
	@sync
	@echo "######Generate package industrial-pi$(VERSION).tar.gz success!!######"
##############################################################
internalpackage:
	@echo "Prepare package ..."
	@cd $(TP) && tar zcvf $(KVER).tar.gz *
	install -p -m 644 -D $(TP)/$(KVER).tar.gz $(TOPDIR)/industrial-pi$(VERSION)/$(KVER).tar.gz
	install -p -m 777 -D $(TOPDIR)/tools/install.sh $(TOPDIR)/industrial-pi$(VERSION)/install.sh
	@tar zcvf industrial-pi$(VERSION).tar.gz industrial-pi$(VERSION)
	@sync
	@echo "######Generate package industrial-pi$(VERSION).tar.gz success!!######"
##############################################################
cleanpackage:
	@rm $(TP) industrial-pi* -rf
	@sync
	@echo "######Clean package success!!######"
##############################################################
clean: cleanpackage uninstall
	@echo "######Clean success!!######"
##############################################################
