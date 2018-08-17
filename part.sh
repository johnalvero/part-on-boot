#!/bin/bash

disk=/dev/xvdb
cfg=scheme.txt

diskname=$(echo $disk|cut -d/ -f3)
totalPartitions=$(grep -c "$diskname[0-9]" /proc/partitions)

if [ $totalPartitions -gt 0 ]
then
        echo "Already partitioned disk. Exiting"
        exit
fi

total_size=$((`blockdev --getsize64 $disk` / 1024000))

# Build the fdisk command text
# Create the extended partition
fdisk_command="echo n; echo e; echo; echo; echo;"

while IFS= read -r var; do
	# Prep
	size_percent=$(echo $var | cut -d' ' -f3)
	partition=$(echo $var | cut -d' ' -f2)

	# Partition Size
	size_mbytes=$(expr $size_percent \* $total_size / 100)
	
	## Logical partitions
	fdisk_command+="echo n; echo l; echo; echo +${size_mbytes}M; echo;"
done < $cfg

# Exit and save fdisk
fdisk_command+="echo; echo w"

# Apply the partition
echo "Applying partition scheme"
eval $fdisk_command | fdisk $disk

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
while IFS= read -r var; do
        partition=$(echo $var | cut -d' ' -f2)
        partition_number=$(echo $var | cut -d' ' -f1)

	install -d $partition
	mount $disk$partition_number $partition
done < $cfg

sleep 2
