# Minecraft Server Deploy

This is an example of how to properly(TM) deploy a minecraft server with the following features:

- 🔒 Sandboxed execution with systemd, and without docker.
- 💾 Automatic incremental world backups with rdiff-backup after each server stop.
- 🚀 Automatic start when players connect. Starting is atomic, so repeated and simultaneous start requests will only start the server once.
- 🛑 Automatic stop when nobody is online for 20 minutes, provided by vane.
- 🔧 Systemd services for proxy & server
- 🖥️ Background console access via tmux (also removetly via ssh)
- 🔋 Includes utilities to update jar files, sort yaml files & server.properties (allows tracking changes properly).
- ⏱️ Uses [PaperMC](https://papermc.io) and [Aikar's JVM flags](https://aikar.co/mcflags.html) for maximum performance.
- 🔢 Account multiplexing. This allows a single account to have two or more player characters. Useful as spectator accounts or to share accounts.

#### Default plugins:

- [vane](https://github.com/oddlama/vane) - Immersive and lore friendly enhancements for vanilla Minecraft
- [bluemap](https://bluemap.bluecolored.de/) - Live online 3D world viewer and minimap

## Installation

Prerequisites:

- A linux server with Java 17 or higher
- systemd, >=python3.7, git, curl (all probably already installed)
- jq, tmux, rdiff-backup

- clone
- create minecraft user
- edit systemd service to allow access to paths
- call install script

## Usage

#### Viewing the console

minec

## Committing your yaml files

-
