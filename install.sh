#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "utils.sh" || exit 1

[[ $EUID == 0 ]] || die "Must be root for system-wide installation."


################################################################
# Install service files

# $1 = src, $2 = dest, $3 = owner, $4 = mode
function install_file() {
	echo "Installing $1 -> $2 ..."
	cp    "$1" "$2" || die "Could not copy '$1' to '$2'"
	chown "$3" "$2" || die "Could not chown '$2'"
	chmod "$4" "$2" || die "Could not chmod '$2'"
}

for name in server proxy; do
	install_file "contrib/systemd/minecraft-$name.service" \
		"/lib/systemd/system/minecraft-$name.service" \
		root: 644
done

install_file "contrib/systemd/minecraft-attach" \
	"/usr/bin/minecraft-attach" \
	root: 755
