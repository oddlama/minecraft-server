#!/bin/bash

# Arguments:
# $1: action (start, stop, attach)

# Necessary environment variables:
# CALLED_FROM_SERVICE=true
# SERVER_NAME
# PIDFILE

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../contrib/utils.sh" || exit 1
source "../contrib/server-helper.sh" || die "Failed to source server-helper"

# Invocation protection
CALLED_FROM_SERVICE="${CALLED_FROM_SERVICE:-false}"
[[ $CALLED_FROM_SERVICE == true ]] \
	|| die "Do not call this script directly! Use the init.d wrapper!"

mkdir -p "$(dirname "$TMUX_SOCKET")"  \
	|| die "Could not create tmux socket directory"

case "$1" in
	"start")
		service_start "../contrib/server_loop.py ./start.sh"
		;;

	"stop")
		service_stop || true
		;;

	"attach")
		service_attach
		;;
esac
