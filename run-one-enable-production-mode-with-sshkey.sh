#!/usr/bin/env bash

# * connect to the device with balena ssh, pipe in the task script, and
#   save the log with the UUID prepended
# * Config:
#   * DEVELOPMENT_MODE_ENABLE: false
#   * Insert sshkey into the device

uuid=$1
sshkey=$2

# don't run if the device has already been processed
#grep -a -q '{} : DONE' config.log 2>/dev/null && exit 0

# these settings need to be handled separately because they need to be different 
# per-device even when processing a large batch

if [ -z "${sshkey}" ]; then
    echo "No sshkey found for ${uuid} in parameters. Loading from file \"ssh_keys\""
    sshkey=$(grep "${uuid}" ssh_keys 2> /dev/null | sed 's/.*\s*->\s*//')
fi

if [ -z "${sshkey}" ]; then
    echo "No sshkey found for ${uuid} in file ssh_keys. Exiting..."
    exit 1
fi

echo "::: Confirm information :::"
echo "uuid: ${uuid}"
echo "sshkey: ${sshkey}"
echo

while true; do

read -p "Do you want to proceed? (y/n) " yn

case $yn in 
	[yY] ) echo ok, we will proceed;
		break;;
	[nN] ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac

done

# Use non base64 seperation character (|) in sed replace for the sshkey to avoid the need for escaping
(
    cat config.sh \
    | sed "s/^DEVELOPMENT_MODE_ENABLE=.*/DEVELOPMENT_MODE_ENABLE=\"false\"/" \
    | sed "s/^DELETEALLSSHKEYS=.*/DELETEALLSSHKEYS=\"FALSE\"/" \
    | sed "s|^SSHKEYS=.*|SSHKEYS=(\"${sshkey}\")|"
) \
| balena ssh "${uuid}" \
| sed "s/^/${uuid} : /" \
| tee -a config.log