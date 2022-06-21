#!/bin/bash

[[ $EUID == 0 ]] \
	|| die "Must be root for system-wide installation."

for name in server proxy; do
	file="/lib/systemd/system/minecraft-$name.service"
	echo "Installing $file ..."
	cp "contrib/systemd/minecraft-$name.service" "$file"
	chown root: "$file"
	chmod 644 "$file"
done

minecraft_attach="/usr/bin/minecraft-attach"
echo "Installing $minecraft_attach ..."
cp "contrib/systemd/minecraft-attach" "$minecraft_attach"
chown root: "$minecraft_attach"
chmod 755 "$minecraft_attach"
