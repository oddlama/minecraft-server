#!/bin/bash

export DYNMAP_VERSION="3.1-SNAPSHOT"
export VANE_VERSION="1.1.3"

function download_paper() {
	local paper_version
	local paper_build
	paper_version="$(curl -s -o - "https://papermc.io/api/v1/paper" | jq -r ".versions[0]")" \
		|| die "Error while retrieving paper version"
	paper_build="$(curl -s -o - "https://papermc.io/api/v1/paper/$paper_version" | jq -r ".builds.latest")" \
		|| die "Error while retrieving paper build"

	status "Downloading paper version $paper_version build $paper_build"
	curl --progress-bar "https://papermc.io/api/v1/paper/$paper_version/$paper_build/download" \
		-o paper.jar \
		|| die "Could not download paper"
}; export -f download_paper


set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "env.sh" || exit 1

TMP_DIR="$(mktemp -d)" \
	|| die "could not create temporary directory"

status "Preparing temporary directory '$TMP_DIR'"
pushd "$TMP_DIR" >/dev/null \
	|| die "could not cd into '$TMP_DIR'"


TMP_SERVER="$TMP_DIR/tmp_server"
status "Preparing temporary server in '$TMP_SERVER'"
mkdir -p "$TMP_SERVER" \
	|| die "Could not create directory '$TMP_SERVER'"
pushd "$TMP_SERVER" >/dev/null \
	|| die "Could not pushd into '$TMP_SERVER'"

# Download paper
download_paper

# Patch jar, missing eula will prevent the server from starting properly.
status "Patching server jar"
java -jar paper.jar --host 127.0.0.1 --port 15151 nogui

if ! ls "cache/patched"*.jar &>/dev/null; then
	die "Failed to patch server jar"
fi

popd >/dev/null \
	|| die "Could not popd out of '$TMP_SERVER'"

status "Copying patched jar"
mkdir -p "libs" \
	|| die "Could not create directory 'libs'"
cp "$TMP_SERVER/cache/patched"*.jar "libs/" \
	|| die "Could not copy targets to libs/"

popd >/dev/null \
	|| die "could not popd out of '$TMP_DIR'"

[[ $TMP_DIR == /tmp/* ]] \
	&& rm -rf "$TMP_DIR"

status "Updating proxy"
proxy/update.sh \
	|| exit 1

status "Updating server"
server/update.sh \
	|| exit 1
