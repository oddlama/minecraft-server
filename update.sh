#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "utils.sh" || exit 1
become_minecaft "./update.sh"


################################################################
# Update both proxy and server

status "Updating proxy"
proxy/update.sh "$@" || exit 1

status "Updating server"
server/update.sh "$@" || exit 1
