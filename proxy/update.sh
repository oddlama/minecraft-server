#!/bin/bash

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../contrib/utils.sh" || exit 1
become_minecaft "./update.sh"


################################################################
# Download velocity and prepare plugins

download_velocity velocity.jar

# Create plugins directory
mkdir -p plugins \
	|| die "Could not create directory 'plugins'"


################################################################
# Download plugins
# Can use the following util functions to add plugins to the autoupdater:
# syntax: command (required argument) [optional argument]
# - download_file (url) (output file) [failure message]
# - download_latest_github_release (repo) (remote filename) (output file)
#  -> {TAG} will be replaced with the release tag
#  -> {VERSION} will be replaced with release tag excluding a leading v, if present
# - download_from_json_feed (feed url) (jq parser) (output file)
# - download_from_hangar (project) (platform) (output file)
# - download_from_modrinth (mod ID/name) (platform) (output file) [minecraft version]

substatus "Downloading plugins"
download_latest_github_release "oddlama/vane" "vane-velocity-{VERSION}.jar" "plugins/vane-velocity.jar"
download_from_json_feed \
  "https://ci.lucko.me/job/spark/lastSuccessfulBuild/api/json" \
  '.artifacts[]
   | select(.fileName | test("^spark-.*-velocity\\.jar$"))
   | "https://ci.lucko.me/job/spark/lastSuccessfulBuild/artifact/"+.relativePath' \
  "plugins/Spark.jar"
