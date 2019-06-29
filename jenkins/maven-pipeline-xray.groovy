node {
    def server = Artifactory.server('gcp-local')
    def rtMaven = Artifactory.newMavenBuild()
    def buildInfo

    stage ('Clone') {
        git url: 'https://github.com/jfrog/project-examples.git'
    }

    stage ('Artifactory configuration') {
        rtMaven.tool = 'maven' // Tool name from Jenkins configuration
        rtMaven.deployer releaseRepo: 'libs-release-local', snapshotRepo: 'libs-snapshot-local', server: server
        rtMaven.resolver releaseRepo: 'libs-release', snapshotRepo: 'libs-snapshot', server: server
        buildInfo = Artifactory.newBuildInfo()
    }

    stage ('Exec Maven') {
        rtMaven.run pom: 'maven-example/pom.xml', goals: 'clean install -U', buildInfo: buildInfo
    }

    stage ('Publish build info') {
        server.publishBuildInfo buildInfo
    }
    stage ('Xray indexability') {
    // bash script that adds build to index list, and to a watch that has a CI policy defined
        sh '''#!/bin/bash
        xray=localhost:8000
        user=admin
        pass=password
        art_id=artifactory
        build=${JOB_NAME}
        # Pre-defined watch and policy for builds
        gen_build_watch="general-build-watch"
        build_info=$(curl -su $user:$pass $xray/api/v1/binMgr/$art_id/builds | jq .)
        indexed_builds=$(echo $build_info | jq '.indexed_builds[]')
        if [[ ! $indexed_builds == *"$build"* ]]; then
            echo "build \"$build\" is not in the indexed build list, adding"
            update_indexed_build_count=$(echo $build_info | jq -r ".indexed_builds | length")
            update_indexed_build=$(echo $build_info | jq -c --arg build $build --arg update_indexed_build_count $update_indexed_build_count '.indexed_builds[$update_indexed_build_count | tonumber] += $build')
            # echo $update_indexed_build
            curl --data "$update_indexed_build" -su $user:$pass $xray/api/v1/binMgr/$art_id/builds -XPUT -H "Content-Type: application/json"
        fi
        
        builds_in_watches=$(curl -su $user:$pass $xray/api/v2/watches | jq '.[] | .project_resources | .resources[] | select (.type == "build") | .name')
        if [[ ! $builds_in_watches == *"$build"* ]]; then
            echo "build \"$build\" is not in a watch, adding"
            gen_watch_data=$(curl -su $user:$pass $xray/api/v2/watches/$gen_build_watch | jq .)
            update_resource_count=$(echo $gen_watch_data | jq '.project_resources | .resources | length')
            update_resource=$(echo $gen_watch_data | jq -c --arg build $build --arg update_resource_count $update_resource_count '.project_resources | .resources[$update_resource_count | tonumber] += {\"type\": \"build\", \"name\": $build, \"bin_mgr_id\": \"artifactory\"}')
            updated_watch_data=$(echo $gen_watch_data | jq ".project_resources = $update_resource")
            # echo $updated_watch_data
            curl --data "$updated_watch_data" -su $user:$pass $xray/api/v2/watches/$gen_build_watch -XPUT -H "Content-Type: application/json"
        fi'''
    }
    
    stage ('Xray scan') {
        def scanConfig = [
        'buildName'      : buildInfo.name,
        'buildNumber'    : buildInfo.number
        ]
        def scanResult = server.xrayScan scanConfig
        echo scanResult as String
    }
}
