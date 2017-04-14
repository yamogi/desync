#!/bin/sh

# desync.sh - decrypt one or more external drives
#             and sync files between them

#############
# FUNCTIONS #
#############
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

decrypt_drives () {
    echo "Preparing to decrypt drives..."
}

##########
# CHECKS #
##########
# Check running as root
[ "$(id -u)" = 0 ] || not_root

# Check keys file exists
keys_file="/usr/local/etc/keys"
[ -f "$keys_file" ] || keys_file_no_exist

# Check keys file has correct mode
expected_mode="600"
actual_mode=$(stat -c %a "$keys_file")
if [ "$actual_mode" != "$expected_mode" ]; then keys_file_incorrect_mode ; fi

#########
# START #
#########
# Get list of drives that contain unmounted partitions
drives=$(lsblk --noheadings --raw -o NAME,MOUNTPOINT |         # grab all disks/parts
         #awk '$1~/sd.[[:digit:]]/ { print $1 }' |             # get any sd<number>
         awk '$1~/sd.[[:digit:]]/ && $2 == "" { print $1 }' |  # get any sd<number> with no mountpoint
         tr -d '[:blank:]' |                                   # remove any blank characters
         sort                                                  # sort
)

[ -z "$drives" ] && no_external_drives  # Exit if $drives is zero-length

echo "Found $(echo "$drives" | wc -l) unmounted partitions:"
for drive in $drives; do
    echo "  /dev/$drive"
done
echo

for drive in $(echo "$drives" | sed 's/.$//' | sort | uniq); do
    echo "  Getting size of /dev/$drive..."
    echo "    $(lsblk --noheadings --raw -o NAME,SIZE /dev/"$drive" \
                 | head -n1 \
                 | awk '{ print $NF }')"
    echo
done

while true; do
    read -r -p "Do you wish to continue (y/n)? " choice
    case $choice in
        [Yy]|yes ) echo "Yes picked" ; decrypt_drives ; break;;
        [Nn]|no ) echo "No picked" ; exit 1;;
        * ) echo "Please answer Y/y/yes or N/n/no.";;
    esac
done
