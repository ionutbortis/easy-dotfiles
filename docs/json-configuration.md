<!-- start header -->

[<< Back to contents][contents doc url]

---

<!-- end header -->

<!-- start TOC -->

- [JSON configuration](#json-configuration)
  - [Applications](#applications)
    - [What if...](#what-if)
      - [An app comes preinstalled on some distros?](#an-app-comes-preinstalled-on-some-distros)
      - [My app is a flatpak and has the same install command?](#my-app-is-a-flatpak-and-has-the-same-install-command)
      - [I have an app that has a weird install command?](#i-have-an-app-that-has-a-weird-install-command)
      - [My app is not found in the default package repositories?](#my-app-is-not-found-in-the-default-package-repositories)
      - [I have config files and also `dconf` entries for an app?](#i-have-config-files-and-also-dconf-entries-for-an-app)
  - [Extensions](#extensions)
  - [Keybindings](#keybindings)
  - [Miscellaneous](#miscellaneous)
  - [Tweaks](#tweaks)
    - [How to filter for specific `dconf` keys or sub-path](#how-to-filter-for-specific-dconf-keys-or-sub-path)

<!-- end TOC -->

# JSON configuration

**`easy-dotfiles`** is configured via [JSON](https://www.w3schools.com/js/js_json_intro.asp) files :wink:

_Why JSON?_ Because is extremely popular and easy to understand. Many text editors offer json support by default or you can easily add a plugin for validating json files. Also, some newer linux distros come out of the box with the [`jq package`](https://stedolan.github.io/jq/) preinstalled.

In order to keep things nice and tidy, the configuration is split into multiple files. You can check the [config][sample config folder] folder where you can see separate folders for each main configuration section. The configuration json files are kept private, on your private git repository and they are specific to your installations. The [sample][sample folder] folder was created to help you bootstrap your initial configuration :hammer_and_wrench:

:exclamation:**NOTE:** The **`easy-dotfiles`** scripts are expecting [this configuration][sample config folder] of folders and files to exist. If you don't want to use a specific config section you must leave the corresponding JSON file **empty**. **No deletion** of config folders or config files is accepted, just leave the json files empty and everything should run without errors.

## Applications

All of the **`easy-dotfiles`** cofig JSON files are starting with an json array `[]`. This root array contains entries specific to each configuration section.

For [apps][apps config json] config we need the following information:

- `name` - Used by the install script to nicely print the list of apps configured for the selected distro and the app that is currently installing.

- `url` - It's not used in the scripts, you can skip adding this property if it's too much overhead. I added it to have a future reference of which app that config entry is actually referring to.

- `install` - This is a property object that will contain the app install command for each supported distro. The supported distros is configured in the [defaults script][defaults script] file. If you don't want an app to be installed on a specific distro, you can skip the entry for that distro.

- `files` - Property object that can have two child array properties:

  - `include` - Specifies the app specific dotfiles (configuration files) to be included by the import and export scripts. Supports `*` character for globbing but only for the last level in the supplied path. The path can be a file or a folder.

  - `exclude` - Helpful if you want to exclude some files from the configuration. Maybe some cache or other binaries that are too large and you don't want to be pushed to the private git repository. Supports `*` character for globbing but only for the last level in the supplied path. The path can be a file or a folder.

- `dconf` - Gnome uses the [dconf](https://wiki.gnome.org/Projects/dconf) database in order to configure it's settings. Gnome Extensions and some Gnome Applications are also using `dconf` to store their settings. `dconf` is a simple folder like structure that can contain child configuration properties or sub-paths. A `dconf` setting is a key-value pair. This config part is not mandatory, you can use it for Gnome apps that are storing their settings into the `dconf` database. The **`easy-dotfiles`** apps `dconf` property object can have two child properties:

  - `schema_path` - This specifies the `dconf` path from which all modified properties will be exported / imported. More on this later.

  - `file` - The file to which the `dconf` properties are exported / imported. The file name is chosen by you. I usually give them the `.conf` extension because `vscode` does some code highlighting for the .conf files. You can choose whatever name you like, just make sure there isn't any name clash with other `dconf` config parts from the same config section (apps, keybindings, tweaks, etc.). These files are also stored into your private git repository.

The provided sample [apps config][apps config json] JSON file tries to cover most of the configuration variation you might need.

Let's talk first about the `vscode` app config part as an example:

```json
{
  "name": "Visual Studio Code",
  "url": "https://code.visualstudio.com/",
  "install": {
    "fedora": "sudo dnf install code -y",
    "ubuntu": "sudo apt-get install code -y"
  },
  "files": {
    "include": ["~/.config/Code", "~/.config/Code/User"],
    "exclude": [
      "~/.config/Code/*Storage*",
      "~/.config/Code/*Cache*",
      "~/.config/Code/*Crash*",
      "~/.config/Code/*Service*",
      "~/.config/Code/logs"
    ]
  }
}
```

You can see here the `install` property which has two child properties expressing the install commands for each supported distros. The trick here is to make the install commands run unattended by using the `-y` flag. For flatpak installs use also the `--noninteractive` flag:

```sh
sudo flatpak install flathub com.mattjakeman.ExtensionManager -y --noninteractive
```

This way you'll only enter your sudo password at the beginning of the install script and you won't be bothered with confirmation prompts afterwards. You can go out for a coffee break until the install script finishes it's run :coffee:

The `files` property describes here what to `include` and what to `exclude` from the `vscode` dotfiles (config files). You can see that the `*` character is used only for the last level of the path.

If you want to `include` or `exclude` files like this, it won't work:

```json
"files": {
  "include": ["~/.config/Code/Ca*/extra/wanted"],
  "exclude": ["~/.config/Code/*rage*/extra/unwanted"]
}
```

:exclamation:**NOTE:** You can **use globbing only** for the **last level** of the path:

```json
"files": {
  "include": ["~/.config/Code/extra/want*"],
  "exclude": ["~/.config/Code/extra/unw*"]
}
```

**P.S:** For `Visual Studio Code` I recommend that you use their builtin feature for [syncing settings](https://code.visualstudio.com/docs/editor/settings-sync) and plugins. The above and sample config for `vscode` in only as a showcase, I'm not using that config for my private repo. I use something similar for `Kodi` (not included in the sample config), which can help transferring nicely your library and you app settings to another system or VM:

```json
{
  "name": "Kodi",
  "url": "https://kodi.tv/",
  "install": {
    "fedora": "sudo dnf install kodi -y",
    "ubuntu": "sudo apt-get install kodi -y"
  },
  "files": {
    "include": ["~/.kodi"],
    "exclude": ["~/.kodi/temp", "~/.kodi/userdata/Thumbnails", "~/.kodi/addons/packages"]
  }
}
```

`Kodi` has a lot of binaries in it's config folders so you might want to be careful when including large files or folders because they will be pushed to your private git repository. Usually, git providers set some limits on how much data you can store there.

Another interesting thing here is the use of the tilde `~` character at the beginning of the path. **`easy-dotfiles`** scripts are smart enough to handle this automatically for you. This way you can keep your apps config file rather generic and not tied to a specific user path on the system, `/home/ionut` for example.

Of course you can specify the absolute path if you desire, but you'll use the ability of using the same apps config file on another system with a different user name. **NOTE:** Even if you use tilde `~`, your apps might save absolute paths in their dotfiles, so this solution is not bulletproof but it might help for some apps.

:exclamation:**NOTE:** `include` and `exclude` config properties must express **absolute paths**, the only exception is when using tilde `~` for the the files inside the `home` folder.

Also, you're not limited only to your `home` files. There might be some apps that have config files outside your `home` folder. Let's have `timeshift` as an example:

```json
{
  "name": "Timeshift",
  "url": "https://github.com/teejee2008/timeshift",
  "install": {
    "fedora": "sudo dnf install timeshift -y",
    "ubuntu": "sudo apt-get install timeshift -y"
  },
  "files": {
    "include": ["/etc/timeshift/timeshift.json"]
  }
}
```

You can see that for `timeshift` we include a file that is outside our home folder, a file which we don't own: `/etc/timeshift/timeshift.json`

**`easy-dotfiles`** handles _outside home_ files by creating a `.permissions` file which holds all the original owner and file permissions. When exporting the _outside home_ files we make a copy of the file inside the private local repo, which is owned by the current user. When we import the config files to a new system, the original permissions of the _outside home_ files are restored.

You can configure any _outside home_ file or folders, even if your user doesn't have read permissions. The script will prompt you for the sudo password and the transfer operation will be performed.

### What if...

#### An app comes preinstalled on some distros?

Just skip the `install` part all together or only for a specific distro that comes with that particular app preinstalled. `Gnome Weather` comes preinstalled on `Fedora` but not on `Ubuntu`:

```json
{
  "name": "Gnome Weather",
  "url": "https://wiki.gnome.org/Apps/Weather",
  "install": {
    "ubuntu": "sudo apt-get install gnome-weather -y"
  },
  "dconf": {
    "schema_path": "/org/gnome/Weather/",
    "file": "gnome-weather.conf"
  }
}
```

By using the `install` part you can tell **`easy-dotfiles`** to install apps only for a specific distro, for example a visual UI app for the package manager:

```json
{
  "name": "dnfdragora",
  "url": "https://github.com/manatools/dnfdragora",
  "install": {
    "fedora": "sudo dnf install dnfdragora -y"
  }
},
{
  "name": "Synaptic Package Manager",
  "url": "https://www.nongnu.org/synaptic/",
  "install": {
    "ubuntu": "sudo apt-get install synaptic -y"
  }
}
```

#### My app is a flatpak and has the same install command?

If you have the same install command for different distros (flatpaks or custom install scripts) you can use only one line for the install command config. Just put the corresponding distro names in the same field, separated by spaces:

```json
{
  "name": "Extension Manager",
  "url": "https://flathub.org/apps/details/com.mattjakeman.ExtensionManager",
  "install": {
    "fedora ubuntu": "sudo flatpak install flathub com.mattjakeman.ExtensionManager -y --noninteractive"
  }
},
{
  "name": "IntelliJ IDEA Ultimate",
  "url": "https://www.jetbrains.com/idea/",
  "install": {
    "fedora ubuntu": "../private/scripts/apps/jidea-install.sh"
  },
  "files": {
    "include": ["~/.config/JetBrains"]
  }
}
```

#### I have an app that has a weird install command?

You can use custom scripts or commands for installing apps. For example, let's look at the `IntelliJ IDEA`'s app config:

```json
{
  "name": "IntelliJ IDEA Ultimate",
  "url": "https://www.jetbrains.com/idea/",
  "install": {
    "fedora ubuntu": "../private/scripts/apps/jidea-install.sh"
  },
  "files": {
    "include": ["~/.config/JetBrains"]
  }
}
```

The **`easy-dotfiles`** install script is changing the current working directory to a pre-configured work dir (`~/easy-dotfiles/tmp`) so each downloaded package or intermediary files can be cleaned up automatically. Because of this, if you want a custom app install script to be run by the main install script, you need to provide here a relative path:

```json
"install": {
  "fedora ubuntu": "../private/scripts/apps/your_custom_app_install.sh"
}
```

I recommend you put your custom app install scripts into the private repository (`~/easy-dotfiles/private`). I chose to put them inside the `~/easy-dotfiles/private/scripts/apps/` folder just to keep things more organized.

You can check out my custom [jidea install script][jidea install script] which installs a custom version at a specific location with a custom `.desktop` file.

If you don't need such elaborate custom app install scripts, but maybe just a quickly download of an `.rpm` or `.deb` file you can configure something similar to this:

```json
{
  "name": "TeamViewer",
  "url": "https://www.teamviewer.com/",
  "install": {
    "fedora": "wget -q https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm && sudo dnf install teamviewer.x86_64.rpm -y",
    "ubuntu": "sudo apt-get install teamviewer -y"
  },
  "files": {
    "include": ["~/.config/teamviewer/client.conf"]
  }
},

```

You can see in the above example that for `fedora` we download the `.rpm` file and install it with the `dnf` command. Just make sure you keep the `install` command unattended so it won't ask for confirmations of passwords. No need to clean up the files afterwards, the install script will take care of that for you. Also, you can put whatever command you see fit there, as long as the config file remains a valid JSON file.

:exclamation:**NOTE:** When doing custom install scripts or commands, please make sure that you don't have a command that's outputting some kind of download progress. For example, **always use** `wget -q` otherwise you'll pollute the **`easy-dotfiles`** logs with lots of unnecessary data.

#### My app is not found in the default package repositories?

Before running the individual app install commands, **`easy-dotfiles`** runs a specific distro setup script, depending on what distro you selected when prompted by the install script.

The distro setup scripts are also kept on your private repository and you can find them here: `~/easy-dotfiles/scripts/[DISTRO]/setup.sh`. The sample configuration comes with two distro specific setup [scripts][sample scripts folder], one for [fedora][fedora setup script] and one for [ubuntu][ubuntu setup script].

These scripts are very useful when you need to tinker your distro a little bit, maybe improve the package manager's speed (see fedora [setup.sh][fedora setup script]: `update_dnf_config`) or replace the Firefox snap with a deb version (see ubuntu [setup.sh][ubuntu setup script]: `replace_snap_firefox`).

The distro setup scripts are also a very good place to add the software repos that are missing for some of your favorite apps. For more info on them you can check out this [section][distro setup scripts doc url].

So, long story short :sweat_smile:, you need to go to the specific app official website and check if they provide a way to add their software repo to your distro. Get those commands, test them first and make them unattended, then just add the code to the specific distro setup script.

Done! Now you can properly run `sudo dnf install code -y` for `fedora` or `sudo apt-get install code -y` for `ubuntu` :tada:

#### I have config files and also `dconf` entries for an app?

Use both `files` and `dconf` parts (we use here `Meld` as an example even if I didn't configured files for it in the sample [config][apps config json]):

```json
{
  "name": "Meld Merge",
  "url": "https://meldmerge.org/",
  "install": {
    "fedora": "sudo dnf install meld -y",
    "ubuntu": "sudo apt-get install meld -y"
  },
  "files": {
    "include": ["~/.config/something"]
  },
  "dconf": {
    "schema_path": "/org/gnome/meld/",
    "file": "meld.conf"
  }
}
```

:exclamation:**NOTE:** For `dconf` `file` property we need to use **only** the **file name** with **no path**. Why? Because this file is auto generated by **`easy-dotfiles`** and it's used only as a vessel for exporting and importing dconf settings.

Go to [this folder][apps data folder] and check the contents of the `meld.conf` file. Also, you can see how the apps data is stored inside **`easy-dotfiles`**.

There is a tilde `~` folder that contains all the home config files for the configured apps. If you would configure app dotfiles by your full home path `/home/ionut/some_config/...` the apps data folder would have a `home/ionut` folder inside it. `Timeshift` config file is inside the `etc` folder. There you can also see the `.permissions` file.

The `.conf` files are located at the top level because we didn't specify a path for them. They are easily located by configuring them like this. You don't have to care much about `.conf` files, just make sure their names are **unique** inside the **same config section**, like inside [apps][apps config json] config or [extensions][extensions config json] config. Otherwise, they'll override themselves.

## Extensions

Hopefully you got so far and you're not utterly confused :sweat_smile:

[Extensions][extensions config json] config JSON is more simple than the apps config. You can see it as a subset, because Gnome Extensions only use the `dconf` database for their settings. The only extra addition is the extension name and URL that needs to be taken from the official [Gnome Extensions](https://extensions.gnome.org/) website.

Let me make a [shameless plug](https://github.com/ionutbortis/gnome-bedtime-mode) and have a look at the config for my awesome [Bedtime Mode](https://extensions.gnome.org/extension/4012/gnome-bedtime/) Gnome extension:

```json
{
  "name": "Bedtime Mode",
  "url": "https://extensions.gnome.org/extension/4012/gnome-bedtime/",
  "dconf": {
    "schema_path": "/org/gnome/shell/extensions/bedtime-mode/",
    "file": "bedtime-mode.conf"
  }
}
```

- `name` - Is not mandatory, but nice to have. The install script will nicely print the extension that's currently processing.

- `url` - Vital for a proper automatic installation of extensions. The install script will use this URL for getting the extension ID and compute the proper extension download URL.

- `dconf` - This config part behaves exactly as the one for apps. You only need to specify the extension's `schema_path` and the `file` to which it's settings will be saved. The proper `schema_path` for an extension can be easily obtained by using the nice [dconf editor](https://apps.gnome.org/app/ca.desrt.dconf-editor/) app. You need to go to the `/org/gnome/shell/extensions/` path and copy the path to the corresponding extension.

:exclamation:**NOTE:** Please make sure the `dconf` `file` names are unique inside this config section. Also, if an extension doesn't store any settings, you can just skip the `dconf` part:

```json
{
  "name": "Auto select headset",
  "url": "https://extensions.gnome.org/extension/3928/auto-select-headset/"
}
```

## Keybindings

After finishing this guide one might argue that there's no need for a separate `keybindings` config section. Well, I also agree on that but I'll just leave this as a separate section in order not to clutter too much the [Tweaks](#tweaks) section :sunglasses:

For [keybindings][keybindings config json] config JSON you can leave it as it is provided in the sample folder. It should cover all the places where user defined keybindings might occur in the Gnome Shell.

You can observe that the json structure is very similar to previous mentioned `dconf` parts. We just skipped the redundant `dconf` parent property and used only `schema_path` and `file`.

On my setup, only two of those `schema_path` paths have settings, so not all the sample keybindings [data files][keybindings data folder] have content. By looking into the `.conf` files you can see my interesting collection of shortcuts that I configured for the sample data.

## Miscellaneous

You might have some files, that are not tied to a specific app or extension, and you want to manage also those by using **`easy-dotfiles`**.

The [miscellaneous][misc config json] config section does exactly that. Here you can configure other needed files or folders that didn't fit into the apps config section.

You might have some backgrounds that you use as wallpapers and want to transfer also those to another setup. Maybe you want to preserve the configured auto start applications, your bash aliases or some other custom scripts or files. This is the place for those outcasts :sweat_smile:

The JSON structure is a subset of the apps config, for example:

```json
{
  "name": "Startup Apps",
  "files": {
    "include": ["~/.config/autostart"]
  }
}
```

- `name` - Just a nice way to name a group of similar files.

- `files` - Behaves exactly as the [apps config](#applications) part. You specify the `include` property child for files or folders and `exclude` if you want to filter out some stuff. Supports `*` character for globbing but only for the last level in the supplied path. The path can be a user home file or an outside home file. For the _outside home_ files their permissions are stored in a `.permissions` file and restored when importing.

:exclamation:**NOTE:** Be careful when configuring **outside home** files that are **system** files.

For example the `/var/lib/AccountsService/users/ionut` file which is not readable by my user has some info related to my login icon and some other stuff. I can configure this file to be managed by **`easy-dotfiles`** but when I restore it on another system, the terminal won't open anymore. So you might get **unexpected results** if you tinker with **system files**. App config files or other personal files should be usually safe to configure.

## Tweaks

The [tweaks][tweaks config json] configuration section can be used to manage your tinkering with the Gnome Shell configuration. This json contains only `dconf` specific config and can look like this:

```json
{
  "schema_path": "/org/gnome/GWeather4/",
  "keys": ["temperature-unit"],
  "file": "g-weather.conf"
},
{
  "schema_path": "/org/gtk/",
  "keys": ["/settings/file-chooser/", "/gtk4/settings/file-chooser/"],
  "file": "file-chooser.conf"
},
{
  "schema_path": "/org/gnome/settings-daemon/plugins/power/",
  "file": "power.conf"
}
```

The above is just a snippet from the included sample [tweaks][tweaks config json] config. The structure is the same as for [Keybindings](#keybindings) and the `dconf` part of the [Applications](#applications) config:

- `schema_path` - The `dconf` schema path of the settings you want to be managed by **`easy-dotfiles`**. All the settings that are stored under this path, direct children or sub-paths containing other child settings or paths are exported to the `.conf` file if you don't specify the next `keys` field.

- `keys` - If you want to filter for specific keys or sub-paths. Usually, you don't need to use this field, especially for `dconf` parts of [apps](#applications) or [extensions](#extensions) config. It comes handy when you want manage only specific settings or a more complex scenario that involves different `schema_path` folders. More on this later on, inside the dedicated [section](#how-to-filter-for-specific-dconf-keys-or-sub-path).

- `file` - The name of the file to which the `dconf` settings specified by `schema_path` are saved. Only file names with no path, they will be saved on the section's top level folder, see the [tweaks data][tweaks data folder] folder contents. Please make sure that the [tweaks config][tweaks config json] file has unique `file` names configured.

By using the tweaks configuration you can export / import all your tweaks to the Gnome Shell and Gnome Applications. Wait, what? Didn't we cover [apps](#applications) already? :confused:

Yes, we already covered apps, but this configuration section is mainly for [core Gnome apps](https://apps.gnome.org/) that are usually bundled with the Gnome shell. Most of them will be already preinstalled and are using `dconf` for storing their settings.

Apps like [Text Editor](https://apps.gnome.org/app/org.gnome.TextEditor/), [Files (Nautilus)](https://apps.gnome.org/app/org.gnome.Nautilus/), [System Monitor](https://apps.gnome.org/app/gnome-system-monitor/) or [Calendar](https://apps.gnome.org/app/org.gnome.Calendar/) are storing their settings into the `dconf` database and the [tweaks][tweaks config json] section is a very good place to let **`easy-dotfiles`** know of them.

Beside core apps settings, Gnome stores some of its internal settings also into the `dconf` database. Things like favorite apps for the dash, light / dark theme wallpapers, power configuration, etc. The [tweaks][tweaks config json] section is also the place for all of these settings. You can check the `.conf` files from the sample [tweaks data][tweaks data folder] folder where you can see what settings were exported by using the [tweaks config][tweaks config json] file.

### How to filter for specific `dconf` keys or sub-path

There might be some cases when you don't want to export all the settings from a specific `schema_path`. Maybe a distro will configure Gnome Shell its own way and you don't want to really import those settings on another distro that might configured it slightly different. Here comes the `keys` property to the rescue :smiley:

Let's have a look at this snippet from the [tweaks][tweaks config json] config file:

```json
{
  "schema_path": "/org/gnome/shell/",
  "keys": ["favorite-apps", "/weather/"],
  "file": "gnome.shell.conf"
}
```

The `keys` property is an array that can specify which keys should be included from the corresponding `schema_path`.

Launch the [dconf editor](https://apps.gnome.org/app/ca.desrt.dconf-editor/) app and go to the `/org/gnome/shell/` path. You can see that there are some sub-paths (sub-folders) and some direct properties as children. The direct properties are `key` - `value` pairs and they can be explicitly filtered by using the `keys` config json property.

You have `/org/gnome/shell/` as `schema_path` but you only want to manage the value for the `favorite-apps` setting. Then you would add a json config like this:

```json
{
  "schema_path": "/org/gnome/shell/",
  "keys": ["favorite-apps"],
  "file": "gnome.shell.conf"
}
```

If you want to filter by multiple keys you would do something like this:

```json
{
  "schema_path": "/org/gnome/shell/",
  "keys": ["favorite-apps", "command-history"],
  "file": "gnome.shell.conf"
}
```

But what if you want to **filter the keys** for the current `shema_path` but want to include also the direct child settings of a **specific sub-path**? :thinking:

Then you can do this:

```json
{
  "schema_path": "/org/gnome/shell/",
  "keys": ["favorite-apps", "/weather/"],
  "file": "gnome.shell.conf"
}
```

The above will include the `favorite-apps` setting from `/org/gnome/shell/` path and all the direct child settings of the `/org/gnome/shell/weather/` sub-path. What? :exploding_head:

Go to the `dconf editor` app and check the `/org/gnome/shell/` path. Now go into the `weather` sub-path and check it's child settings. There are two of them: `automatic-location` and `locations`. By using the `"keys": ["favorite-apps", "/weather/"]` config you will manage the `favorite-apps` setting and all the child settings (`automatic-location` and `locations`) of the `/weather/` sub-path.

A **sub-path** is defined as a string surrounded by slashes `/`: `/weather/`, `/calendar/`, `/peripherals/keyboard/`, `/peripherals/mouse/`.

So a `keys` json config property can contain **actual keys** and (or) **sub-paths** and **keys**, separated by space :sweat_smile:

Let's say that for the above example you only want to manage the `favorite-apps` and `automatic-location` setting from the `/weather/` sub-path. You have two options:

1. Basic `schema_path` config:

```json
{
  "schema_path": "/org/gnome/shell/",
  "keys": ["favorite-apps"],
  "file": "gnome.shell.fav-apps.conf"
},
{
  "schema_path": "/org/gnome/shell/weather/",
  "keys": ["automatic-location"],
  "file": "gnome.shell.auto-location.conf"
}
```

2. Advanced `schema_path` config:

```json
{
  "schema_path": "/org/gnome/shell/",
  "keys": ["favorite-apps", "/weather/ automatic-location"],
  "file": "gnome.shell.conf"
}
```

By using the "advanced config" approach you're not forced to create two separate `.conf` files in order to manage those settings. You can use a single `.conf` file and by incorporating the `/weather/` sub-path in the `keys` property you can filter out for the `automatic-location` setting.

:exclamation:**NOTE:** Sub-paths must be enclosed by the forward slash `/` character and the child keys should follow delimited by space:

```json
{
  "schema_path": "/org/gnome/desktop/",
  "keys": ["/sound/ allow-volume-above-100-percent event-sounds"],
  "file": "gnome.desktop.sound.conf"
}
```

The above will tell **`easy-dotfiles`** that starting from the `/org/gnome/desktop/` `schema_path` it should manage only the `allow-volume-above-100-percent` and `event-sounds` settings of the `/sound/` sub-path.

:exclamation:**NOTE:** Sub-path filtering will include **only** the **direct child settings** of that path. Let's say you want to do an advanced `schema_path` config for the gnome desktop accessibility and peripherals settings:

```json
{
  "schema_path": "/org/gnome/desktop/",
  "keys": ["/a11y/", "/peripherals/"],
  "file": "gnome.desktop.conf"
}
```

The above configuration **won't match all the settings** in `/a11y/` and `/peripherals/` because if you go to the `dconf editor` app and check the `/org/gnome/desktop/peripherals/` path, there aren't any direct child settings, only other sub-paths.

If you check the `/org/gnome/desktop/a11y/` path in the `dconf editor` app, there are only two direct child settings of this path, but also another sub-paths, `applications`, `keyboard`, `magnifier` and `mouse`. Only the direct child settings will be managed if you use the above config json.

If you want to manage all the subsequent child settings, you need to use asterisk `*` in the sub-path name: `/a11y*/`, `/peripherals*/`, `/other/sub/path*/`.

:exclamation:**NOTE:** Only one sub-path permitted per `keys` array entry and asterisk `*` works only on the last part of the sub-path:

```json
{
  "schema_path": "/org/gnome/desktop/",
  "keys": ["/a11y*/", "/peripherals*/"],
  "file": "gnome.desktop.conf"
}
```

The above will include all the child settings from all the sub-paths starting from `a11y` and `peripherals`. Even if you use the asterisk `*` character you can filter for child settings by doing this:

```json
{
  "schema_path": "/org/gnome/desktop/",
  "keys": ["/a11y*/", "/peripherals*/ natural-scroll"],
  "file": "gnome.desktop.conf"
}
```

The above will include all the child settings from the `a11y` sub-paths and only `natural-scroll` settings from the `peripherals` sub-paths.

If you don't mind having multiple `.conf` files, you can always create two separate entries for the above config and don't use the `keys` property:

```json
{
  "schema_path": "/org/gnome/desktop/a11y/",
  "file": "gnome.desktop.a11y.conf"
},
{
  "schema_path": "/org/gnome/desktop/peripherals/",
  "file": "gnome.desktop.peripherals.conf"
}
```

So you have multiple options on how to manage your `dconf` settings.

Advanced `schema_path` config can look a tad complicated but it's an interesting way of reducing the number of needed `.conf` files :sunglasses:

```json
{
  "schema_path": "/org/gnome/desktop/",
  "keys": [
    "/interface/ text-scaling-factor clock-show-weekday",
    "/calendar/",
    "/datetime/",
    "/input-sources/",
    "/background/",
    "/wm/preferences/",
    "/a11y*/",
    "/peripherals*/",
    "/sound/ allow-volume-above-100-percent event-sounds"
  ],
  "file": "gnome.desktop.conf"
}
```

If you reached so far, I think some congratulations are in order :tada: :sweat_smile:

I hope you got familiar on how to configure the different JSON sections. You always have the [sample config][sample config folder] to bootstrap your **`easy-dotfiles`** configuration or to use it as a reference. I should be _set it once and forget it_ kind of thing.

There are some other small configuration parts that you might want to have a look at by reading this [section][shell scripts doc url].

<!-- start footer -->

---

[<< Back to contents][contents doc url]

<!-- end footer -->

<!-- start links -->

[sample folder]: ../sample
[sample config folder]: ../sample/config
[sample data folder]: ../sample/data
[sample scripts folder]: ../sample/scripts
[sample common setup script]: ../sample/scripts/common/setup.sh
[apps config json]: ../sample/config/apps/config.json
[apps data folder]: ../sample/data/apps
[extensions config json]: ../sample/config/extensions/config.json
[extensions data folder]: ../sample/data/extensions
[keybindings config json]: ../sample/config/keybindings/config.json
[keybindings data folder]: ../sample/data/keybindings
[misc config json]: ../sample/config/misc/config.json
[misc data folder]: ../sample/data/misc
[tweaks config json]: ../sample/config/tweaks/config.json
[tweaks data folder]: ../sample/data/tweaks

<!-- -->

[main scripts]: ../scripts
[install script]: ../scripts/install.sh
[export script]: ../scripts/export.sh
[import script]: ../scripts/import.sh
[remove script]: ../scripts/remove.sh
[git setup script]: ../scripts/git/setup.sh
[git push script]: ../scripts/git/push.sh
[git pull script]: ../scripts/git/pull.sh
[git reset script]: ../scripts/git/reset.sh
[anacron setup script]: ../scripts/anacron/setup.sh
[common setup script]: ../scripts/common/setup.sh
[defaults script]: ../sample/scripts/defaults.sh
[jidea install script]: ../sample/scripts/apps/jidea-install.sh
[fedora setup script]: ../sample/scripts/fedora/setup.sh
[ubuntu setup script]: ../sample/scripts/ubuntu/setup.sh

<!-- -->

[contents doc url]: ./README.md
[disclaimer doc url]: ./disclaimer.md#disclaimer
[quick demo doc url]: ./quick-demo.md#quick-demo
[main desktop setup doc url]: ./main-desktop-setup.md#main-desktop-setup
[json configuration doc url]: ./json-configuration.md#json-configuration
[shell scripts doc url]: ./shell-scripts.md#shell-scripts
[common setup script doc url]: ./shell-scripts.md#public-commonsetupsh-script
[private common setup script doc url]: ./shell-scripts.md#private-commonsetupsh-script
[distro specific setup script doc url]: ./shell-scripts.md#private-distro-specific-setupsh-script
[export script doc url]: ./shell-scripts.md#exportsh
[import script doc url]: ./shell-scripts.md#importsh
[install script doc url]: ./shell-scripts.md#installsh
[git scripts doc url]: ./shell-scripts.md#git-scripts
[distro setup scripts doc url]: ./shell-scripts.md#private-distro-specific-setupsh-script
[anacron setup script doc url]: ./shell-scripts.md#anacron-setup
[automatic actions doc url]: ./automatic-actions.md#scheduling-automatic-actions
[tips and tricks doc url]: ./tips-and-tricks.md#tips--tricks

<!-- end links -->
