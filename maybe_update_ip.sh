#!/usr/bin/env bash
set -eo pipefail

DOMAIN="$1"
SUBDOMAIN="${2:-@}"

if [ -z "$PATH" ]; then PATH="/usr/bin:/bin"; fi

if [[ "$DOMAIN" == "" ]] || \
   [[ "$DOMAIN" == '\-h' ]] || \
   [[ "$DOMAIN" == '\-\-help' ]]
then
    echo -e "\n\tUSAGE: $THIS_BNAME [ -h | --help ] <DOMAIN> [ <SUBDOMAIN> ]\n"
    echo "Note that this program requires that the doctl command-line program be installed as well."
    exit 1
fi

# since this will probably run in a cronjob, and since the cron
# environment doesn't have PATH set by default, we do an extra
# check for the doctl program
DOCTL=doctl
if [ ! $(which $DOCTL) ]; then
    function find_exe() {
        for P in $@; do
            if [ -x "$P" ]; then
                DOCTL="$P"
                break
            fi
        done
    }
    switch $(uname) in
        Darwin)
            find_exe /usr/local/bin/doctl /opt/digitalocean/bin/doctl
        ;;
        Linux)
            find_exe /usr/bin/doctl /snap/bin /opt/digitalocean/bin/doctl /usr/local/bin/doctl
        *)
            DOCTL=''
        ;;
    esac
    if [ -z "$DOCTL" ]; then
        echo "Could not find the program 'doctl'. Install it before rerunning."
        exit 2
    else
        echo "Using $DOCTL"
    fi
fi

export DIGITALOCEAN_ENABLE_BETA=1

function get_field() {
    S="$1"
    F=$2
    echo $S | cut -d '|' -f $F
}

CURR_REC=$("$DOCTL" compute domain records list $DOMAIN --format Data,ID,Type,Name,Priority,Port,TTL,Weight --no-header | sed -E 's/\s+/|/g' | grep -F "|A|$SUBDOMAIN|")
DNS_IP=$(get_field $CURR_REC 1)
CURR_IP=$(curl --silent https://dynamicdns.park-your-domain.com/getip)
if [ "$DNS_IP" != "$CURR_IP" ]; then
    ID=$(get_field $CURR_REC 2)
    TYPE=$(get_field $CURR_REC 3)
    NAME=$(get_field $CURR_REC 4)
    PRIO=$(get_field $CURR_REC 5)
    PORT=$(get_field $CURR_REC 6)
    TTL=$(get_field $CURR_REC 7)
    WGT=$(get_field $CURR_REC 8)
    echo "Updating DO DNS IP for $ID from $DNS_IP to $CURR_IP"
    "$DOCTL" compute domain records update --verbose armarti.com \
        --record-data $CURR_IP \
        --record-id $ID \
        --record-type $TYPE \
        --record-name $NAME \
        --record-priority $PRIO \
        --record-port $PORT \
        --record-ttl $TTL \
        --record-weight $WGT
else
    echo "DO DNS IP $DNS_IP is up to date"
fi

exit 0
