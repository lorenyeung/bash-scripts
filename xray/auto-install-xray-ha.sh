#!/bin/bash

#First node installation
mkdir /var/opt/jfrog/xray1/data
home="/var/opt/jfrog/xray1/data"
postgres="postgres://xray1:xray@postgres:5432/xraydb?sslmode=disable"
mongodb="mongodb://xray1:password@mongodb:27017/?authSource=xray&authMechanism=SCRAM-SHA-1"
version=2.7.0
# Home dir - either enter a directory or just \n for default. No for "adding to cluster". No for installing pg. No for installing mongo. Pass in pg string. Pass in mongo string.
printf $home'\nn\nn\nn\n'$postgres'\n'$mongodb'\n' | ./xray-ubuntu-$version/installXray-ubuntu.sh;
# if you get "invalid option" its likely that something was messed up. Try removing the "installer.info" file and trying again. You may need to uninstall xray as well.
