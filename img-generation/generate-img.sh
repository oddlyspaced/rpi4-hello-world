#!/bin/bash

bs=4

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

round_to_bs 2.3
echo $?
