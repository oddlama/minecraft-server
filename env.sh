#!/bin/bash

export PATH="/opt/oracle-jdk-bin-11.0.2/bin:$PATH"
export JAVA_HOME="/opt/oracle-jdk-bin-11.0.2"

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

download_paper() {
	paper_version="$(curl -s -o - "https://papermc.io/api/v1/paper" | jq -r ".versions[0]")" \
		|| die "Error while retrieving paper version"
	paper_build="$(curl -s -o - "https://papermc.io/api/v1/paper/$paper_version" | jq -r ".builds.latest")" \
		|| die "Error while retrieving paper build"

	status "Downloading paper version $paper_version build $paper_build"
	curl "https://papermc.io/api/v1/paper/$paper_version/$paper_build/download" \
		-o paper.jar \
		|| die "Could not download paper"
}

download_waterfall() {
	waterfall_version="$(curl -s -o - "https://papermc.io/api/v1/waterfall" | jq -r ".versions[0]")" \
		|| die "Error while retrieving waterfall version"
	waterfall_build="$(curl -s -o - "https://papermc.io/api/v1/waterfall/$waterfall_version" | jq -r ".builds.latest")" \
		|| die "Error while retrieving waterfall build"

	status "Downloading waterfall version $waterfall_version build $waterfall_build"
	curl "https://papermc.io/api/v1/waterfall/$waterfall_version/$waterfall_build/download" \
		-o waterfall.jar \
		|| die "Could not download waterfall"
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
