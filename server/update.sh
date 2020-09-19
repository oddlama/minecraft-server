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

# Copy vane modules
status "Copying vane modules"
cp "../build/vane/"*.jar plugins/ \
	|| die "Could not copy vane modules"

# Download ProtocolLib
status "Downloading ProtocolLib"
curl "https://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/target/ProtocolLib.jar" \
	-o plugins/ProtocolLib.jar \
	|| die "Could not download ProtocolLib"

# Dynmap
status "Downloading dynmap"
curl "https://dynmap.us/builds/dynmap/Dynmap-3.1-SNAPSHOT-spigot.jar" \
	-o plugins/dynmap.jar \
	|| die "Could not download dynmap"

# WorldBorder
status "Please manually update WorldBorder from here: https://github.com/PryPurity/WorldBorder"

# WorldEdit?
status "Downloading worldedit"
curl "https://dev.bukkit.org/projects/worldedit/files/latest" \
	-o plugins/optional/worldedit.jar \
	|| die "Could not download worldedit"
