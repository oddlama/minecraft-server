#!/bin/bash

# Arguments:
# $1: action (start, stop, attach)

# Neceessary environment variables:
# INITD=true
# SERVER_NAME
# PIDFILE

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1
source "../contrib/server-helper.sh" || die "Failed to source server-helper"

# Invocation protection
INITD="${INITD:-false}"
[[ $INITD == true ]] \
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
