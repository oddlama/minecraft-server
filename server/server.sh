#!/bin/bash

LOG_DIR="/var/log/minecraft/server"
BACKUP_LOG_FILE="$LOG_DIR/backup.log"
BACKUP_TO="backup"
BACKUP_DIRS=(
	'plugins'
	'world'
	'world_nether'
	'world_the_end'
)

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1

# Create logs directory link
mkdir -p "$LOG_DIR" \
	|| die "Could not create directory '$LOG_DIR'"

link_dir "$LOG_DIR" "logs"

# Start java
status "Starting server"
java -Xms10G -Xmx10G \
	-XX:+UseG1GC \
	-XX:+ParallelRefProcEnabled \
	-XX:MaxGCPauseMillis=200 \
	-XX:+UnlockExperimentalVMOptions \
	-XX:+DisableExplicitGC \
	-XX:+AlwaysPreTouch \
	-XX:G1NewSizePercent=30 \
	-XX:G1MaxNewSizePercent=40 \
	-XX:G1HeapRegionSize=8M \
	-XX:G1ReservePercent=20 \
	-XX:G1HeapWastePercent=5 \
	-XX:G1MixedGCCountTarget=4 \
	-XX:InitiatingHeapOccupancyPercent=15 \
	-XX:G1MixedGCLiveThresholdPercent=90 \
	-XX:G1RSetUpdatingPauseTimePercent=5 \
	-XX:SurvivorRatio=32 \
	-XX:+PerfDisableSharedMem \
	-XX:MaxTenuringThreshold=1 \
	-Dusing.aikars.flags=https://mcflags.emc.gs \
	-Daikars.new.flags=true \
	-jar paper.jar nogui

# Backup world
status_time "Starting backup"

mkdir -p "$BACKUP_TO" &>/dev/null
for i in "${!BACKUP_DIRS[@]}"; do
	status_time "Backing up ${BACKUP_DIRS[$i]}"
	echo "$(datetime) Backing up ${BACKUP_DIRS[$i]}" &>> "$BACKUP_LOG_FILE"
	rdiff-backup "${BACKUP_DIRS[$i]}" "$BACKUP_TO/${BACKUP_DIRS[$i]}" &>> "$BACKUP_LOG_FILE"
done

status_time "Backup finished"
echo "$(datetime) Backup finished" &>> "$BACKUP_LOG_FILE"
