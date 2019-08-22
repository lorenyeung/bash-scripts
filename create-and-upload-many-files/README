This is a script collection that creates many files in batches, then uploads them to Artifactory.

spawn.sh
creates 10 repositories with a random ID + local, then passes it to the files.sh script (with X number of process ids for multi tasking.

files.sh
creates a random file, then splits it so that each is 100b in size. Uses JFrog CLI to upload

reupload.sh
script that can perform the upload, should the script fail/be halted before the upload process begins.

Notes:
Make sure to check that there is enough space! df -h is your friend. Also check the inodes, as this script creates many small files and you may run out of inodes before actual disk space is filled.
df -i /   

You'll need to download the JFrog cli and run ./jfrog rt c before this script will work. Could be modified to pass in the url and creds as well inline.
