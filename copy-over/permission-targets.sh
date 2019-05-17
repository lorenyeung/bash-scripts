#!/bin/bash
SOURCE_ARTI_CREDS="admin:password"
TARGET_ARTI_CREDS="admin:password"
SOURCE_ARTI_URL="http://source:8081/artifactory"
TARGET_ARTI_URL="http://target:8081/artifactory"
# does not check whether repositories, groups, users exist - the PUT will fail if missing
declare -a ALL_PERM_TARGETS
ALL_PERM_TARGETS=($(curl -su $SOURCE_ARTI_CREDS "$SOURCE_ARTI_URL/api/security/permissions" | jq -r '.[]| .name' | sed 's/ /%20/g'))
for elem in "${ALL_PERM_TARGETS[@]}"; do
    echo $elem
    JSON=$(curl -su $SOURCE_ARTI_CREDS "$SOURCE_ARTI_URL/api/security/permissions/$elem")
    curl -XPUT -su $TARGET_ARTI_CREDS "$TARGET_ARTI_URL/api/security/permissions/$elem" -d ''"$JSON"'' -H "Content-Type: application/json"
done
