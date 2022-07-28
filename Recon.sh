#!/bin/bash

domain=$1
RED="\033[1;31m"
RESET="\033[0m"

info_path=$domain/info
subdomain_path=$domain/subdomain
screenshot_path=$domain/screenshots
directory_enum=$domain/directory_enum


if [ ! -d "$domain" ];then
        mkdir $domain
fi

if [ ! -d "$info_path" ];then
        mkdir $info_path
fi
if [ !  -d "$subdomain" ];then
        mkdir $subdomain_path
fi
if [ ! -d "$screenshots" ];then
        mkdir $screenshot_path
fi
if [ ! -d "$directory_enum" ];then
        mkdir $directory_enum
fi

echo -e "${RED} [+] Checking who it is ... ${RESET}"
whois $1 > $info_path/whois.txt

echo -e "${RED} [+] Launching subfinder ... ${RESET}"
subfinder -d $domain -all > $subdomain_path/found.txt

echo -e "${RED} [+] Running assetfinder... ${RESET}"
assetfinder $domain | grep $domain >> $subdomain_path/found.txt

echo -e "${RED} [+]Launching AMASS Scanner... ${RESET}"
amass enum -d $domain >> $subdomain_path/found.txt


echo -e "${RED} [+] Checking What's Alive... ${RESET}"
cat $subdomain_path/found.txt | grep $domain | sort -u | httprobe -prefer-https | grep https | sed 's/https\?:\/\///' | tee -a $subdomain_path/alive.txt

echo -e "${RED} [+] Taking the Screenshots... ${RESET}"
gowitness file -f $subdomain_path/alive.txt -P $screenshot_path/ --no-http

echo -e "${RED} [+] Starting Directory Enumneration using Gobuster... ${RESET}"

for i in `cat $subdomain_path/alive.txt`
do
    gobuster dir -u https://$i -w /usr/share/wordlists/dirbuster/directory-list-1.0.txt --discover-backup >> $directory_enum/Dir_enum.txt
done

echo -e "${RED} [+]Doing FFUF subdomain enum...${RESET}"

echo -e "${RED} [+] This may take some time... Make sure you take a break and have a walk....${RESET}"

for i in `cat $subdomain_path/alive.txt`
do
        ffuf -u https://$i/FUZZ -w /usr/share/wordlists/amass/all.txt -recursion >> $directory_enum/ffuf_enum.txt
done
echo -e "DONE"