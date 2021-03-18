#!/bin/bash
echo 'This script will remove packages and files installed by the Mac Login Tool (yubico_pam)'
echo 'Press Enter to continue or Control-C to quit now.'
read

receipt=/var/db/receipts/com.yubico.pam_yubico.bom
[ -e ${receipt} ] && {
  echo 'Removing files and folders...'
  lsbom -f -l -s -pf ${receipt} | while read i; do
    rm -v /usr/local/${i}
  done
  rm -vrf /usr/local/share/pam_yubico
  rm -vrf /var/db/receipts/com.yubico.pam_yubico.*

  echo -e "\nCleaning up configuration files..."
  sed -i ".yubibak" -E "/auth.+pam_yubico\.so.+mode=challenge-response/d" /etc/pam.d/{authorization,screensaver}

  echo -e "\nSuccess! The Mac Login Tool has been uninstalled."
  exit 0
} || {
  echo 'The Mac Login Tool is not installed, exiting.'
  exit -1
}