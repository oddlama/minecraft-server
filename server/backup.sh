#!/bin/bash

set -uo pipefail

BACKUP_LOG_FILE="logs/backup.log"
BACKUP_TO="backups"
BACKUP_DIRS=(
	'plugins'
	'world'
	'world_nether'
	'world_the_end'
)

cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../env.sh" || exit 1

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
