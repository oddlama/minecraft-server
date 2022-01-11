#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1

# Download waterfall
function download_waterfall() {
	local waterfall_version
	local waterfall_build
	local waterfall_download
	waterfall_version="$(curl -s -o - "https://papermc.io/api/v2/projects/waterfall" | jq -r ".versions[-1]")" \
		|| die "Error while retrieving waterfall version"
	waterfall_build="$(curl -s -o - "https://papermc.io/api/v2/projects/waterfall/versions/$waterfall_version" | jq -r ".builds[-1]")" \
		|| die "Error while retrieving waterfall builds"
	waterfall_download="$(curl -s -o - "https://papermc.io/api/v2/projects/waterfall/versions/$waterfall_version/builds/$waterfall_build" | jq -r ".downloads.application.name")" \
		|| die "Error while retrieving waterfall download name"

	status "Downloading waterfall version $waterfall_version build $waterfall_build ($waterfall_download)"
	curl --progress-bar "https://papermc.io/api/v2/projects/waterfall/versions/$waterfall_version/builds/$waterfall_build/downloads/$waterfall_download" \
		-o waterfall.jar \
		|| die "Could not download waterfall"
}

download_waterfall

# Create plugins directory
mkdir -p plugins \
	|| die "Could not create directory 'plugins'"

# Download and verify vane modules
status "Downloading vane modules"
latest_vane_version="$(curl -s "https://api.github.com/repos/oddlama/vane/releases/latest" | jq -r .tag_name)"
latest_vane_version="${latest_vane_version:1}" # strip v
for module in waterfall; do
	curl --progress-bar -L "https://github.com/oddlama/vane/releases/download/v$latest_vane_version/vane-$module-$latest_vane_version.jar" \
		-o plugins/vane-$module.jar \
		|| die "Could not download vane-$module-$latest_vane_version.jar"

	curl -s -L "https://github.com/oddlama/vane/releases/download/v$latest_vane_version/vane-$module-$latest_vane_version.jar.asc" \
		-o plugins/vane-$module.jar.asc \
		|| die "Could not download vane-$module-$latest_vane_version.jar.asc"
done

if [[ "$1" != "noverify" ]]; then
	status "Verifying vane signatures"
	for jar in plugins/vane-*.jar; do
		gpg --verify "$jar.asc" "$jar" \
			|| die "Could not verify signature for '$jar'"
		rm "$jar.asc"
	done
fi
