#!/bin/bash
# USB-Sheepdip:  Prototype sheep dip appliance for USB security in airgapped environments to be run on a Raspberry FGS
# Authors:  Thomas Peterson <tpeterson@foxguardsolutions.com> and Charisse Rigdon (asv0r) <crigdon@foxguardsolutions.com>
# Version: 0.4 July 2015
#


initializeLog () {		#  append header for this run to log

	printf "\n\n===================================[ SDA Start : %s]============================================\n\n" , "$(date + %c)"| tee -a log.txt
	
}

checkMountPoints () {
        
     sudo mount -a
	 
     df -Th | grep sd
		
     printf "\nAre these mount points correct? (y/n): "
		
     read -r input
		
        if  [ $input != y ] or [ $input != Y ]
		
        then
		
			printf "Exiting due to incorrect mount points.\n"  | tee -a ./log.txt
		
			exit 1
        fi
}


updateAV () {			#  update clamav definitions -- * not implemented yet *

	printf  "Updating anti-virus definitions... \n" | tee -a ./log.txt
	
	sudo freshclam
	
		if [ $? == 0 ] 
		
	    then
		 
		   printf "%s: Update successful.\n" , "$(date +%T)" | tee -a ./log.txt
		  
		else 
		 
		  exit 1
		  
		fi
}

scanOutside () {		#  scan the outside USB drive, display infected files, remove them and write the output to a log file in the users home directory home/sda

	printf "%s:  Scanning the outside USB now... \n", "$(date +%T)" | tee -a ./log.txt
	
	sudo clamscan -v -r /home/FGS/USBs/outside | tee -a ./log.txt

		if [ $? == 0 ]
		
		then 
		
			printf "** Virus scan complete no threat found **\n" | tee -a ./log.txt 
			
			exit 1
		
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

	printf "%s:  Scanning the inside USB now... \n", "$(date +%T)" | tee -a ./log.txt
	
	sudo clamscan -v -r /home/FGS/USBs/inside | tee -a ./log.txt
	
			if [ $? == 0 ]
		
		then 
		
			printf "** Virus scan complete no threat found **\n" | tee -a ./log.txt 
			
			exit 1
		
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

	printf "%s : Shredding inside USB now... \n" , "$(date +%T)" | tee -a ./log.
	
	sudo umount -v /dev/sdb1 | tee -a ./log.txt
	
	sudo shred -v -z -n 0 /dev/sdb1 | tee -a ./log.txt		#  no overwriting; just one pass of writing zeroes
	
		if [ $? != 0 ]
		
		then
            
			printf "%s : ERROR: shred failed.  Please check logs before continuing. Attempting to format USB now... \n", "$(date +%T)"
          
            exit 1
			
		else
		
			printf "Shred Complete... \n"
			
        fi
	        
}

formatInside () {		#  format USB drive to FAT32 

	printf "\n %s : Creating new FAT32 filesystem on inside USB...\n", "$(date +%T)"
	
	sudo mkdosfs -v -F 32 -I /dev/sdb1 | tee -a ./log.txt 
	
		if [ $? == 0 ]
	
		then
	    
			printf "%s : USB formatted.\n" , "$(date +%T)"
    
		else
        
			printf "%s : ERROR: Unable to format drive.\n", "$(date +%T)"
       
			exit 1
		
		fi
}

remount () {			#  remount the drive to prepare for copy

	sudo mount -v -t vfat /dev/sdb1 /home/FGS/USBs/inside | tee -a ./log.txt

}

copyOutsideToInside () {	# copy everything on outside USB to newly formatted inside USB

	printf " %s : Copying USB now... \n" , "$(date +%T)"| tee -a ./log.txt 
	
	sudo cp -v /home/FGS/USBs/outside/* /home/FGS/USBs/inside/ | tee -a ./log.txt
	
	printf " %s:  Process complete. * WARNING: CHECK THE LOG FILE BEFORE CONTINUING *\n" , "$(date +%T)"
	
}

unmount ()  {		# unmount USB drives so they can be safley removed 

	printf " %s:Unmounting USB now standby... \n" ,"$(date +%T)" |tee -a ./log.txt 
	
	sudo umount -v /dev/sda1 | tee -a ./log.txt
	
	sudo umount -v /dev/sdb1 | tee -a ./log.txt
	
	printf " %s:Unmount complete USBs can be safely removed * WARNING CHECK THE LOG FILE BEFORE CONTINUING *\n" , "$(date +%T)"
	
}
	
finishLog () {		#  append footer for this run to log

printf "===================================[ End : %s ]============================================\n\n" | tee -a log.txt , "$(date +%T)"
	
}


initializeLog

checkMountPoints
#updateAV
scanOutside
scanInside
shredInside
formatInside
remount
unmount
copyOutsideToInside
finishLog




