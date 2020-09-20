#!/bin/bash

for name in server proxy; do
	file="/etc/init.d/minecraft-$name"
	echo "Installing $file ..."

	cat > "$file" << EOF
#!/sbin/openrc-run

SERVER_NAME="$name"

source /opt/minecraft/server/scripts/init-helper.sh
EOF

	chown root: "$file"
	chmod 755 "$file"
done
