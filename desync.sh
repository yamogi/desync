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
