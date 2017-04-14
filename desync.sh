#!/bin/sh

# desync.sh - decrypt one or more external drives
#             and sync files between them

# General plan:
#  0. Ensure decryption keys are stored in the file /usr/local/etc/keys
#     (mode 600), one key per line:
#
#     # cat /usr/local/etc/keys
#     key1
#     key2
#     ...
#
#     $ cat /usr/local/etc/keys
#     cat: /usr/local/etc/keys: Permission denied
#
#  0.5. Ensure script is being run as root (for reading keys file)
#  1. Try and work out how many drives are connected (parse fdisk or lsblk?)
#  2. Let user know how many external drives it thinks are attached and
#     wait for confirmation
#  3. Use /usr/local/etc/keys and loop through drives, decrypting all with
#     cryptsetup
#  3.5. Set some sort of trap in the script that luksCloses all drives if
#       ^C is triggered?
#  4. Make necessary /mnt directories and mount all drives
#  5. rsync files from specified path onto first drive (dry-run first then
#     wait for confirmation?)
#  6. Once initial rsync is complete, rsync again (unsure of source yet) onto
#     each separate drive
#  7. When all rsyncs are complete, unmount all external drives and luksClose

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

# Check running as root
(( $EUID == 0 )) || not_root

# Check keys file exists
keys_file="/usr/local/etc/keys"
[ -f "$keys_file" ] || keys_file_no_exist

# Check keys file has correct mode
expected_mode="600"
#(( $(stat -c %a "$keys_file" == "$expected_mode") )) || keys_file_incorrect_mode
# Above not working yet...

# Get list of drives that contain unmounted partitions
drives=$(lsblk --noheadings --raw -o NAME,MOUNTPOINT |  # grab disks/parts
         awk '$1~/sd.[[:digit:]]/ && $2 == ""' |        # get sd<number> with no mountpoint
         tr -d '[:blank:]' |                            # remove blank characters
         sed 's/.$//' |                                 # remove last character (sdb1 > sdb)
         sort |                                         # sort
         uniq                                           # remove duplicates
)

echo "Assuming $(wc -l <<< "$drives") drive(s), is this correct?"
