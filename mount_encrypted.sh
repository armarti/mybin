#!/usr/bin/env bash

PARTITION="$1"
MOUNT_POINT="$2"

echo -e "\nMapping '$PARTITION' as MOUNT_ENCRYPTED"
sudo cryptsetup luksOpen $PARTITION MOUNT_ENCRYPTED

LV_DEV_LINK="$(sudo lvdisplay --colon|grep '/root' --color=never|cut -d: -f1)"
LV_DEV_DIR="$(sudo dirname $LV_DEV_LINK)"
LV_DEV_PATH="$(sudo readlink $LV_DEV_LINK)"
REL_TEST="$(echo $LV_DEV_PATH | grep -E '^\.\./|^\./')"

if [ -n "$REL_TEST" ]; then
    LV_DEV_PATH="${LV_DEV_DIR}/${LV_DEV_PATH}"
fi
echo -e "MOUNT_ENCRYPTED is at \""$LV_DEV_LINK"\" linking to \""$LV_DEV_PATH"\""

echo -e "Mounting \""$LV_DEV_PATH"\" to \""$MOUNT_POINT
sudo mount "$LV_DEV_PATH" "$MOUNT_POINT"
