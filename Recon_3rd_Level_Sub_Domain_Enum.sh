#!/usr/bin/env bash
if [ $# -gt 2 ]; then
echo "Usage ./script.sh <domain>"
echo "Example: ./script.sh yahoo.com"
fi
mkdir "$1"
if [ ! -d "thirdlevels" ]; then
mkdir "$1"/thirdlevels
fi
if [ ! -d "scans" ]; then
mkdir "$1"/scans
fi
if [ ! -d "eyewitness" ]; then
mkdir "$1"/eyewitness
fi
if [ ! -d "email" ]; then
mkdir "$1"/email
fi
pwd=$(pwd)
echo -e "\e[1m\e[35m Finding Emails...\e[0m"
emailfinder -d "$1" | tee "$1"/email/email.txt
echo -e "\e[1m\e[35m Email findings Done and Saved \e[0m"
echo -e "\e[1m\e[35m Gathering Subdomains using AMASS...\e[0m"
amass enum -active -d "$1" | tee "$1"/final.txt
echo -e "\e[1m\e[35m Subdomain Enumeration Completed using AMASS\e[0m"
echo -e "\e[1m\e[35m Gathering Subdomains using Sublist3r...\e[0m"
sublist3r -d "$1" -o ~/bug/"$1"/final.txt
echo -e "\e[1m\e[35m Subdomain Enumeration Completed using Sublist3r\e[0m"
echo -e "\e[1m\e[35m Gathering Subdomains using Assetfinder...\e[0m"
~/go/bin/assetfinder --subs-only "$1" | tee -a "$1"/final.txt
echo -e "\e[1m\e[35m Subdomain Enumeration done using Assetfinder\e[0m"
echo "$1" >> "$1"/final.txt
echo -e "\e[1m\e[35m Compiling third level domains...\e[0m"
cat "$1"/final.txt | grep -Po "(\w+\.\w+\.\w+)$" | sort -u >> "$1"/third-level.txt
echo -e "\e[1m\e[35m Gathering full third-level domains with Sublist3r...\e[0m"
for domain in $(cat "$1"/third-level.txt); do
sublist3r -d "$domain" -o ~/bug/"$1"/thirdlevels/domain.txt; cat ~/bug/"$1"/thirdlevels/domain.txt | sort -u >> final.txt;
done
echo -e "\e[1m\e[35m Third Level Subdomain Enumeration Done\e[0m"
if [ $# -eq 2 ]; then
echo -e "\e[1m\e[35m Probing for alive third-levels...\e[0m" cat "$1"/final.txt | sort -u | grep -v "$2" | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ":443" > "$1"/probed.txt
else
echo -e "\e[1m\e[35m Probing for alive third-levels...\e[0m" cat "$1"/final.txt | sort -u | httprobe -s -p https:443 \ sed 's/https\?:\/\///' | tr -d ":443" > "$1"/probed.txt
fi
echo -e "\e[1m\e[35m Httprobe Scanning has been Completed\e[0m"
echo -e "\e[1m\e[35m Scannig for open ports\e[0m"
nmap -iL ~bug/"$1"/final.txt -sV -sC -Pn -T5 -oA ~/bug/"$1"/scans/scanned
echo -e "\e[1m\e[35m Nmap Scan Finished\e[0m"
echo -e "\e[1m\e[35m Exiting...\e[0m"
exit 