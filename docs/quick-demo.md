<!-- start header -->

[<< Back to contents][contents doc url]

---

<!-- end header -->

<!-- start TOC -->

- [Quick demo](#quick-demo)
  - [Experience some magic](#experience-some-magic)
  - [How to use other git providers?](#how-to-use-other-git-providers)
    - [Clone the github repository](#clone-the-github-repository)

<!-- end TOC -->

# Quick demo

First you need to [fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this [github repository](https://github.com/ionutbortis/easy-dotfiles). If you want to use a separate git provider, please check the [How to use other git providers](#how-to-use-other-git-providers) section and come back here afterwards.

Install [Gnome Boxes](https://flathub.org/apps/details/org.gnome.Boxes) or use your preferred virtualization solution. Create a new Virtual Machine and install on it the latest [Fedora](https://getfedora.org/en/workstation/download/) or [Ubuntu](https://ubuntu.com/download) release. **`easy-dotfiles`** [sample][sample folder] supports out of the box **Fedora** and **Ubuntu** with **Gnome Shell 40+** as desktop environment.

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

```sh
cd ~ && git clone git@github.com:your_github_username/easy-dotfiles.git
```

Now you need to configure your local installation of **`easy-dotfiles`**:

```sh
cd ~/easy-dotfiles/ && ./scripts/git/setup.sh
```

Follow the git setup script instructions, use the sample data when prompted and choose to push your configuration at the end.

You will now have a properly configured installation of **`easy-dotfiles`** and can start using its awesomeness :tada:

## Experience some magic

Let's install all the [apps][apps config json] and [extensions][extensions config json] configured in the **`easy-dotfiles`** sample:

```sh
cd ~/easy-dotfiles/ && ./scripts/install.sh
```

Select the corresponding distro when prompted and sit back and relax :palm_tree: while the configured applications and extensions are automatically installed.

When the installation has finished, run this to import all the managed dotfiles and settings:

```sh
cd ~/easy-dotfiles/ && ./scripts/import.sh
```

Log out and log in again into the `ionut` user account. Now you need to open the `Extension Manager` app (that is also pinned to the dash), disable all the `System Extensions` and enable all the `User-Installed Extensions`. Cool, all the managed **apps** and **Gnome extensions** are installed and already configured.

You now have a fully setup VM **exactly** like mine :astonished: Awesome job! :clap: :partying_face:

If you switch to Dark Mode, boom :boom:, another custom desktop image is displayed. If you open **Visual Studio Code**, boom :boom:, the **`easy-dotfiles`** project is already there and some files are open, magic? Yes, [Bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>) Magic :magic_wand: :sweat_smile:

The **Github Desktop** app is also already configured to handle the **`easy-dotfiles`** repos (forked and private).

**Double Commander** will open at configured paths on the left and right sides.

**Gnome Weather** is configured with some locations and specific temperature settings. **Gnome Shell** and other apps have specific configuration applied to them. You can check the `tweaks` configuration [json file][tweaks config json] and corresponding [data folder][tweaks data folder].

Also, [keybindings][keybindings config json] were [imported][keybindings data folder] and the [managed][misc config json] miscellaneous [files][misc data folder].

Don't worry about the [data][sample data folder] files, they are automatically handled. All you need to do when using **`easy-dotfiles`** is to configure it to your liking by adapting these simple `json` files:

- [Applications config][apps config json]
- [Extensions config][extensions config json]
- [Keybindings config][keybindings config json]
- [Miscellaneous files config][misc config json]
- [Gnome tweaks config][tweaks config json]

That's all. Easy! :star_struck:

Are you now convinced of the **`easy-dotfiles`** awesomeness? :grin: If yes, please continue reading this [section][main desktop setup doc url] to see how you can configure it on your main desktop :computer:

## How to use other git providers?

If you don't like github or you already have another git provider, don't worry, I got you covered :thumbsup:

On your git provider website interface create the following repositories:

- **easy-dotfiles** - Public (or private) **EMPTY** repository.

:exclamation:**NOTE:** It's very important that the **easy-dotfiles** repo is utterly empty, no readme, no nothing.

- **easy-dotfiles-private** - Private **NON-EMPTY** repository.

:exclamation:**NOTE:** It's very important that the **easy-dotfiles-private** repo is not empty. When creating the private repository, use the `Add README.md file` option, if available. If that option is not available, you need to manually add an empty `README.md` file to this repository's root.

After setting up the repositories, have their SSH urls on hand because you will need them later on.

If you came from [Quick demo](#quick-demo), go back there and follow the steps for setting up the VM. When you have git running and SSH authentication working with your git provider inside the VM, come back here.

### Clone the github repository

Now you will clone the github **`easy-dotfiles`** repository.

Open a terminal and run:

```sh
cd ~ && git clone https://github.com/ionutbortis/easy-dotfiles.git
```

You need to change the git remote URL from this local clone to point to your git provider's **easy-dotfiles** repo you previously created. Open a terminal and adapt the following by using your **easy-dotfiles** SSH repo URL:

```sh
cd ~/easy-dotfiles
git remote set-url origin git@your_git_provider.com:your_user_name/easy-dotfiles.git
git branch -M main && git push -uf origin main
```

If everything went fine, you can configure now your local installation of **`easy-dotfiles`**:

```sh
cd ~/easy-dotfiles/ && ./scripts/git/setup.sh
```

Follow the git setup script instructions, use the sample data when prompted and choose to push your configuration at the end.

You will now have a properly configured installation of **`easy-dotfiles`** and can start using its awesomeness :tada:

Go [here](#experience-some-magic) to follow instructions on how to install sample apps, extensions and import configurations.

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
