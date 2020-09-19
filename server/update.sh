#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1

# Download paper
download_paper

# Copy vane modules
status "Copying vane modules"
mkdir -p plugins \
	|| die "Could not create plugins directory"
cp "../build/vane/"*.jar plugins/ \
	|| die "Could not copy vane modules"

# Download plugins
# ProtocolLib
# Dynmap
# WorldBorder
# WorldEdit?
