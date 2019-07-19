#!/bin/bash

echo "Enabling SSH..."
sudo apt-get update
sudo apt-get install -y dropbear
sudo sed -i -e 's/^NO_START=1/NO_START=0/g' /etc/default/dropbear
sudo /etc/init.d/ssh stop
sudo /etc/init.d/dropbear start
sudo apt-get purge openssh-server -y
echo "SSH enabled!"
read -p "Press enter to continue"

echo "Setting up fbcp..."
etc_modules=/etc/modules
if ! grep '^spi-bcm2835' $etc_modules; then
  echo 'spi-bcm2835' >> $etc_modules
  echo 'i2c-dev' >> $etc_modules
  echo "Done!"
else
  echo "etc/modules already set up."
fi

echo "Fetching rpi-fbcp..."
git clone https://github.com/tasanakorn/rpi-fbcp
echo "Done."
cd rpi-fbcp/
mkdir build
cd build/
cmake ..
echo "Setting up fbcp..."
make
sudo install fbcp /usr/local/bin/fbcp
sudo cp "/boot/mintyPi/landscape.dtb" "/boot/overlays/landscape.dtb"
cd /usr/local/bin 
sudo cp ./fbcp ./mintyPiScreen
sudo chmod 777 ./mintyPiScreen
sudo rm fbcp
sudo mv ./mintyPiScreen /usr/bin/
sudo cp /boot/mintyPi/mintyPiScreen.service /etc/systemd/system/mintyPiScreen.service
sudo chmod 777 /etc/systemd/system/mintyPiScreen.service
sudo systemctl enable mintyPiScreen
echo "Done."
read -p "Press enter to continue"

config_txt=/boot/config.txt
minty_pi_setup_section=#minty_pi_setup_section
echo "Setting up /boot/config.txt..."
if ! grep '^#minty_pi_setup_section' $config_txt; then
    sed -i -e 's/^framebuffer_/#framebuffer_/g' $config_txt
    echo '$minty_pi_setup_section' >> $config_txt
    echo 'hdmi_mode=1' >> $config_txt
    echo 'hdmi_force_hotplug=1' >> $config_txt
    echo 'hdmi_cvt=320 240 60 1 0 0 0' >> $config_txt
    echo 'hdmi_group=2' >> $config_txt
    echo 'hdmi_mode=87' >> $config_txt
    echo 'dtoverlay=landscape,speed=82000000,rotate=180' >> $config_txt
    echo 'display_rotate=2' >> $config_txt
    echo 'dtparam=i2c_arm=on' >> $config_txt
    echo 'enable_uart=0' >> $config_txt
    echo 'dtoverlay=hifiberry-dac' >> $config_txt
    echo 'dtoverlay=i2s-mmap' >> $config_txt
    echo 'dtoverlay=gpio-poweroff,gpiopin=14,active_low="y"' >> $config_txt
    echo 'ignore_lcd=1' >> $config_txt
    echo 'start_x=0' >> $config_txt
    echo 'enable_uart=0' >> $config_txt
    echo 'avoid_warnings=1' >> $config_txt
    echo 'disable_splash=1' >> $config_txt
    echo 'initial_turbo=60' >> $config_txt
    sed -i -e 's/^dtparam=audio=on/#dtparam=audio=on/g' $config_txt
    echo "Done!"
else
  echo "/boot/config already set up."
fi
read -p "Press enter to continue"

echo "Installing rfkill..."
sudo apt-get install -y rfkill
echo "Done!"
read -p "Press enter to continue"

sudo sh ./copy-files.sh

echo "Disabling wait for network on boot..."
rm -f /etc/systemd/system/dhcpcd.service.d/wait.conf
echo "Done!"
read -p "Press enter to continue"

