#!/bin/bash

# Usage: mgc mongo-dump -o <origin_host> -n <database_name> -t <dumpdir> [-u <username>]
# Summary: Dumps the specified MongoDB database onto a file
#
# Help: Dumps the specified MongoDB database onto a file
#
#   Optional:
#      -o : the origin database host
#      -n : the database name
#      -t : the target directory
#      -u : username (mongo-dump will ask for password)
#      -a : sync all databases
#
#  * Example:
#       $> mgc mongo-dump -o mongodb.host:27017 -n personalisation -t dumpdir
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

while getopts "o:n:t:u:a" optname
do
    case "$optname" in
        "o")
            host="$OPTARG"
        ;;
        "n")
            db_name="$OPTARG"
        ;;
        "t")
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
  mgc help mongo-dump
  exit 2
fi

if [[ $db_name == "" ]] && [[ $all_databases == "" ]]; then
  printError "Missing arguments. Either the -n or -a option must be used.\n"
  mgc help mongo-dump
  exit 2
fi

if [[ -d $dumpdir ]]; then
  get_confirmation "overwrite $dumpdir"
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
echo "Dumping remote database to $dumpdir... "
mongodump \
    -h "$host" \
    $db_name_command \
    $userpass_section \
    -o "$dumpdir" \
    --numThreads 1 > /dev/null

if [[ "$?" != "0" ]]; then
    printError "Error dumping remote database"
    exit 3
else
    printSuccess "Remote database dump finished successfully"
fi
