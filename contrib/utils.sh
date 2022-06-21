#!/bin/bash

set -uo pipefail


################################################################
# General helper functions

function print_error() { echo "[1;31merror:[m $*" >&2; }
function die() { print_error "$@"; exit 1; }

function status() { echo "[1;33m$*[m"; }
function substatus() { echo "[32m$*[m"; }
function datetime() { date "+%Y-%m-%d %H:%M:%S"; }
function status_time() { echo "[1;33m[$(datetime)] [1m$*[m"; }

function ask() {
	local response
	while true; do
		flush_stdin
		read -r -p "$* (Y/n) " response || die "Error in read"
		case "${response,,}" in
			'') return 0 ;;
			y|yes) return 0 ;;
			n|no) return 1 ;;
			*) continue ;;
		esac
	done
}


################################################################
# Download helper functions

# $@: command to run as minecraft if user was changed.
#     You want to pass path/to/curent/script.sh "$@".
function become_minecaft() {
	if [[ $(id -un) != "minecraft" ]]; then
		if [[ $EUID == 0 ]] && ask "This script must be executed as the minecraft user. Change user and continue?"; then
			exec runuser -u minecraft "$@"
			die "Could not change user!"
		else
			die "This script must be executed as the minecraft user!"
		fi
	fi
}

# $1: output file name
function download_paper() {
	local paper_version
	local paper_build
	local paper_download
	paper_version="$(curl -s -o - "https://papermc.io/api/v2/projects/paper" | jq -r ".versions[-1]")" \
		|| die "Error while retrieving paper version"
	paper_build="$(curl -s -o - "https://papermc.io/api/v2/projects/paper/versions/$paper_version" | jq -r ".builds[-1]")" \
		|| die "Error while retrieving paper builds"
	paper_download="$(curl -s -o - "https://papermc.io/api/v2/projects/paper/versions/$paper_version/builds/$paper_build" | jq -r ".downloads.application.name")" \
		|| die "Error while retrieving paper download name"

	substatus "Downloading paper version $paper_version build $paper_build ($paper_download)"
	curl --progress-bar "https://papermc.io/api/v2/projects/paper/versions/$paper_version/builds/$paper_build/downloads/$paper_download" \
		-o "$1" \
		|| die "Could not download paper"
}

# $1: output file name
function download_waterfall() {
	local waterfall_version
	local waterfall_build
	local waterfall_download
	waterfall_version="$(curl -s -o - "https://papermc.io/api/v2/projects/waterfall" | jq -r ".versions[-1]")" \
		|| die "Error while retrieving waterfall version"
	waterfall_build="$(curl -s -o - "https://papermc.io/api/v2/projects/waterfall/versions/$waterfall_version" | jq -r ".builds[-1]")" \
		|| die "Error while retrieving waterfall builds"
	waterfall_download="$(curl -s -o - "https://papermc.io/api/v2/projects/waterfall/versions/$waterfall_version/builds/$waterfall_build" | jq -r ".downloads.application.name")" \
		|| die "Error while retrieving waterfall download name"

	substatus "Downloading waterfall version $waterfall_version build $waterfall_build ($waterfall_download)"
	curl --progress-bar "https://papermc.io/api/v2/projects/waterfall/versions/$waterfall_version/builds/$waterfall_build/downloads/$waterfall_download" \
		-o "$1" \
		|| die "Could not download waterfall"
}

# $1: repo, e.g. "oddlama/vane"
declare -A LATEST_GITHUB_RELEASE_TAG_CACHE
function latest_github_release_tag() {
	local repo=$1
	if [[ -v "LATEST_GITHUB_RELEASE_TAG_CACHE[$repo]" ]]; then
		echo "cached: ${LATEST_GITHUB_RELEASE_TAG_CACHE[$repo]}" >&2
		echo "${LATEST_GITHUB_RELEASE_TAG_CACHE[$repo]}"
	else
		local tmp
		tmp=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name) \
			|| die "Error while retrieving latest github release tag of $repo"
		LATEST_GITHUB_RELEASE_TAG_CACHE[$repo]="$tmp"
		echo "new: $tmp -> store ${LATEST_GITHUB_RELEASE_TAG_CACHE[$repo]}" >&2
	fi
}

# $1: repo, e.g. "oddlama/vane"
# $2: remote file name.
#     {TAG} will be replaced with the release tag
#     {VERSION} will be replaced with release tag excluding a leading v, if present
# $3: output file name
function download_latest_github_release() {
	local repo=$1
	local remote_file=$2
	local output=$3

	local tag=$(latest_github_release_tag "$repo")
	local version="${tag#v}" # Always strip leading v in version.

	remote_file="${remote_file//"{TAG}"/"$tag"}"
	remote_file="${remote_file//"{VERSION}"/"$version"}"

	substatus "Downloading $remote_file from github repo $repo"
	curl --progress-bar -L "https://github.com/$repo/releases/download/$tag/$remote_file" -o "$output" \
		|| die "Could not download $remote_file from github repo $repo"
}

# $1: url
# $2: output file name
function download_file() {
	substatus "Downloading $2"
	curl --progress-bar -L "$1" -o "$2" || die "Could not download $1"
}
