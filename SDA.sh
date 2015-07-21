#!/bin/bash
#
# USB-Sheepdip:  Prototype sheep dip appliance for USB security in airgapped environments to be run on a Raspberry Pi
# Authors:  Thomas Peterson <tpeterson@foxguardsolutions.com> and Charisse Rigdon <crigdon@foxguardsolutions.com>
# Version: 0.2 June 2015
#



initializeLog () {
	printf "\n\n===================================[ Start : `date +%c` ]============================================" >> log.txt
	
}

updateAV () {			#  update clamav definitions -- not implemented yet

	printf "\n`date +%c`:  Updating anti-virus definitions... " | tee ./log.txt
	#sudo freshclam
}

scanOutside () {		#  scan the outside USB drive, display infected files, remove them and write the output to a log file in the users home directory home/sda

	printf "\n`date +%c`:  Scanning the outside USB now... "
	sudo clamscan -v -r /home/pi/USBs/inside | tee ./log.txt
}

scanInside () {			#  scan the inside USB drive, display infected files, remove them and write the output to a log file in the users home directory home/sda

	printf "\n`date +%c`:  Scanning the inside USB now... " 
	sudo clamscan -v -r /home/pi/USBs/inside | tee ./log.txt
}

shredInside () {		#  secure erase the inside USB drive, the default setting writes 38 times and write the output to the log file

	printf "\n`date +%c`:  Shredding USB now... "
	#sudo umount /dev/sdb1
	sudo shred -v -z -n 0 /dev/sdb1 | tee ./log.txt		#  no overwriting; just one pass of writing zeroes
}

formatInside () {		#  format USB drive to FAT32 

	printf "\n`date +%c`:  Creating new FAT32 filesystem on inside USB..."
	sudo mkdosfs -F 32 -I /dev/sdb1 | tee ./log.txt
	printf "\n`date +%c`:  USB formatted."
}

remount () {			#  remount the drive to prepare for copy

	sudo mount /dev/sdb1 /home/pi/USBs/inside | tee ./log.txt

}

copyOutsideToInside () {	# copy everything on outside USB to newly formatted inside USB

	printf "\n`date +%c`:  Copying USB now... "
	cp -a /home/pi/USBs/outside/* /home/pi/USBs/inside/ | tee ./log.txt
	printf "\n`date +%c`:  Process complete. * WARNING: CHECK THE LOG FILE BEFORE CONTINUING *"
}

initializeLog
updateAV
scanOutside
scanInside
shredInside
formatInside
remount
copyOutsideToInside

