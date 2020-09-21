#!/bin/bash

set -uo pipefail

exec_fork() {
	setsid "$@" &
}

MAX_SECONDS_WAIT=300
wait_for_pidfile_to_disappear() {
	# Wait for pidfile to disappear
	local seconds_waited=0
	while [[ $seconds_waited -lt $MAX_SECONDS_WAIT ]] ; do
		[[ -e $PIDFILE ]] || break
		sleep 1
		((++seconds_waited))
	done

	[[ $seconds_waited -lt $MAX_SECONDS_WAIT ]]
}

# Prepare TMUX command
TMUX_SOCKET="/opt/minecraft/tmux/$SERVER_NAME"
TMUX_EXEC="/usr/bin/tmux -2 -f /etc/tmux.conf -S $TMUX_SOCKET set -g default-shell /bin/bash ; "

service_start() {
	$TMUX_EXEC kill-server 2>/dev/null
	wait_for_pidfile_to_disappear

	exec_fork $TMUX_EXEC new-session -d "$1"
}

service_stop() {
	einfo "Please be patient, stopping the server can take some time (up to $MAX_SECONDS_WAIT seconds)."

	# Kill the pid
	kill "$(cat "$PIDFILE")"
	sleep 5

	# Wait until stopped
	wait_for_pidfile_to_disappear \
		|| eerror "Pidfile still existent after $MAX_SECONDS_WAIT seconds. Ignoring, server might be forcibly killed."

	sleep 5
	# Then exit tmux
	$TMUX_EXEC kill-server 2>/dev/null
}

service_attach() {
	$TMUX_EXEC attach-session
}
