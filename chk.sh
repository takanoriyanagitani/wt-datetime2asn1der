#!/bin/sh

wsm="./dt2der.wasm"

asn1chk() {
	printf 04060123456789ab |
		python3 -m asn1tools \
			convert \
			-i der \
			-o jer \
			./datetime.asn \
			FixedBytes48bits \
			-
}

ymdhms2packed() {
	year=8191
	month=12
	day=31
	hour=23
	min=59
	sec=59
	us=999900
	us100=$((us / 100))
	wasmer \
		run \
		--invoke ymdhms2packed \
		"${wsm}" \
		$year \
		$month \
		$day \
		$hour \
		$min \
		$sec \
		$us100 |
		xargs printf '%016x\n'
}

der2jer() {
	cat /dev/stdin |
		python3 -m asn1tools \
			convert \
			-i der \
			-o jer \
			./datetime.asn \
			Packed \
			-
}

dt2packed2jer() {
	ymdhms2packed |
		der2jer |
		jq -c
}

dt2unpacked(){
	node dt2der.mjs
}

unpacked2jer(){
	cat /dev/stdin |
		xxd -ps |
		tr -d '\n' |
		python3 -m asn1tools \
			convert \
			-i der \
			-o jer \
			./datetime.asn \
			Unpacked \
			-
}

dt2unpacked | unpacked2jer | jq
