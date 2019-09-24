#!/bin/bash

# 5. Modify the fields to match what we defined in clickhouse DB
# 6. Save to file to allow archiving, keep backup in case import fails and to
#    batch-import instead of line by line

if [[ "$1" == "__self__" ]]; then
	set -euxo pipefail
	SRC_FILE="$2"
	DST_DIR="$3"
	DST_FILE="$DST_DIR/$(basename "$SRC_FILE")"
	DST_FILE="${DST_FILE%log.gz}data"
	gzcat "$SRC_FILE" | grep 'ACCEPT OK$' | gawk -F' ' '{print strftime("%Y-%m-%d", $11)","strftime("%Y-%m-%d %H:%M:%S", $11)","$3","$4","$5","$6","$7","$8","$9","$10","$11","$12}' > "$DST_FILE"
	exit 0
fi

SRC_DIR="$1"
DST_DIR="$2"

function usage() {
	echo "Usage: SRC_DIR DST_DIR"
}

if [ ! -d "$SRC_DIR" ]; then
	echo "SRC_DIR does not exists"
	usage
	exit 1
fi

if [ ! -d "$DST_DIR" ]; then
	echo "DST_DIR does not exists"
	usage
	exit 1
fi


#find "$SRC_DIR" -type f -name '*.log.gz' | gzip -d
#find "$SRC_DIR" -type f -name '*.log.gz' | head -n 1 | xargs -n1 -I{} bash -euo pipefail -c 'zcat \'{}\' | grep \'^2 \' | awk -F\' \' \'{print strftime("%Y-%m-%d", $11)","strftime("%Y-%m-%d %H:%M:%S", $11)","$3","$4","$5","$6","$7","$8","$9","$10","$11","$12}\' >> $DST_DIR/{}'
find "$SRC_DIR" -type f -name '*.log.gz' | head -n 1 | xargs -n1 -I{} bash -euo pipefail "$0" __self__ "{}" "$DST_DIR"


