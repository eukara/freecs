#!/bin/sh

get_cspack()
{
	wget -nc -O $1.pk3 https://archive.org/download/hl-counter-strike/$2.zip
}

if [ "$1" = "-accumulative" ]; then
	get_cspack pak00 csbeta_1.0
	get_cspack pak01 csbeta_1.0_b2premaps
	get_cspack pak02 csbeta_1.0_to_1.1
	get_cspack pak03 csbeta_1.1_to_2.0
	get_cspack pak04 csbeta_2.0_to_2.1
	get_cspack pak05 csbeta_2.1_to_3.0
	get_cspack pak06 csbeta_3.0_to_3.1
	get_cspack pak07 csbeta_3.1_to_4.0
	get_cspack pak08 csbeta_4.0_to_4.1
	get_cspack pak09 csbeta_4.1_to_5.0
	get_cspack pak10 csbeta_5.0_to_5.2
	get_cspack pak11 csbeta_5.2_to_6.0
	get_cspack pak12 csbeta_6.0_to_6.1
	get_cspack pak13 csbeta_6.1_to_6.5
	get_cspack pak14 csbeta_6.5_to_6.6
	get_cspack pak15 csbeta_6.6_to_7.0
	get_cspack pak16 csbeta_7.0_to_7.1
	get_cspack pak17 csbeta_7.1_to_v1.0
	get_cspack pak18 csfull_1.0_to_1.1
	get_cspack pak19 csfull_1.1_to_1.3
	get_cspack pak20 csfull_1.3_to_1.4
	get_cspack pak21 csfull_1.4_to_1.5
else
	wget -nc -O pak0.pk3 https://archive.org/download/counter-strike-1.5/csv15full_cstrike.zip
fi
