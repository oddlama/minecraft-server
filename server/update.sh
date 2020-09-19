#!/bin/bash

set -uo pipefail

die() {
	echo "[1;31merror:[m $*" >&2
	exit 1
}

#waterfall_version="$(curl -s -o - "https://papermc.io/api/v1/waterfall" | jq -r ".versions[0]")" \
#	|| die "Error while retrieving waterfall version"
#waterfall_build="$(curl -s -o - "https://papermc.io/api/v1/waterfall/$waterfall_version" | jq -r ".builds.latest")" \
#	|| die "Error while retrieving waterfall build"
#
#curl "https://papermc.io/api/v1/waterfall/$waterfall_version/$waterfall_build/download" \
#	-o waterfall.jar

# Download paper
paper_version="$(curl -s -o - "https://papermc.io/api/v1/paper" | jq -r ".versions[0]")" \
	|| die "Error while retrieving paper version"
paper_build="$(curl -s -o - "https://papermc.io/api/v1/paper/$paper_version" | jq -r ".builds.latest")" \
	|| die "Error while retrieving paper build"

echo "[+] Downloading paper version $paper_version build $paper_build"
curl "https://papermc.io/api/v1/paper/$paper_version/$paper_build/download" \
	-o paper.jar

# Download plugins
# vane Clone repo, build?
# ProtocolLib
# Dynmap
# WorldBorder
# WorldEdit?
