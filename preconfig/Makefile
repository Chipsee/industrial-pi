all: install

install:
	install -p -b -m 755 -D boot/config-cs10600ra070.txt /boot/config-cs10600ra070.txt
	install -p -m 755 -D boot/config-cs10600ra070.txt $(TP)/boot/config-cs10600ra070.txt
	install -p -b -m 755 -D boot/config-cs12800ra101.txt /boot/config-cs12800ra101.txt
	install -p -m 755 -D boot/config-cs12800ra101.txt $(TP)/boot/config-cs12800ra101.txt
	install -p -b -m 755 -D boot/config-cs12800ra4101.txt /boot/config-cs12800ra4101.txt
	install -p -m 755 -D boot/config-cs12800ra4101.txt $(TP)/boot/config-cs12800ra4101.txt
	install -p -b -m 755 -D boot/config-cs12800ra4101box.txt /boot/config-cs12800ra4101box.txt
	install -p -m 755 -D boot/config-cs12800ra4101box.txt $(TP)/boot/config-cs12800ra4101box.txt
	install -p -b -m 755 -D boot/config-cs10600ra4070.txt /boot/config-cs10600ra4070.txt
	install -p -m 755 -D boot/config-cs10600ra4070.txt $(TP)/boot/config-cs10600ra4070.txt
	install -p -b -m 755 -D boot/config-cs12720ra4050.txt /boot/config-cs12720ra4050.txt
	install -p -m 755 -D boot/config-cs12720ra4050.txt $(TP)/boot/config-cs12720ra4050.txt
	install -p -b -m 755 -D boot/config.txt /boot/config.txt
	install -p -m 755 -D boot/config.txt $(TP)/boot/config.txt
	install -p -m 644 -D usr/lib/systemd/system/chipsee-init.service /usr/lib/systemd/system/chipsee-init.service
	install -p -m 644 -D usr/lib/systemd/system/chipsee-init.service $(TP)/usr/lib/systemd/system/chipsee-init.service
	install -p -m 644 -D usr/lib/systemd/user/audioswitch.service /usr/lib/systemd/user/audioswitch.service
	install -p -m 644 -D usr/lib/systemd/user/audioswitch.service $(TP)/usr/lib/systemd/user/audioswitch.service
	install -p -m 644 -D usr/lib/systemd/user/dpms-lcd.service /usr/lib/systemd/user/dpms-lcd.service
	install -p -m 644 -D usr/lib/systemd/user/dpms-lcd.service $(TP)/usr/lib/systemd/user/dpms-lcd.service
	install -p -m 755 -D usr/bin/lt8619cinit /usr/bin/lt8619cinit
	install -p -m 755 -D usr/bin/lt8619cinit $(TP)/usr/bin/lt8619cinit
	install -p -b -m 755 -D usr/bin/piwiz /usr/bin/piwiz
	install -p -m 755 -D usr/bin/piwiz $(TP)/usr/bin/piwiz
	install -p -b -m 755 -D usr/bin/piwizhs /usr/bin/piwizhs
	install -p -m 755 -D usr/bin/piwizhs $(TP)/usr/bin/piwizhs
	install -p -b -m 755 -D usr/share/piwiz/piwiz.ui /usr/share/piwiz/piwiz.ui
	install -p -m 755 -D usr/share/piwiz/piwiz.ui $(TP)/usr/share/piwiz/piwiz.ui
	install -p -m 777 -D opt/chipsee/chipsee-init.sh /opt/chipsee/chipsee-init.sh
	install -p -m 777 -D opt/chipsee/chipsee-init.sh $(TP)/opt/chipsee/chipsee-init.sh
	install -p -m 777 -D opt/chipsee/audioswitch.sh /opt/chipsee/audioswitch.sh
	install -p -m 777 -D opt/chipsee/audioswitch.sh $(TP)/opt/chipsee/audioswitch.sh
	install -p -m 777 -D opt/chipsee/dpms-lcd.sh /opt/chipsee/dpms-lcd.sh
	install -p -m 777 -D opt/chipsee/dpms-lcd.sh $(TP)/opt/chipsee/dpms-lcd.sh
	install -p -m 777 -D opt/chipsee/test/gpiotest.sh /opt/chipsee/test/gpiotest.sh
	install -p -m 777 -D opt/chipsee/test/gpiotest.sh $(TP)/opt/chipsee/test/gpiotest.sh
	install -p -m 777 -D opt/chipsee/test/uarttest.txt /opt/chipsee/test/uarttest.txt
	install -p -m 777 -D opt/chipsee/test/uarttest.txt $(TP)/opt/chipsee/test/uarttest.txt
	install -p -m 777 -D opt/chipsee/test/i2cdetect /opt/chipsee/test/i2cdetect
	install -p -m 777 -D opt/chipsee/test/i2cdetect $(TP)/opt/chipsee/test/i2cdetect
	install -p -m 777 -D opt/chipsee/test/libi2c.so.0 /opt/chipsee/test/libi2c.so.0
	install -p -m 777 -D opt/chipsee/test/libi2c.so.0 $(TP)/opt/chipsee/test/libi2c.so.0
	install -p -m 777 -D opt/chipsee/test/cantest/canconfig /opt/chipsee/test/cantest/canconfig
	install -p -m 777 -D opt/chipsee/test/cantest/canconfig $(TP)/opt/chipsee/test/cantest/canconfig
	install -p -m 777 -D opt/chipsee/test/cantest/candump /opt/chipsee/test/cantest/candump
	install -p -m 777 -D opt/chipsee/test/cantest/candump $(TP)/opt/chipsee/test/cantest/candump
	install -p -m 777 -D opt/chipsee/test/cantest/canecho /opt/chipsee/test/cantest/canecho
	install -p -m 777 -D opt/chipsee/test/cantest/canecho $(TP)/opt/chipsee/test/cantest/canecho
	install -p -m 777 -D opt/chipsee/test/cantest/cansend /opt/chipsee/test/cantest/cansend
	install -p -m 777 -D opt/chipsee/test/cantest/cansend $(TP)/opt/chipsee/test/cantest/cansend
	install -p -m 777 -D opt/chipsee/test/cantest/cansequence /opt/chipsee/test/cantest/cansequence
	install -p -m 777 -D opt/chipsee/test/cantest/cansequence $(TP)/opt/chipsee/test/cantest/cansequence
	install -p -m 777 -D opt/chipsee/test/cantest/cantest.sh /opt/chipsee/test/cantest/cantest.sh
	install -p -m 777 -D opt/chipsee/test/cantest/cantest.sh $(TP)/opt/chipsee/test/cantest/cantest.sh
	install -p -m 777 -D opt/chipsee/test/cantest/README /opt/chipsee/test/cantest/README
	install -p -m 777 -D opt/chipsee/test/cantest/README $(TP)/opt/chipsee/test/cantest/README
	install -p -m 777 -D opt/chipsee/voicecard/asound_2mic.conf /opt/chipsee/voicecard/asound_2mic.conf
	install -p -m 777 -D opt/chipsee/voicecard/asound_2mic.conf $(TP)/opt/chipsee/voicecard/asound_2mic.conf
	install -p -m 777 -D opt/chipsee/voicecard/wm8960_asound.state /opt/chipsee/voicecard/wm8960_asound.state
	install -p -m 777 -D opt/chipsee/voicecard/wm8960_asound.state $(TP)/opt/chipsee/voicecard/wm8960_asound.state
	install -p -b -m 755 -D  opt/chipsee/test/linux-ppp-scripts/ip-up /opt/chipsee/test/linux-ppp-scripts/ip-up
	install -p -m 755 -D  opt/chipsee/test/linux-ppp-scripts/ip-up $(TP)/opt/chipsee/test/linux-ppp-scripts/ip-up
	install -p -b -m 755 -D  opt/chipsee/test/linux-ppp-scripts/quectel-chat-connect /opt/chipsee/test/linux-ppp-scripts/quectel-chat-connect
	install -p -m 755 -D  opt/chipsee/test/linux-ppp-scripts/quectel-chat-connect $(TP)/opt/chipsee/test/linux-ppp-scripts/quectel-chat-connect
	install -p -b -m 755 -D  opt/chipsee/test/linux-ppp-scripts/quectel-chat-disconnect /opt/chipsee/test/linux-ppp-scripts/quectel-chat-disconnect
	install -p -m 755 -D  opt/chipsee/test/linux-ppp-scripts/quectel-chat-disconnect $(TP)/opt/chipsee/test/linux-ppp-scripts/quectel-chat-disconnect
	install -p -b -m 755 -D  opt/chipsee/test/linux-ppp-scripts/quectel-ppp /opt/chipsee/test/linux-ppp-scripts/quectel-ppp
	install -p -m 755 -D  opt/chipsee/test/linux-ppp-scripts/quectel-ppp $(TP)/opt/chipsee/test/linux-ppp-scripts/quectel-ppp
	install -p -b -m 755 -D  opt/chipsee/test/linux-ppp-scripts/quectel-pppd.sh /opt/chipsee/test/linux-ppp-scripts/quectel-pppd.sh
	install -p -m 755 -D  opt/chipsee/test/linux-ppp-scripts/quectel-pppd.sh $(TP)/opt/chipsee/test/linux-ppp-scripts/quectel-pppd.sh
	install -p -b -m 755 -D  opt/chipsee/test/linux-ppp-scripts/quectel-ppp-kill /opt/chipsee/test/linux-ppp-scripts/quectel-ppp-kill
	install -p -m 755 -D  opt/chipsee/test/linux-ppp-scripts/quectel-ppp-kill $(TP)/opt/chipsee/test/linux-ppp-scripts/quectel-ppp-kill
	install -p -b -m 755 -D  opt/chipsee/test/linux-ppp-scripts/README /opt/chipsee/test/linux-ppp-scripts/README
	install -p -m 755 -D  opt/chipsee/test/linux-ppp-scripts/README $(TP)/opt/chipsee/test/linux-ppp-scripts/README
	install -p -b -m 755 -D usr/lib/raspi-config/init_resize.sh /usr/lib/raspi-config/init_resize.sh
	install -p -m 755 -D usr/lib/raspi-config/init_resize.sh $(TP)/usr/lib/raspi-config/init_resize.sh
	install -p -b -m 755 -D etc/issue /etc/issue
	install -p -m 755 -D etc/issue $(TP)/etc/issue
	install -p -b -m 755 -D etc/X11/xorg.conf.d/10-blanking.conf /etc/X11/xorg.conf.d/10-blanking.conf
	install -p -m 755 -D  etc/X11/xorg.conf.d/10-blanking.conf $(TP)/etc/X11/xorg.conf.d/10-blanking.conf
	systemctl enable chipsee-init.service

clean: install
	systemctl disable chipsee-init.service
	rm /opt/chipsee -rf
	rm /usr/bin/lt8619cinit
	mv /usr/bin/piwiz~ /usr/bin/piwiz
	mv /usr/bin/piwizhs~ /usr/bin/piwizhs
	mv /usr/share/piwiz/piwiz.ui~ /usr/share/piwiz/piwiz.ui
	rm /boot/config-*.txt
	mv /usr/lib/raspi-config/init_resize.sh~ /usr/lib/raspi-config/init_resize.sh
	mv /boot/config.txt~ /boot/config.txt
