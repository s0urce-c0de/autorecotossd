#!/bin/bash
set -xe
dd if=/dev/zero status=progress bs=1G count=2 >>"$1"
echo "w" | fdisk "$1" 2>/dev/null
(
    echo "d"
    echo "1"

    echo "n"
    echo "1"
    echo ""
    echo ""

    echo "w"
) | fdisk "$1" 2>/dev/null

loop=$(losetup -f)
losetup -P "$loop" "$1"

dd if="${loop}p4" of="${loop}p2" status=progress bs=8M
cgpt add "$loop" -i 2 -P 10 -T 5 -S 0

yes | mkfs.ext4 "${loop}p1"
mnt=$(mktemp -d)
mount "${loop}p1" "$mnt"
touch "$mnt/.developer_mode"
sync
umount "$mnt"
rmdir "$mnt"
losetup -d "$loop"
sync

echo "There ya go :spoob:"