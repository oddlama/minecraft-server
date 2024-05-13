#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../contrib/utils.sh" || exit 1
become_minecaft "./update.sh"


################################################################
# Download velocity and prepare plugins

download_velocity velocity.jar

# Create plugins directory
mkdir -p plugins \
	|| die "Could not create directory 'plugins'"


################################################################
# Download plugins

substatus "Downloading plugins"
download_latest_github_release "oddlama/vane" "vane-velocity-{VERSION}.jar" "plugins/vane-velocity.jar"
