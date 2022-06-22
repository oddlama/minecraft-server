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

#### Server List Text & Icon

The text and icon in your server list now controlled by the proxy instead of your `server.properties`.
Edit `proxy/plugins/vane-waterfall/config.yml` to change the text to your liking. You can also
set different texts based on whether the server is currently started or not.

To set a server icon, simply drop a file name `server-icon.png` in your `server/` directory,
next to where the `paper.jar` is.

## Default Settings

This project comes with a reasonable default configuration for paper (main server)
and waterfall (proxy server). This ensures that autostarting and account multiplexing
work out of the box. Some of these configs depend on your choices in the bootstrap script,
denoted below by the *(asks)* prefix. These are the configuration defaults that differ
by default from a freshly generated configuration:

#### Proxy Settings

- Configure the proxy server (online mode, autostart, ...)
- Enable one account multiplexer (second player character for each account)

#### Spigot Settings

- Remove unnecessary aliases from `commands.yml`
- Tell PaperMC that a proxy is used.
- Don't have PaperMC restart the server on crash. The system service takes care of that.
- Prevent annoying infinite sound broadcasts (dragon death, end portal, wither).
- Change the *moved-too-quickly* threshold to be less aggressive (ensures smoother elytra flight).
- Allow players to see entities up to 512 blocks away.
- Lower xp and item merge radius for a more vanilla experience while still reducing lag.

#### PaperMC Settings

- (asks) Allow TNT duping and bedrock removal.
- (asks) Enable Anti-XRAY.
- (asks) Replenish loot chests after 1-2 realtime days.
- (asks) Disable hopper item move event.

#### Vanilla settings

- Set difficulty to HARD
- Increase slots to 6666
- (asks) Increase view distance to 15 chunks
- Increase entity broadcast range (allow players to see entities far away)
- Disable spawn protection (use better setting from vane-admin if you want this)
- Set online mode to false (this is checked by the proxy)
- Listen on port 25501 so proxy can connect (**do not** forward this port!)

## Usage

In the following you will learn how to use the features of this deploy
to access the console, update your server among other things.

#### Accessing the server/proxy console

Access to your server console is crucial. The services keep both the proxy and server
console in the background at all times, so you can access them from any
terminal on your server (also remotely via ssh!).

```bash
minecraft-attach server # Open the server console
minecraft-attach proxy  # Open the proxy console
```

Once you execute one of the commands above, you will be presented
with the respective console. If that command fails, make sure the
system services are running! Press <kbd>Ctrl</kbd> + <kbd>b</kbd> followed by <kbd>d</kbd>
to leave the console. This will put it in the background again.

#### Updating the server

To update the server jars and all plugins, we first stop all services,
run the updater and then start them again. To do this, execute the
following commands as root:

```bash
systemctl stop minecraft-proxy minecraft-server    # Stop services
cd /var/lib/minecraft/deploy                       # Change into deploy directory
./update.sh                                        # Run update script
systemctl start minecraft-proxy minecraft-server   # Start services again
```

#### Installing/Removing plugins

Plugins are installed and updated by the `update.sh` scripts.
To add a new plugin, find a download link that always points to the latest version
and add an entry at the end of the respective script, similar to those that are already present.

For example to add worldguard, you add the following at the end of `server/update.sh`:
```bash
download_file "https://dev.bukkit.org/projects/worldguard/files/latest" plugins/worldguard.jar
```

To remove plugins, simply delete the jar file and remove the corresponding line in the
script. To remove a vane module, remove it from the list in the for loop.

#### Changing permissions plugin

By default, this setup uses a very lightweight permission plugin called `vane-permissions`.
If you want to use a different permission plugin, be sure remove `vane-permissions` from the
plugins as shown above and follow [this guide](https://github.com/oddlama/vane/wiki/Installation-Guide#3-give-permissions-to-players)
in order not to break vane with your new plugin.

#### Tracking configuration with git

This project include a utility script called `contrib/organize_configs.sh`. If you execute it,
it will sort the keys in all your configuration files alphabetically so they can be tracked by git properly.
This is necessary as the server will rewrite the configuration files each time the server is started,
causing the entries to shift around unpredictably.

The `.gitignore` files are already setup so you will not accidentally commit your whole world
or some cache files. Only configuration files are considered by default.
To actually commit your configs, you should fork this project and update your git remote:

```bash
# Fork on github first, then replace the remote url:
cd deploy
git remote set-url origin git@github.com:youruser/minecraft-server.git
git add .
git commit -m "Initial configuration commit"
git push
```

## Useful tools

- [Cubiomes Viewer](https://github.com/Cubitect/cubiomes-viewer) - To find a good world seed
- [MCASelector](https://github.com/Querz/mcaselector) - To trim e.g. unpopulated chunks

## Contributing

Do you want to suggest a feature or extend this deploy?
Please feel free to create an issue or pull-request on github.

If you want to create and maintain a package for your favourite distribution's package manager
(pacman, apt, ...), feel free to reach out on the [vane discord](https://discord.gg/RueJ6A59x2).
