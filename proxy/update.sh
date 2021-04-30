#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1

# Download waterfall
function download_waterfall() {
	local waterfall_version
	local waterfall_build
	waterfall_version="$(curl -s -o - "https://papermc.io/api/v1/waterfall" | jq -r ".versions[0]")" \
		|| die "Error while retrieving waterfall version"
	waterfall_build="$(curl -s -o - "https://papermc.io/api/v1/waterfall/$waterfall_version" | jq -r ".builds.latest")" \
		|| die "Error while retrieving waterfall build"

	status "Downloading waterfall version $waterfall_version build $waterfall_build"
	curl --progress-bar "https://papermc.io/api/v1/waterfall/$waterfall_version/$waterfall_build/download" \
		-o waterfall.jar \
		|| die "Could not download waterfall"
}

download_waterfall

# Create plugins directory
mkdir -p plugins \
	|| die "Could not create directory 'plugins'"

# Download and verify vane modules
status "Downloading vane modules"
for module in waterfall ; do
	curl --progress-bar -L "https://github.com/oddlama/vane/releases/download/v$VANE_VERSION/vane-$module-$VANE_VERSION.jar" \
		-o plugins/vane-$module.jar \
		|| die "Could not download vane-$module-$VANE_VERSION.jar"

	curl -s -L "https://github.com/oddlama/vane/releases/download/v$VANE_VERSION/vane-$module-$VANE_VERSION.jar.asc" \
		-o plugins/vane-$module.jar.asc \
		|| die "Could not download vane-$module-$VANE_VERSION.jar.asc"
done

status "Verifying vane signatures"
for jar in plugins/vane-*.jar; do
	gpg --quiet --verify "$jar.asc" "$jar" \
		|| die "Could not verify signature for '$jar'"
	rm "$jar.asc"
done
