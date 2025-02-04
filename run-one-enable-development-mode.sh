#!/usr/bin/env bash

# * connect to the device with balena ssh, pipe in the task script, and
#   save the log with the UUID prepended
# * Config:
#   * DEVELOPMENT_MODE_ENABLE: true
#   * DELETEALLSSHKEYS: TRUE (delete all ssh keys to enable passwordless ssh)

uuid=$1

# don't run if the device has already been processed
#grep -a -q '{} : DONE' config.log 2>/dev/null && exit 0

(
    cat config.sh \
    | sed "s/^DEVELOPMENT_MODE_ENABLE=.*/DEVELOPMENT_MODE_ENABLE=\"true\"/" \
    | sed "s/^DELETEALLSSHKEYS=.*/DELETEALLSSHKEYS=\"TRUE\"/"
) \
| balena ssh "${uuid}" \
| sed "s/^/${uuid} : /" \
| tee -a config.log
