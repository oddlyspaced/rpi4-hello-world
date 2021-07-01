#!/bin/bash

bs=4
img_file=temp.img
loop_device=0
mount_point=rootmnt

# rounds number to nearest greater block size
# accepts float value of size
# returns rounded value
round_to_bs () {
	local rnd=$(printf "%.0f" $1)
	let rnd=rnd+1
	while [ $(( $rnd % $bs)) -ne 0 ]
	do
		let rnd=rnd+1
	done
	return $rnd
}

# creates a blank img file
# takes size as parameter
create_blank () {
	round_to_bs $1
	bs_count=$(( $? / $bs ))
	dd if=/dev/zero of=$img_file bs="$bs"M count=$bs_count
	echo "Blank image of size $(($bs * $bs_count))M created"
}

# mounts the blank img file
mount_img () {
	loop_device=$(sudo losetup -f)
	sudo losetup $loop_device $img_file
	echo "Mounted blank image on $loop_device"
}

# partitions the mounted img
partition_img () {
	(
		echo o # clear partitions
		echo n # new partition
		echo p # primary
		echo   # partition number
		echo   # first sector
		echo   # last sector
		echo t # type
		echo c # W95 FAT32 (LBA)
		echo w # write and quit
	) | sudo fdisk $loop_device
	sudo partprobe $loop_device
	echo "Partitioned loop device"
}

# format partition and mount
load_partition () {
	# get latest loop partition name
	loop_name=$(ls $loop_device?[0-9])
	sudo mkfs.vfat $loop_name
	echo "Formatted loop device"
	mkdir $mount_point
	sudo mount $loop_name $mount_point
	echo "Loop device mount successful"
}

create_blank 2.3
mount_img
partition_img
load_partition
