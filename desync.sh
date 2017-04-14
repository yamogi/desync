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

no_unmounted_partitions () {
    echo "No unmounted partitions found"
    exit 1
}

decrypt_drives () {
    echo "Preparing to decrypt drives..."
    loop=1
    for drive in $(echo "$partitions" | sed 's/.$//' | sort | uniq); do
        echo "  Checking /dev/${drive}1 is a valid LUKS device..."
        cryptsetup luksDump /dev/${drive}1 2>&1 >/dev/null || continue
        echo "  Attempting to decrypt /dev/${drive}1 with key found on line $loop of $keys_file"
        passphrase=$(sed "${loop}p" "$keys_file")
        echo "$passphrase" | cryptsetup luksOpen /dev/"$drive"1 drive"$loop"
        loop=$((loop+1))
    done
}

##########
# CHECKS #
##########
# Check running as root
[ "$(id -u)" = 0 ] || not_root
echo "Running as root..."
echo

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
echo

#########
# START #
#########
# Get list of unmounted partitions
partitions=$(lsblk --noheadings --raw -o NAME,MOUNTPOINT |         # grab all disks/parts
             #awk '$1~/sd.[[:digit:]]/ { print $1 }' |              # get any sd<number> ... (testing)
             awk '$1~/sd.[[:digit:]]/ && $2 == "" { print $1 }' |  # get any sd<number> with no mountpoint
             tr -d '[:blank:]' |                                   # remove any blank characters
             sort                                                  # sort
)

[ -z "$partitions" ] && no_unmounted_partitions  # Exit if $partitions is zero-length

# Inform the user about discovered unmounted partitions
echo "Found $(echo "$partitions" | wc -l) unmounted partitions:"
for partition in $partitions; do
    echo "  /dev/$partition"
done
echo

# Get size of drives that contain unmounted partitions
#  - Drives are collapsed when possible - e.g. when presented with sdb1 and sdb2,
#    the script will simply check the overall size of /dev/sdb
#  - This is subject to change in the future
for drive in $(echo "$partitions" | sed 's/.$//' | sort | uniq); do
    echo "  Getting size of /dev/$drive..."
    echo "    $(lsblk --noheadings --raw -o NAME,SIZE /dev/"$drive" \
                 | head -n1 \
                 | awk '{ print $NF }')"
    echo
done

echo "Will assume first partition of each drive"

# Get user input to continue
while true; do
    read -r -p "Do you wish to continue (y/n)? " choice
    case $choice in
        [Yy]|yes ) echo "Yes picked" ; decrypt_drives ; break;;
        [Nn]|no ) echo "No picked" ; exit 1;;
        * ) echo "Please answer Y/y/yes or N/n/no.";;
    esac
done
