#!/bin/bash

subfinder -d globality.com -all -silent | waybackurls | gf redirect | qsreplace 'http://example.com' | httpx -fr -title -match-string "Example Domain"
