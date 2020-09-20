#!/bin/bash

mkdir -p /usr/bin/minecraft
init_helper_file="/usr/bin/minecraft/init-helper.sh"
echo "Installing $init_helper_file ..."
cp "scripts/init-helper.sh" "$init_helper_file"
chown root: "$init_helper_file"
chmod 755 "$init_helper_file"

for name in server proxy; do
	file="/etc/init.d/minecraft-$name"
	echo "Installing $file ..."

	cat > "$file" << EOF
#!/sbin/openrc-run

SERVER_NAME="$name"

source "$init_helper_file"
EOF

	chown root: "$file"
	chmod 755 "$file"
done
