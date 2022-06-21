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
source "../contrib/utils.sh" || exit 1

status_time "Starting backup"

mkdir -p "$BACKUP_TO" &>/dev/null
for i in "${!BACKUP_DIRS[@]}"; do
	status_time "Backing up ${BACKUP_DIRS[$i]}" | tee -a "$BACKUP_LOG_FILE"
	rdiff-backup "${BACKUP_DIRS[$i]}" "$BACKUP_TO/${BACKUP_DIRS[$i]}" &>> "$BACKUP_LOG_FILE"
done

status_time "Backup finished" | tee -a "$BACKUP_LOG_FILE"
