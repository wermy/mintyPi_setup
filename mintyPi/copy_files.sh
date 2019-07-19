#!/bin/bash

asound_conf=asound.conf
echo "Copying i2s sound config..."
cp /boot/mintyPi/$asound_conf  /etc/$asound_conf
echo "Done!"
read -p "Press enter to continue"

retroarch_cfg=retroarch.cfg
echo "Copying retroarch config..."
cp "/boot/mintyPi/$retroarch_cfg" "/opt/retropie/configs/all/$retroarch_cfg" 
echo "Done!"
read -p "Press enter to continue"

es_cfg=es_input.cfg
echo "Copying emulationstation input config..."
cp /boot/mintyPi/$es_cfg /opt/retropie/configs/all/emulationstation/$es_cfg
echo "Done!"
read -p "Press enter to continue"

es_settings=es_settings.cfg
echo "Copying emulationstation settings..."
cp /boot/mintyPi/$es_settings /opt/retropie/configs/all/emulationstation/$es_settings
echo "Done!"
read -p "Press enter to continue"

echo "Adding fixes for PIFBA audio"
sudo cp /boot/mintyPi/.asound.rc /home/pi/
sudo cp /boot/mintyPi/alsa-base.conf /etc/modprobe.d/
echo "Done!"
read -p "Press enter to continue"

echo "Setting up ftp enable/disable scripts..."
enable_ftp=enable-ftp.sh
disable_ftp=disable-ftp.sh
game_list=gamelist.xml
cp /boot/mintyPi/$enable_ftp /home/pi/RetroPie/retropiemenu/$enable_ftp
cp /boot/mintyPi/$disable_ftp /home/pi/RetroPie/retropiemenu/$disable_ftp
cp /boot/mintyPi/$game_list /home/pi/.emulationstation/gamelists/retropie/$game_list
echo "Done!"
read -p "Press enter to continue"

echo "Setting up mintyPi startup script..."
chmod +x /home/pi/mintyPi/minty-startup.sh
sudo cp /boot/mintyPi/mintyPiStartup.service /etc/systemd/system/mintyPiStartup.service
sudo chmod 777 /etc/systemd/system/mintyPiStartup.service
sudo systemctl enable mintyPiStartup
echo "Done!"
read -p "Press enter to continue"

sudo chown -R pi:pi /opt/retropie/configs