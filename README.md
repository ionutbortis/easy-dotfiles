# `easy-dotfiles` :palm_tree:

Oh nooo, another dotfiles manager... :roll_eyes:

OH YES! :sweat_smile: And let me tell you why **`easy-dotfiles`** is different and how by using it you can **fully set up** a new linux desktop in **minutes** :exploding_head: :rocket:

**`easy-dotfiles`** is a free and open source command line power tool, **most suited for [Gnome](https://www.gnome.org/) users**, that can help you manage your dotfiles, **automatically** install all your **favorite apps**, **extensions** and restore **your configuration** for them.

Let's say that you have a pretty sweet linux desktop setup :penguin:, _Fedora_ or _Ubuntu_ or _whatever_, exactly the way you like it :heart_eyes:. With a dock, or with a dash, with favorite apps, backgrounds, shortcuts, lots of tweaks to the Gnome shell, by using extensions or by dconf changes.

You spent some time in configuring it and you would like to replicate this setup on a different machine. Or on the same machine, but a different distro, or a fresh install. Or on a Virtual Machine, maybe testing the latest distro release, to check if all your apps and settings are working properly if you upgrade.

Well, **`easy-dotfiles`** :superhero: to the rescue then, please keep on reading :eyes:

# Quick demo

First you need to [fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this github repository. If you want to use a separate git provider, please check the [How to use other git providers](#how-to-use-other-git-providers) section and come back here afterwards.

Install [Virtual Box](https://www.virtualbox.org/) or use your preferred virtualization solution. Create a new Virtual Machine and install on it the latest [Fedora](https://getfedora.org/en/workstation/download/) or [Ubuntu](https://ubuntu.com/download) release. **`easy-dotfiles`** [sample](./sample) supports out of the box **Fedora** and **Ubuntu** with **Gnome Shell 40+** as desktop environment.

Make sure that the VM Operating System is up to date by running the corresponding command in a terminal:

- Fedora: `sudo dnf update -y`
- Ubuntu: `sudo apt-get update -y`

Now inside the VM OS, create a new user `ionut` that has admin (sudo) privileges. This is needed in order to experience the full **`easy-dotfiles`** potential (the sample data was created under a user with that name).

Log in with the `ionut` user, open a terminal and check that you have `git` installed on your VM: `git --version`

If you don't have it installed, use your package manager to install it:

- Fedora: `sudo dnf install git -y`
- Ubuntu: `sudo apt-get install git -y`

Now you need to setup your `git` authentication. I recommend using [SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh) because it's more reliable and all the upcoming examples will use that.

If `git` SSH setup was successfully done you will now locally clone your forked version of **`easy-dotfiles`**. For other git providers follow the guide from [here](#clone-the-github-repository).

Get the forked repo URL from your github account, open a terminal and adapt the following by using your SSH link:

```bash
cd ~ && git clone git@github.com:your_github_username/easy-dotfiles.git
```

Now you need to configure your local installation of **`easy-dotfiles`**:

```bash
cd ~/easy-dotfiles && ./scripts/git/setup.sh
```

Follow the git setup script instructions, use the sample data when prompted and choose to push your configuration at the end.

You will now have a properly configured installation of **`easy-dotfiles`** and can start using its awesomeness :tada:

## Experience some magic

Let's install all the [apps](./sample/config/apps/config.json) and [extensions](./sample/config/extensions/config.json) configured in the **`easy-dotfiles`** sample:

```bash
cd ~/easy-dotfiles && ./scripts/install.sh
```

Select the corresponding distro when prompted and sit back and relax :palm_tree: while the configured applications and extensions are automatically installed.

When the installation has finished, run this to import all the managed dotfiles and settings:

```bash
cd ~/easy-dotfiles && ./scripts/import.sh
```

Log out and log in again into the `ionut` user account. Now you need to open the `Extension Manager` app (that is also pinned to the dash), disable all the `System Extensions` and enable all the `User-Installed Extensions`. Cool, all the managed **apps** and **Gnome extensions** are installed and already configured.

You now have a fully setup VM **exactly** like mine :astonished: Awesome job! :clap: :partying_face:

If you switch to Dark Mode, boom :boom:, another custom desktop image is displayed. If you open **Visual Studio Code**, boom :boom:, the **`easy-dotfiles`** project is already there and some files are open, magic? Yes, [Bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>) Magic :magic_wand: :sweat_smile:

The **Github Desktop** app is also already configured to handle the **`easy-dotfiles`** repos (forked and private).

**Double Commander** will open at configured paths on the left and right sides.

**Gnome Weather** is configured with some locations and specific temperature settings. **Gnome Shell** and other apps have specific configuration applied to them. You can check the `tweaks` configuration [json file](./sample/config/tweaks/config.json) and corresponding [data folder](./sample/data/tweaks/).

Also, [keybindings](./sample/config/keybindings/config.json) were [imported](./sample/data/keybindings/) and the [managed](./sample/config/misc/config.json) miscellaneous [files](./sample/data/misc/).

Don't worry about the [data](./sample/data/) files, they are automatically handled. All you need to do when using **`easy-dotfiles`** is to configure it to your liking by adapting these simple `json` files:

- [Applications config](./sample/config/apps/config.json)
- [Extensions config](./sample/config/extensions/config.json)
- [Keybindings config](./sample/config/keybindings/config.json)
- [Miscellaneous files config](./sample/config/misc/config.json)
- [Gnome tweaks config](./sample/config/tweaks/config.json)

That's all. Easy! :star_struck:

Are you now convinced of the **`easy-dotfiles`** awesomeness? :grin: If yes, please continue reading this [section]() to see how you can configure it on your main desktop :computer:

## How to use other git providers?

If you don't like github or you already have another git provider, don't worry, I got you covered 👍

On your git provider website interface create the following repositories:

- **easy-dotfiles** - Public (or private) **EMPTY** repository.

:exclamation: **Note**: It's very important that the **easy-dotfiles** repo is utterly empty, no readme, no nothing.

- **easy-dotfiles-private** - Private **NON-EMPTY** repository.

:exclamation: **Note**: It's very important that the **easy-dotfiles-private** repo is not empty. When creating the private repository, use the `Add README.md file` option, if available. If that option is not available, you need to manually add an empty `README.md` file to this repository's root.

After setting up the repositories, have their SSH urls on hand because you will need them later on.

If you came from [Quick Demo](#quick-demo), go back there and follow the steps for setting up the VM. When you have git running and SSH authentication working with your git provider inside the VM, come back here.

### Clone the github repository

Now you will clone the github **`easy-dotfiles`** repository.

Open a terminal and run:

```bash
cd ~ && git clone https://github.com/ionutbortis/easy-dotfiles.git
```

You need to change the git remote URL from this local clone to point to your git provider's **easy-dotfiles** repo you previously created. Open a terminal and adapt the following by using your **easy-dotfiles** SSH repo URL:

```bash
cd ~/easy-dotfiles
git remote set-url origin git@your_git_provider.com:your_user_name/easy-dotfiles.git
git branch -M main && git push -uf origin main
```

If everything went fine, you can configure now your local installation of **`easy-dotfiles`**:

```bash
cd ~/easy-dotfiles && ./scripts/git/setup.sh
```

Follow the git setup script instructions, use the sample data when prompted and choose to push your configuration at the end.

You will now have a properly configured installation of **`easy-dotfiles`** and can start using its awesomeness :tada:

Go [here](#experience-some-magic) to follow instructions on how to install sample apps, extensions and import configurations.
