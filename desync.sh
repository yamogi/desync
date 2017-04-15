#!/bin/sh

# desync.sh - decrypt one or more external drives
#             and sync files between them

#############
# FUNCTIONS #
#############
not_root () {
    printf %s\\n "Please run this script as root"
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
    printf %s\\n "$keys_file not found"
    printf %s\\n "Please create $keys_file and populate it with keys"
    exit 1
}

keys_file_incorrect_mode () {
    printf %s\\n "$keys_file was found to have mode $actual_mode"
    printf %s\\n "Please run: (sudo) chmod $expected_mode $keys_file"
    exit 1
}

decrypt_drives () {
    printf %s\\n "Something will be here eventually..."
}

##########
# CHECKS #
##########
# Check running as root
[ "$(id -u)" = 0 ] || not_root
printf %s\\n "Running as root..."
printf %s\\n

#check_arguments

# Check keys file exists
keys_file="/usr/local/etc/keys"
printf %s\\n "Checking properties of file: $keys_file"
printf %s\\n "\\ Checking for existence of file"
[ -f "$keys_file" ] || keys_file_no_exist
printf %s\\n "  \\ Keys file exists"

# Check keys file has correct mode
expected_mode="600"
actual_mode=$(stat -c %a "$keys_file")
printf %s\\n "\\ Checking permissions of file"
[ "$actual_mode" = "$expected_mode" ] || keys_file_incorrect_mode
printf %s\\n "  \\  Keys file has correct permissions ($expected_mode)"

printf %s\\n "\\ Getting length of file: $keys_file"
length_of_keys_file=$(wc -l < "$keys_file")
printf %s\\n "  \\ Keys file contains: $length_of_keys_file line(s)"

echo  # Newline

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
        [Yy]|yes ) printf %s\\n "Yes picked" ; decrypt_drives ; break;;
        [Nn]|no ) printf %s\\n "No picked" ; exit 1;;
        * ) printf %s\\n "Please answer Y/y/yes or N/n/no.";;
    esac
done
