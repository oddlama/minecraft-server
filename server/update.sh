#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1

# Download paper
function download_paper() {
	local paper_version
	local paper_build
	local paper_download
	paper_version="$(curl -s -o - "https://papermc.io/api/v2/projects/paper" | jq -r ".versions[-1]")" \
		|| die "Error while retrieving paper version"
	paper_build="$(curl -s -o - "https://papermc.io/api/v2/projects/paper/versions/$paper_version" | jq -r ".builds[-1]")" \
		|| die "Error while retrieving paper builds"
	paper_download="$(curl -s -o - "https://papermc.io/api/v2/projects/paper/versions/$paper_version/builds/$paper_build" | jq -r ".downloads.application.name")" \
		|| die "Error while retrieving paper download name"

	status "Downloading paper version $paper_version build $paper_build ($paper_download)"
	curl --progress-bar "https://papermc.io/api/v2/projects/paper/versions/$paper_version/builds/$paper_build/downloads/$paper_download" \
		-o paper.jar \
		|| die "Could not download paper"
}

download_paper

# Create plugins directory
mkdir -p plugins \
	|| die "Could not create directory 'plugins'"

# Create optional plugins directory
mkdir -p plugins/optional \
	|| die "Could not create directory 'plugins/optional'"

# Download and verify vane modules
status "Downloading vane modules"
latest_vane_version="$(curl -s "https://api.github.com/repos/oddlama/vane/releases/latest" | jq -r .tag_name)"
latest_vane_version="${latest_vane_version:1}" # strip v
for module in admin bedtime core enchantments permissions portals regions trifles; do
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

# Download ProtocolLib
status "Downloading ProtocolLib"
curl --progress-bar "https://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/target/ProtocolLib.jar" \
	-o plugins/ProtocolLib.jar \
	|| die "Could not download ProtocolLib"

# BlueMap
status "Downloading BlueMap"
latest_bluemap_version="$(curl -s "https://api.github.com/repos/BlueMap-Minecraft/BlueMap/releases/latest" | jq -r .tag_name)"
curl -L "https://github.com/BlueMap-Minecraft/BlueMap/releases/download/$latest_bluemap_version/BlueMap-${latest_bluemap_version:1}-spigot.jar" \
       -o plugins/bluemap.jar \
       || die "Could not download bluemap"

# WorldBorder
#status "Please manually update WorldBorder from here: https://github.com/PryPurity/WorldBorder"

# WorldEdit?
status "Downloading worldedit"
curl --progress-bar -L "https://dev.bukkit.org/projects/worldedit/files/latest" \
	-o plugins/optional/worldedit.jar \
	|| die "Could not download worldedit"
