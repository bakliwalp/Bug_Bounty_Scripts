#!/bin/bash

subfinder -d globality.com -silent -all | httpx -silent -o globality_httpx.txt; for i in $(cat globality_httpx.txt); do DOMAIN=$(echo $i | unfurl format %d); ffuf -u $i/FUZZ -w /usr/share/wordlists/dirb/common.txt -o ${DOMAIN}_ffuf.txt; done
