#!/bin/bash
bs=1288
art=http://localhost:8081/artifactory
creds=admin:password
empty=($(curl $art/api/storageinfo -u $creds | jq -r '.repositoriesSummaryList[] | select(.filesCount==0) | .repoKey'))
for i in "${empty[@]}"; do
	if [[ $i == *"customer-run-"* ]]; then
		echo "deleting $i"
		curl -XDELETE -u $creds $art/api/repositories/$i
	continue
	fi
	echo "skipping delete of $i"
done
for i in {1..10};do
	ID=$(openssl rand -hex 8)
	mkdir run-$ID
	echo "creating local customer-run-$ID-local"
	curl -u $creds -XPUT $art/api/repositories/customer-run-$ID-local -H "Content-type: application/json" --data '{"rclass": "local", "packageType": "generic"}'
	echo "spawning worker $i with bytesize $bs"
	./files.sh $bs $ID &
	let "bs++"
done
echo "complete 10 runs, starting inode checker"
while true; do
	echo "running inode"	
	inode=$(df -i / | grep -v "I" | awk '{print $5}' | sed 's/%//g')	
	echo "$inode"
	if [ $inode -ge 90 ]; then
		echo "uh oh, inode usage is over 90%, killing split to force upload"
		kill -9 $(ps -ef | grep split | awk '{print $2}')
		break
	fi
	sleep 30
done
