all: install

install:
	install -p -b -m 755 -D boot/config-cs10600ra070.txt /boot/config-cs10600ra070.txt
	install -p -m 755 -D boot/config-cs10600ra070.txt $(TP)/boot/config-cs10600ra070.txt
	install -p -b -m 755 -D boot/config-cs12800ra101.txt /boot/config-cs12800ra101.txt
	install -p -m 755 -D boot/config-cs12800ra101.txt $(TP)/boot/config-cs12800ra101.txt
	install -p -b -m 644 -D etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf
	install -p -m 644 -D etc/lightdm/lightdm.conf $(TP)/etc/lightdm/lightdm.conf
	install -p -m 644 -D lib/systemd/system/chipsee-init.service /lib/systemd/system/chipsee-init.service
	install -p -m 644 -D lib/systemd/system/chipsee-init.service $(TP)/lib/systemd/system/chipsee-init.service
	install -p -m 755 -D usr/bin/lt8619cinit /usr/bin/lt8619cinit
	install -p -m 755 -D usr/bin/lt8619cinit $(TP)/usr/bin/lt8619cinit
	install -p -m 777 -D opt/chipsee/chipsee-init.sh /opt/chipsee/chipsee-init.sh
	install -p -m 777 -D opt/chipsee/chipsee-init.sh $(TP)/opt/chipsee/chipsee-init.sh
	install -p -m 777 -D opt/chipsee/test/gpiotest.sh /opt/chipsee/test/gpiotest.sh
	install -p -m 777 -D opt/chipsee/test/gpiotest.sh $(TP)/opt/chipsee/test/gpiotest.sh
	install -p -m 777 -D opt/chipsee/test/uarttest.txt /opt/chipsee/test/uarttest.txt
	install -p -m 777 -D opt/chipsee/test/uarttest.txt $(TP)/opt/chipsee/test/uarttest.txt
	install -p -b -m 755 -D usr/lib/raspi-config/init_resize.sh /usr/lib/raspi-config/init_resize.sh
	install -p -m 755 -D usr/lib/raspi-config/init_resize.sh $(TP)/usr/lib/raspi-config/init_resize.sh
	systemctl enable chipsee-init.service

clean: install
	systemctl disable chipsee-init.service
	rm /opt/chipsee -rf
	rm /usr/bin/lt8619cinit
	mv /etc/lightdm/lightdm.conf~ /etc/lightdm/lightdm.conf
	mv /boot/config.txt~ /boot/config.txt
	rm /boot/config-*.txt
	mv /usr/lib/raspi-config/init_resize.sh~ /usr/lib/raspi-config/init_resize.sh
