#!/bin/bash
# 
# Copyright 2023. 
#
# Author: Xiaoqing Wang, 2023
# xwang106@mgh.harvard.edu
#

set -e


helpstr=$(cat <<- EOF
Preparation of undersampled data and echo times for moba phase-contrast GRE.
-k kth slice
-h help
EOF
)

usage="Usage: $0 [-h] [-k slice_index] <input> <psf> <out_kspace>"


while getopts "hk:" opt; do
	case $opt in
	h) 
		echo "$usage"
		echo "$helpstr"
		exit 0 
		;;		
	k) 
		slice=${OPTARG}
		;;
	\?)
		echo "$usage" >&2
		exit 1
		;;
	esac
done
shift $(($OPTIND -1 ))


input=$(readlink -f "$1")
psf=$(readlink -f "$2")
out_kspace=$(readlink -f "$3")


if [ ! -e ${input}.cfl ] ; then
        echo "Input file does not exist." >&2
        echo "$usage" >&2
        exit 1
fi



#-----------------------------
# Prepare k-space
#-----------------------------

bart extract 2 $slice $((slice+1)) $input tmp-img-2D
bart fft -u -i $(bart bitmask 0 1) tmp-img-2D tmp-ksp-2D
# bart transpose 5 9 tmp-ksp-2D tmp-ksp-2D-1
bart fmac $psf tmp-ksp-2D $out_kspace


rm tmp*.{cfl,hdr}
