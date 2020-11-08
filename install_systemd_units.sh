#!/bin/bash

for name in server proxy; do
	file="/lib/systemd/system/minecraft-$name.service"
	echo "Installing $file ..."
	cp "scripts/systemd/minecraft-$name.service" "$file"
	chown root: "$file"
	chmod 644 "$file"
done

minecraft_attach="/usr/bin/minecraft-attach"
echo "Installing $minecraft_attach ..."
cp "scripts/systemd/minecraft-attach" "$minecraft_attach"
chown root: "$minecraft_attach"
chmod 755 "$minecraft_attach"
