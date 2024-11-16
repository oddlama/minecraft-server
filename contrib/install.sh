#!/bin/bash

# REMEMBER:
# $1: DEPLOY directory WITHOUT end slash

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

# install proxy service file
install_file "systemd/minecraft-proxy.service" \
	"/lib/systemd/system/minecraft-proxy.service" \
	root: 644

# install multi-minecraft server service file
install_file "systemd/minecraft-server@.service" \
	"/lib/systemd/system/minecraft-server@.service" \
	root: 644

# fill deply directory placeholders

sed -i "s|{{DEPLOY_DIRECTORY}}|$1|" \
	'/lib/systemd/system/minecraft-proxy.service' \
	|| die "Could not fill proxy directory placeholder"

sed -i "s|{{DEPLOY_DIRECTORY}}|$1|" \
	'/lib/systemd/system/minecraft-server@.service' \
	|| die "Could not fill proxy directory placeholder"

echo "Reloading service files..."
systemctl daemon-reload

###############################################################
# Install minecraft-attach util to attach to server console
install_file "minecraft-attach" \
	"/usr/bin/minecraft-attach" \
	root: 755
