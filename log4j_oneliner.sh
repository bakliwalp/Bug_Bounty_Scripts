#!/bin/bash

subfinder -d ups.com -silent -all | httpx -silent -threads 80 -ports 80,443,8080,8443,4443,4000,5000,9001 | nuclei -tags log4j
