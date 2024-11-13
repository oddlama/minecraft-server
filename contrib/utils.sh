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

function flush_stdin() {
	local empty_stdin
	# Unused variable is intentional.
	# shellcheck disable=SC2034
	while read -r -t 0.01 empty_stdin; do true; done
}

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

# $1: url
# $2: output file name
# $3: failure message (optional)
function download_file() {
	local failure_message
	if [[ "$#" == "3" ]]; then
		failure_message="$3"
	else
		failure_message="Could not download $2 from $1"
	fi
	wget -L -q --show-progress "$1" -O "$2" || die "$failure_message"
}

# $1: output file name
# $2: OPTIONAL - paper minecraft version (eg. 1.20.4)
function download_paper() {
	local paper_version
	local paper_build
	local paper_download
	if [ $# -eq 1 ]; then
		paper_version="$(curl -s -o - "https://api.papermc.io/v2/projects/paper" | jq -r ".versions[-1]")" \
			|| die "Error while retrieving latest paper version"
	elif [ $# -eq 2 ]; then
		paper_version="$2"
	elif [ $# -gt 2 ]; then
		die "Too many arguments passed to download_paper"
	fi
	paper_build="$(curl -s -o - "https://api.papermc.io/v2/projects/paper/versions/$paper_version" | jq -r ".builds[-1]")" \
		|| die "Error while retrieving paper builds"
	paper_download="$(curl -s -o - "https://api.papermc.io/v2/projects/paper/versions/$paper_version/builds/$paper_build" | jq -r ".downloads.application.name")" \
		|| die "Error while retrieving paper download name"

	substatus "Downloading paper version $paper_version build $paper_build ($paper_download)"
	wget -q --show-progress "https://api.papermc.io/v2/projects/paper/versions/$paper_version/builds/$paper_build/downloads/$paper_download" \
		-O "$1" \
		|| die "Could not download paper"
}

# $1: output file name
function download_velocity() {
	local velocity_version
	local velocity_build
	local velocity_download
	velocity_version="$(curl -s -o - "https://api.papermc.io/v2/projects/velocity" | jq -r ".versions[-1]")" \
		|| die "Error while retrieving velocity version"
	velocity_build="$(curl -s -o - "https://api.papermc.io/v2/projects/velocity/versions/$velocity_version" | jq -r ".builds[-1]")" \
		|| die "Error while retrieving velocity builds"
	velocity_download="$(curl -s -o - "https://api.papermc.io/v2/projects/velocity/versions/$velocity_version/builds/$velocity_build" | jq -r ".downloads.application.name")" \
		|| die "Error while retrieving velocity download name"

	substatus "Downloading velocity version $velocity_version build $velocity_build ($velocity_download)"
	wget -q --show-progress "https://api.papermc.io/v2/projects/velocity/versions/$velocity_version/builds/$velocity_build/downloads/$velocity_download" \
		-O "$1" \
		|| die "Could not download velocity"
}

# $1: repo, e.g. "oddlama/vane"
declare -A LATEST_GITHUB_RELEASE_TAG_CACHE
function latest_github_release_tag() {
	local repo=$1
	if [[ ! -v "LATEST_GITHUB_RELEASE_TAG_CACHE[$repo]" ]]; then
		local tmp
		tmp=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name) \
			|| die "Error while retrieving latest github release tag of $repo"
		LATEST_GITHUB_RELEASE_TAG_CACHE[$repo]="$tmp"
	fi
	echo "${LATEST_GITHUB_RELEASE_TAG_CACHE[$repo]}"
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

	wget -L -q --show-progress "https://github.com/$repo/releases/download/$tag/$remote_file" -O "$output" \
		|| die "Could not download $remote_file from github repo $repo"
}

# $1: Feed URL
# $2: json location
# $3: output file name
function download_from_json_feed() {
        local download_url

        download_url="$(curl -s -o - "$1" | jq -r "$2")" \
                || die "Error while retrieving url of type $2 from feed $1"

        wget -L -q --show-progress "$download_url" \
                -O "$3" \
                || die "Could not download $download_url"
}

# $1: mod ID / name
# $2: platform (paper, folia, etc)
# $3: output file name
# $4: (optional) minecraft game version
function download_from_modrinth() {
	local feed
	local jq_filter
	local download_url
	if [[ "$#" -lt 3 ]]; then
		die "Not enough args for download_from_modrinth to download $2"
	fi
	feed=$(curl -s -o - "https://api.modrinth.com/v2/project/$1/version") \
		|| die "Error while fetching modrinth api for $1"
	jq_filter="first(.[] | {versions: .game_versions, platforms: .loaders, url: .files[0].url} | select(.platforms[] | contains(\"$2\"))"
	if [[ "$#" -gt 3 ]]; then
		jq_filter+=" | select(.versions[] | contains(\"$4\"))"
	fi
	jq_filter+=').url'
	download_url=$(echo "$feed" | jq -r "$jq_filter") \
		|| die "jq filter $jq_filter is invalid"
	wget -L -q --show-progress "$download_url" \
		-O "$3" \
		|| die "Could not download $download_url"
}