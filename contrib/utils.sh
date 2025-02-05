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
	local domain
	local middle_path
	local last_part
	local cache_path
	# decide error message
	if [[ "$#" -gt "3" ]]; then
		die "Incorrect argument count for download_file"
	elif [[ "$#" -eq "3" ]]; then
		failure_message="$3"
	else
		failure_message="Could not download $2 from $1"
	fi

	# parse the url
	domain=$(     echo "$1" | sed -E 's#^https?://([^/]+).*#\1#')
	middle_path=$(echo "$1" | sed -E 's#^https?://[^/]+/##; s#/[^/]+$##')
	last_part=$(  echo "$1" | sed -E 's#^.*/([^/?]+).*#\1#')
	# where in the world is this file in the cache??????????
	cache_path=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
	cache_path+="/cache/$domain/$middle_path/$last_part"
	# is it not in cache?
	if [[ ! -f "$cache_path" ]]; then
		mkdir -p "$(dirname "$cache_path")" # just in case
		# fetch it
		wget -L -q --show-progress "$1" -O "$cache_path" || die "$failure_message"
	else
		touch -c -a "$cache_path"
	fi
	# link to conserve space
	mkdir -p "$(dirname "$2")"
	ln -sf "$cache_path" "$2"
}

# $1: output file name
function download_paper() {
	local paper_version
	local paper_build
	local paper_download
	paper_version="$(curl -s -o - "https://api.papermc.io/v2/projects/paper" | jq -r ".versions[-1]")" \
		|| die "Error while retrieving paper version"
	paper_build="$(curl -s -o - "https://api.papermc.io/v2/projects/paper/versions/$paper_version" | jq -r ".builds[-1]")" \
		|| die "Error while retrieving paper builds"
	paper_download="$(curl -s -o - "https://api.papermc.io/v2/projects/paper/versions/$paper_version/builds/$paper_build" | jq -r ".downloads.application.name")" \
		|| die "Error while retrieving paper download name"

	substatus "Downloading paper version $paper_version build $paper_build ($paper_download)"
	download_file "https://api.papermc.io/v2/projects/paper/versions/$paper_version/builds/$paper_build/downloads/$paper_download" \
		"$1" "Could not download paper"
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
	download_file "https://api.papermc.io/v2/projects/velocity/versions/$velocity_version/builds/$velocity_build/downloads/$velocity_download" \
		"$1" "Could not download velocity"
}

# $1: repo, e.g. "oddlama/vane"
function latest_github_release_tag() {
	local repo=$1
	local cache=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
	cache+="/cache/github/$repo.txt"
	##### :( github rate limits suck!
	##### thankfully, we can check if there were modifications
	##### with the last_modified header, and it doesn't count
	##### towards the limit
	## stored in files named cache/github/user_name/repo_name.txt
	## cache format:
	## line #1: version info
	## line #2: latest time checked
	local last_modified
	# first, check if cache file exists
	if [[ -f "$cache" ]]; then
		# if it does, great! we can store it into last_modified
		last_modified=$(cat "$cache" | tail -n 1)
	else
		# I wonder, did the internet exist in times of Christ?
		last_modified='Sun, 25 Dec 0000 07:18:26 GMT'
	fi

	# send the request
	local response=$(curl -i -s "https://api.github.com/repos/$repo/releases/latest" \
		--include --header "if-modified-since: $last_modified")
	local response_code=$(echo "$response" | head -n 1 | sed 's/^[^ ]* //')
	# echos the response, sed only the headers, grep the header we want, and extract the contents with sed once more. Beautiful!
	local response_last_modified=$(echo "$response" | sed '/^\r$/q' | grep 'last-modified: ' | sed 's/^[^:]*: //')
	local response_requests_left=$(echo "$response" | sed '/^\r$/q' | grep 'x-ratelimit-remaining: ' | sed 's/^[^:]*: //')
	local response_body=$(echo "$response" | sed '1,/^\r$/d')

	if [[ "$response_requests_left" == "0" || ( "$response_code" == "403" || "$response_code" == "429" ) ]]; then
		die 'Exceeded Github ratelimit, try again later'
	elif [[ "$last_modified" == "$response_last_modified" && "$response_body" == "" ]]; then
		# wasn't modified, we can use cache
		cat "$cache" | head -n 1
	elif [[ "$last_modified" != "$response_last_modified" && "$response_body" != "" ]]; then
		# was modified, need to overwrite cache
		local tag=$(echo "$response_body" | jq -r '.tag_name')
		mkdir -p "$(dirname "$cache")"
		if [[ "$tag" == "null" || "$response_last_modified" == "" ]]; then
			die 'Incorrect tags, have you hit a ratelimit?'
		fi
		echo "$tag" > "$cache"
		echo "$response_last_modified" >> "$cache"
		echo "$tag"
	else
		die "Unreachable in latest_github_release_tag"
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

	if [[ "$tag" == "" ]]; then
		die "Tag fetching failed for $remote_file in $repo"
	fi

	download_file "https://github.com/$repo/releases/download/$tag/$remote_file" \
		"$output" "Could not download $remote_file from github repo $repo"
}

