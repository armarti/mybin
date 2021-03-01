#!/usr/bin/env bash
# Archive, Compress, Encrypt (ACE)

INFILE="$1"
OUTFILE="$2"
PUB_KEYFILE="$3"
PRIV_KEYFILE="$4"

## Run some checks before doing anything ######################################
# see that we have enough args
if [[ $# < 4 ]]; then echo "USAGE: $0 infile outfile pubkey privkey"; exit 1; fi

# see that important files actually exist
if [ ! -a "$INFILE" ]; then echo "$INFILE does not exist. Exiting."; exit 2; fi
if [ ! -a "$PUB_KEYFILE" ]; then echo "$PUB_KEYFILE does not exist. Exiting."; exit 3; fi
if [ ! -a "$PRIV_KEYFILE" ]; then echo "$PRIV_KEYFILE does not exist. Exiting."; exit 4; fi

# see that the destination directory exists
TEMP=$(dirname "$OUTFILE")
if [ ! -a "$TEMP" ]; then echo "The directory $TEMP/ does not exist. Exiting."; exit 5; fi

# check that the pub & priv keys are actually a pair
# this mostly serves to ensure the user has the pvt key to later decrypt the file
MISMATCH=$(diff --brief <(openssl ec -in "$PRIV_KEYFILE" -pubout 2>/dev/null) "$PUB_KEYFILE")
if [ -n "$MISMATCH" ]; then echo "Public and private keys don't match. Exiting."; exit 6; fi
###############################################################################

## Make functions #############################################################
# tars, gzips, and encrypts file/directory
function tar_gzip_encrypt
{
    # ARG1 = infile
    # ARG2 = outfile
    # ARG3 = hexadecimal key
    tar --create                 \
        --gzip                   \
        --preserve-permissions   \
        --atime-preserve=system  \
        --blocking-factor 8      \
        --checkpoint             \
        --check-links            \
        --numeric-owner          \
        --absolute-names         \
        --xattrs                 \
        "$1"                   | \
    openssl enc -e -K "$3" -out "$2"
}
###############################################################################

## Get maybe useful info abt INFILE ###########################################
INFILE_FULLPATH=$(realpath "$INFILE")
INFILE_ISDIR=0
if [ -d "$INFILE_FULLPATH" ]; then INFILE_ISDIR=1; fi
INFILE_BASENAME=$(basename "$INFILE_FULLPATH")
INFILE_DIRNAME=$(dirname "$INFILE_FULLPATH")
###############################################################################

# Get maybe-useful info abt OUTFILE ##########################################
OUTFILE_FULLPATH=$(realpath "$OUTFILE")
OUTFILE_ISDIR=0
if [ -d "$OUTFILE_FULLPATH" ]; then
    OUTFILE_ISDIR=1
    OUTFILE_FULLPATH="$OUTFILE_FULLPATH/${INFILE_BASENAME}.tar.gz.enc"
fi
OUTFILE_BASENAME=$(basename "$OUTFILE_FULLPATH")
OUTFILE_DIRNAME=$(dirname "$OUTFILE_FULLPATH")
###############################################################################

## Convert the keys to hexadecimal ############################################
# hexdump command from here: unix.stackexchange.com/a/76951
PUB_KEY_HEX=$(hexdump -v -e '/1 "%02X"' < "$PUB_KEYFILE")
PRIV_KEY_HEX=$(hexdump -v -e '/1 "%02X"' < "$PRIV_KEYFILE")
###############################################################################

## Do stuff ###################################################################
tar_gzip_encode "$INFILE_FULLPATH" "$OUTFILE_FULLPATH" "$PUB_KEY_HEX"
###############################################################################

exit 0
