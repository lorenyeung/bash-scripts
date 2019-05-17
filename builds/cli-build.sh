#!/bin/bash
art_url=http://localhost:8081/artifactory
art_user=admin
art_pass=password
art_cred="$art_user:$art_pass"
art_repo=generic-local
build=test-generic
latest_build=""
test_binary_name=docker-example.txt
declare -a builds
date=$(date)
builds_raw=$(curl -su $art_cred $art_url/api/build/$build)

# check if build exists
if [[ ! "$builds_raw" == *"No build was found for build name: $build"* ]]; then
	builds=$(echo $builds_raw | jq -r '.buildsNumbers[] | .uri' | sed 's/\///g')
	# get largest build number
	for i in ${builds[i]}; do
		latest_build="$i"
	done 
fi
# increment 
let "latest_build = $latest_build + 1"
echo "Building number $latest_build of $build"
if [ ! -f "$test_binary_name" ]; then
	echo "Example binary $test_binary_name doesn't exist, creating something arbituary.." 
	echo "this is a binary test $date" > $test_binary_name 
fi

echo "Uploading $test_binary_name to $art_url/$art_repo as build $latest_build of $build"
jfrog rt u --url=$art_url --user=$art_user --password=$art_pass --build-name=$build --build-number=$latest_build $test_binary_name $art_repo
echo "Publishing build $build"
jfrog rt bp --url=$art_url --user=$art_user --password=$art_pass $build $latest_build
