#!/bin/bash

# simple snapshotting mechanism

MIRROR_PATH=$1
DAYS_RETENTION=$2
SNAPSHOT_NAME=`date +snapshot-%Y-%m-%d`

cd ${MIRROR_PATH}

# taking a daily snapshot, if it already exists, exit
# this allows multiple mirror updates per day, but
# only one snapshot
if [ -d "${SNAPSHOT_NAME}" ]; then
	exit 0
fi

# packages are in a central place, so just clone the index
echo "Creating simple index snapshot ${SNAPSHOT_NAME}"
cp -r simple ${SNAPSHOT_NAME}

# remove everything but the last $DAYS_RETENTION snapshots
rm -rf `ls -1d snapshot*| head -n -${DAYS_RETENTION}`

# snapshots are now available at http://your-mirror.network/snapshot-DATE/
