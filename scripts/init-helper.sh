#!/bin/bash
# vim: set filetype=gentoo-init-d:
#
# Necessary environment variables:
# SERVER_NAME

set -uo pipefail

extra_started_commands="attach"

SERVER_DIR="/opt/minecraft/server/$SERVER_NAME"
SERVER_SERVICE_SCRIPT="$SERVER_DIR/service.sh"

LOG_DIR="/var/log/minecraft/$SERVER_NAME"
TMUX_DIR="/opt/minecraft/tmux"

PIDDIR="/var/run/minecraft"
PIDFILE="$PIDDIR/$SERVER_NAME.pid"

depend() {
	need net
}

run_server() {
	(
		cd "$SERVER_DIR"
		sudo -u minecraft -- \
			env \
				INITD=true \
				PIDFILE="$PIDFILE" \
				SERVER_NAME="$SERVER_NAME" \
				"$SERVER_SERVICE_SCRIPT" \
				"$@"
	)
}

start_pre() {
	checkpath -qd --owner minecraft:minecraft --mode 0700 \
		"$LOG_DIR" \
		"$TMUX_DIR" \
		"$PIDDIR" \
			|| { eerror "checkpath returned $?"; return 1; }
}

start() {
	ebegin "Starting minecraft server '$SERVER_NAME'"
	if ! start-stop-daemon \
		--start \
		--pidfile "$PIDFILE" \
		--chdir "$SERVER_DIR" \
		--user minecraft \
		--env INITD=true \
		--env PIDFILE="$PIDFILE" \
		--env SERVER_NAME="$SERVER_NAME" \
		--exec "$SERVER_SERVICE_SCRIPT" -- \
			start
	then
		# Failure -> exit immediately
		eend $?
	else
		# Wait for pidfile to appear
		SECONDS_WAITED=0 MAX_SECONDS_WAIT=5
		while [[ $SECONDS_WAITED -lt $MAX_SECONDS_WAIT ]] ; do
			[[ -e $PIDFILE ]] && break
			sleep 1
			((++SECONDS_WAITED))
		done

		# Return OK (0) if we waited less than the maximum allowed amount of seconds
		[[ $SECONDS_WAITED -lt $MAX_SECONDS_WAIT ]]
		eend $?
	fi
}

attach() {
	run_server attach
}

stop() {
	ebegin "Stopping minecraft server '$SERVER_NAME'"
	run_server stop
	eend $?
}
