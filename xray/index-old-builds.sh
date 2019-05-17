#!/bin/bash
# Author: loren Y
echo "Welcome to the internal Xray historical build indexer. This script will send an index request for Builds that were performed prior to the Xray connection." 
arti_url=""
xray_url=""
arti_creds=""
xray_creds=""
bin_mgr=""

#logging mechanism
__VERBOSE=$2
if [ -z "$__VERBOSE" ];then
    __VERBOSE=3
fi
case "$2" in
    warning)
        __VERBOSE=4;;
    info)
        __VERBOSE=6;;
    debug)
        __VERBOSE=7;;
    trace)
        __VERBOSE=8;;
esac

declare -a LOG_LEVELS
# https://en.wikipedia.org/wiki/Syslog#Severity_level
LOG_LEVELS=([0]="emerg" [1]="alert" [2]="critical" [3]="error" [4]="warning" [5]="notice" [6]="info" [7]="debug" [8]="trace")
function .log () {
  local LEVEL=${1}
  shift
  if [ ${__VERBOSE} -ge ${LEVEL} ]; then
    tput setaf $LEVEL
    case  "$LEVEL" in
        0)
            tput setaf 1;;
        1)
            tput setaf 1;;
        2)
            tput setaf 1;;
        3)
            tput setaf 1;;
        4)
            tput setaf 3;;
        5)
            tput setaf 8;;
        6)
            tput setaf 8;;
        7)
            tput setaf 0;;
        8)
            tput setaf 4;;
    esac
    echo "[${LOG_LEVELS[$LEVEL]}]" "$@"
    tput sgr0
    CURL_SILENT="Lv"
  fi
}

setup() {
    while true; do
        echo "Enter your Artifactory URL (e.g. http://localhost:8081/artifactory):"
        read arti_url
        if [ "$(curl -s $arti_url/api/system/ping)" != "OK" ]; then
            echo "Artifactory doesn't look to be either running or reachable from here, or there is a typo in the url $arti_url. Please try again:"
        else
            break
        fi
    done
    while true; do
        echo "Enter your $arti_url username:"
        read username
        echo "Enter your $arti_url password:"
        read -s password
        test_arti_creds=$(curl -su $username:$password $arti_url/api/system/ping)
        if [ "$test_arti_creds" != "OK" ] ; then 
            echo "Oh no. $(echo $test_arti_creds | jq -r '.errors[] | .message')"
        else
            echo "Artifactory credentials are good."
            arti_creds="$username:$password"
            password="clear"
            break
        fi
    done
    while true; do
        echo "Enter your Xray URL (e.g. http://localhost:8000):"
        read xray_url
        if [ "$(curl -s $xray_url/api/v1/system/ping | jq -r .status)" != "pong" ]; then
            echo "Xray doesn't look to be either running or reachable from here, or there is a typo in the url $xray_url. Please try again:"
        else
            break
        fi
    done
    echo "Enter your $xray_url username:"
    read username
    echo "Enter your $xray_url password:"
    read -s password
    xray_creds="$username:$password"
    echo "Getting binary manager from Xray"
    bin_mgr=$(curl -su $xray_creds $xray_url/api/v1/binMgr | jq -r '.[] | .binMgrId')
    echo "Before proceeding, be sure to 1. ensure builds are selected for indexing and 2. each build is assigned to a watch with a CI action defined."
}

index() {
    echo "How would you like to perform indexing?"
    select sel in "All" "Number" "Select"; do
        case $sel in
            All ) break;;
            Number ) break;;
	        Select ) break;;
    	esac
    done
    echo $sel
    builds_array=$(curl -su $arti_creds $arti_url/api/build | jq -r '.builds[] | .uri' | sed 's/\///')
    if [ "$sel" = "Number" ]; then
        echo "Which builds do you wish to index? Please separate each number by a space."
        counter=0
        for i in ${builds_array[@]}; do
            echo "$counter $i"
            let 'counter++'
        done
        read selection
        selection=$(echo $selection | sed 's/[^0-9 ]//g')
        counter2=0
        for n in ${builds_array[@]}; do
            for m in $selection; do
                if [ "$counter2" == "$m" ]; then
                    array=$(curl -su $arti_creds "$arti_url/api/build/$n" | jq -r '.buildsNumbers[] | .uri' | sed 's/\///')
                    for j in ${array[@]}; do
                        echo "indexing Build $n $j"
                        curl -XPOST $xray_url/api/v1/scanBuild -u $xray_creds -H "Content-type: application/json" -d '{"artifactoryId":"'$bin_mgr'","buildName":"'$n'","buildNumber":"'$j'"}'
                    done
                fi
            done
            let 'counter2++'
        done
        exit
    fi
    builds_array=$(curl -su $arti_creds $arti_url/api/build | jq -r '.builds[] | .uri' | sed 's/\///')
    for i in ${builds_array[@]}; do
        array=$(curl -su $arti_creds "$arti_url/api/build/$i" | jq -r '.buildsNumbers[] | .uri' | sed 's/\///')
        noSkip=true
        if [ "$sel" = "Select" ]; then
            echo "Do you want to index Build $i?"
            select yn in "Yes" "No"; do
                case $yn in
                    Yes ) break;;
                    No ) noSkip=false; break;;
                esac
            done
        fi
        if $noSkip; then
            for j in ${array[@]}; do
                echo "indexing Build $i $j"
                curl -XPOST $xray_url/api/v1/scanBuild -u $xray_creds -H "Content-type: application/json" -d '{"artifactoryId":"'$bin_mgr'","buildName":"'$i'","buildNumber":"'$j'"}'
            done
        fi
    done
}

# main
if [ "$1" != "silent" ]; then
    setup
else
    arti_url="http://localhost:8081/artifactory"
    xray_url="http://localhost:8000"
    arti_creds="admin:password"
    xray_creds="admin:password"
    bin_mgr="artifactory"
fi
index
