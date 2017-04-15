# Test
## General plan:
1. Ensure script is being run as root (for reading keys file)
2. Ensure decryption keys are stored in the file /usr/local/etc/keys (mode 600), one key per line:

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

3. Get user to specify local directory to sync (using getopts)
4. Get user to specify partitions to mount

Normal brace expansion should be supported, for example:
```
./desync.sh -d ~/test sd{b,c}2      # Expands to sdb2,sdc2
```

```
./desync.sh -d ~/test sd{b..d}1     # Expands to sdb1,sdc1,sdd1
```

```
./desync.sh -d ~/test sd{b,c}{1,2}  # Expands to sdb1,sdb2,sdc1,sdc2
```
5. Use /usr/local/etc/keys and loop through drives, decrypting all with cryptsetup
6. Set some sort of trap in the script that luksCloses all drives if ^C is triggered?
7. Make necessary /mnt directories and mount all drives
8. rsync files from specified path onto first drive (dry-run first then wait for confirmation?)
9. Once initial rsync is complete, rsync again (unsure of source yet) onto each separate drive
10. When all rsyncs are complete, unmount all external drives and luksClose
