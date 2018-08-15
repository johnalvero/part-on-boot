#!/bin/bash

disk=/dev/xvdb
cfg=scheme.txt

total_size=$((`blockdev --getsize64 $disk` / 1024000))

# Build the fdisk command text
fdisk_command="n
e



"

while IFS= read -r var; do
	# Prep
	size_percent=$(echo $var | cut -d' ' -f3)
	partition=$(echo $var | cut -d' ' -f2)

	# Partition Size
	size_mbytes=$(expr $size_percent \* $total_size / 100)
	
	## Logical partitions
	fdisk_command="$fdisk_command
	n
	l

	+${size_mbytes}M
"
done < $cfg

fdisk_command="$fdisk_command

w
"

# Apply the partition
echo "Applying partition scheme"
echo "$fdisk_command" | fdisk $disk

# Do other tasks
while IFS= read -r var; do

	# Prep
	partition=$(echo $var | cut -d' ' -f2)
	partition_number=$(echo $var | cut -d' ' -f1)

        # Format
        echo "Formatting $partition"
	mkfs.ext4 $disk$partition_number

        # FSTAB
	echo "Adding $partition to fstab"
	echo "$disk$partition_number $partition ext4 defaults 0 2" >> /etc/fstab
done < $cfg

# Mount
echo "Mounting partitions"
#mount -a

while IFS= read -r var; do
        partition=$(echo $var | cut -d' ' -f2)
        partition_number=$(echo $var | cut -d' ' -f1)

	install -d $partition
	mount $disk$partition_number $partition
done < $cfg
