#!/bin/bash

bs=4
img_file=temp.img

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
	dd if=/dev/zero of=$img_file bs=4M count=$bs_count
	echo "Blank image of size $(($bs * $bs_count))M created"
}

# mounts the blank img file
mount_img () {
	loop_device=$(sudo losetup -f)
	sudo losetup $loop_device $img_file
	echo "Mounted blank image on $loop_device"
}

create_blank 2.3
mount_img
