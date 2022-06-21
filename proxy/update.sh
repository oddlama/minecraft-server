#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../utils.sh" || exit 1
become_minecaft "./update.sh"


################################################################
# Download waterfall and prepare plugins

download_waterfall waterfall.jar

# Create plugins directory
mkdir -p plugins \
	|| die "Could not create directory 'plugins'"


################################################################
# Download plugins

download_latest_github_release "oddlama/vane" "vane-waterfall-{VERSION}.jar" "plugins/vane-waterfall.jar"
