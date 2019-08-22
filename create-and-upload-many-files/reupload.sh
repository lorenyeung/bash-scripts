#!/bin/bash

for f in run*; do
	echo "$f"
	./jfrog rt u "$f/" customer-$f-local/files/ --threads 10 --build-name name-$f --build-number number-$f  
done
