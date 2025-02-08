##############################################################

GT9XX_DIR := ./gt9xx
QUECTEL_CM_DIR := ./quectel-CM
WM8960_DIR := ./wm8960
ES8388_DIR := ./es8388
PWMBL_DIR := ./pwmbl
MCP23008_DIR := ./mcp23008
PRECONFIG_DIR := ./preconfig
AT24_DIR := ./at24
AV4HELPER_DIR := ./av4helper
MCP251XFD_DIR := ./mcp251xfd
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
	@make -C $(GT9XX_DIR)
	@echo "=========>Install GT9XX success!!"
	@make -C $(QUECTEL_CM_DIR)
	@echo "=========>Install quectel-cm success!!"
	@make -C $(WM8960_DIR)
	@echo "=========>Install wm8960 success!!"
	@make -C $(ES8388_DIR)
	@echo "=========>Install es8388 success!!"
	@make -C $(PWMBL_DIR)
	@echo "=========>Install pwmbl success!!"
	@make -C $(MCP23008_DIR)
	@echo "=========>Install mcp230008 success!!"
	@make -C $(PRECONFIG_DIR)
	@echo "=========>Install preconfig success!!"
	@make -C $(AT24_DIR)
	@echo "=========>Install at24 success!!"
	@make -C $(AV4HELPER_DIR)
	@echo "=========>Install av4helper success!!"
	@sync
	@echo ""
	@echo "######Install industrial-pi drivers success!!######"
##############################################################
uninstall:
	@make clean -C $(GT9XX_DIR)
	@echo "=========>Uninstall GT9XX success!!"
	@make clean -C $(QUECTEL_CM_DIR)
	@echo "=========>Uninstall quectel-cm success!!"
	@make clean -C $(WM8960_DIR)
	@echo "=========>Uninstall wm8960 success!!"
	@make clean -C $(ES8388_DIR)
	@echo "=========>Uninstall es8388 success!!"
	@make clean -C $(PWMBL_DIR)
	@echo "=========>Uninstall pwmbl success!!"
	@make clean -C $(MCP23008_DIR)
	@echo "=========>Uninstall mcp23008 success!!"
	@make clean -C $(PRECONFIG_DIR)
	@echo "=========>Uninstall preconfig success!!"
	@make clean -C $(AT24_DIR)
	@echo "=========>Uninstall at24 success!!"
	@make clean -C $(AV4HELPER_DIR)
	@echo "=========>Uninstall av4helper success!!"
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
