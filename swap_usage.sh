#!/usr/bin/env bash


PID="$1"
declare -a ARR

if [ $PID ]; then
	NAME=$(grep -iE '^Name' /proc/$PID/status --color=never | cut -d: -f2)
	SWAP_KB=$(grep -iE '^VmSwap' /proc/$PID/status --color=never | cut -d: -f2)
    SWAP_KB=$(echo ${SWAP_KB/ /} | cut -d' ' -f1)
    ROW="$SWAP_KB kB\t$PID\t$NAME"
	echo -e $ROW
else
	ALL_PID=$(ls -d /proc/*/status)
	declare -a SWAPTABLE
	for X in $ALL_PID; do
		NAME=$(grep -iE '^Name' $X --color=never | cut -d: -f2)
		SWAP_KB=$(grep -iE '^VmSwap' $X --color=never | cut -d: -f2)
		SWAP_KB=$(echo ${SWAP_KB/ /} | cut -d' ' -f1)
		SWAPTABLE+=("$SWAP_KB kB\t$PID\t$NAME")
	done
	echo "$SWAPTABLE"
fi

exit 0