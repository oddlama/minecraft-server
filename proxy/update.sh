#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1

# Download waterfall
download_waterfall

# Copy vane-waterfall
status "Copying vane-waterfall plugins"
mkdir -p plugins \
	|| die "Could not create plugins directory"
cp "../build/vane-waterfall/"*.jar plugins/ \
	|| die "Could not copy vane-waterfall plugins"
