#!/bin/bash

# this script checks for helm charts that aren't indexing properly and thus are missing helm properties
# perhaps due to having an empty requirements.yaml. 

arti_creds="admin:password"
arti_url="http://localhost:8081/artifactory"
repo="helm"
files=($(curl -v -u $arti_creds "$arti_url/api/storage/$repo/charts/?list" | jq -r '.files[] | .uri'))
bad_charts=()
helm_prop="chart.name"

for i in "${files[@]}"; do
	echo "Checking chart $i for property $helm_prop"
	properties=$(curl -su $arti_creds "$arti_url/api/storage/$repo/charts$i?properties")
        # Uncomment echo if you want to see the property findings for all
	#echo $properties
	if [[ ! "$properties" = *"$helm_prop"* ]]; then
		echo "no $helm_prop property found for $i"
		bad_charts+=($i)
	fi
done

echo "List of charts with out the property $helm_prop:"
for j in "${bad_charts[@]}"; do
	echo $j
done
