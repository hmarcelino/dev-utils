#!/bin/bash

# Usage: mgc mongo-restore -o <destination_host> -n <database_name> -t <dumpdir> [-u <username>]
# Summary: Restores a dump directory onto the specified MongoDB database
#
# Help: Restores a directory onto a MongoDB database
#
#   Optional:
#      -d : the destination database host
#      -n : the database name
#      -s : the source directory
#      -u : username (mongo-dump will ask for password)
#      -a : sync all databases
#
#  * Example:
#       $> mgc mongo-restore -d mongodb.host:27017 -n personalisation -s dumpdir
#
# This implementation was based on https://github.com/sheharyarn/mongo-sync
#

source $_MGC_ROOT/share/utils.sh

host=""
db_name=""
dumpdir=""
username=""
password=""
all_databases=""

while getopts "d:n:s:u:a" optname
do
    case "$optname" in
        "d")
            host="$OPTARG"
        ;;
        "n")
            db_name="$OPTARG"
        ;;
        "s")
            dumpdir="$OPTARG"
        ;;
        "u")
            username="$OPTARG"
        ;;
        "a")
            all_databases="true"
        ;;
        "?")
            echo "Unknown option $OPTARG"
            exit 1
        ;;
        ":")
            echo "No argument value for option $OPTARG"
            exit 1
        ;;
        *)
            # Should not occur
            echo "Unknown error while processing options"
            exit 1
        ;;
    esac
done

if [[ $host == "" ]] || [[ $dumpdir == "" ]]; then
  printError "Missing arguments. Check help information\n"
  mgc help mongo-restore
  exit 1
fi

if [[ $db_name == "" ]] && [[ $all_databases == "" ]]; then
  printError "Missing arguments. Either the -n or -a option must be used.\n"
  mgc help mongo-restore
  exit 2
fi

if [[ ! -d $dumpdir ]]; then
  printError "Dump directory does not exist\n"
  mgc help mongo-restore
  exit 2
fi

userpass_section=""
if [[ $username != "" ]]; then
    printf "Password: "
    password=$(get_password)
    userpass_section="-u $username -p $password"
fi

db_name_command=""
if [[ $all_databases == "" ]]; then
    db_name_command="-d $db_name"
fi

# numThreads is being used to avoid I/O errors
echo "Overwriting remote database with $dumpdir... "
mongorestore \
    -h "$host" \
    $db_name_command \
    $userpass_section \
    "$dumpdir"/"$db_name" \
    --drop \
    --numThreads 1 > /dev/null

if [[ "$?" != "0" ]]; then
    printError "Error restoring remote database"
    exit 3
else
    printSuccess "Remote database restore finished successfully"
fi
