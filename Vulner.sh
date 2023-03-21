#!/bin/bash

#Eddie/S10/cfc2407/James
#This Script is to enumerate, check password and store the results.

# inst function is to install and update the relevant tools
function inst()
{	
	# Updating OS
	sudo apt-get update && sudo apt-get upgrade -y
	# Installing nmap and hydra
	sudo apt-get install nmap -y && sudo apt-get install hydra -y	
	# Install vulscan module
	git clone https://github.com/scipag/vulscan scipag_vulscan
	sudo ln -s `pwd`/scipag_vulscan/usr/share/nmap/scripts/vulscan
	
}	
inst
# main function is to provide user choice of options,as well to diplay live host on the current network range
function main()
{
	# Storing the CIDRin a variable
	hostcidr=$(ip -4 addr | grep brd | awk '{print$2}')
	# Retrieveing the network range and storing it in a variable 
	networkrange=$(netmask -r "$hostcidr")
	# Diplaying the networkrange
	echo -e "\n[*]LAN Network Range:"
	echo $networkrange
	# To create space between the output
	echo -e "\n\n"
	# To retrieve the live host on the network range and saving it in a variable
	livehost=$(sudo nmap "$hostcidr" -sn | grep 'scan' | awk '{print$5}' | tail -n +3 | head -n -3)
	sudo nmap "$hostcidr" -sn | grep 'scan' | awk '{print$5}' | tail -n +3 | head -n -3 > livehost.lst
	# Displaying the live host
	echo -e "[*]List of Live Host:"
	cat livehost.lst


	# Providing user options to choose
	echo -e "\n 1) Enumerate and Vulnerability\n 2) Password checker\n 3) Scaned Report\n 4) exit\n"

	read -p "[*]Enter your choice above: " choice
	case $choice in
		1)
			echo -e "\n\n\n[*]Enumerate and Vulnerability\n"
			enumvuln
        
		;;
		2)
			echo -e "\n\n\n[*]Password checker\n"
			pwchecker
		;;
		3)
			echo -e "\n\n\n[*]Reports"
			reports
		;;    
		4)
			exit
		;;

     
	esac
}


# enumvuln function is to enumerate the respective vulnebilities and store in a file
function enumvuln()
{	
	echo -e "\n\n[*]....Creating fol1der to store the report...."
	# Using forloop for create directories for the respective live host 
	for each_livehost in $livehost 
	do
		mkdir $each_livehost
	done
	
	# Diplay the live host
	cat livehost.lst
	# Storing the user input in a variable
	echo -e "\n[*]Input The Host's IP Address Listed Above: "
	read hostip
	# Using Nmap Vulner to enumerate vulnebilities and storing it in a file
	sudo nmap -sV -A --script=./scipag_vulscan/vulscan.nse "$hostip" -o "$hostip"/enum_vuln.res
	# Caling the main function to return back to the main menu
	main
}


# pwchecker function is to enable the user to check weak password usage
function pwchecker()
{
	
	# Display Live host
	cat livehost.lst
	# Storing the user input in a variable
	echo -e "\n[*]Please select the host's IP address above: "
	read hostip
	# Providing user options to choose 
	echo -e "\n\nWould you like to Brute Force \n1) Own password and user list, \n2) Own user name and create a new password list \n3) Common password and user file list: \n" 
	read -p "[*]Select the an option: " bruteforce
	case $bruteforce in
		
		1)
			# Storing the respective input in a variable
			echo -e "\n[*]Please specify the user list file: "
			read user1
			echo -e "\n[*]Please specify the password list file: "
			read passwd1
			echo -e "\n[*]Please specify the service protocol to Brute Force(E.g. ssh,ftp):"
			read servicename1
			echo -e "\n[*]Please specify the protocol number to Brute Force(E.g. 21,22):"
			read portn1
			# Using Hydra to brute force and storing it in a file
			sudo hydra -L "$user1" -P "$passwd1" "$hostip" "$servicename1" -s "$portn1" -t 1 -vV -I >> "$hostip"/bruteforce.txt
			
			main
		;;
		2)	
			# Storing users name in a variable
			echo "[*]Please specify the user name : "
			read user2
				
			# Using forloop for create passwordlist
			echo "Input password 5 times to creat a password list"
			for i in {1..5}; 
			do 
				echo "[*]Enter password : "
				read passwd2
				echo $passwd2 >> npasswd.lst
			done
			
			echo -e "\n Password list have list has been created and saved as (npasswd.lst)in the current directory. \n\n"
			# Storing the respective input in a variable
			echo "[*]Please specify the service protocol to Brute Force(E.g. ssh,ftp):"
			read servicename2
			echo "[*]Please specify the protocol number to Brute Force(E.g. 21,22):"
			read portn2
			# Using Hydra to brute force and storing it in a file
			sudo hydra -l "$user2" -P npasswd.lst "$hostip" "$servicename2" -s "$portn2" -t 1 -vV -I >>"$hostip"/bruteforce.txt
			
			main
		;;
		3)	# Creating a word list
			echo -e "123456\n123456789\nQwerty\nPassw0rd!\n12345\nmsfadmin\nadmin\n123123\nadmin\ntc" > 10commonpasswd.lst
			echo -e "myqsp\ninfo\npostgres\nguest\nnagios\nuser\noracle\nadmin\ntest\nroot\ntc" > 11commonuser.lst
			# Storing the respective input in a variable
			echo "[*]Please specify the service protocol to Brute Force(E.g. ssh,ftp):"
			read servicename3
			echo "[*]Please specify the protocol number to Brute Force(E.g. 21,22):"
			read portn3
			# Using Hydra to brute force and storing it in a file
			sudo hydra -L 11commonuser.lst -P 10commonpasswd.lst "$hostip" "$servicename3" -s "$portn3" -t 1 -vV -I >> "$hostip"/bruteforce.txt
			
			main
		;;
	esac	
}




function reports()
{
	# Display live host
	cat livehost.lst
	echo -e "\n"
	# To enable user to specify the directory and store it in a variable
	read -p "[*]Enter IP address directory: " ipdir
	echo -e "\n\n"
	# Change directory to the specific directory
	cd $ipdir
	# Using while loop to return back to the main menu
	while true 
	do

		ls
		# Storing the respective file in a variable
		read -p "[*]Enter the file the print the report:" file 
		# To display the file content 
		cat $file
		# To return to the previous directory
		cd ..
		main

	done
	}
main