# $1: Feed URL
# $2: json location
# $3: output file name
function download_from_json_feed() {
	local download_url

	download_url="$(curl -s -o - "$1" | jq -r "$2")" \
			|| die "Error while retrieving url of type $2 from feed $1"

	download_file "$download_url" "$3"
}

# $1: Project slug, eg. "ViaVersion"
# $2: (optional) release channel eg. Alpha, Experimental, Snapshot, Release...
#     defaults to "release"
# returns the hangar release version string in stdout
function latest_hangar_release_version() {
	local project=$1
	# no caching latest version...
	# but yes error handling
	local response=''
	local channel=''
	if [[ "$#" == "1" ]]; then
		response=$(curl -X GET "https://hangar.papermc.io/api/v1/projects/$project/latestrelease" -i -H 'accept: text/plain')
	elif [[ "$#" == "2" ]]; then
		channel=$2
		response=$(curl -X GET "https://hangar.papermc.io/api/v1/projects/$project/latest?channel=$channel" -i -H 'accept: text/plain')
	else
		die "Incorrect argument count for fetching hangar release version for project $project: $#"
	fi
	
	local response_code=$(echo "$response" | head -n 1 | sed 's/^[^ ]* //' | xargs)
	local response_body=$(echo "$response" | sed '1,/^\r$/d')
	if [[ ! "$response_code" == "200" ]]; then
		die "Failure fetching hangar release version for project $project, status code $response_code"
	elif [[ "$response_body" == "" ]]; then
		die "Failure fetching hangar release version for project $project, response body empty"
	fi

	echo "$response_body"
}

# $1: Project slug, eg. "ViaVersion"
# $2: Platform (one from:['PAPER', 'WATERFALL', 'VELOCITY'])
# $3: Output file
# $4: (optional) release channel eg. Alpha, Experimental, Snapshot, Release...
#     defaults to "release"
function download_from_hangar() {
	local project=$1
	local platform=$2
	local output_file=$3
	# first, find version
	local version=''
	if [[ "$#" == "3" ]]; then
		version=$(latest_hangar_release_version "$project")
	elif [[ "$#" == "4" ]]; then
		version=$(latest_hangar_release_version "$project" "$4")
	else
		die "Wrong number of arguments for download_from_hangar: $#"
	fi

	download_file "https://hangar.papermc.io/api/v1/projects/$project/versions/$version/$platform/download" \
		"$output_file" "Error downloading $project $version from hangar for $platform, does it exist?"
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
	# selects the first element of the list of versions
	jq_filter="first(.[]"
	# remap the versions, platforms, and url to a simple json object
	jq_filter+= " | {versions: .game_versions, platforms: .loaders, url: .files[0].url}"
	# and select those that contain $2 in their platform list
	jq_filter+=" | select(.platforms[] | contains(\"$2\"))"
	if [[ "$#" -gt 3 ]]; then
		# if version is also specified, select that too...
		jq_filter+=" | select(.versions[] | contains(\"$4\"))"
	fi
	# of the first item, get and return the url
	jq_filter+=').url'
	download_url=$(echo "$feed" | jq -r "$jq_filter") \
		|| die "jq filter $jq_filter is invalid"
	
	download_file "$download_url" "$3"
}