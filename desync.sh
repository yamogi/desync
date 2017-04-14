#!/bin/sh

# desync.sh - decrypt one or more external drives
#             and sync files between them

function not_root () {
    echo "Not running as root, unable to continue"
    exit 1
}

function keys_file_no_exist () {
    echo "$keys_file not found"
    echo "Please create $keys_file and populate it with keys"
    exit 1
}

function keys_file_incorrect_mode () {
    echo "Blah"
    exit 1
}

function no_external_drives () {
    echo "I could not find any drives with unmounted partitions"
    exit 1
}

# Check running as root
(( $EUID == 0 )) || not_root

# Check keys file exists
keys_file="/usr/local/etc/keys"
[ -f "$keys_file" ] || keys_file_no_exist

# Check keys file has correct mode (not working yet)
expected_mode="600"
#(( $(stat -c %a "$keys_file" == "$expected_mode") )) || keys_file_incorrect_mode

# Get list of drives that contain unmounted partitions
drives=$(lsblk --noheadings --raw -o NAME,MOUNTPOINT |  # grab all disks/parts
         awk '$1~/sd.[[:digit:]]/ && $2 == ""' |        # get any sd<number> with no mountpoint
         tr -d '[:blank:]' |                            # remove any blank characters
         sed 's/.$//' |                                 # remove the last character (e.g. sdb1 becomes sdb)
         sort |                                         # sort
         uniq                                           # remove duplicates
)

[ -z "$drives" ] && no_external_drives  # Exit if $drives is zero-length

echo "Assuming $(wc -l <<< "$drives") drive(s), is this correct?"
