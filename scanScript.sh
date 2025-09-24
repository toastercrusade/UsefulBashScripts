#!/bin/bash

# This script should be ran inside a file dedicated to its ouput files (with it inside the folder)

# IP_ADDR is automatically set to the ip of the system running the script, with the last character chopped off...
# ... which will be filled when the user inputs what ips they want to scan in Scan 1
IP_ADDR="$(ifconfig | awk '/inet / && $2 != "127.0.0.1" {print $2; exit}' | sed 's/.$//')"

# verify if the file exists or not
verify_file() {
	test -s "$1" && return 0 || return 1
}

# if live.txt exists, either overwrite it or end the script
if verify_file "./live.txt"; then
	printf "File \"./live.txt\" already exists!\n"
	printf "Would you like to overwrite it? (Y/N)\n"

	read answer

	if [[ "$answer" == "Y" ]]; then
		rm -f ./live.txt
		touch live.txt
	else
		printf "%s\n" "-----Ending Program-----"
		exit 1
	fi
else
	touch live.txt
	# printf "live.txt file created!\n"
fi

# Asks which ips to scan for scan 1
printf "\nWhat targets would you like to scan?\n"
printf "(Answer format(s): \"/24\" (scans all targets within the /24 subnet),\n" 
printf "\"x-y\" (x and y being whole numbers denoting the range of ips you want"
printf " to scan\n(.34.x - .34.y)),\n"
printf "or \"x, y, z...\" (variables being whole numbers denoting the fourth"
printf " octet of the\nips you want to scan)):\n"

read scan_input

printf "\nYour input: %s!\n" "$scan_input"

printf "%s\n" "-----Scan 1 Results-----" > "./live.txt"

# Sets IP_ADDR to the correct ip range/address...
# ...then scan them
if [[ "$scan_input" == "/24" ]]; then
	#printf "/24\n"
	IP_ADDR+="0/24"
	printf "\nStarting Scan 1...\n"
	nmap $IP_ADDR >> "./live.txt"
elif [[ "$scan_input" == *","* ]]; then
	#printf "commas\n"
	if [[ "$scan_input" == *" "* ]] ; then
		scan_input=$(echo "$scan_input" | sed 's/ *, */,/g')
	fi
	IP_ADDR+=$scan_input
	#printf "%s\n" "$IP_ADDR"
	printf "\nStarting Scan 1...\n"
	nmap $IP_ADDR >> "./live.txt"
elif [[ "$scan_input" == *"-"* ]]; then
	#printf "x-y\n"
	IP_ADDR+=$scan_input
	printf "\nStarting Scan 1...\n"
	nmap $IP_ADDR >> "./live.txt"
else
	printf "Invalid input!\n"
	printf "%s\n" "-----Ending Program-----"
	exit 1
fi

printf "Scan 1 Complete!\n\n"

# Gathers the ips of all the hosts that were identified
hosts=$(grep "Nmap scan report for" ./live.txt | awk '{print $5}')

#printf "Hosts:\n%s\n" "$hosts"

# if ports.txt exists, either overwrite it or end the script
if verify_file "./ports.txt"; then
	printf "File \"./ports.txt\" already exists!\n"
	printf "Would you like to overwrite it? (Y/N)\n"

	read answer

	if [[ "$answer" == "Y" ]]; then
		rm -f ./ports.txt
		touch ports.txt
	else
		printf "%s\n" "-----Ending Program-----"
		exit 1
	fi
else
	touch ports.txt
	# printf "ports.txt file created!\n"
fi

printf "%s\n" "-----Scan 2 Results-----" > "./ports.txt"

#scan the ports of the hosts
printf "\nStarting Scan 2...\n"
nmap -p- $hosts >> "./ports.txt"
printf "Scan 2 Complete!\n\n"

# if enumerated.txt exists, either overwrite it or end the script
if verify_file "./enumerated.txt"; then
	printf "File \"./enumerated.txt\" already exists!\n"
	printf "Would you like to overwrite it? (Y/N)\n"

	read answer3

	if [[ "$answer3" == "Y" ]]; then
		rm -f ./enumerated.txt
		touch enumerated.txt
	else
		printf "%s\n" "-----Ending Program-----"
		exit 1
	fi
else
	touch ports.txt
	# printf "enumerated.txt file created!\n"
fi

printf "%s\n" "------Scan 3 Results-----" > "./enumerated.txt"

# scan the OS and the services running on the hosts
printf "\nStarting Scan 3...\n"
nmap -O -sV $hosts >> "./enumerated.txt"
printf "Scan 3 Complete!\n\n"


# if web.html exists, either overwrite it or end the script
if verify_file "./web.html"; then
	printf "File \"./web.html\" already exists!\n"
	printf "Would you like to overwrite it? (Y/N)\n"

	read answer3

	if [[ "$answer3" == "Y" ]]; then
		rm -f ./web.html
		touch web.html
	else
		printf "%s\n" "-----Ending Program-----"
		exit 1
	fi
else
	touch web.html
	# printf "web.html file created!\n"
fi

printf "<html><h1>%s</h1><body>" "-----Scan 4 Results-----" > web.html

# if ./screenshots/ exists, either overwrite it or end the script
if [ -d "./screenshots" ]; then
	printf "\nThe \"./screenshots/\" directory already exists!\n"
	printf "Would you like to overwrite it? (Y/N)\n"

	read answer4

	if [[ "$answer4" == "Y" ]]; then
		rm -rf ./screenshots/
		mkdir ./screenshots/
	else
		printf "%s\n" "-----Ending Program-----"
		exit 1
	fi
else
	mkdir ./screenshots/
fi

# gather the ips of the hosts with services running on either port 80 or 443
web_hosts=($(awk '/Nmap scan report for/ {webHost=$5} /80\/tcp open/ || /443\/tcp open/ {print webHost}' ./ports.txt | sort -u))

# take a screenshot on firefox of the identified hosts, and then put those screenshots both in web.html and in ./screenshots/
printf "\nStarting Scan 4...\n"
for host in "${web_hosts[@]}"; do
	screenshot_file="$(realpath ./)"
	screenshot_file+="/screenshots/${host}.png"

	firefox --headless --screenshot "$screenshot_file" "http://$host" > /dev/null 2>&1

	printf "<h3>$host</h3><img src='$screenshot_file' alt='screenshot of $host'/>" >> "./web.html"
done
printf "</body></html>" >> "./web.html"
printf "Scan 4 Complete!\n\n"


printf "%s\n" "-----Ending Program-----"

exit 0
