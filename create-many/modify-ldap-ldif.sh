#!/bin/bash

user=user
group=group
dc_options="dc=example,dc=org"
user_ou=users
group_ou=groups
gidnumber=10000

for i in {1..1000}; do
	printf "\
dn: cn=$group$i,ou=groups,dc=example,dc=org\n\
changetype: modify\n\
add: memberUid\n\
memberUid: lyeung\n\n" >> example.ldif
done
