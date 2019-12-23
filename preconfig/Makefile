all: install

install:
	install -p -b -m 755 -D boot/config.txt /boot/config.txt
	install -p -m 755 -D boot/config.txt $(TP)/boot/config.txt
	install -p -b -m 644 -D etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf
	install -p -m 644 -D etc/lightdm/lightdm.conf $(TP)/etc/lightdm/lightdm.conf
	install -p -m 644 -D lib/systemd/system/chipsee-init.service /lib/systemd/system/chipsee-init.service
	install -p -m 644 -D lib/systemd/system/chipsee-init.service $(TP)/lib/systemd/system/chipsee-init.service
	install -p -m 777 -D opt/chipsee/chipsee-init.sh /opt/chipsee/chipsee-init.sh
	install -p -m 777 -D opt/chipsee/chipsee-init.sh $(TP)/opt/chipsee/chipsee-init.sh
	install -p -m 777 -D opt/chipsee/test/gpiotest.sh /opt/chipsee/test/gpiotest.sh
	install -p -m 777 -D opt/chipsee/test/gpiotest.sh $(TP)/opt/chipsee/test/gpiotest.sh
	install -p -m 777 -D opt/chipsee/test/uarttest.txt /opt/chipsee/test/uarttest.txt
	install -p -m 777 -D opt/chipsee/test/uarttest.txt $(TP)/opt/chipsee/test/uarttest.txt
	systemctl daemon-reload
	systemctl enable chipsee-init.service

clean: install
	systemctl disable chipsee-init.service
	systemctl daemon-reload
	rm /opt/chipsee -rf
	mv /etc/lightdm/lightdm.conf~ /etc/lightdm/lightdm.conf
	mv /boot/config.txt~ /boot/config.txt
