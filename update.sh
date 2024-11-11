#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "contrib/utils.sh" || exit 1
become_minecaft "./update.sh"


################################################################
# Update both proxy and server

status "Updating proxy"
proxy/update.sh "$@" || exit 1

echo
status "Updating servers"
for dir in servers/*/; do
	if [ -d "$dir" ]; then
		status "Updating $(basename "$dir") server"
		"$dir"update.sh "$@" || exit 1
	fi
done