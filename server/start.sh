#!/bin/bash

set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null \
	|| exit 1
source "../contrib/utils.sh" || exit 1

# Use 80% of RAM, but not more than 12GiB and not less than 1GiB
total_ram_gibi=$(free -g | grep -oP '\d+' | head -n1)
ram="$((total_ram_gibi * 8 / 10))"
[[ "$ram" -le 12 ]] || ram=12
[[ "$ram" -ge 1 ]] || ram=1

status "Executing server using ${ram}GiB of RAM"
exec java -Xms${ram}G -Xmx${ram}G \
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
	-DpreferSparkPlugin=true \
	-jar paper.jar nogui
