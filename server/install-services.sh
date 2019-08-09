#!/bin/bash
# THIS IS WIP, not complete
HOST=<Your host here>

# Bamboo
docker volume create --name bambooVolume
docker volume create —-name bambooAgentVolume
docker network create bamboo
docker run -v bambooVolume:/var/atlassian/application-data/bamboo --name bamboo-server --network bamboo --hostname bamboo-server --init -d -p 8085:8085 atlassian/bamboo-server
docker run -v bambooAgentVolume:/home/bamboo/bamboo-agent-home --name bamboo-agent --network bamboo --hostname bamboo-agent --init -d atlassian/bamboo-agent-base http://bamboo-server:8085

# Openldap/PhpLdapAdmin
docker run --name ldap-service --hostname $HOST --detach -p 389:389 -p 636:636 osixia/openldap
docker run --name phpldapadmin-service --hostname $HOST --link ldap-service:ldap-host --env PHPLDAPADMIN_LDAP_HOSTS=ldap-host -p 82:80 -p 445:443 --detach osixia/phpldapadmin

# Mailhog
docker run —name mailhog -d -p 1025:1025 8025:8025 mailhog/mailhog

# Jenkins
docker volume create —name jenkinsVolume
docker run —name Jenkins -d -p 8080:8080 -p 50000:50000 -v jenkinsVolume:/var/jenkins_home jenkins/jenkins

# Teamcity
docker run -it --name teamcity-server-instance  \
    -v <path to data directory>:/data/teamcity_server/datadir \
    -v <path to logs directory>:/opt/teamcity/logs  \
    -p <port on host>:8111 \
    jetbrains/teamcity-server
    
# set restart to always for all containers
docker update --restart=always $(docker ps -aq)
