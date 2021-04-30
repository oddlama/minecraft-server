#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1

# Download paper
download_paper

# Create plugins directory
mkdir -p plugins \
	|| die "Could not create directory 'plugins'"

# Create optional plugins directory
mkdir -p plugins/optional \
	|| die "Could not create directory 'plugins/optional'"

# Download and verify vane modules
status "Downloading vane modules"
for module in admin bedtime core enchantments permissions portals regions trifles; do
	curl --progress-bar -L "https://github.com/oddlama/vane/releases/download/v$VANE_VERSION/vane-$module-$VANE_VERSION.jar" \
		-o plugins/vane-$module.jar \
		|| die "Could not download vane-$module-$VANE_VERSION.jar"

	curl -s -L "https://github.com/oddlama/vane/releases/download/v$VANE_VERSION/vane-$module-$VANE_VERSION.jar.asc" \
		-o plugins/vane-$module.jar.asc \
		|| die "Could not download vane-$module-$VANE_VERSION.jar.asc"
done

status "Verifying vane signatures"
for jar in plugins/vane-*.jar; do
	gpg --verify "$jar.asc" "$jar" \
		|| die "Could not verify signature for '$jar'"
	rm "$jar.asc"
done

# Download ProtocolLib
status "Downloading ProtocolLib"
curl --progress-bar "https://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/target/ProtocolLib.jar" \
	-o plugins/ProtocolLib.jar \
	|| die "Could not download ProtocolLib"

# Dynmap
status "Downloading dynmap"
curl --progress-bar "https://dynmap.us/builds/dynmap/Dynmap-$DYNMAP_VERSION-spigot.jar" \
	-o plugins/dynmap.jar \
	|| die "Could not download dynmap"

# WorldBorder
#status "Please manually update WorldBorder from here: https://github.com/PryPurity/WorldBorder"

# WorldEdit?
status "Downloading worldedit"
curl --progress-bar -L "https://dev.bukkit.org/projects/worldedit/files/latest" \
	-o plugins/optional/worldedit.jar \
	|| die "Could not download worldedit"
