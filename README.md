[![MIT License](https://img.shields.io/badge/license-MIT-informational.svg)](./LICENSE)
[![Join us on Discord](https://img.shields.io/discord/907277628816388106.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.gg/RueJ6A59x2)

# Minecraft Server Deploy

This is a simple but fully-featured minecraft server installer for linux.
It should server as an example of how to properly(TM) deploy a personal minecraft server with the following features:

- 🚀 Server starts automatically when players connect and shuts down when idle
- ⏱️ Uses [PaperMC](https://papermc.io) and [Aikar's JVM flags](https://aikar.co/mcflags.html) for maximum performance
- 🔒 Sandboxed execution with systemd, no docker
- 💾 Creates incremental world backups after each server stop
- 🖥️ Background console access via tmux (also removetly via ssh)
- 🔢 Account multiplexing allows a single account to have two or more player characters
- 🗺️ Awesome 3D online map using [BlueMap](https://bluemap.bluecolored.de/)
- 🔋 Single-command scripts to update server and plugins
- 🐙 Ready for configuration file tracking via git
- <img width="auto" height="20px" src="https://github.com/oddlama/vane/blob/main/docs/vane.png"> Includes vanilla enhancements by [vane](https://github.com/oddlama/vane)

## 🛠 Installation

To begin the automatic installation, simply run the provided bootstrap script.
Afterwards you can continue [configuring your server](#Server-Configuration),
or jump straight to the [Usage](#Usage) section if you are happy with the defaults.

```bash
sudo curl -sL https://oddlama.github.io/minecraft-server/bootstrap | bash
# Connect to the console (Press Ctrl+b then d to detach again)
minecraft-attach server
# Don't forget to foward or expose TCP ports 25565 (server), 25566 (multiplexer 1)
# and 8100 (online map). The map will be available under http://<your-ip>:8100
```

You may want to [review](https://github.com/oddlama/minecraft-server/blob/pages/bootstrap) the script before executing it.
In summary, the script will perform the following steps:

- Check whether all required tools are installed
- Create a new `minecraft` user for the server (if not existing)
- Update the server jars and download all plugins
- Install, enable and start the systemd services

## ⚙️ Server configuration

At this point, your proxy server is already running and the actual
server will be started once you connect to it. Now is the time to
review or change the server configuration. Here is a list of things you
might want to configure now. All settings that were changed by this script
compared to the minecraft default, are listed in [Default Settings](#Default-Settings).
When you are happy with your configuration, continue to the [Usage](#Usage) section.

### 🌱 Seed

Before your server is started for the first time, you can can specify `level-seed=`
in `server.properties`. To find a good seed before generating your world, have a look
at [Cubiomes Viewer](https://github.com/Cubitect/cubiomes-viewer).

### 📜 Whitelist / Graylist

By default there is no protection enabled, everyone can join and play.
You can enable a classic whitelist with `whitelist on`.

Another option that vane provides is a feature similar to a graylist.
This allows anyone to connect to your server but in a *no touch, only look!* kind of way.
To modify anything about the world, a player must either be opped,
or be assigned to the user group with `perm add player_name user`, or any higher group.
To enable the graylist, set the following option in `server/plugins/vane-admin/config.yml`.

```yaml
world_protection:
  enabled: true
```

Additionally, if you assign a player to the verified group with `perm add player_name verified`,
they may vouch for other users by using `/vouch other_player`. This will lift the other user into the `users` group.
Useful to give your friends the permission to invite other people they know. It will
be stored who vouched for whom.

### 🗒️ Serverlist text & icon

The text and icon in your server list now controlled by the proxy instead of your `server.properties`.
Edit `proxy/plugins/vane-waterfall/config.yml` to change the text to your liking. You can also
set different texts based on whether the server is currently started or not.

To set a server icon, simply drop a file name `server-icon.png` in your `server/` directory,
next to where the `paper.jar` is.

## 🚀 Usage

In the following you will learn how to use the features of this deploy
to access the console, update your server among other things.

### 🔑 Accessing the server/proxy console

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

### 🗺️ 3D Online map (BlueMap)

The awesome 3D online map comes fully preconfigured. All you need to
do is open `http://<your-server-address>:8100` in your favourite browser,
when your server is online. Replace your-server-address with the IP or domain name
you use to connect in minecraft.

If you have an external webserver, BlueMap can be configured to be always available.

### 🔢 Account multiplexing

A multiplexer is an additional port for your server. When someone connects
via this port, they will be logged into a secondary player character. This also
works while being logged in on the main server. Very useful for account sharing or
to hand out spectator accounts. Just add a new serverlist entry for the multiplexer
and enjoy having multiple accounts!

Two accounts is not enough? Adding additional multiplexers is simple:

1. Forward or expose a new port. (e.g. 25567)
2. Copy and add an additional listener entry in `proxy/config.yml`. Copy one of the existing ones and just change the port to whatever you chose.
3. Finally add `- 25567: 2` to the multiplexer config in `proxy/plugins/vane-waterfall/config.yml`.
4. (Repeat for each additional multiplexer you want to add)

To disable this feature altogether, simply remove the second listener (with port 25566) from `proxy/config.yml`.

### 🔄 Updating the server

To update the server jars and all plugins, we first stop all services,
run the updater and then start them again. To do this, execute the
following commands as root:

```bash
systemctl stop minecraft-proxy minecraft-server    # Stop services
cd /var/lib/minecraft/deploy                       # Change into deploy directory
./update.sh                                        # Run update script
systemctl start minecraft-proxy minecraft-server   # Start services again
```

### 🔌 Installing and removing plugins

Plugins are installed and updated by the `update.sh` scripts.
To add a new plugin, find a download link that always points to the latest version
and add an entry at the end of the respective script, similar to those that are already present.

For example to add worldguard, you add the following at the end of `server/update.sh`:
```bash
download_file "https://dev.bukkit.org/projects/worldguard/files/latest" plugins/worldguard.jar
```

To remove plugins, simply delete the jar file and remove the corresponding line in the
script. To remove a vane module, remove it from the list in the for loop.

### 🔐 Changing permissions plugin

By default, this setup uses a very lightweight permission plugin called `vane-permissions`.
If you want to use a different permission plugin, be sure remove `vane-permissions` from the
plugins as shown above and follow [this guide](https://github.com/oddlama/vane/wiki/Installation-Guide#3-give-permissions-to-players)
in order not to break vane with your new plugin.

### 💾 Changing or disabling backups

The `server/backup.sh` file is called automatically each time the server stops.
Feel free to adjust this script to your liking. To completely disable backups,
replace the script's content with:

```bash
#!/bin/bash
exit 0
```

### 🐙 Tracking configuration with git

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

## 🔧 Default settings

This project comes with a reasonable default configuration for paper (main server)
and waterfall (proxy server). This ensures that autostarting and account multiplexing
work out of the box. Some of these configs depend on your choices in the bootstrap script,
denoted below by the *(asks)* prefix. These are the configuration defaults that differ
by default from a freshly generated configuration:

#### Proxy settings

- Configure the proxy server (online mode, autostart, ...)
- Enable one account multiplexer (second player character for each account)

#### Spigot settings

- Remove unnecessary aliases from `commands.yml`
- Tell PaperMC that a proxy is used.
- Don't have PaperMC restart the server on crash. The system service takes care of that.
- Prevent annoying infinite sound broadcasts (dragon death, end portal, wither).
- Change the *moved-too-quickly* threshold to be less aggressive (ensures smoother elytra flight).
- Allow players to see entities up to 512 blocks away.
- Lower xp and item merge radius for a more vanilla experience while still reducing lag.

#### PaperMC settings

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

## 🛠️ Useful tools

- [Cubiomes Viewer](https://github.com/Cubitect/cubiomes-viewer) - To find a good world seed
- [MCASelector](https://github.com/Querz/mcaselector) - To trim e.g. unpopulated chunks

## ❤️ Contributing

Do you want to suggest a feature or extend this deploy?
Please feel free to create an issue or pull-request on github!
Also if you want to create and maintain a packaged version of this deploy for your favourite distribution's package manager,
feel free to reach out on the [Vane Discord Server](https://discord.gg/RueJ6A59x2).
