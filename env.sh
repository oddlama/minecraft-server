#!/bin/bash

#export JAVA_HOME="$HOME/openjdk-jre-bin-17"
#export PATH="$JAVA_HOME/bin:$PATH"

function einfo() { echo " [1;32m*[m $*"; }
function eerror() { echo "[1;31merror:[m $*" >&2; }
function die() { eerror "$@"; exit 1; }

function status() { echo "[1m[[1;32m+[m[1m][m $*"; }
function datetime() { date "+%Y-%m-%d %H:%M:%S"; }
function status_time() { status "[$(datetime)]" "$@"; }
