#!/bin/bash

export PATH="/opt/oracle-jdk-bin-11.0.2/bin:$PATH"
export JAVA_HOME="/opt/oracle-jdk-bin-11.0.2"

einfo() {
	echo " [1;32m*[m $*"
}

eerror() {
	echo "[1;31merror:[m $*" >&2
}

die() {
	eerror "$@"
	exit 1
}

status() {
	echo "[1m[[1;32m+[m[1m][m $*"
}

datetime() {
	date "+%Y-%m-%d %H:%M:%S"
}

status_time() {
	status "[$(datetime)]" "$@"
}

link_dir() {
	local dst="$1"
	local link="$2"
	if [[ -h "$link" ]]; then
		if [[ "$(readlink "$link")" == "$dst" ]]; then
			return 0
		else
			# Relink
			rm "$link"
		fi
	elif [[ -e "$link" ]]; then
		die "'$link' already exists and is not a link. Please resolve manually."
	fi

	ln -s "$dst" "$link" \
		|| die "Could not link '$dst' to '$link' directory"
}
