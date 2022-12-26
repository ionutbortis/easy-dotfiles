<!-- start header -->

[<< Back to contents][contents doc url]

---

<!-- end header -->

<!-- start TOC -->

- [Tips \& Tricks](#tips--tricks)
  - [Unattended `install` run (mostly)](#unattended-install-run-mostly)
  - [Testing scheduled action](#testing-scheduled-action)
  - [Partial import](#partial-import)
  - [Passworldless SSH keys](#passworldless-ssh-keys)
  - [Hacking away](#hacking-away)

<!-- end TOC -->

# Tips & Tricks

This section will outline some neat **tips & tricks** that I found during the development of the **`easy-dotfiles`** tool. If you find something cool and you want to let other people know about it, submit an issue [here](https://github.com/ionutbortis/easy-dotfiles/issues) and I'll make sure to have a look over it.

## Unattended `install` run (mostly)

**`easy-dotfiles`**'s [`install`][install script doc url] script run is the most time consuming one because it will install all of your configured apps and gnome extensions. It will also run the `common/setup.sh` script and _distro specific_ `setup.sh` script. So, many things to configure, download and install.

The idea here is to **make the scripts ask** for all the `sudo` passwords (`sudo` prefixed commands) only **at the beginning** and leverage the `sudo` caching mechanism for the rest of the script run. If you're not using caching, then you'll need to be around in case you're prompted for entering your password.

The [`common setup`][common setup script doc url] script already does that for you by setting the computer name, which requires `sudo`. But during the [_distro specific_ `setup`][distro specific setup script doc url] script you might run `flatpak` (or other programs) that will prompt for the `sudo` password by using an UI **password confirmation dialog**. You need to **put also those commands** somewhere **at the beginning of the scripts** so you can enter the password once and go out for a `tea/coffee/beer` until the `install` script run has finished.

## Testing scheduled action

In the [automatic actions][automatic actions doc url] section I mentioned that you can force `anacron` to run immediately by invoking this command:

```sh
sudo anacron -f -n
```

That's good but you might want to know how to troubleshoot the scheduled action if it doesn't run and you cannot figure out the problem from the logs.

When you run the [anacron setup][anacron setup script doc url] script, **`easy-dotfiles`** creates a `root` owned script inside a specific `/etc` folder, depending on your selected schedule. You are informed of the created script and its path at the end of the setup phase, or you can obtain it from the corresponding anacron setup log file.

**You can simulate** what `anacron` is doing by **invoking directly that script** as `sudo`. This way you can check if there is some error during execution because that script run doesn't create a standard **`easy-dotfiles`** log file:

```sh
sudo /etc/cron.daily/ionut-easy-dotfiles-export
```

The above is the script created by **`easy-dotfiles`** for a scheduled `daily export`.

I's prefixed with your username, followed by the project name and the configured action. It's owned by `root`, it doesn't have an extension and it's not written in bash, but with the standard `/bin/sh` interpreter.

Running it directly with `sudo` or as `root` might help you in troubleshooting some issues, if they arise, hopefully not.

## Partial import

Because the **`easy-dotfiles`**'s automatic import action has some special requirements, the [`import`][import script doc url] script can be run just partially:

- Import **only files** - Will import only the configured apps dotfiles and misc files:

```sh
cd ~/easy-dotfiles/ && ./scripts/import.sh --only-files
```

- Import **only dconf settings** - Will import only the configured apps dconf settings, keybindings and tweaks:

```sh
cd ~/easy-dotfiles/ && ./scripts/import.sh --only-dconfs
```

I could see a scenario where you have your `HOME` folder on a separate partition (as you should have it ) and you freshly installed the OS.

You don't have your remote private repository up to date with all the dotfiles and settings. Maybe you forgot to do an export and in order to minimize the damage, you want to import only the outdated dconf settings, because you already have your latest dotfiles in your home folder.

## Passworldless SSH keys

I guess you could use SSH keys that don't have a passphrase associated, if you _really really_ hate entering passwords (login, keyring unlock, etc.).

You can make your `git` SSH key without a passphrase by using this:

```sh
 ssh-keygen -p
```

**NOTE:** I would **strongly advice against** passphrase-less
SSH keys because if an attacker gets hold of your private SSH key then it will have access to all of your github account associated repositories, not only the **`easy-dotfiles`** repos.

One way to mitigate this could be using dedicated SSH keys for the **`easy-dotfiles`** repos. Github offers the [deploy keys](https://docs.github.com/en/developers/overview/managing-deploy-keys#deploy-keys) feature which might be something to look into if you don't want passphrases.

## Hacking away

**_What if_ you really don't like JSON but you love shell scripts?**

I guess you could change **your private** [apps][apps config json] config JSON to have only one entry for all of your dotfiles and the `dconf` part could manage the whole database:

```json
[
  {
    "name": "Everything Everywhere All at Once", 
    "files": {
      "include": [
        "~/.config/app1_dotfiles", 
        "~/.config/app2_dotfiles", 
        "~/.app3_dotfiles", 
        "~/.app4_dotfiles", 
        "~/.local/share/gnome-shell/extensions", 
        "~/misc/files", 
        "/etc/some/file"
      ], 
      "exclude": [
        "~/.config/app1_dotfiles/exclude", 
        "~/.config/app2_dotfiles/exclude", 
        "~/.app3_dotfiles/exclude", 
        "~/.app4_dotfiles/exclude"
      ]
    }, 
    "dconf": {
      "schema_path": "/", 
      "file": "everything.conf"
    }
  }
]
```

Or you could use an even more aggressive apps config, something like:

```json
[
  {
    "name": "To Infinity and Beyond", 
    "files": {
      "include": ["~/.*"], 
      "exclude": ["~/.cache", "~/.gnupg", "~/.ssh", "~/.local/share/Trash"]
    }, 
    "dconf": {
      "schema_path": "/", 
      "file": "everything.conf"
    }
  }
]
```

And now to install your apps, you would use the [distro specific setup][distro specific setup script doc url] scripts. You could put there one long line for all the `flatpaks` and another one for `dnf`, `apt-get` or the corresponding distro package manager.

If you included the `~/.local/share/gnome-shell/extensions` folder in the previous mentioned app config, you can **empty** (not file deletion) the [extensions][extensions config json] config JSON because you'll store into your private repo also the user installed extensions.

Gnome shell should push some updates for them if you `import` your data on a newer version of Gnome.

You can also **empty** (not file deletion) the [keybindings][keybindings config json], [tweaks][tweaks config json] and [misc][misc config json] config JSON files because they're not needed anymore.

So now you're left with **only one** configuration JSON file.

Configuration FLEXIBILITY at its finest!

**NOTE:** I didn't tested out these hacks, but in theory they should be possible. I don't recommend them, but hey, this is linux and you can use the FOSS tools as you see fit.

<!-- start footer -->

---

[<< Back to contents][contents doc url]

<!-- end footer -->

<!-- start links -->

[sample folder]:../../sample
[sample config folder]:../../sample/config
[sample data folder]:../../sample/data
[sample scripts folder]:../../sample/scripts
[sample common setup script]:../../sample/scripts/common/setup.sh
[apps config json]:../../sample/config/apps/config.json
[apps data folder]:../../sample/data/apps
[extensions config json]:../../sample/config/extensions/config.json
[extensions data folder]:../../sample/data/extensions
[keybindings config json]:../../sample/config/keybindings/config.json
[keybindings data folder]:../../sample/data/keybindings
[misc config json]:../../sample/config/misc/config.json
[misc data folder]:../../sample/data/misc
[tweaks config json]:../../sample/config/tweaks/config.json
[tweaks data folder]:../../sample/data/tweaks

<!-- -->

[main scripts]:../../scripts
[install script]:../../scripts/install.sh
[export script]:../../scripts/export.sh
[import script]:../../scripts/import.sh
[remove script]:../../scripts/remove.sh
[git setup script]:../../scripts/git/setup.sh
[git push script]:../../scripts/git/push.sh
[git pull script]:../../scripts/git/pull.sh
[git reset script]:../../scripts/git/reset.sh
[anacron setup script]:../../scripts/anacron/setup.sh
[common setup script]:../../scripts/common/setup.sh
[defaults script]:../../sample/scripts/defaults.sh
[jidea install script]:../../sample/scripts/apps/jidea-install.sh
[fedora setup script]:../../sample/scripts/fedora/setup.sh
[ubuntu setup script]:../../sample/scripts/ubuntu/setup.sh

<!-- -->

[contents doc url]:./README.md
[disclaimer doc url]:./disclaimer.md#disclaimer
[quick demo doc url]:./quick-demo.md#quick-demo
[main desktop setup doc url]:./main-desktop-setup.md#main-desktop-setup
[json configuration doc url]:./json-configuration.md#json-configuration
[shell scripts doc url]:./shell-scripts.md#shell-scripts
[common setup script doc url]:./shell-scripts.md#public-commonsetupsh-script
[private common setup script doc url]:./shell-scripts.md#private-commonsetupsh-script
[distro specific setup script doc url]:./shell-scripts.md#private-distro-specific-setupsh-script
[export script doc url]:./shell-scripts.md#exportsh
[import script doc url]:./shell-scripts.md#importsh
[install script doc url]:./shell-scripts.md#installsh
[git scripts doc url]:./shell-scripts.md#git-scripts
[distro setup scripts doc url]:./shell-scripts.md#private-distro-specific-setupsh-script
[anacron setup script doc url]:./shell-scripts.md#anacron-setup
[automatic actions doc url]:./automatic-actions.md#scheduling-automatic-actions
[tips and tricks doc url]:./tips-and-tricks.md#tips--tricks

<!-- end links -->
