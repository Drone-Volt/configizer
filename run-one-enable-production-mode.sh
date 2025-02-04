#!/usr/bin/env bash

# * connect to the device with balena ssh, pipe in the task script, and
#   save the log with the UUID prepended
# * Config:
#   * DEVELOPMENT_MODE_ENABLE: false
#   * DELETEALLSSHKEYS: FALSE (do not touch ssh keys)

uuid=$1

# don't run if the device has already been processed
#grep -a -q '{} : DONE' config.log 2>/dev/null && exit 0

# these settings need to be handled separately because they need to be different 
# per-device even when processing a large batch

echo "::: Confirm information :::"
echo "uuid: ${uuid}"
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
    | sed "s/^DELETEALLSSHKEYS=.*/DELETEALLSSHKEYS=\"FALSE\"/"
) \
| balena ssh "${uuid}" \
| sed "s/^/${uuid} : /" \
| tee -a config.log