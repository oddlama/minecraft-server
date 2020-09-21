#!/bin/bash

set -uo pipefail

LOG_DIR="/var/log/minecraft/proxy"

cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1

# Create logs directory link
mkdir -p "$LOG_DIR" \
	|| die "Could not create directory '$LOG_DIR'"

link_dir "$LOG_DIR" "logs"

# Start java
status "Exec server"
exec java -Xms1G -Xmx1G \
	-jar waterfall.jar nogui
