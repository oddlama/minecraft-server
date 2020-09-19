#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1

# Download waterfall
download_waterfall

# Create plugins directory
mkdir -p plugins \
	|| die "Could not create directory 'plugins'"

# Copy vane-waterfall
status "Copying vane-waterfall plugins"
cp "../build/vane-waterfall/"*.jar plugins/ \
	|| die "Could not copy vane-waterfall plugins"
