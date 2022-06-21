#!/bin/bash

set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1

# Start java
status "Exec server"
exec java -Xms1G -Xmx1G \
	-jar waterfall.jar nogui
