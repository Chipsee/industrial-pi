##############################################################

GT9XX_DIR := ./gt9xx
LSM6DS3_DIR := ./lsm6ds3
QUECTEL_CM_DIR := ./quectel-CM
RTL8723BU_DIR := ./rtl8723bu
PRECONFIG_DIR := ./preconfig

##############################################################
install:
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
