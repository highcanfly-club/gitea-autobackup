#!/bin/bash
if [ ! -f /scripts/autobackup.sh ]; then
    echo "you must provide your backup script at /scripts/autobackup.sh"
else
    /bin/bash /scripts/autobackup.sh
fi