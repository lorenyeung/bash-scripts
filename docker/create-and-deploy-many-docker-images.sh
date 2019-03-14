#!/bin/bash
#
# Purpose: Create and deploy a lot of docker images to Artifactory
# Requirements:  docker
# Author: Loren Y
#
version=0
org=0
group=0

# set these accordingly if you want to skip the select statements below
artifactory=10.128.0.51:8081
method=RepositoryPath
repo=docker-local
image=larger-test
user=admin
pass=password

declare -a docker_id=("httpd" "docker" "python" "jetty" "node" "vault" "influxdb" "neo4j" "ghost" "sentry" "sonarqube" "jenkins" "maven" "logstash" "tomcat" "gradle" "jruby" "solr" "groovy" "elasticsearch" "openjdk" "nextcloud" "telegraf" "php" "traefik" "redmine" "wordpress" "owncloud" "drupal" "perl" "golang" "ruby" "rethinkdb" "redis" "rabbitmq" "postgres" "percona" "mongo" "memcached" "kibana" "mariadb" "haproxy" "cassandra" "buildpack-deps" "debian" "kong" "fedora" "ubuntu" "composer" "nats" "busybox" "amazonlinux" "consul" "registry" "alpine" "swarm" "java")

# enter artifactory if not hard coded
if [ -z "$artifactory" ]; then
read -p "Please enter your Artifactory URL and port [10.128.0.51:8081]: " artifactory
artifactory=${artifactory:-10.128.0.51:8081}
read -p "Please enter your Artifactory user [admin]: " user
user=${user:-admin}
read -p "Please enter your Artifactory password [password]: " pass
pass=${pass:-password}
fi

# enter repo if not hard coded
if [ -z "$repo" ]; then
read -p "Please enter your Docker repository on Artifactory [docker-local]: " repo
repo=${repo:-docker-local}
fi

# choose method if not hard coded
if [ -z "$method" ]; then
    echo "Choose your docker method:" 
    select yn in "RepositoryPath" "Subdomain" "Ports"; do
        case $yn in
            RepositoryPath ) method=$yn; break;;
            Subdomain ) method=$yn; artifactory=$repo.$artifactory; break;;
		        Ports ) method=$yn; break;;
        esac
    done
fi
echo "You have selected $method"

docker login $artifactory -u $user -p $pass
declare -a size0=("5" "6" "7")
declare -a size1=("1" "2" "3" "4" "5" "6" "7" "8" "9")

for n in {1..90000}; do
   size1_sel=${size1[$RANDOM % ${#size1[@]}]}
   size0_sel=${size0[$RANDOM % ${#size0[@]}]}
   head -c "$size0_sel$size1_sel"000000 </dev/urandom > $n-$image
   selected=${docker_id[$RANDOM % ${#docker_id[@]} ]}
   touch Dockerfile
   echo "FROM $selected" > Dockerfile
   echo "ADD $n-$image /" >> Dockerfile
   echo "Created $selected $size0_sel$size_sel size file"
   version=$(($version+1))
   epoch=$(date +%s)
   case $method in
	RepositoryPath ) image_name=$artifactory/$repo/org-$org/group-$group/version-$version/$n-$image:$epoch; ;;
	Subdomain ) image_name=$artifactory/org-$org/group-$group/version-$version/$n-$image:$epoch; ;;
	Ports ) image_name=$artifactory/org-$org/group-$group/version-$version/$n-$image:$epoch; ;;
    esac   
    echo "Building image: $image_name"
	exit
   if [ $version -ge 50 ]; then
       group=$(($group+1))
       version=0
   fi

   if [ $group -ge 50 ]; then
       org=$(($org+1))
       group=0
   fi
   docker build . -t $image_name
   rm Dockerfile
   docker push $image_name
   rm $n-$image
   docker rmi $image_name
done
