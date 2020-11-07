#!/bin/bash

for name in server proxy; do
	file="/lib/systemd/system/minecraft-$name.service"
	echo "Installing $file ..."
	cp "scripts/systemd/minecraft-$name.service" "$file"
	chown root: "$file"
	chmod 644 "$file"
done
