#!/bin/bash
bs=$1
ID=$2
DATE=$(date)
echo "splitting massive file with byte size $bs"
dd if=/dev/urandom bs=$bs count=50400 | split -a 5 -b 100 - run-$ID/file.
echo "uploading via cli"
./jfrog rt u "run-$ID/" customer-run-$ID-local/files/ --threads 50 --build-name name-$ID --build-number number-$ID --props "key1=$DATE;key2=$(openssl rand -hex 8);key3=$(openssl rand -hex 8);key4=$(openssl rand -hex 8)"
