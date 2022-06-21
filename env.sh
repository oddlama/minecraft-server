#!/bin/bash

#export JAVA_HOME="$HOME/openjdk-jre-bin-17"
#export PATH="$JAVA_HOME/bin:$PATH"

function einfo() { echo " [1;32m*[m $*"; }
function eerror() { echo "[1;31merror:[m $*" >&2; }
function die() { eerror "$@"; exit 1; }

function status() { echo "[1m[[1;32m+[m[1m][m $*"; }
function datetime() { date "+%Y-%m-%d %H:%M:%S"; }
function status_time() { status "[$(datetime)]" "$@"; }

function link_dir() {
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
