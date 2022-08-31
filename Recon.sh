#!/bin/bash

domain=$1
RED="\033[1;31m"
RESET="\033[0m"
censys=$1

info_path=$domain/info
subdomain_path=$domain/subdomain
screenshot_path=$domain/screenshots
directory_enum=$domain/directory_enum
gau=$domain/gau
ip=$domain/ip
misc=$domain/misc

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
if [ ! -d "$gau" ];then
        mkdir $gau
fi

if [ ! -d "ip" ];then
        mkdir $ip
fi
if [ ! -d "$misc" ];then
        mkdir $misc
fi


echo -e "${RED} [+] Checking who it is ... ${RESET}"
whois $1 > $info_path/whois.txt

echo -e "${RED} [+] Running Censys for IP Scan... ${RESET}"
censys search ' services.tls.certificates.leaf_data.subject.common_name: "$censys"' --index-type hosts | jq -c '.[] | {ip: .ip}' > ip.txt


echo -e "${RED} [+] Launching subfinder ... ${RESET}"
subfinder -d $domain -all > $subdomain_path/found.txt

echo -e "${RED} [+] Running assetfinder... ${RESET}"
assetfinder $domain | grep $domain >> $subdomain_path/found.txt

echo -e "${RED} [+] Launching SubDomainizer... ${RESET}"
sudo SubDomainizer.py -u $domain >> $misc/subdomainizer.txt
cat $misc/subdomainizer.txt | grep "$domain" >> $subdomain_path/found.txt


echo -e "${RED} [+]Launching AMASS Scanner... ${RESET}"
#amass enum -d $domain -passive -active -brute -w ~/tools/86a06c5dc309d08580a018c66354a056/all.txt >> $subdomain_path/found.txt


echo -e "${RED} [+] Checking What's Alive... ${RESET}"
cat $subdomain_path/found.txt | sort -u | httpx | grep https | sed 's/https\?:\/\///' | tee -a $subdomain_path/alive.txt
cat $subdomain_path/found.txt | sort -u | httpx -title -tech-detect -status-code >> $subdomain_path/techdetect.txt

echo -e "${RED} [+] Taking the Screenshots... ${RESET}"
#gowitness file -f $subdomain_path/alive.txt -P $screenshot_path/ --no-http

echo -e "${RED} [+] Starting Directory Enumneration using Gobuster... ${RESET}"

#for i in `cat $subdomain_path/alive.txt`
#do
#   gobuster dir -u https://$i -w /usr/share/wordlists/dirb/big.txt >> $directory_enum/Dir_enum.txt
#done

echo -e "${RED} [+]Doing FFUF subdomain enum...${RESET}"

echo -e "${RED} [+] This may take some time... Make sure you take a break and have a walk....${RESET}"

#for i in `cat $subdomain_path/alive.txt`
#do
#       ffuf -u https://$i/FUZZ -w /usr/share/wordlists/amass/all.txt -c  >> $directory_enum/ffuf_enum.txt
#done

echo -e "${RED} [+] Running Automated Tool Nikto... ${RESET}"
nikto -h $subdomain_path/found.txt >> $misc/nikto_result.txt

echo -e "${RED} [+] Getting all urls and checking probable XSS....${RESET}"
echo "$1" | gau | kxss >> $gau/gau_xss.txt

echo -e "${RED} [+] Running Nuclei Scanner... Maybe It Will give you some Info.... ${RESET}"
cat $subdomain_path/alive.txt | httpx | nuclei >> $domain/nuclei.txt

echo -e "DONE"