echo "Removing samba (use ftp!)..."
sudo apt-get remove -y --purge samba
sudo apt-get install -y proftpd
sudo sed -i -e 's/^UseIPv6/UseIPv6 off #/g' /etc/proftpd/proftpd.conf
sudo sed -i -e 's/^ServerName/ServerName \"mintypi\" #/g' /etc/proftpd/proftpd.conf
sudo sed -i -e 's/^# AuthOrder/AuthOrder/g' /etc/proftpd/proftpd.conf
sudo systemctl disable proftpd.service
echo "Done!"
read -p "Press enter to continue"

echo "Configuring git..."
echo 'raspberry' | sudo -u pi git config --global user.ghname "mintyPi User"
echo 'raspberry' | sudo -u pi git config --global user.ghemail "mintyPi@sudomod.com"
echo "Done!"
read -p "Press enter to continue"

echo "Setting up mintyPi update script"
minty_update=minty-update.sh
minty_logo=minty-logo.png
cd /home/pi
echo 'raspberry' | sudo -u pi git clone -b mintyPiv3 https://github.com/wermy/mintyPi.git
cp /boot/mintyPi/$minty_update /home/pi/RetroPie/retropiemenu/$minty_update
cp /boot/mintyPi/$minty_logo /home/pi/RetroPie/retropiemenu/icons/$minty_logo
echo "Done!"
read -p "Press enter to continue"

echo "Setting up Bluup's scripts..."
sudo apt update
sudo apt install -y python-pip --fix-missing
sudo pip install python-uinput
sudo pip install configparser
sudo pip install Adafruit_ADS1x15
echo "Done!"
read -p "Press enter to continue"

one_for_all_rules=10-OneForAll.rules
echo "Copying retrogame udev config..."
cp /boot/mintyPi/$one_for_all_rules /etc/udev/rules.d/$one_for_all_rules
cd /home/pi
echo 'raspberry' | sudo -u pi git clone --recursive --single-branch --branch mintypi_v3 https://github.com/withgallantry/OneForAll.git
cd OneForAll/
make
sudo chmod 777 ./osd/osd
cd ..
echo "Done!"
read -p "Press enter to continue"

echo "Downloading custom themes..."
mkdir /home/pi/.emulationstation/themes
cd /home/pi
echo 'raspberry' | sudo -u pi git clone https://github.com/wermy/es-theme-material.git
echo 'raspberry' | sudo -u pi git clone https://github.com/wstevens0n/tft-mintypi.git
echo 'raspberry' | sudo -u pi git clone https://github.com/wermy/es-theme-carbon.git
mv es-theme-material /home/pi/.emulationstation/themes/
mv tft-mintypi /home/pi/.emulationstation/themes/
mv es-theme-carbon /home/pi/.emulationstation/themes/
echo "Done!"
read -p "Press enter to continue"

echo "Setting up mintypi hostname..."
sudo sed -i -e 's/^retropie/mintypi/g' /etc/hostname
sudo sed -i -e 's/retropie/mintypi/g' /etc/hosts
sudo rm /etc/ssh/ssh_host_* 
sudo dpkg-reconfigure openssh-server
echo "Done!"
read -p "Press enter to continue"

echo "Finishing up..."
sudo apt-get purge avahi-daemon -y
sudo apt-get autoremove --purge -y
sudo systemctl disable triggerhappy
sudo systemctl disable cron.service
sudo systemctl disable keyboard-setup.service
sudo systemctl disable apt-daily.service
sudo systemctl disable hciuart.service
sudo systemctl disable raspi-config.service
sudo update-rc.d dphys-swapfile remove
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo rm -rf /lib/modules/4.14.30-v7+
echo 'vm.swappiness=1' >> /etc/sysctl.conf

rc_local=/etc/rc.local
sudo sed -i "/IP/,/exit 0/d" $rc_local
sudo echo "dmesg --console-off" >> $rc_local
sudo echo "exit 0" >> $rc_local

# sudo rm -rf /boot/mintyPi
echo "All done!"
read -p "Press enter to continue"