#!/usr/bin/env bash
#set -x  # for debugging

function module_is_loaded()
{
    local SEARCHFOR="$(echo $1 | cut -d'.' -f1)"
    local RESULTS="$(lsmod | grep -E '^\$SEARCHFOR\s')"
    if [ "$RESULTS" != "" ]; then
        echo '(loaded)'
    fi
}

function do_module_search
{
    local DIR="$1"
    local SEARCH_FOR="$2"
    for X in $DIR; do
        local MATCHES=$(ls -1pA "$X" | grep -vE '/$' | grep --color=always -i "$SEARCH_FOR")
        if [ "$MATCHES" != "" ]; then
            echo "$DIR MATCHES:"
            for MATCH in "${MATCHES[@]}"; do
                echo "$MATCH $(module_is_loaded $MATCH)"
            done
            echo ""
        fi
    done

    # recurse through subdirs
    local SUBDIRS=$(ls -1pA "$DIR" | grep -E '/$')
    for SUBDIR in $SUBDIRS; do
        local SUBDIR="$(echo $SUBDIR | sed 's/\///g')"
        do_module_search "$DIR/$SUBDIR" "$SEARCH_FOR"
    done
}

SEARCH_WORD="$1"
SEARCH_START="/lib/modules/$(uname -r)"

echo -e "\n### SEARCHING FOR MATCHING MODULES IN $SEARCH_START ###\n"
do_module_search "$SEARCH_START" "$SEARCH_WORD"
echo -e "### DONE SEARCHING ###\n"

exit 0
