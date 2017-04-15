#!/bin/sh

# desync.sh - decrypt one or more external drives
#             and sync files between them

#############
# FUNCTIONS #
#############
not_root () {
    echo "Please run this script as root"
    exit 1
}

check_arguments () {
    [ "$#" = 0 ] && usage  # Show usage (and exit) if no further arguments

}

usage () {
    printf %s\\n "Usage $(basename "$0") -d [directory] partition1 [partition2...]"
    printf %s\\n " - A valid directory must be specified"
    printf %s\\n " - At least one partition must be specified"
    exit 1
}

keys_file_no_exist () {
    echo "$keys_file not found"
    echo "Please create $keys_file and populate it with keys"
    exit 1
}

keys_file_incorrect_mode () {
    echo "$keys_file was found to have mode $actual_mode"
    echo "Please run: (sudo) chmod $expected_mode $keys_file"
    exit 1
}

get_length_of_keys_file () {
    length_of_keys_file=$(wc -l < "$keys_file")
    echo "  Keys file contains: $length_of_keys_file line(s)"
}

decrypt_drives () {
    echo "Something will be here eventually..."
}

##########
# CHECKS #
##########
# Check running as root
[ "$(id -u)" = 0 ] || not_root
echo "Running as root..."
echo

check_arguments

# Check keys file exists
keys_file="/usr/local/etc/keys"
echo "Keys file: $keys_file"
[ -f "$keys_file" ] || keys_file_no_exist
echo "  Test 1 passed: Keys file exists..."

# Check keys file has correct mode
expected_mode="600"
actual_mode=$(stat -c %a "$keys_file")
[ "$actual_mode" = "$expected_mode" ] || keys_file_incorrect_mode
echo "  Test 2 passed: Keys file has correct permissions ($expected_mode)..."

get_length_of_keys_file

###########
# OPTIONS #
###########
directory=

while getopts "d:" opt; do
    case $opt in
        d)
            [ -d "$OPTARG" ] || usage  # Exit if not a directory
            directory=$OPTARG
            printf %s\\n "$directory is a valid directory"
            ;;
    esac
done

[ -z "$directory" ] && usage

shift $((OPTIND-1))

partitions=$*
printf %s\\n "Showing partitions..."
for partition in $partitions; do
    printf %s\\n "$partition"
done

# Get user input to continue
while true; do
    read -r -p "Do you wish to continue (y/n)? " choice
    case $choice in
        [Yy]|yes ) echo "Yes picked" ; decrypt_drives ; break;;
        [Nn]|no ) echo "No picked" ; exit 1;;
        * ) echo "Please answer Y/y/yes or N/n/no.";;
    esac
done
