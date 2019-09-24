#!/bin/bash

# 1. Find files modify more than 2 minutes ago and insert to clickhouse DB
# 2. In case of errors don't delete the input files

DIR="$1"
SERVER="$2"

function usage() {
	echo "Usage: $0 DIR SERVER"
}

if [ ! -d "$DIR" ]; then
	echo "DIR expected"
	usage
	exit 1
fi

if [ -z "$SERVER" ]; then
	echo "SERVER should not be empty"
	usage
	exit 1
fi

set -euo pipefail

for f in $(find "$DIR" -type f -name '*.csv'); do
	echo "Processing $f"
	clickhouse-client --host "$SERVER" --query="INSERT INFO vpc_flow_logs.flowlogs FORMAT CSV" <"$f"
	rm "$f"
done

