#!/usr/bin/env bash

# validates a string (arg1) against regex (arg2), returns the trimmed string if valid, else "INVALID"
function VALIDATE
{
    STR="$1"; REGEX="$2";
    STR="${STR// /}"  # remove spaces from input
    STR="${STR//\"/}"  # remove quotes from input
    if ! [[ $STR =~ $REGEX ]]; then
        echo "INVALID"
    else
    	echo "$STR"
    fi
}

function CMDLINE_FROM_PID
{
	echo ""
	# http://stackoverflow.com/a/821889
	# ps -fp "$1"
	#cat "/proc/$1/cmdline"
	# http://stackoverflow.com/a/13399254
	xargs -0 < "/proc/$1/cmdline"
	# http://unix.stackexchange.com/a/163146
	#ps -p $(pidof dhcpcd) -o args --no-headers
	#ps -eo args | grep dhcpcd | head -n -1
	#ps -p $(pidof dhcpcd) -o args | awk 'NR > 1'
	#ps -p $(pidof dhcpcd) -o args | sed 1d
	#ps -p $(pidof dhcpcd) -o args --no-headers
	#ps -eo args | grep dhcpcd | head -n -1
	#ps -p $(pidof dhcpcd) -o args
	#ps -p [PID] -o args
	#ps -eo args
	echo -e ""
}

NUM_ARGS="$#"
if [[ $NUM_ARGS == 1 ]]; then 
	ARG1_IFUM="$(VALIDATE $1 '^[0-9]+$')"
	if [[ "$ARG1_IFUM" != "INVALID" ]]; then
		CMDLINE_FROM_PID "$ARG1_IFUM"
		exit 0
	fi
fi


