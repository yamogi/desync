#!/bin/sh

# desync.sh - decrypt one or more external drives
#             and sync files between them

#############
# FUNCTIONS #
#############
not_root () {
    printf %s\\n "-- ERROR --"
    printf %s\\n "Please run this script as root"
    usage
}

check_arguments () {
    [ "$#" = 0 ] && not_enough_arguments  # Show usage (and exit) if no further arguments
}

not_enough_arguments () {
    printf %s\\n "-- ERROR --"
    printf %s\\n "Not enough arguments to continue!"
    usage
}

usage () {
    printf "\n"  # Newline
    printf %s\\n "Usage: $(basename "$0") -d [directory] partition1 [partition2...]"
    printf "\n"
    printf %s\\n "Options"
    printf %s\\n " -d              local directory to sync to external devices"
    printf %s\\n "                  - One valid directory required"
    printf %s\\n " partition<n>    partition to decrypt and mount (e.g. sdb1)"
    printf %s\\n "                  - At least one valid (unmounted) partition required"
    exit 1
}

not_a_directory () {
    printf %s\\n "-- ERROR --"
    printf %s\\n "$OPTARG is not a valid directory"
    usage
}

no_directory_specified () {
    printf %s\\n "-- ERROR --"
    printf %s\\n "-d was not specified, or was specified with a blank argument"
    usage
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

keys_file_incorrect_user () {
    printf %s\\n "-- ERROR --"
    printf %s\\n "$keys_file was found to have user $actual_user"
    printf %s\\n "Please run: (sudo) chown $expected_user:$expected_user $keys_file"
    exit 1
}

keys_file_incorrect_group () {
    printf %s\\n "-- ERROR --"
    printf %s\\n "$keys_file was found to have user $actual_group"
    printf %s\\n "Please run: (sudo) chown $expected_group:$expected_group $keys_file"
    exit 1
}

continue_check () {
    # Get user input to continue
    while true; do
        read -r -p "Do you wish to continue (y/n)? " choice
        case $choice in
            [Yy]|yes) printf "\n"; break
                ;;
            [Nn]|no) exit 1
                ;;
            *) printf %s\\n "Please answer Y/y/yes or N/n/no."
                ;;
        esac
    done
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

check_arguments "$@"  # Exit if zero arguments

directory=
while getopts ":d:h" opt; do
    case $opt in
        d)
            [ -d "$OPTARG" ] || not_a_directory  # Exit if not a directory
            directory=$OPTARG
            printf %s\\n "$directory is a valid directory"
            printf %s\\n "INFO: Getting size of $directory"
            dir_size=$(du -sh -- "$directory" 2>/dev/null | awk '{ print $1 }')
            printf %s\\n "INFO: $directory is $dir_size"
            printf "\n"
            ;;
        h)
            usage
            ;;
    esac
done

[ -z "$directory" ] && no_directory_specified  # Exit if nothing specified with -d

shift $((OPTIND-1))  # Leave only partitions as remaining arguments

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

# Check keys file has correct user
expected_user="root"
printf %s\\n "\\ Checking user of file"
actual_user=$(stat -c %U "$keys_file")
[ "$actual_user" = "$expected_user" ] || keys_file_incorrect_user
printf %s\\n "  \\ Keys file has correct user ($expected_user)"

# Check keys file has correct group
expected_group="root"
printf %s\\n "\\ Checking group of file"
actual_group=$(stat -c %G "$keys_file")
[ "$actual_group" = "$expected_group" ] || keys_file_incorrect_group
printf %s\\n "  \\ Keys file has correct group ($expected_group)"

# Get length of keys file (will compare against number of partitions specified at a later point)
printf %s\\n "\\ Getting length of file: $keys_file"
length_of_keys_file=$(wc -l < "$keys_file")
printf %s\\n "  \\ Keys file contains: $length_of_keys_file line(s)"

printf "\n"  # Newline

partitions=$*
printf %s\\n "Showing partitions..."
for partition in $partitions; do
    printf %s\\n "$partition"
done

continue_check && decrypt_drives
