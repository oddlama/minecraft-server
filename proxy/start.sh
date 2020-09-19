#!/bin/bash

LOG_DIR="/var/log/minecraft/proxy"

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1

# Create logs directory link
mkdir -p "$LOG_DIR" \
	|| die "Could not create directory '$LOG_DIR'"

link_dir "$LOG_DIR" "logs"

# Start java
java -Xms1G -Xmx1G \
	-jar waterfall.jar nogui
