#!/usr/bin/env bash

echo "" #; exit 1
if [[ !# == 0 ]]; then echo -e 'USAGE: makeec <base_filename_or_fullpathname> [<curve_name>]'; exit 0; fi
CURVE="brainpoolP512r1"
if [[ !# > 1 ]]; then CURVE="$2"; CURVE="${CURVE/ /}"; fi

ARG1="$1"
# make directory if it doesnt exist
DIR_NAME=$(dirname "$ARG1")
mkdir -p "$DIR_NAME"  

# get base name and absolute path
FULLPATH_ARG1=$(realpath "$ARG1")
BASE_NAME=$(basename "$FULLPATH_ARG1")
DIR_NAME=$(dirname "$FULLPATH_ARG1")

# name the keyfiles
PARAM_NAME="${BASE_NAME}.ecparam.pem"
PVT_NAME="${BASE_NAME}.pvt.pem"
PUB_NAME="${BASE_NAME}.pub.pem"

cd "$DIR_NAME"

echo "Making parameters file $DIR_NAME/$PARAM_NAME"
openssl ecparam -name brainpoolP512r1 -param_enc explicit -conv_form uncompressed -outform PEM -out "$PARAM_NAME"

echo "Making private key file $DIR_NAME/$PVT_NAME"
openssl ecparam -in "$PARAM_NAME" -inform PEM -genkey -noout -outform PEM -out "$PVT_NAME"

echo "Making public key file $DIR_NAME/$PUB_NAME"
openssl ec -inform PEM -in "$PVT_NAME" -pubout -outform PEM -out "$PUB_NAME"

echo ""
ls -lh "$PARAM_NAME" "$PVT_NAME" "$PUB_NAME"
echo ""
exit 0