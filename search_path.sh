#!/usr/bin/env bash

SEARCH_WORD="$1"

OLDIFS=$IFS
IFS=':'
PATH_ARR="${PATH[@]}"

echo -e "\n### SEARCHING FOR MATCHING FILES IN \$PATH ###\n"
for DIR in $PATH_ARR; do

    MATCH_FILES=$(ls -1A "$DIR" | grep --color=always -i "$SEARCH_WORD")
    if [ "$MATCH_FILES" != "" ]; then

        echo "$DIR MATCHES:"
        echo $MATCH_FILES
        echo ""

    fi

done
echo -e "### DONE SEARCHING ###\n"

IFS=$OLDIFS
