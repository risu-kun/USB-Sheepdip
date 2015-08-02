#!/bin/bash
#
# USB-Sheepdip:  Prototype sheep dip appliance for USB security in airgapped environments to be run on a Raspberry fgstest
# Authors:  Thomas Peterson <tpeterson@foxguardsolutions.com> and Charisse Rigdon (asv0r) <crigdon@foxguardsolutions.com>
# Version: 0.4 July 2015
#


initializeLog () {		#  append header for this run to log
	printf "\n\n===================================[ sda Start : `date +%c` ]============================================\n\n" | tee -a log.txt
	
}

checkMountPoints () {
        
        sudo mount -a
        df -Th | grep sd
        printf "\nAre these mount points correct? (y/n): "
        read input
        if  [ "$input" != "y" ]
                then
                        printf "Exiting due to incorrect mount points.\n"  | tee -a ./log.txt
                        exit 1
        fi
}


updateAV () {			#  update clamav definitions -- * not implemented yet *

	printf "`date +%T`:  Updating anti-virus definitions... \n" | tee -a ./log.txt
	sudo freshclam
	if [ $? eq 0 ] 
	        then
	         printf "Update successful.\n" | tee -a log.txt
	fi
}

scanOutside () {		#  scan the outside USB drive, display infected files, remove them and write the output to a log file in the users home directory home/sda

	printf "`date +%T`:  Scanning the outside USB now... \n" | tee -a ./log.txt
	sudo clamscan -v -r /home/fgstest/USBs/outside | tee -a ./log.txt
	
	if [ $? == 0 ]
		then 
			printf "Virus scan complete no threat found \n"
			
	elif [ $? == 1 ]
		then 
			printf "** VIRUSES FOUND.  DO NOT USE THESE FILES! **\n" | tee -a ./log.txt 
			exit 1
	else
			printf "Error occurred with virus scan.\n" | tee -a ./log.txt
			exit 1
			
	fi	
}

scanInside () {			#  scan the inside USB drive, display infected files, remove them and write the output to a log file in the users home directory home/sda

	printf "`date +%T`:  Scanning the inside USB now... \n" | tee -a ./log.txt
	sudo clamscan -v -r /home/fgstest/USBs/inside | tee -a ./log.txt
	
	if [ $? == 0 ]
		then 
			printf "Virus scan complete no threat found \n"
			
	elif [ $? == 1 ]
		then 
			printf "** VIRUSES FOUND.  DO NOT USE THESE FILES! **\n" | tee -a ./log.txt 
			exit 1
	else
			printf "Error occurred with virus scan.\n" | tee -a ./log.txt
			exit 1
			
	fi	
}

shredInside () {		#  secure erase the inside USB drive, the default setting writes 38 times and write the output to the log file

	printf "`date +%T`:  Shredding inside USB now... \n" | tee -a ./log.txt
	sudo umount -v /dev/sdb | tee -a ./log.txt
	sudo shred -v -z -n 0 /dev/sdb | tee -a ./log.txt		#  no overwriting; just one pass of writing zeroes
	
	if [ $? != 0 ]
                then
                        printf "`date +%T`:  ERROR: shred failed.  Please check logs before continuing. Attempting to format USB now... \n"
                        formatInside
                        exit 1
        fi
	        
}

formatInside () {		#  format USB drive to FAT32 

	printf "\n`date +%T`:  Creating new FAT32 filesystem on inside USB...\n"
	sudo mkdosfs -v -F 32 -I /dev/sdb | tee -a ./log.txt
	
	if [ $? == 0 ]
	        then
	                printf "`date +%T`:  USB formatted.\n"
                else
                        printf "`date +%T`:  ERROR: Unable to format drive.\n"
                        exit 1
        fi
}

remount () {			#  remount the drive to prepare for copy

	sudo mount -v -t vfat /dev/sdb /home/fgstest/USBs/inside | tee -a ./log.txt

}

copyOutsideToInside () {	# copy everything on outside USB to newly formatted inside USB

	printf "`date +%T`:  Copying USB now... \n" | tee -a ./log.txt
	sudo cp -v /home/fgstest/USBs/outside/* /home/fgstest/USBs/inside/ | tee -a ./log.txt
	printf "`date +%T`:  Process complete. * WARNING: CHECK THE LOG FILE BEFORE CONTINUING *\n"
}

unmount ()  {		# unmount USB drives so they can be safley removed 

	printf " `date +%T`:Unmounting USB now standby... \n" |tee -a ./log.txt 
	sudo umount -v /dev/sda | tee -a ./log.txt
	sudo umount -v /dev/sdb | tee -a ./log.txt
	printf ":Unmount complete USBs can be safely removed * WARNING CHECK THE LOG FILE BEFORE CONTINUING *\n" 
	
}


finishLog () {		#  append footer for this run to log
	printf "===================================[ End : `date +%c` ]============================================\n\n" | tee -a log.txt
	
}


initializeLog

checkMountPoints
#updateAV
scanOutside
scanInside
shredInside
formatInside
remount
copyOutsideToInside
umount 

finishLog








