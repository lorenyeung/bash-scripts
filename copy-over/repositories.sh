#!/bin/bash
SOURCE_ARTI_CREDS="admin:password"
TARGET_ARTI_CREDS="admin:password"
SOURCE_ARTI_URL="http://<SOURCE>/artifactory"
TARGET_ARTI_URL="http://<TARGET>/artifactory"
# PUT will fail if the repository already exists. It will also fail for virtual creation if it references a virtual that has not been created yet. In that case, you need to run the script again.
declare -a ALL_REPOSITORIES
ALL_REPOSITORIES=($(curl -su $SOURCE_ARTI_CREDS "$SOURCE_ARTI_URL/api/repositories" | jq -r '.[]| .key' | sed 's/ /%20/g'))
for elem in "${ALL_REPOSITORIES[@]}"; do
    echo $elem
    JSON=$(curl -su $SOURCE_ARTI_CREDS "$SOURCE_ARTI_URL/api/repositories/$elem")
    curl -XPUT -su $TARGET_ARTI_CREDS "$TARGET_ARTI_URL/api/repositories/$elem" -d ''"$JSON"'' -H "Content-Type: application/json"
done
