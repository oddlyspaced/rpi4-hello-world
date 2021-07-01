#!/bin/bash

# !!!!!!!!!!!!!!!!!!!!!!!
# !! User configurable !!
# !!!!!!!!!!!!!!!!!!!!!!!

# source files for boot partition (these files will be copied over to the image)
source_files=/home/hardik/Raspberry-Pi/mount-bkp/*
# final img file name
final_img=generated.img

# !!!!!!!!!!!!!!!!!!!!!!
# !! Script variables !!
# !!!!!!!!!!!!!!!!!!!!!!

# temporary mount folder for script
mount_point=rootmnt
# block size for blank size in mb
bs=4
# temporary img file used while generation
img_file=temp.img
# loop device name (populated at runtime)
loop_device=0

# !!!!!!!!!!!!!!!
# !! Functions !!
# !!!!!!!!!!!!!!!

# calculates size of source files
# returns calculated size in MB
calculate_source_size () {
	local size=$(du -shc $source_files --block-size=1M | grep "total" | cut -f 1)
	return $size
}

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
	# img file must be atleast 8 mb in size
	if [ $(( $bs_count * $bs )) -lt 8 ]
	then
		bs_count=$(( 8 / $bs ))
	fi
	dd if=/dev/zero of=$img_file bs=""$bs"M" count=$bs_count
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
	local loop_name=$(ls $loop_device?[0-9])
	sudo mkfs.vfat $loop_name
	echo "Formatted loop device"
	mkdir $mount_point
	sudo mount $loop_name $mount_point
	echo "Loop device mount successful"
}

# !!!!!!!!!!!!!!!
# !! Execution !!
# !!!!!!!!!!!!!!!

calculate_source_size
create_blank $?
mount_img
partition_img
load_partition
echo "Copying over boot files..."
sudo cp -r $source_files $mount_point
echo "Copying boot files done"
sudo umount $mount_point
rm -rf $mount_point
echo "Unmounted loop device"
sudo losetup -d $loop_device
echo "Detached loop device"
mv $img_file $final_img
echo "Generated $final_img successfully"
