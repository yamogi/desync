#!/bin/sh

# desync.sh - decrypt one or more external drives
#             and sync files between them

#############
# FUNCTIONS #
#############
not_root () {
    printf %s\\n "-- ERROR --"
    printf %s\\n "Please run this script as root"
    exit 1
}

check_arguments () {
    printf $s\\n "Inside function: $#"
    [ "$#" = 0 ] && not_enough_arguments  # Show usage (and exit) if no further arguments
}

not_enough_arguments () {
    printf %s\\n "-- ERROR --"
    printf %s\\n "Not enough arguments to continue!"
    usage
}

usage () {
    printf "\n"  # Newline
    printf %s\\n "Usage $(basename "$0") -d [directory] partition1 [partition2...]"
    printf %s\\n " - A valid directory must be specified"
    printf %s\\n " - At least one partition must be specified"
    exit 1
}

not_a_directory () {
    printf %s\\n "-- ERROR --"
    printf %s\\n "$OPTARG is not a valid directory"
    exit 1
}

keys_file_no_exist () {
    printf %s\\n "-- ERROR --"
    printf %s\\n "$keys_file not found"
    printf %s\\n "Please create $keys_file and populate it with keys"
    exit 1
}

keys_file_incorrect_mode () {
    printf %s\\n "-- ERROR --"
    printf %s\\n "$keys_file was found to have mode $actual_mode"
    printf %s\\n "Please run: (sudo) chmod $expected_mode $keys_file"
    exit 1
}

decrypt_drives () {
    printf %s\\n "Something will be here eventually..."
}

######################
# CHECKS AND OPTIONS #
######################
# Check running as root
[ "$(id -u)" = 0 ] || not_root
printf %s\\n "Running as root..."
printf "\n"

printf %s\\n "Outside function: $#"
check_arguments  # Exit if zero arguments

directory=
while getopts "d:h" opt; do
    case $opt in
        d)
            [ -d "$OPTARG" ] || not_a_directory  # Exit if not a directory
            directory=$OPTARG
            printf %s\\n "$directory is a valid directory"
            ;;
        h)
            usage
            ;;
    esac
done

[ -z "$directory" ] && exit 1  # Exit if nothing specified with -d

shift $((OPTIND-1))  # Leave only partitions as remaining arguments

echo "Number of arguments: $#"

#check_arguments  # Commented out for the time being, there's probably a better way to handle this

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
printf %s\\n "  \\ Keys file has correct permissions ($expected_mode)"

# Get length of keys file (will compare against number of partitions specified at a later point)
printf %s\\n "\\ Getting length of file: $keys_file"
length_of_keys_file=$(wc -l < "$keys_file")
printf %s\\n "  \\ Keys file contains: $length_of_keys_file line(s)"

echo  # Newline

# Stuff was here...

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
