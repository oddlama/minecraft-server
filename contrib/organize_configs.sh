#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "utils.sh" || exit 1


################################################################
# Sort keys in all configuration files

cd ..
contrib/sort_yaml.py server/*.yml proxy/*.yml
contrib/sort_server_properties.py server/server.properties
