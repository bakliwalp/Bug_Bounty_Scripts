#!/bin/bash

subfinder -d disney.com -silent -all | httpx -silent -threads 100 | nuclei -id CVE-2022-26138 -v
