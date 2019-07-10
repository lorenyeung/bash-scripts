#!/bin/bash
# install a metric ton of npm packages. Enter a number following the script name to spawn X number of workers. You'll want to run in a folder. Assumes anonymous download permission

script_name=`basename "$0"`
dl_folder=npm-downloads-tgz
art_url=http://localhost:8081/artifactory

if [ ! -f all-npm.json ]; then
curl https://replicate.npmjs.com/_all_docs > all-npm.json
fi
if [ ! -f all-npm-id.txt ]; then
cat all-npm.json | jq -r '.rows[] | .id' > all-npm-id.txt
fi
if [ ! -d $dl_folder ]; then
    mkdir $dl_folder
fi

function install {
    init_skip=0
    count=$2
    while read -r line
    do
        if [ $init_skip -lt $1 ]; then
            let "init_skip++"
            continue
        fi
        if [ $count -lt $2 ]; then
            let "count++"
            continue
        else
            count=0
            key=($(curl -s $art_url/api/npm/npm/$line | jq -r '.versions | keys[]'))
            for i in "${key[@]}"; do
                tarball=$(curl -s $art_url/api/npm/npm/$line | jq -r ".versions | .\"$i\" | .dist | .tarball")
                curl -so npm-downloads-tgz/$line-$i.tgz $tarball & 
            done 
        fi
    done < all-npm-id.txt
}

function cleanup {
    while true; do
        sleep 5
        echo "Cleaning up tgzs.."
        rm $dl_folder/*.tgz
    done
}

skip=$1
if [ -z "$skip" ]; then
    echo "please enter worker thread count"
    exit
fi
if [ "$1" == "stop" ]; then
    echo "Final clean up"
    rm $dl_folder/*.tgz
    echo "stopping all pids associated with $script_name"
    kill $(ps -ef | grep $script_name | awk '{print $2}')
    exit
fi

let "skip--"
for ((i=0;i<=$skip;i++)); do
    echo "spawning worker $i"
    install "$i" "$skip" &
done

# trigger clean up function every 5 seconds
cleanup
