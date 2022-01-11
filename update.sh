#!/bin/bash

set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "env.sh" || exit 1

status "Updating proxy"
proxy/update.sh "$@" \
	|| exit 1

status "Updating server"
server/update.sh "$@" \
	|| exit 1
