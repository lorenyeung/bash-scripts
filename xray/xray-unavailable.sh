#!/bin/bash
# Purpose: This script is a fix for a weird bug where Artifactory does not healthcheck xray properly and marks it as "unavailable
# even though xray is up and reachable
# can set a crontab with crontab -e and entering something like */15 * * * * /home/loreny/scripts/xray-unavailable.sh
arti_url=http://localhost:8081/artifactory
arti_creds=admin:password
while true; do
    ui=$(curl -is $arti_url/ui/auth/current -u $arti_creds | grep "Artifactory-UI-messages")
    if [[ "$ui" == *"unavailable"* ]]; then
        curl -X POST $arti_url/ui/xrayRepo/setXrayEnabled -d '{"xrayEnabled": false }' -H "Content-type: application/json" -u $arti_creds
        curl -X POST $arti_url/ui/xrayRepo/setXrayEnabled -d '{"xrayEnabled": true }' -H "Content-type: application/json" -u $arti_creds
        echo "Fixing Xray"
    else
        break;
    fi
    sleep 5
done
