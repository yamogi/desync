#!/bin/sh

# desync.sh - decrypt one or more external drives
#             and sync files between them

not_root () {
    echo "Not running as root, unable to continue"
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

no_external_drives () {
    echo "I could not find any drives with unmounted partitions"
    exit 1
}

# Check running as root
[ "$(id -u)" = 0 ] || not_root

# Check keys file exists
keys_file="/usr/local/etc/keys"
[ -f "$keys_file" ] || keys_file_no_exist

# Check keys file has correct mode (not working yet)
expected_mode="600"
actual_mode=$(stat -c %a "$keys_file")
if [ "$actual_mode" != "$expected_mode" ]; then keys_file_incorrect_mode ; fi

# Get list of drives that contain unmounted partitions
drives=$(lsblk --noheadings --raw -o NAME,MOUNTPOINT |  # grab all disks/parts
         awk '$1~/sd.[[:digit:]]/ && $2 == ""' |        # get any sd<number> with no mountpoint
         tr -d '[:blank:]' |                            # remove any blank characters
         sed 's/.$//' |                                 # remove the last character (e.g. sdb1 becomes sdb)
         sort |                                         # sort
         uniq                                           # remove duplicates
)

[ -z "$drives" ] && no_external_drives  # Exit if $drives is zero-length

echo "Assuming $(echo "$drives" | wc -l) drive(s), is this correct?"
