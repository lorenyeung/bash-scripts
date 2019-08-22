#!/bin/bash

for f in run*; do
	echo "$f"
	./jfrog rt u "$f/" customer-$f-local/files/ --threads 10 --build-name name-$f --build-number number-$f --props "key1=$DATE;key2=$(openssl rand -hex 8);key3=$(openssl rand -hex 8);key4=$(openssl rand -hex 8)"
done
