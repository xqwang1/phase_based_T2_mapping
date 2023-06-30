#!/bin/bash
# 
# Copyright 2022. Berkin Bilgic's Lab, 
# Martinos Center for Biomedical Imaging,
# Massachusetts General Hospital,
# Harvard Medical School.
#
# Author: Xiaoqing Wang, 2022
# xwang106@mgh.harvard.edu
#

set -e

function calc() { awk "BEGIN { print "$*" }"; }

# set the path for bart
# for example: export PATH="/users/Xiaoqing/Code/bart:$PATH"

input=images_all
psf=psf_vd_cpd_R9_1

s_index=32

./prep.sh -k $s_index $input $psf ksp_vd_cpd_R9

bart extract 10 $s_index $((s_index+1)) coils_all coils_$s_index

### l2 pics ###
bart pics -l2 -g ksp_vd_cpd_R9 coils_$s_index recon_l2_R9_$s_index

bart extract 5 0 1 recon_l2_R9_$s_index tmp-reco_01
bart extract 5 1 2 recon_l2_R9_$s_index tmp-reco_02
    
bart fmac -C tmp-reco_01 tmp-reco_02 tmp_img_mac

bart carg tmp_img_mac recon_l2_R9_${s_index}_phase_diff

### moba ###

# create index: negative phase - 0; positive phase - 1
bart zeros 6 1 1 1 1 1 1 tmp_0
bart ones 6 1 1 1 1 1 1 tmp_1

bart join 5 tmp_0 tmp_1 VENC_ARRAY

reg_type=1
reg_para=0.01
reco=moba_R9

ADD_OPTS=" --normalize_scaling --scale_data 500 --scale_psf 150 -l$reg_type -j$reg_para -k --kfilter-2 -e1e-2"

coils=coils_${s_index}

data2=ksp_vd_cpd_R9

bart moba $ADD_OPTS -E -i20 -g -R3 -d4 -S -o1.0 --other sens=$coils -C200 -f1 -p $psf $data2 VENC_ARRAY $reco

