#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "env.sh" || exit 1

TMP_DIR="$(mktemp -d)" \
	|| die "could not create temporary directory"

status "Preparing temporary directory '$TMP_DIR'"
pushd "$TMP_DIR" >/dev/null \
	|| die "could not cd into '$TMP_DIR'"


status "Cloning into https://github.com/oddlama/vane"
git clone "https://github.com/oddlama/vane" \
	|| die "Could not clone into vane"

cd vane \
	|| die "Could not cd into vane"

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

status "Compiling vane"
if ! ./gradlew build; then
	status "Gradle failed, retrying once."
	./gradlew build \
		|| die "Could not compile vane"
fi

popd >/dev/null \
	|| die "could not popd out of '$TMP_DIR'"

status "Copying targets"
mkdir -p "build/vane" \
	|| die "Could not create directory build/vane"
mkdir -p "build/vane-waterfall" \
	|| die "Could not create directory build/vane-waterfall"
cp "$TMP_DIR/vane/target/"*.jar "build/vane/" \
	|| die "Could not copy targets to build/vane/"
cp "$TMP_DIR/vane/target-waterfall/"*.jar "build/vane-waterfall/" \
	|| die "Could not copy targets to build/vane-waterfall/"

[[ $TMP_DIR == /tmp/* ]] \
	&& rm -rf "$TMP_DIR"

status "Updating proxy"
proxy/update.sh \
	|| exit 1

status "Updating server"
server/update.sh \
	|| exit 1

status "Cleaning up"
rm -r build
