# Test
## General plan:
1. Ensure decryption keys are stored in the file /usr/local/etc/keys (mode 600), one key per line:

```
# cat /usr/local/etc/keys
key1
key2
...
```

```
$ cat /usr/local/etc/keys
cat: /usr/local/etc/keys: Permission denied
```

2. Ensure script is being run as root (for reading keys file)
3. Try and work out how many drives are connected (parse fdisk or lsblk?)
4. Let user know how many external drives it thinks are attached and wait for confirmation
5. Use /usr/local/etc/keys and loop through drives, decrypting all with cryptsetup
6. Set some sort of trap in the script that luksCloses all drives if ^C is triggered?
7. Make necessary /mnt directories and mount all drives
8. rsync files from specified path onto first drive (dry-run first then wait for confirmation?)
9. Once initial rsync is complete, rsync again (unsure of source yet) onto each separate drive
10. When all rsyncs are complete, unmount all external drives and luksClose
