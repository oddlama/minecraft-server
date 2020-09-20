#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1

case "$1" in
	"start")
		# "./server.sh" &
		;;

	"stop")   ;;
	"attach") ;;
esac
