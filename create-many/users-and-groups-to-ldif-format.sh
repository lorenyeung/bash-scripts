#!/bin/bash

user=user
group=group
dc_options="dc=example,dc=org"
user_ou=thousandUsers
group_ou=thousandGroups
gidnumber=10000

for i in {1..1000}; do
	printf "\
dn: cn=$user$i,ou=$user_ou,dc=example,dc=org\n\
changetype: add\n\
cn:  $user$i\n\
objectClass: inetOrgPerson\n\
sn: $user$i\n\
uid: $user$i\n\
userPassword: {MD5}X03MO1qnZdYdgyfeuILPmQ==\n\

dn: cn=$group$i,ou=$group_ou,dc=example,dc=org\n\
changetype: add\n\
cn: $group$i\n\
objectClass: top\n\
objectClass: posixGroup\n\
gidNumber: $gidnumber\n\
memberUid: $user$i\n\
memberUid: lyeung\n\n" >> example.ldif
	gidnumber=$((gidnumber + 1))
done
