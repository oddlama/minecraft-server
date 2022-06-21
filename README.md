# Minecraft Server Deploy

This is an example of how to properly(TM) deploy a minecraft server with the following features:

- ⏱️ Uses [PaperMC](https://papermc.io) and [Aikar's JVM flags](https://aikar.co/mcflags.html) for maximum performance.
- 🔒 Sandboxed execution with systemd, no docker.
- 🚀 Server starts automatically when players connect and shuts down when idle.
- 💾 Creates incremental world backups after each server stop.
- 🖥️ Background console access via tmux (also removetly via ssh)
- 🔋 Includes scripts for automatic server & plugin updates.
- 🐙 Can sort yaml files & server.properties to allow git tracking.
- 🔢 Account multiplexing. This allows a single account to have two or more player charcters. Useful as spectator accounts or to share accounts.

#### Default plugins:

- [vane](https://github.com/oddlama/vane) - Immersive and lore friendly enhancements for vanilla Minecraft
- [bluemap](https://bluemap.bluecolored.de/) - Live online 3D world viewer and minimap

## Installation

The main installation is very simple, afterwards you can continue with [Server Configuration](#Server-Configuration).

```bash
sudo curl -sL https://oddlama.github.io/minecraft-server/bootstrap | bash
```

This will perform the following steps:

- Checks whether all required tools are installed
- Creates a new `minecraft` user for the server
- Updates the server jars and downloads plugins
- Installs, enables and starts systemd services

Please review the bootstrap script to ensure that it doesn't do something unexpected.
For most setups, the bootusers, the bootstrap script should be sufficient.

## Server Configuration

By default

## Usage

#### Viewing the console

minec

## Committing your yaml files

## Useful tools

- [Cubiomes Viewer](https://github.com/Cubitect/cubiomes-viewer) - To find a good world seed
- [MCASelector](https://github.com/Querz/mcaselector) - To trim e.g. unpopulated chunks

## Contributing

Whether you'd like to create and maintain a package for your favourite distribution,
or add a new feature to this deploy, always feel free to create an issue or pull-request on github.
