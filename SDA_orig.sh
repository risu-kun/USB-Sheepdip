#!/bin/bash
#SDA process, Thomas Peterson for FoxGuard Solutions June 2015
#Clamav, anti-virus software used to scan both the inside and outside USB drives
#Secure-delete, utility used to erase the inside USB drive before copy
#update Clamav before running a scan


echo "Updating anti-virus definitions"

#sudo freshclam

#scan the inside and outside USB drives, display infected files, remove them and write the output to a log file in the users home directory home/sda

echo " Scanning the outside USB now"

sudo clamscan -r /home/sda/outside_USB > /home/sda/log.txt

echo "Scanning the inside USB now"

sudo clamscan -r /home/sda/inside_USB >> /home/sda/log.txt

#secure erase the inside USB drive, the default setting writes 38 times and write the output to the log file

echo "Shredding USB now"

sudo shred -v -z -n 1 /dev/sdb1 >> /home/sda/log.txt

echo "Copying USB now"

cp -a /home/sda/outside_USB/. /home/sda/inside_USB/.

echo "Process complete * WARNING CHECK THE LOG FILE BEFORE CONTINUING *"

