# Minecraft Server Deploy

This is an example of how to properly(TM) deploy a minecraft server with the following features:

- 🚀 Server starts automatically when players connect and shuts down when idle.
- ⏱️ Uses [PaperMC](https://papermc.io) and [Aikar's JVM flags](https://aikar.co/mcflags.html) for maximum performance.
- 🔒 Sandboxed execution with systemd, no docker.
- 💾 Creates incremental world backups after each server stop.
- 🖥️ Background console access via tmux (also removetly via ssh)
- 🔋 Includes scripts for automatic server & plugin updates.
- 🐙 Can sort yaml files & server.properties to allow git tracking.
- 🔢 Account multiplexing. Allows a single account to have two or more player characters.

#### Default plugins

- [vane](https://github.com/oddlama/vane) - Immersive and lore friendly enhancements for vanilla Minecraft
- [bluemap](https://bluemap.bluecolored.de/) - Live online 3D world viewer and minimap

## Installation

To begin the automatic installation, simply run the provided bootstrap script.
Afterwards you can continue [configuring your server](#Server-Configuration),
or jump straight to the [Usage](#Usage) section if you are happy with the defaults.

```bash
sudo curl -sL https://oddlama.github.io/minecraft-server/bootstrap | bash
# Connect to the console (Press Ctrl+b then d to detach again)
minecraft-attach server
```

You may want to [review](https://github.com/oddlama/minecraft-server/blob/pages/bootstrap) the script before executing it.
In summary, the script will perform the following steps:

- Check whether all required tools are installed
- Create a new `minecraft` user for the server (if not existing)
- Update the server jars and download all plugins
- Install, enable and start the systemd services

## Server Configuration

At this point, your proxy server is already running and the actual
server will be started once you connect to it. Now is the time to
review or change the server configuration. Here is a list of things you
might want to configure now. All settings that were changed by this script
compared to the minecraft default, are listed in [Default Settings](#Default-Settings).
When you are happy with your configuration, continue to the [Usage](#Usage) section.

#### Seed

Before your server is started for the first time, you can can specify `level-seed=`
in `server.properties`. To find a good seed before generating your world, have a look
at [Cubiomes Viewer](https://github.com/Cubitect/cubiomes-viewer).

#### Whitelist

By default there is no whitelist, but vane makes your server behave like it has a "graylist".
This means anyone can connect to your server but in a *no touch, only look!* kind of way.
To change the world, a player must either be opped (`op player_name` in the console),
or you must be assigned to the user group (`perm add player_name user`) or a higher group.

If you assign a player to the verified group (`perm add player_name verified`), they may
vouch for other users by using `/vouch other_player` to lift them into the `users` group.
Useful to give your friends the permission to invite other people they know. It will
be stored who vouched for whom.

Of course you can also just enable a classic whitelist.

### Default Settings

This project comes with a reasonable default configuration for paper (main server)
and waterfall (proxy server). This ensures that autostarting and account multiplexing
work out of the box. Some of these configs depend on your choices in the bootstrap script,
denoted below by the *(asks)* prefix. These are the configuration defaults that differ
by default from a freshly generated configuration:

#### proxy

- Configure the proxy server (online mode, autostart, ...)
- Enable one account multiplexer (second player character for each account)

#### spigot.yml

- Remove unnecessary aliases from `commands.yml`
- Tell PaperMC that a proxy is used.
- Don't have PaperMC restart the server on crash. The system service takes care of that.
- Prevent annoying infinite sound broadcasts (dragon death, end portal, wither).
- Change the *moved-too-quickly* threshold to be less aggressive (ensures smoother elytra flight).
- Allow players to see entities up to 512 blocks away.
- Lower xp and item merge radius for a more vanilla experience while still reducing lag.

#### config/paper-*.yml

- (asks) Allow TNT duping and bedrock removal.
- (asks) Enable Anti-XRAY.
- (asks) Replenish loot chests after 1-2 realtime days.
- (asks) Disable hopper item move event.

#### server.properties

- Set difficulty to HARD
- Increase slots to 6666
- (asks) Increase view distance to 15 chunks
- Increase entity broadcast range (allow players to see entities far away)
- Disable spawn protection (use better setting from vane-admin if you want this)
- Set online mode to false (this is checked by the proxy)
- Listen on port 25501 so proxy can connect (**do not** forward this port!)

### Server list

## Installing new plugins

By default, this uses vane-permssions as the permission plugin.
If you want to use a different permission plugin, be sure remove `vane-permissions` from the
plugins to install and follow [this guide](https://github.com/oddlama/vane/wiki/Installation-Guide#3-give-permissions-to-players)
in order not to break vane with your new plugin.

## Updating the server

## Updating the deploy

## Tracking config with git

## Usage

You can stop the server or proxy completely by temporarily stopping the service.
This is useful if you want to do maintenance (updates) while nobody should be
able to connect to the server or proxy. There also is a maintenance command
in the proxy if you do maintenance on the actual server

    systemctl stop <minecraft-proxy|minecraft-server>
    systemctl start <minecraft-proxy|minecraft-server> # Start again afterwards


#### Viewing the console

minec

## Committing your yaml files

## Useful tools

- [Cubiomes Viewer](https://github.com/Cubitect/cubiomes-viewer) - To find a good world seed
- [MCASelector](https://github.com/Querz/mcaselector) - To trim e.g. unpopulated chunks

## Contributing

If you'd like to create and maintain a package for your favourite distribution,
or add a new feature to this deploy,
Please feel free to create an issue or pull-request on github.
