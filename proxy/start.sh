#!/bin/bash

set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../contrib/utils.sh" || exit 1

status "Executing proxy server"
exec java -Xms1G -Xmx1G \
	-jar waterfall.jar nogui
