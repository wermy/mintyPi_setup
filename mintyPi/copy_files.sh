#!/bin/bash

asound_conf=asound.conf
echo "Copying i2s sound config..."
cp /home/pi/mintyPi_setup/mintyPi/$asound_conf  /etc/$asound_conf
echo "Done!"
read -p "Press enter to continue"

retroarch_cfg=retroarch.cfg
echo "Copying retroarch config..."
cp "/home/pi/mintyPi_setup/mintyPi/$retroarch_cfg" "/opt/retropie/configs/all/$retroarch_cfg" 
echo "Done!"
read -p "Press enter to continue"

es_cfg=es_input.cfg
echo "Copying emulationstation input config..."
cp /home/pi/mintyPi_setup/mintyPi/$es_cfg /opt/retropie/configs/all/emulationstation/$es_cfg
echo "Done!"
read -p "Press enter to continue"

es_settings=es_settings.cfg
echo "Copying emulationstation settings..."
cp /home/pi/mintyPi_setup/mintyPi/$es_settings /opt/retropie/configs/all/emulationstation/$es_settings
echo "Done!"
read -p "Press enter to continue"

echo "Adding fixes for PIFBA audio"
sudo cp /home/pi/mintyPi_setup/mintyPi/.asound.rc /home/pi/
sudo cp /home/pi/mintyPi_setup/mintyPi/alsa-base.conf /etc/modprobe.d/
echo "Done!"
read -p "Press enter to continue"

echo "Setting up ftp enable/disable scripts..."
enable_ftp=enable-ftp.sh
disable_ftp=disable-ftp.sh
game_list=gamelist.xml
cp /home/pi/mintyPi_setup/mintyPi/$enable_ftp /home/pi/RetroPie/retropiemenu/$enable_ftp
cp /home/pi/mintyPi_setup/mintyPi/$disable_ftp /home/pi/RetroPie/retropiemenu/$disable_ftp
cp /home/pi/mintyPi_setup/mintyPi/$game_list /home/pi/.emulationstation/gamelists/retropie/$game_list
echo "Done!"
read -p "Press enter to continue"

echo "Setting up mintyPi startup script..."
chmod +x /home/pi/mintyPi/minty-startup.sh
sudo cp /home/pi/mintyPi_setup/mintyPi/mintyPiStartup.service /etc/systemd/system/mintyPiStartup.service
sudo chmod 777 /etc/systemd/system/mintyPiStartup.service
sudo systemctl enable mintyPiStartup
echo "Done!"
read -p "Press enter to continue"

sudo chown -R pi:pi /opt/retropie/configs